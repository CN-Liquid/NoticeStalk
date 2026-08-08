import 'dart:io';
import 'package:logger/logger.dart';
import 'package:notice_stalk/core/api.dart';
import 'package:notice_stalk/core/notice.dart';
import 'package:notice_stalk/plugins/ioe_pc/api.dart';
import 'package:notice_stalk/repository/network/network.dart';
import 'package:notice_stalk/repository/storage/database.dart';
import 'package:notice_stalk/plugins/ioe_exam/api.dart';
import 'package:notice_stalk/repository/storage/file_storage.dart';
import 'package:notice_stalk/core/result.dart';

final logger = Logger();

class NoticeRepository {
  NoticeRepository._private();
  static final NoticeRepository instance = NoticeRepository._private();

  Api client = IoeExam.instance;

  Result<String> setClient(String clientId) {
    switch (clientId) {
      case 'ioe_exam':
        client = IoeExam.instance;
        IoeExam.instance.notices.clear();
        return Result.success(client.id);
      case 'ioe_pc':
        client = IoePc.instance;
        IoePc.instance.notices.clear();
        return Result.success(client.id);
      default:
        return Result.failure('Invalid client id');
    }
  }

  Future<Result<Notice>> getNotice(String link) async {
    final result = await NoticeDatabase.instance.fetchNotice(link: link);

    return result;
  }

  Future<Result<List<Notice>>> getNotices({
    int page = 0,
    String searchText = '',
  }) async {
    final result = await NoticeDatabase.instance.fetchNotices(
      id: client.id,
      page: page,
      searchText: searchText,
    );

    if (!result.isSuccess) {
      return result;
    }

    if (result.data!.isEmpty && searchText.isEmpty) {
      final result = (client.id == 'ioe_exam')
          ? await fetchNoticesByCursor(page: page)
          : await fetchNotices(page: page);

      if (!result.isSuccess) {
        return Result.failure(result.error!);
      }

      final newData = await NoticeDatabase.instance.fetchNotices(
        id: client.id,
        page: page,
      );

      if (!newData.isSuccess) {
        return Result.failure(newData.error!);
      }

      return newData;
    }

    if (result.data!.isEmpty) {
      return Result.failure('There are no notices in this page');
    }
    return result;
  }

  Future<Result<List<Notice>>> fetchNotices({int page = 0}) async {
    List<Notice> insertedNotices = [];
    logger.d('Fetching');
    final fetchResult = await client.retrieve(page: page);

    if (!fetchResult.isSuccess) {
      return Result.failure(fetchResult.error!);
    }

    final notices = client.notices;

    if (notices.isEmpty) {
      return Result.failure('There are no notices in this page');
    }

    for (final data in notices) {
      final notice = Notice(
        id: client.id,
        date: data.date,
        details: data.details,
        link: data.link,
        docLink: data.docLink,
      );
      final result = await NoticeDatabase.instance.insert(notice);

      if (!result.isSuccess) {
        logger.e('failed to insert notices');
        continue;
        //Donot return if one insertion fails
        //return Result.failure(result.error!);
      }

      if (result.data == true) {
        insertedNotices.add(data);
      }
    }

    return Result.success(insertedNotices);
  }

  Future<Result<List<Notice>>> fetchNoticesByCursor({int page = 0}) async {
    final cursor = await getCursor(page);

    List<Notice> insertedNotices = [];

    if (!cursor.isSuccess) {
      return Result.failure(cursor.error!);
    }

    logger.d('Fetching');

    final fetchResult = await client.retrieveByCursor(cursor.data!);
    if (!fetchResult.isSuccess) {
      return Result.failure(fetchResult.error!);
    }

    final notices = client.notices;

    if (notices.isEmpty) {
      return Result.failure('There are no notices in this page');
    }

    for (final data in notices) {
      final notice = Notice(
        id: client.id,
        date: data.date,
        details: data.details,
        link: data.link,
        docLink: data.docLink,
      );
      final result = await NoticeDatabase.instance.insert(notice);

      if (!result.isSuccess) {
        logger.e(result.error);
        continue;
      }

      if (result.data == true) {
        insertedNotices.add(data);
      }
    }

    final cursorResult = await NoticeDatabase.instance.insertCursor(
      client.id,
      page,
      cursor.data!,
    );

    if (!cursorResult.isSuccess) {
      logger.e(cursorResult.error);
    }

    return Result.success(insertedNotices);
  }

  Future<Result<String?>> getFile({required String link}) async {
    final result = await NoticeDatabase.instance.fetchNotice(link: link);

    if (!result.isSuccess) {
      return Result.failure(result.error!);
    }

    final notice = result.data!;

    String? docPath = notice.docPath;
    String? docLink = notice.docLink;

    if (docLink == null) {
      return Result.failure('No Download link');
    }

    if (notice.docPath == null) {
      final downloadResult = await NetworkService.download(docLink);

      if (!downloadResult.isSuccess) {
        return Result.failure(downloadResult.error!);
      }

      final (resultFile, contentType) =
          downloadResult.data as (List<int>, String?);

      final downloadedFile = await FileStorage.saveFile(
        resultFile,
        contentType != null ? '${notice.details}.$contentType' : notice.details,
      );

      if (!downloadedFile.isSuccess) {
        return Result.failure(downloadedFile.error!);
      }

      docPath = downloadedFile.data!.path;

      final insertResult = await NoticeDatabase.instance.insert(
        notice.copyWith(docPath: docPath, docLink: docLink),
      );

      if (!insertResult.isSuccess) {
        return Result.failure(insertResult.error!);
      }

      return Result.success(docPath);
    }

    return Result.success(docPath);
  }

  Future<Result<String?>> getCursor(int page) async {
    if (page == 0) {
      return Result.success('');
    } else {
      final cursorResult = await NoticeDatabase.instance.getCursor(
        client.id,
        page - 1,
      );

      if (!cursorResult.isSuccess) {
        return Result.failure(cursorResult.error!);
      }

      String? prevCursor = cursorResult.data;

      if (prevCursor == null) {
        final result = await getCursor(page - 1);
        prevCursor = result.data;
      }

      final cursorRes = await client.getCursor(prevCursor!);
      if (!cursorRes.isSuccess) {
        return Result.failure('Unable to get cursor');
      }
      final cursor = cursorRes.data!;

      return Result.success(cursor);
    }
  }

  Future<Result<void>> deleteFiles(Directory directory) async {
    final noticesResult = await NoticeDatabase.instance.fetchAllNotices();

    if (!noticesResult.isSuccess) {
      return Result.failure(noticesResult.error!);
    }

    for (final notice in noticesResult.data!) {
      final noticeObj = Notice(
        id: notice['id'],
        details: notice['details'],
        date: notice['date'],
        link: notice['link'],
        docLink: notice['docLink'],
        docPath: null,
      );

      final insertResult = await NoticeDatabase.instance.insert(noticeObj);

      if (!insertResult.isSuccess) {
        return Result.failure('Error in Purging document reference');
      }
    }

    final deleteResult = await FileStorage.deleteDirectoryContents(directory);

    if (!deleteResult.isSuccess) {
      return Result.failure(deleteResult.error!);
    }

    return Result.success(null);
  }
}

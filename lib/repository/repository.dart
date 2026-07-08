import 'dart:io';
import 'package:logger/logger.dart';
import 'package:notice_stalk/core/notice.dart';
import 'package:notice_stalk/repository/network/network.dart';
import 'package:notice_stalk/repository/storage/database.dart';
import 'package:notice_stalk/plugins/ioe_exam/api.dart';
import 'package:notice_stalk/repository/storage/file_storage.dart';
import 'package:notice_stalk/core/result.dart';

final logger = Logger();

class NoticeRepository {
  NoticeRepository._private();
  static final NoticeRepository instance = NoticeRepository._private();

  final client = IoeExam.instance;

  Future<Result<List<Map<String, dynamic>>>> getNotices({
    int page = 0,
    String searchText = '',
  }) async {
    final result = await NoticeDatabase.fetchNotices(
      page: page,
      searchText: searchText,
    );

    if (!result.isSuccess) {
      return result;
    }

    if (result.data!.isEmpty && searchText.isEmpty) {
      final result = await fetchNotices(page: page);

      if (!result.isSuccess) {
        return Result.failure(result.error!);
      }

      final newData = await NoticeDatabase.fetchNotices(page: page);

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

  Future<Result<List<Map<String, dynamic>>>> fetchNotices({
    int page = 0,
  }) async {
    final cursor = await getCursor(page);

    List<Map<String, dynamic>> insertedNotices = [];

    if (!cursor.isSuccess) {
      return Result.failure(cursor.error!);
    }

    logger.d('Fetching');

    bool isFetched = await client.retrieveByCursor(cursor.data!);
    if (isFetched) {
      final notices = client.notices;

      if (notices.isEmpty) {
        return Result.failure('There are no notices in this page');
      }

      for (final data in notices) {
        final notice = Notice(
          date: data['date'],
          details: data['details'],
          link: data['link'],
          docLink: data['docLink'],
        );
        final result = await NoticeDatabase.insert(notice);

        if (!result.isSuccess) {
          return Result.failure(result.error!);
        }

        if (result.data == true) {
          insertedNotices.add(data);
        }
      }

      final cursorResult = await NoticeDatabase.insertCursor(
        page,
        cursor.data!,
      );

      if (!cursorResult.isSuccess) {
        return Result.failure(cursorResult.error!);
      }

      return Result.success(insertedNotices);
    }

    return Result.failure('Unable to reach to the network');
  }

  Future<Result<String?>> getFile({
    required String date,
    required String details,
  }) async {
    final result = await NoticeDatabase.fetchNotice(
      date: date,
      details: details,
    );

    if (!result.isSuccess) {
      return Result.failure(result.error!);
    }

    final notice = result.data!;

    String? docPath = notice.docPath;
    String docLink = notice.docLink;
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

      final insertResult = await NoticeDatabase.insert(
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
      final cursorResult = await NoticeDatabase.getCursor(page - 1);

      if (!cursorResult.isSuccess) {
        return Result.failure(cursorResult.error!);
      }

      String? prevCursor = cursorResult.data;

      if (prevCursor == null) {
        final result = await getCursor(page - 1);
        prevCursor = result.data;
      }

      final cursor = await client.getCursor(prevCursor!);

      if (cursor == null) {
        return Result.failure('There are no notices in this page');
      }

      return Result.success(cursor);
    }
  }

  Future<Result<void>> deleteFiles(Directory directory) async {
    final noticesResult = await NoticeDatabase.fetchAllNotices();

    if (!noticesResult.isSuccess) {
      return Result.failure(noticesResult.error!);
    }

    for (final notice in noticesResult.data!) {
      final noticeObj = Notice(
        details: notice['details'],
        date: notice['date'],
        link: notice['link'],
        docLink: notice['docLink'],
        docPath: null,
      );

      final insertResult = await NoticeDatabase.insert(noticeObj);

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

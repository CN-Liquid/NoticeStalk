import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:notice_stalk/core/result.dart';

class NetworkService {
  static final _client = Dio();

  static Future<Result<(List<int>, String?)>> download(String fileUrl) async {
    Logger().d('Downloading');

    if (fileUrl.startsWith('data')) {
      String mimeTypeAndData = fileUrl.split(';').first;
      String format = mimeTypeAndData.split('/').last;

      if (format.isEmpty) {
        return Result.failure('unable to determine the content type');
      }

      String payload = fileUrl.split(',').last;

      List<int> bytes = base64Decode(payload);

      return Result.success((bytes, format));
    }

    String modifiedUrl = fileUrl;

    if (fileUrl.contains('drive.google')) {
      final regex = RegExp(r'(?<=/d/)[a-zA-Z0-9_-]+');
      final match = regex.firstMatch(fileUrl);

      modifiedUrl =
          'https://drive.google.com/uc?export=download&id=${match!.group(0)}';
    }

    try {
      final response = await _client.get(
        modifiedUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      final contentType = DioMediaType.parse(
        response.headers.value('content-type')!,
      );

      if (contentType.mimeType == 'text/html') {
        return Result.failure('Unable to download file : Bad download link');
      }

      final bytes = response.data as List<int>;

      return Result.success((bytes, contentType.subtype));
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.error is SocketException) {
        return Result.failure(
          'Unable to communicate with the network. Please check your internet connection',
        );
      }
      return Result.failure('Server error : ${e.message}');
    } catch (e) {
      return Result.failure('An unexpected error has occured : $e');
    }
  }
}

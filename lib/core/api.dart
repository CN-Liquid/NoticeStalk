import 'package:notice_stalk/core/dio_client.dart';
import 'package:notice_stalk/core/result.dart';
import 'package:notice_stalk/core/notice.dart';

class Api {
  final String url;
  final String id;
  final dioClient = DioClient.instance.client;
  List<Notice> notices = [];

  Api({required this.url, required this.id});

  Future<Result<void>> retrieve({int page = 0}) async {
    return Result.failure('Not Implemented');
  }

  Future<Result<void>> retrieveByCursor(String prevCursor) async {
    return Result.failure('Not Implemented');
  }

  Future<Result<String?>> getCursor(String prevCursor) async {
    return Result.failure('Not Implemented');
  }
}

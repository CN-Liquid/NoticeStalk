import 'package:notice_stalk/core/result.dart';

class Api {
  final String url;
  final String id;

  const Api({required this.url, required this.id});

  Future<Result<void>> retrieve() async {
    return Result.failure('Not Implemented');
  }

  Future<Result<void>> retrieveByCursor() async {
    return Result.failure('Not Implemented');
  }

  Future<Result<String?>> getDocumentLink(String noticeLink) async {
    return Result.failure('Not Implemented');
  }

  Future<Result<String?>> getCursor(String prevCursor) async {
    return Result.failure('Not Implemented');
  }
}

import 'package:notice_stalk/core/result.dart';

class Api {
  final String url;
  final String id;
  List<Map<String, dynamic>> notices = [];

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

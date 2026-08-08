import 'package:dio/dio.dart';

class DioClient {
  DioClient._private() {
    client.options.connectTimeout = Duration(seconds: 5);
    client.options.receiveTimeout = Duration(seconds: 3);
  }
  final Dio client = Dio();
  static final instance = DioClient._private();
}

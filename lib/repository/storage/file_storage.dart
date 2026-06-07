import 'dart:io';
import 'package:notice_stalk/core/result.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class FileStorage {
  static Directory? _downloadDir;

  static Future<Result<Directory>> get downloadDir async {
    if (_downloadDir != null) {
      return Result.success(_downloadDir!);
    }

    try {
      final dir = await getDownloadsDirectory();

      if (dir == null) {
        return Result.failure('Downloads folder is not accessible');
      }
      _downloadDir = dir;
      return Result.success(_downloadDir!);
    } catch (e) {
      return Result.failure('Error in getting the downloads directory');
    }
  }

  static Future<Result<File>> saveFile(List<int> bytes, String fileName) async {
    final downloadDirectory = await downloadDir;

    if (!downloadDirectory.isSuccess) {
      return Result.failure(downloadDirectory.error!);
    }

    String filePath = p.join(
      downloadDirectory.data!.path,
      'notice_stalk',
      fileName,
    );

    try {
      File file = File(filePath);

      await file.parent.create(recursive: true);

      await file.writeAsBytes(bytes);

      return Result.success(file);
    } catch (e) {
      return Result.failure('Error saving the file : $e');
    }
  }
}

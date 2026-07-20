import 'dart:io';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:notice_stalk/repository/repository.dart';
import 'package:notice_stalk/repository/storage/file_storage.dart';

class StoragePage extends StatefulWidget {
  const StoragePage({super.key});

  @override
  State<StoragePage> createState() => _StoragePageState();
}

class _StoragePageState extends State<StoragePage> {
  Directory? downloadsDirectory;
  FileStat? metadata;
  int numberOfFiles = 0;
  int totalSize = 0;
  bool isClearPressed = false;

  @override
  void initState() {
    super.initState();
    fetchDownloadsDirectoryMetadata();
  }

  Future fetchDownloadsDirectoryMetadata() async {
    final result = await FileStorage.downloadDir;
    if (!result.isSuccess) {
      Logger().e(result.error);
      return;
    }
    final tempDownloadsDirectory = result.data;
    final tempMetadata = await tempDownloadsDirectory!.stat();

    setState(() {
      downloadsDirectory = tempDownloadsDirectory;
      metadata = tempMetadata;
    });

    fetchDirectorySize();
  }

  Future<void> fetchDirectorySize() async {
    final result = await FileStorage.getDirectorySize(downloadsDirectory!);

    if (!result.isSuccess) {
      Logger().e(result.error);
    }

    setState(() {
      numberOfFiles = result.data!['numberOfFiles']!;
      totalSize = result.data!['totalSize']!;
    });
  }

  Future<void> clearData() async {
    if (downloadsDirectory == null) {
      logger.e('Downloads directory is null');
      return;
    }
    setState(() {
      isClearPressed = true;
    });
    final result = await NoticeRepository.instance.deleteFiles(
      downloadsDirectory!,
    );
    setState(() {
      isClearPressed = false;
      fetchDirectorySize();
    });

    if (!result.isSuccess) {
      logger.e(result.error);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Storage'), centerTitle: true),
      body: Center(
        child: Column(
          children: [
            metadata == null ? CircularProgressIndicator() : Text('$metadata'),
            Text('Number of files : $numberOfFiles'),
            Text('Total size : $totalSize MB'),
            TextButton(
              onPressed: (isClearPressed)
                  ? null
                  : () {
                      clearData();
                    },
              style: ButtonStyle(
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.horizontal(),
                  ),
                ),
                backgroundColor: WidgetStateProperty.all(Colors.grey),
                foregroundColor: WidgetStateProperty.all(Colors.black),
              ),

              child: Text('Clear'),
            ),
          ],
        ),
      ),
    );
  }
}

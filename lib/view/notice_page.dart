import 'dart:io';
import 'package:flutter/material.dart';
import 'package:notice_stalk/repository/repository.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pdfrx/pdfrx.dart';

class NoticePage extends StatefulWidget {
  const NoticePage({
    super.key,
    required this.details,
    required this.date,
    required this.link,
  });

  final String details;
  final String date;
  final String link;

  @override
  State<NoticePage> createState() => _NoticePageState();
}

class _NoticePageState extends State<NoticePage> {
  String? pdfDocument;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    _getFile();
  }

  Future<void> _getFile() async {
    final result = await NoticeRepository.instance.getFile(
      date: widget.date,
      details: widget.details,
    );
    if (!result.isSuccess) {
      logger.e(result.error);
      setState(() {
        isError = true;
      });

      return;
    }

    setState(() {
      pdfDocument = result.data;
    });
  }

  bool _isImage(String filePath) {
    final path = filePath.toLowerCase();
    return path.endsWith('.png') ||
        path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.webp');
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      logger.e('Could not open url : $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notice Page'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.details),
            Text(widget.date),
            TextButton(
              onPressed: () => _launchUrl(Uri.parse(widget.link)),
              child: Text(widget.link),
            ),
            isError == true
                ? Text('Unable To load document')
                : pdfDocument == null
                ? CircularProgressIndicator()
                : Expanded(
                    child: _isImage(pdfDocument!)
                        ? Image.file(File(pdfDocument!))
                        : PdfViewer.file(pdfDocument!),
                  ),
          ],
        ),
      ),
    );
  }
}

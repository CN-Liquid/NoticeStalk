import 'package:html/dom.dart' as dom;
import 'package:dio/dio.dart';
import 'package:html/parser.dart';
import 'package:logger/logger.dart';
import 'package:notice_stalk/core/api.dart';
import 'package:notice_stalk/core/notice.dart';
import 'package:notice_stalk/core/result.dart';

final logger = Logger();

class IoePc extends Api {
  IoePc._private()
    : super(
        url: 'https://www.ioepc.edu.np/info/category/notice/page',
        id: 'ioe_pc',
      );

  static final IoePc instance = IoePc._private();
  final client = Dio();

  @override
  Future<Result<void>> retrieve({int page = 0}) async {
    dom.Document? document;

    final modifiedUrl = '$url/${page + 1}';

    try {
      final res = await client.get(modifiedUrl);
      document = parse(res.data);
    } catch (e) {
      logger.e('Non-Dio Exception: $e');
      return Result.failure('Unexpected error: $e');
    }

    final data = document.querySelectorAll('.col-md-4.d-flex');

    for (final d in data) {
      final docLink = await getDocumentLink(
        d.querySelector('a')!.attributes['href']!.trim(),
      );

      if (!docLink.isSuccess) {
        Logger().e('failed to retrieve document link : ${docLink.error}');
        final element = dom.Element.tag('p')..text = null;

        d.append(element);
      } else {
        final element = dom.Element.tag('p')..text = docLink.data;

        d.append(element);
      }
    }
    if (data.isNotEmpty) {
      notices = convertToList(data);
      return Result.success(null);
    }
    return Result.failure('Unable to retrieve notice');
  }

  List<Notice> convertToList(List<dom.Element> data) {
    return data.map((d) {
      return Notice(
        id: id,
        details: d.querySelector('a')!.text.trim(),
        date: d.querySelector('h7')!.text.trim(),
        link: d.querySelector('a')!.attributes['href']!.trim(),
        docLink: d.querySelector('p')?.text.trim(),
      );
    }).toList();
  }

  Future<Result<String?>> getDocumentLink(String noticeLink) async {
    dom.Document? document;
    try {
      final response = await client.get(noticeLink);
      document = parse(response.data);

      final link = document.querySelector(
        '.btn.btn-outline-primary.text-decoration-none.fw-bold',
      );
      return Result.success(link!.attributes['href']);
    } on TypeError {
      final img = document!.querySelector('.wp-image-7207');
      if (img == null) {
        return Result.failure('Unable to extract image');
      }
      return Result.success(img.attributes['src']);
    } catch (e) {
      return Result.failure('Error occured when retrieving document link $e');
    }
  }
}

import 'package:html/dom.dart' as dom;
import 'package:dio/dio.dart';
import 'package:html/parser.dart';
import 'package:logger/logger.dart';
import 'package:notice_stalk/core/api.dart';
import 'package:notice_stalk/core/notice.dart';
import 'package:notice_stalk/core/result.dart';

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

    final res = await client.get(modifiedUrl);

    document = parse(res.data);

    final data = document.querySelectorAll('.col-md-4.d-flex');

    for (final d in data) {
      final docLink = await getDocumentLink(
        d.querySelector('a')!.attributes['href']!.trim(),
      );

      if (docLink == null) {
        Logger().e(
          'failed to retrieve document link : ${d.querySelector('a')!.attributes['href']!.trim()}',
        );
      }

      final element = dom.Element.tag('p')..text = docLink;

      d.append(element);
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
        details: d.querySelector('.detail')!.text.trim(),
        date: d.querySelector('.date')!.text.trim(),
        link: d.querySelector('a')!.attributes['href']!.trim(),
        docLink: d.querySelector('p')!.text.trim(),
      );
    }).toList();
  }

  Future<String?> getDocumentLink(String noticeLink) async {
    final response = await client.get(noticeLink);
    final document = parse(response.data);
    try {
      final link = document.querySelector(
        '.btn.btn-outline-primary.text-decoration-none.fw-bold',
      );
      return link!.attributes['href'];
    } on TypeError {
      final img = document.querySelector('.wp-image-7207');
      if (img == null) {
        return null;
      }
      return img.attributes['src'];
    }
  }
}

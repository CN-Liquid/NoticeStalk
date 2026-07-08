import 'package:html/dom.dart' as dom;
import 'package:dio/dio.dart';
import 'package:html/parser.dart';
import 'package:logger/logger.dart';

class IoeExam {
  IoeExam._private();

  static final IoeExam instance = IoeExam._private();
  List<Map<String, dynamic>> notices = [];
  final dioClient = Dio();
  final url = 'https://exam.ioe.tu.edu.np/notices';

  Future<bool> retrieve({int page = 0}) async {
    dom.Document? document;
    String cursor = '';

    for (int i = 0; i <= page; i++) {
      final modifiedUrl = '$url?cursor=$cursor';

      final res = await dioClient.get(modifiedUrl);

      document = parse(res.data);

      final nextLink = document.querySelector('a.page-link[rel="next"]');

      final href = Uri.parse(nextLink!.attributes['href']!);

      cursor = href.queryParameters['cursor']!;
    }

    final data = document!.querySelectorAll('.recent-post-wrapper.shdow');
    if (data.isNotEmpty) {
      notices = convertToList(data);
      return true;
    }
    return false;
  }

  Future<bool> retrieveByCursor(String prevCursor) async {
    dom.Document? document;

    final modifiedUrl = '$url?cursor=$prevCursor';

    final res = await dioClient.get(modifiedUrl);

    document = parse(res.data);

    final data = document.querySelectorAll('.recent-post-wrapper.shdow');

    for (final d in data) {
      final link = await getDocumentLink(
        d.querySelector('a')!.attributes['href']!.trim(),
      );

      if (link == null) {
        Logger().e('failed to retrieve document link');
        return false;
      }

      final element = dom.Element.tag('p')..text = link;

      d.append(element);
    }

    if (data.isNotEmpty) {
      notices = convertToList(data);
      return true;
    }
    return false;
  }

  List<Map<String, dynamic>> convertToList(List<dom.Element> data) {
    return data.map((d) {
      return {
        'date': d.querySelector('.date')!.text.trim(),
        'details': d.querySelector('.detail')!.text.trim(),
        'link': d.querySelector('a')!.attributes['href']!.trim(),
        'docLink': d.querySelector('p')!.text.trim(),
      };
    }).toList();
  }

  Future<String?> getDocumentLink(String noticeLink) async {
    final response = await dioClient.get(noticeLink);
    final document = parse(response.data);
    try {
      final link = document
          .querySelectorAll('a')
          .firstWhere(
            (element) =>
                (element.text.trim() == 'Click here to view the full notice.') |
                (element.text.trim() == 'Click here to view the result.'),
          );
      return link.attributes['href'];
    } on StateError {
      final img = document.querySelector('.ck-table img');
      return img!.attributes['src'];
    }
  }

  Future<String?> getCursor(String prevCursor) async {
    dom.Document? document;
    String? cursor;

    final modifiedUrl = '$url?cursor=$prevCursor';

    final res = await dioClient.get(modifiedUrl);

    document = parse(res.data);

    final nextLink = document.querySelector('a.page-link[rel="next"]');
    if (nextLink == null) {
      return null;
    }

    final href = Uri.parse(nextLink.attributes['href']!);

    cursor = href.queryParameters['cursor']!;

    return cursor;
  }
}

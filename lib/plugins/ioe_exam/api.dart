import 'package:html/dom.dart' as dom;
import 'package:dio/dio.dart';
import 'package:html/parser.dart';
import 'package:logger/logger.dart';
import 'package:notice_stalk/core/api.dart';
import 'package:notice_stalk/core/result.dart';

class IoeExam extends Api {
  IoeExam._private()
    : super(url: 'https://exam.ioe.tu.edu.np/notices', id: 'ioe_exam');

  static final IoeExam instance = IoeExam._private();
  List<Map<String, dynamic>> notices = [];
  final dioClient = Dio();

  @override
  Future<Result<void>> retrieve({int page = 0}) async {
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
      return Result.success(null);
    }
    return Result.failure('Unable to retrieve data');
  }

  @override
  Future<Result<void>> retrieveByCursor(String prevCursor) async {
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
        Logger().e(
          'failed to retrieve document link ${d.querySelector('a')!.attributes['href']!.trim()}',
        );

        return Result.failure(
          'failed to retrieve document link ${d.querySelector('a')!.attributes['href']!.trim()}',
        );
      }

      final element = dom.Element.tag('p')..text = link;

      d.append(element);
    }

    if (data.isNotEmpty) {
      notices = convertToList(data);
      return Result.success(null);
    }
    return Result.failure('Unable To retrieve by cursor');
  }

  List<Map<String, dynamic>> convertToList(List<dom.Element> data) {
    return data.map((d) {
      return {
        'id': 'ioe_exam',
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
    final parentDiv = document.querySelector('[class="ck-table"]');
    if (parentDiv!.querySelector('a') != null) {
      final link = parentDiv.querySelector('a');
      return link!.attributes['href'];
    } else {
      final link = parentDiv.querySelector('img');
      return link!.attributes['src'];
    }
  }

  @override
  Future<Result<String?>> getCursor(String prevCursor) async {
    dom.Document? document;
    String? cursor;

    final modifiedUrl = '$url?cursor=$prevCursor';

    final res = await dioClient.get(modifiedUrl);

    document = parse(res.data);

    final nextLink = document.querySelector('a.page-link[rel="next"]');
    if (nextLink == null) {
      return Result.failure('Unable to retrieve cursor');
    }

    final href = Uri.parse(nextLink.attributes['href']!);

    cursor = href.queryParameters['cursor']!;

    return Result.success(cursor);
  }
}

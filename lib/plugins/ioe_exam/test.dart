import 'package:notice_stalk/plugins/ioe_exam/api.dart';

void main() async {
  await IoeExam.getDocumentLink('https://exam.ioe.tu.edu.np/notices/13033');
}

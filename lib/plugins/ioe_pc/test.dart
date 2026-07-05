import 'package:notice_stalk/plugins/ioe_pc/api.dart';

void main() async {
  await IoePc.retrieve(page: 1);
  IoePc.notices.forEach((notice) {
    print(notice['details']);
    print(notice['date']);
    print(notice['link']);
    print(notice['docLink']);
    print('');
  });
}

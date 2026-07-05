import 'package:notice_stalk/plugins/ioe_pc/api.dart';

void main() async {
  await IoePc.instance.retrieve(page: 1);
  IoePc.instance.notices.forEach((notice) {
    print(notice['details']);
    print(notice['date']);
    print(notice['link']);
    print(notice['docLink']);
    print('');
  });
}

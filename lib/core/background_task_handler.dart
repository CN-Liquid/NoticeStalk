import 'package:logger/logger.dart';
import 'package:workmanager/workmanager.dart';
import 'package:notice_stalk/repository/repository.dart';
import 'package:notice_stalk/core/notification.dart';

final clients = ['ioe_exam', 'ioe_pc'];

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == 'check_for_updates') {
      await NotificationManager.initialize();
      for (final client in clients) {
        NoticeRepository.instance.setClient(client);
        final newNotices = await NoticeRepository.instance.fetchNotices();

        if (!newNotices.isSuccess) {
          await NotificationManager.show(
            title: 'Failed to fetch notices',
            details: newNotices.error!,
          );
          Logger().e(newNotices.error);
          continue;
        } else if (newNotices.data!.isEmpty) {
          Logger().d('No new notices');
          continue;
        }
        final notices = newNotices.data!;

        for (final data in notices) {
          await NotificationManager.show(
            title: data.details,
            details: data.date,
          );
        }
      }
    }

    return Future.value(true);
  });
}

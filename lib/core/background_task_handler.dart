import 'package:logger/logger.dart';
import 'package:workmanager/workmanager.dart';
import 'package:notice_stalk/repository/repository.dart';
import 'package:notice_stalk/core/notification.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == 'check_for_updates') {
      final newNotices = await NoticeRepository.instance.fetchNotices();

      if (!newNotices.isSuccess) {
        NotificationManager.show(
          title: 'Failed to fetch notices',
          details: newNotices.error!,
        );
        Logger().e(newNotices.error);
        return Future.value(false);
      } else if (newNotices.data!.isEmpty) {
        logger.d('No new notices');

        return Future.value(true);
      }
      final notices = newNotices.data!;
      await NotificationManager.initialize();
      for (final data in notices) {
        NotificationManager.show(title: data['details'], details: data['date']);
      }
    }

    return Future.value(true);
  });
}

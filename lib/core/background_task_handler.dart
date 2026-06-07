import 'package:logger/logger.dart';
import 'package:workmanager/workmanager.dart';
import 'package:notice_stalk/repository/repository.dart';
import 'package:notice_stalk/core/notification.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == 'check_for_updates') {
      final result = await NoticeRepository.fetchNotices();

      if (!result.isSuccess) {
        Logger().e(result.error);
        return Future.value(false);
      } else if (result.data!.isEmpty) {
        logger.d('No new notices');
        return Future.value(true);
      }
      final notices = result.data!;
      await NotificationManager.initialize();
      for (final data in notices) {
        NotificationManager.show(title: data['details'], details: data['date']);
      }
    }

    return Future.value(true);
  });
}

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notice_stalk/core/result.dart';

class NotificationManager {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationManager._init();

  static Future<Result<bool>> initialize() async {
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('app_icon');

      final InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      final result = await flutterLocalNotificationPlugin.initialize(
        initializationSettings,
      );

      if (result == null) {
        return Result.failure('Unable to init notification plugin');
      }

      return Result.success(result);
    } catch (e) {
      return Result.failure('Unable to initialize notification manager : $e');
    }
  }

  static Future<Result<void>> show({
    required String title,
    required String details,
  }) async {
    try {
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
            'notice_channel',
            'Notice Alerts',
            channelDescription: 'Used to alert about latest notices',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker',
          );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
      );
      final int uniqueId = title.hashCode.remainder(100000);

      await flutterLocalNotificationPlugin.show(
        uniqueId,
        title,
        details,
        notificationDetails,
        payload: 'item x',
      );

      return Result.success(null);
    } catch (e) {
      return Result.failure('Unable to show notification : $e');
    }
  }
}

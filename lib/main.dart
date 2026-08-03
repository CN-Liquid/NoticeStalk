import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:notice_stalk/core/background_task_handler.dart';
import 'package:notice_stalk/core/notification.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:notice_stalk/view/plugins.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AndroidAlarmManager.initialize();

  final notificationInitResult = await NotificationManager.initialize();

  if (!notificationInitResult.isSuccess) {
    Logger().e(notificationInitResult.error!);
  }

  final status = await Permission.notification.status;

  if (status.isDenied) {
    await Permission.notification.request();
  }

  runApp(const MyApp());

  final int helloAlarmID = 0;
  await AndroidAlarmManager.periodic(
    const Duration(minutes: 5),
    helloAlarmID,
    checkForUpdates,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notice Stalk',
      home: SafeArea(child: PluginsPage()),
    );
  }
}

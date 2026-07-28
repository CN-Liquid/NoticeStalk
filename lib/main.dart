import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:notice_stalk/core/background_task_handler.dart';
import 'package:notice_stalk/core/notification.dart';
import 'package:workmanager/workmanager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:notice_stalk/view/plugins.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Workmanager().initialize(callbackDispatcher);

  Workmanager().registerPeriodicTask(
    "check_for_updates",
    "check_for_updates",
    frequency: const Duration(minutes: 15),
  );

  final notificationInitResult = await NotificationManager.initialize();

  if (!notificationInitResult.isSuccess) {
    Logger().e(notificationInitResult.error!);
  }

  final status = await Permission.notification.status;

  if (status.isDenied) {
    await Permission.notification.request();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: SafeArea(child: PluginsPage()),
    );
  }
}

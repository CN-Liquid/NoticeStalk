import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:notice_stalk/repository/repository.dart';
import 'package:notice_stalk/core/notification.dart';

@pragma('vm:entry-point')
Future<void> checkForUpdates() async {
  final clients = ['ioe_exam', 'ioe_pc'];
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationManager.initialize();
  for (final client in clients) {
    NoticeRepository.instance.setClient(client);
    final newNotices = (client == 'ioe_exam')
        ? await NoticeRepository.instance.fetchNoticesByCursor()
        : await NoticeRepository.instance.fetchNotices();

    if (!newNotices.isSuccess) {
      await NotificationManager.show(
        title: 'Failed to fetch notices',
        details: newNotices.error!,
      );
      Logger().e(newNotices.error);
      continue;
    } else if (newNotices.data!.isEmpty) {
      await NotificationManager.show(title: 'No New Notices', details: client);
      Logger().d('No new notices : $client');
      continue;
    }
    final notices = newNotices.data!;

    for (final data in notices) {
      await NotificationManager.show(title: data.details, details: data.date);
    }
  }
}

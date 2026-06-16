import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class Permissions extends StatefulWidget {
  const Permissions({super.key});

  @override
  State<Permissions> createState() => _PermissionsState();
}

class _PermissionsState extends State<Permissions> {
  PermissionStatus? notificationStatus;

  Future<void> getNotificationStatus() async {
    final status = await Permission.notification.status;

    setState(() {
      notificationStatus = status;
    });
  }

  @override
  void initState() {
    super.initState();
    getNotificationStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Permissions')),
      body: ListView(
        children: [
          ListTile(
            title: Text('Notification permission'),
            trailing: Checkbox(
              tristate: true,
              value: notificationStatus?.isGranted,
              onChanged: (value) async {
                if (value == true) {
                  final result = await Permission.notification.request();

                  if (result.isGranted) {
                    setState(() {
                      notificationStatus = PermissionStatus.granted;
                    });
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:notice_stalk/repository/repository.dart';
import 'package:notice_stalk/view/ioe_pc.dart';
import 'package:notice_stalk/view/ioe_exam.dart';
import 'package:notice_stalk/view/permissions.dart';
import 'package:notice_stalk/view/storage.dart';

class PluginsPage extends StatefulWidget {
  const PluginsPage({super.key});

  @override
  State<PluginsPage> createState() => _PluginsPageState();
}

class _PluginsPageState extends State<PluginsPage> {
  int index = 0;
  final plugins = [IoeExam(), IoePc()];
  final title = ['IOE Exam', 'IOE Pc'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title[index]), centerTitle: true),
      drawer: Drawer(
        child: Column(
          children: [
            ListTile(
              title: Text('Permissions'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return Permissions();
                    },
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Storage'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return StoragePage();
                    },
                  ),
                );
              },
            ),
            ListTile(
              title: Text('IOE Exam'),
              onTap: () {
                NoticeRepository.instance.setClient('ioe_exam');

                setState(() {
                  index = 0;
                });
              },
            ),
            ListTile(
              title: Text('IOE Pc'),
              onTap: () {
                setState(() {
                  index = 1;
                });
              },
            ),
          ],
        ),
      ),
      body: index == 0 ? IoeExam() : IoePc(),
    );
  }
}

import 'package:flutter/material.dart';
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
        shape: RoundedRectangleBorder(side: BorderSide.none),
        width: 200,
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.security),
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
              leading: Icon(Icons.storage),
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
              leading: Icon(Icons.power),
              title: Text('IOE Exam'),
              selected: index == 0,
              selectedColor: Colors.blue,
              onTap: () {
                setState(() {
                  index = 0;
                });

                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: Icon(Icons.power),
              title: Text('IOE Pc'),
              selected: index == 1,
              selectedColor: Colors.blue,
              onTap: () {
                setState(() {
                  index = 1;
                });

                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
      body: index == 0 ? IoeExam() : IoePc(),
    );
  }
}

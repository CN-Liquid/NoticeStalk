import 'package:flutter/material.dart';
import 'package:notice_stalk/view/ioe_exam.dart';

class PluginsPage extends StatelessWidget {
  const PluginsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Plugins Page'), centerTitle: true),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return IoeExam();
                      },
                    ),
                  );
                },
                title: Text('IOE Exam'),
              ),
              ListTile(onTap: () {}, title: Text('IOE Pc')),
            ],
          ),
        ),
      ),
    );
  }
}

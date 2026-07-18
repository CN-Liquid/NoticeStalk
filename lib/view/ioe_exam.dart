import 'package:flutter/material.dart';
import 'package:notice_stalk/repository/repository.dart';
import 'package:notice_stalk/view/notice_page.dart';
import 'package:logger/logger.dart';
import 'package:notice_stalk/view/permissions.dart';
import 'package:notice_stalk/view/storage.dart';

final logger = Logger();

class IoeExam extends StatefulWidget {
  const IoeExam({super.key});

  @override
  State<IoeExam> createState() => _IoeExamState();
}

class _IoeExamState extends State<IoeExam> {
  List<Map<String, dynamic>>? notices;
  bool isLoading = true;
  bool empty = false;
  int page = 0;
  String searchTerm = '';

  @override
  void initState() {
    super.initState();
    NoticeRepository.instance.setClient('ioe_pc');
    _refetch();
  }

  Future<void> _getNotices() async {
    setState(() => isLoading = true);

    final result = await NoticeRepository.instance.getNotices(
      page: page,
      searchText: searchTerm,
    );
    if ((!result.isSuccess) &&
        (result.error == 'There are no notices in this page')) {
      empty = true;
    } else if (!result.isSuccess) {
      logger.e(result.error);
    } else {
      notices = result.data!;
    }

    setState(() => isLoading = false);
  }

  Future<void> _refetch() async {
    setState(() => isLoading = true);
    await NoticeRepository.instance.fetchNoticesByCursor(page: page);
    final result = await NoticeRepository.instance.getNotices(page: page);

    if (!result.isSuccess) {
      logger.e(result.error);
      return;
    }

    notices = result.data!;
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
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
          ],
        ),
      ),
      appBar: AppBar(title: Text('IOE Exam'), centerTitle: true),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TextFormField(
                  initialValue: searchTerm,
                  onChanged: (value) {
                    searchTerm = value;
                  },
                ),
                TextButton(
                  onPressed: () {
                    logger.d(searchTerm);
                    page = 0;
                    _getNotices();
                  },
                  child: Text('Search'),
                ),
                SizedBox(height: 10),
                empty == false
                    ? Flexible(
                        flex: 4,
                        child: ListView.builder(
                          itemCount: notices!.length,
                          itemBuilder: (context, index) {
                            final notice = notices![index];
                            return ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) {
                                      return NoticePage(
                                        details: notice['details'],
                                        date: notice['date'],
                                        link: notice['link'],
                                      );
                                    },
                                  ),
                                );
                              },
                              title: Text(notice['details']),
                              subtitle: Text(notice['date']),
                            );
                          },
                        ),
                      )
                    : Text('This is the end'),

                Flexible(
                  flex: 1,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          empty = false;
                          page = page == 0 ? page = 0 : (page - 1);

                          _getNotices();
                        },
                        child: Text('Previous'),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          if (empty == false) {
                            page = page + 1;
                            _getNotices();
                          }
                        },
                        child: Text('Next'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refetch,
        child: Icon(Icons.refresh),
      ),
    );
  }
}

import 'package:notice_stalk/core/result.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:notice_stalk/core/notice.dart';

class NoticeDatabase {
  NoticeDatabase._private();

  static final NoticeDatabase instance = NoticeDatabase._private();
  Database? _database;

  Future<Result<Database>> get database async {
    if (_database != null) {
      return Result.success(_database!);
    }

    final result = await _initDB('notices.db');

    return result;
  }

  Future<Result<Database>> _initDB(String filePath) async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);

      final db = await openDatabase(path, version: 1, onCreate: _createDB);

      _database = db;

      return Result.success(db);
    } catch (e) {
      return Result.failure('Unable to initialize database $e');
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute("""CREATE TABLE Notices (
    id TEXT,
    date TEXT,
    details TEXT,
    link TEXT,
    docLink TEXT NULL,
    docPath TEXT NULL,
    PRIMARY KEY (date,details)
    )""");

    await db.execute(
      """ CREATE TABLE Pages (id TEXT,page INT , cursor TEXT NULL) """,
    );
  }

  Future<Result<void>> close() async {
    if (_database == null) {
      return Result.success(null);
    }

    try {
      await _database!.close();
      _database = null;

      return Result.success(null);
    } catch (e) {
      return Result.failure('Unable to close the database cleanly : $e');
    }
  }

  Future<Result<bool>> insert(Notice notice) async {
    final result = await database;
    bool isInserted = false;

    if (!result.isSuccess) {
      return Result.failure(result.error!);
    }

    final noticeResult = await fetchNotice(
      id: notice.id,
      date: notice.date,
      details: notice.details,
    );

    if (!noticeResult.isSuccess &&
        noticeResult.error == 'Notice not found in database') {
      isInserted = true;
    } else if (!noticeResult.isSuccess) {
      return Result.failure(noticeResult.error!);
    }

    try {
      final db = result.data!;
      await db.rawInsert(
        'INSERT OR REPLACE INTO Notices(id,date,details,link,docLink,docPath) VALUES(?,?,?,?,?,?)',
        [
          notice.id,
          notice.date,
          notice.details,
          notice.link,
          notice.docLink,
          notice.docPath,
        ],
      );

      return Result.success(isInserted);
    } catch (e) {
      return Result.failure('Unable to insert into the database : $e');
    }
  }

  Future<Result<List<Map<String, dynamic>>>> fetchAllNotices() async {
    final result = await database;

    if (!result.isSuccess) {
      return Result.failure(result.error!);
    }

    try {
      final data = await result.data!.query('Notices');
      return Result.success(data);
    } catch (e) {
      return Result.failure('Unable to query the database : $e');
    }
  }

  Future<Result<List<Notice>>> fetchNotices({
    required String id,
    int page = 0,
    String searchText = '',
  }) async {
    final result = await database;

    if (!result.isSuccess) {
      return Result.failure(result.error!);
    }

    try {
      List<Map<String, Object?>> data;

      if (searchText.isNotEmpty) {
        final formattedText = '%$searchText%';
        data = await result.data!.query(
          'Notices',
          limit: 6,
          offset: 6 * page,
          orderBy: 'date DESC',
          where: 'details LIKE ? AND id=?',
          whereArgs: [formattedText, id],
        );
      } else {
        data = await result.data!.query(
          'Notices',
          limit: 6,
          offset: 6 * page,
          orderBy: 'date DESC',
          where: 'id=? ',
          whereArgs: [id],
        );
      }

      return Result.success(
        data
            .map(
              (d) => Notice(
                id: d['id'] as String,
                details: d['details'] as String,
                date: d['date'] as String,
                link: d['link'] as String,
                docLink: d['docLink'] as String,
                docPath: d['docPath'] as String?,
              ),
            )
            .toList(),
      );
    } catch (e) {
      return Result.failure('Unable to query the database : $e');
    }
  }

  Future<Result<Notice>> fetchNotice({
    required String id,
    required String date,
    required String details,
  }) async {
    final result = await database;

    if (!result.isSuccess) {
      return Result.failure(result.error!);
    }

    try {
      final data = await result.data!.query(
        'Notices',
        where: 'date = ? AND details = ? AND id=?',
        whereArgs: [date, details, id],
      );

      if (data.isEmpty) {
        return Result.failure('Notice not found in database');
      }

      final row = data.first;
      return Result.success(
        Notice(
          id: row['id'] as String,
          date: row['date'] as String,
          details: row['details'] as String,
          link: row['link'] as String,
          docLink: row['docLink'] as String,
          docPath: row['docPath'] as String?,
        ),
      );
    } catch (e) {
      return Result.failure('Unable to query the database : $e');
    }
  }

  Future<Result<void>> insertCursor(String id, int page, String cursor) async {
    final result = await database;

    if (!result.isSuccess) {
      return Result.failure(result.error!);
    }

    try {
      final db = result.data;

      await db!.insert('Pages', {'id': id, 'page': page, 'cursor': cursor});

      return Result.success(null);
    } catch (e) {
      return Result.failure('Unable to insert into the pages table : $e');
    }
  }

  Future<Result<String?>> getCursor(String id, int page) async {
    if (page == 0) {
      return Result.success('');
    }

    final result = await database;

    if (!result.isSuccess) {
      return Result.failure(result.error!);
    }

    try {
      final db = result.data;
      final cursor = await db!.query(
        'Pages',
        where: 'page = ? AND id=?',
        whereArgs: [page, id],
      );

      if (cursor.isEmpty) {
        return Result.success(null);
      }

      return Result.success(cursor.first['cursor'].toString());
    } catch (e) {
      return Result.failure('Error in reading cursor : $e');
    }
  }
}

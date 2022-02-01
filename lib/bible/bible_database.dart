import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';


// (Global 변수) 메인DB이름 정의
var MainDBName = "bible.db"; // holybible.db / hicor.db / echo_db_1.db
var DB_Dir     = "assets";
var Version    = 1;

class BibleDatabase {
  // (함수) DB연결
  static Future<Database> getDb() async {
    String documentDir = await getDatabasesPath();
    String dbPath = join(documentDir, MainDBName);

    if (!await databaseExists(dbPath)) {
      await _prepareDatabaseFile(dbPath);
      _removeOldDatabaseFile(documentDir);
    }

    return await openDatabase(
        dbPath,
        version: Version,
        singleInstance: true,
        onUpgrade: _handleUpgrade
    );
  }

  // (함수) DB상태업그레이드
  static FutureOr<void> _handleUpgrade(Database db, int oldVersion, int newVersion) {
    var batch = db.batch();
    if (oldVersion < Version && newVersion >= Version) {
      print('[DB_UPGRADE] ${new DateTime.now()}: upgrade v2');
      batch.execute('update verses set bookmarked=false');
      batch.execute('update hymns set bookmarked=false');
    }
  }

  // (함수) DB준비
  static _prepareDatabaseFile(dbPath) async {
    ByteData data = await rootBundle.load(join(DB_Dir, MainDBName));
    List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    await new File(dbPath).writeAsBytes(bytes);
  }

  // (함수) 안쓰는 DB 삭제
  static _removeOldDatabaseFile(String documentDir) async {
    var oldDatabases = [
      "asset_holybible.db",
      "holybible-1.db"
      "holybible.db"
      "echo_db_1.db"
    ];

    oldDatabases.forEach((filename) async {
      var path = join(documentDir, filename);
      if (!await databaseExists(path)) {
        await deleteDatabase(path);
      }
    });
  }
}

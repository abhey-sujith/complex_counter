import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqlite_api.dart';

class DBHelper {
  static Future<Database> database() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(path.join(dbPath, 'countflutter.db'),
        onCreate: (db, version) {
          return db.execute(
              'CREATE TABLE countflutter(id TEXT PRIMARY KEY, title TEXT, count INTEGER)');
        }, version: 1);
  }

  static Future<void> insert(String table, Map<String, Object> data) async {
    final db = await DBHelper.database();
    db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> getData(String table) async {
    final db = await DBHelper.database();
    return db.query(table);
  }

  static Future<int> deleteData(String table,String idDelete) async {
    final db = await DBHelper.database();
    return db.delete(table, where: 'id = ?', whereArgs: [idDelete]);
  }

}



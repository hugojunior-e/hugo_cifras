import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  
  static void createTables(sql.Database database) {
    database.execute("""CREATE TABLE items(
        id          INTEGER  PRIMARY KEY AUTOINCREMENT NOT NULL,
        titulo      varchar(100),
        tom         varchar(10),
        cifra       TEXT
      )
      """);
  }

  static Future<sql.Database> db() async {
    sqfliteFfiInit();

    Future<sql.Database> db = sql.openDatabase(
      '/storage/emulated/0/Download/hcifras.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        createTables(database);
        if (kDebugMode) {
          print("Database Criado");
        }
      },
    );
    return db;
  }

  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await DatabaseHelper.db();
    return db.query('items', orderBy: "titulo",);
  }

  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await DatabaseHelper.db();
    return db.query('items', where: "id = ?", whereArgs: [id], limit: 1);
  }

  static Future<int> createItem(String? title, String? descrption) async {
    final db = await DatabaseHelper.db();

    final data = {'title': title, 'description': descrption};
    final id = await db.insert('items', data, conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }


  static Future<int> updateItem(int id, String title, String? descrption) async {
    final db = await DatabaseHelper.db();

    final data = {
      'title': title,
      'description': descrption,
      'createdAt': DateTime.now().toString()
    };

    final result =  await db.update('items', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  static Future<void> deleteItem(int id) async {
    final db = await DatabaseHelper.db();
    try {
      await db.delete("items", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
}

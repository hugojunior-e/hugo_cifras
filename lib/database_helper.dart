import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

//db.delete("items", where: "id = ?", whereArgs: [id]);
//db.update('items', data, where: "id = ?", whereArgs: [id]);
//db.insert('items', data, conflictAlgorithm: sql.ConflictAlgorithm.replace);

class DatabaseHelper {
  List<Map<String, dynamic>> lista = [];
  late sql.Database db;

  DatabaseHelper() {
    sqfliteFfiInit();

    sql.openDatabase('/storage/emulated/0/Download/hcifras.db',
        version: 1, onCreate: dbOnCreate, onOpen: dbOnOpen);
  }

  void dbOnCreate(sql.Database database, int version) {
    database.execute("""
      CREATE TABLE items(
        id          INTEGER  PRIMARY KEY AUTOINCREMENT NOT NULL,
        titulo      varchar(100),
        tom         varchar(10),
        cifra       TEXT
      )
      """);

    if (kDebugMode) {
      print("Database Criado");
    }
  }

  void dbOnOpen(sql.Database database) {
    db = database;

    db
        .query(
      'items',
      orderBy: "titulo",
    )
        .then((e) {
      lista = e;
      if (kDebugMode) {
        print("Lista com total de ${lista.length}");      
    }});
  }
}

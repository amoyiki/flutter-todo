import 'dart:collection';
import 'dart:io';

import 'package:flutter_todo/constant.dart';
import 'package:flutter_todo/models.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class SqliteUtil {
  SqliteUtil._();
  static SqliteUtil sqliteUtil = SqliteUtil._();
  static late Database _database;
  Future<Database> get database async => _database = await createDatabase();

  Future<Database> createDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'todo.db';
    Database database = await openDatabase(path, version: 1, onCreate: (db, v) {
      db.execute(
          'CREATE TABLE $tableName($tableId INTEGER PRIMARY KEY AUTOINCREMENT, $tableContent TEXT, $tableIsComplete INTEGER, $tableCreated TEXT, $tableUpdated TEXT)');
    });
    return database;
  }

  insertNewTask(TaskModel taskModel) async {
    Database database = await sqliteUtil.database;
    int rowIndex = await database.insert(tableName, taskModel.toJson());
    print("add row $rowIndex");
    List<Map> result =
        await database.query(tableName, where: "id = ?", whereArgs: [rowIndex]);
    print('data is ${result}');
  }

  getTaskAll() async {
    Database database = await sqliteUtil.database;
    List<Map> result = await database.query(tableName);
    print(result);
  }

  getTaskByMap(LinkedHashMap where, int limit, int offset) async {
    Database database = await sqliteUtil.database;
    String whereStr = "";
    List<String> whereKeyList = [];
    List<String> whereValList = [];
    for (var key in where.keys) {
      whereKeyList.add(' $key = ? ');
    }
    for (var v in where.values) {
      whereValList.add(v);
    }
    whereStr = whereKeyList.join("AND");
    List<Map> result = await database.query(tableName,
        where: whereStr, whereArgs: whereValList, limit: limit, offset: offset);
    print(result);
    return result;
  }
  getTaskCountByMap(LinkedHashMap where) async {
    Database database = await sqliteUtil.database;
    String whereStr = "";
    List<String> whereKeyList = [];
    List<String> whereValList = [];
    for (var key in where.keys) {
      whereKeyList.add(' $key = ? ');
    }
    for (var v in where.values) {
      whereValList.add(v);
    }
    whereStr = whereKeyList.join("AND");
    List<Map> result = await database.query(tableName, columns: ['id'],
        where: whereStr, whereArgs: whereValList);
    print(result);
    return result.length;
  }

  getTaskById(int id) async {
    Database database = await sqliteUtil.database;
    List<Map> result =
        await database.query(tableName, where: "id = ?", whereArgs: [id]);
    print(result);
    return result;
  }

  deleteTaskById(int id) async {
    Database database = await sqliteUtil.database;
    int rowIndex =
        await database.delete(tableName, where: "id = ?", whereArgs: [id]);
    print(rowIndex);
  }

  updateTask(TaskModel taskModel) async {
    Database database = await sqliteUtil.database;
    database.update(tableName, taskModel.toJson(),
        where: "id = ?", whereArgs: [taskModel.id]);
  }
}

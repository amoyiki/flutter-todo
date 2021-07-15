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

  Future<List<TaskModel>> getTaskAll() async {
    Database database = await sqliteUtil.database;
    List<Map<String, dynamic>> result = await database.query(tableName);
    return result.map((e) => TaskModel.fromJson(e)).toList();
  }

  Future<List<TaskModel>> getTaskByMap(
      LinkedHashMap<String, dynamic> where, int limit, int offset) async {
    Database database = await sqliteUtil.database;
    String whereStr = "";
    List<String> whereKeyList = [];
    List<dynamic> whereValList = [];
    for (var key in where.keys) {
      whereKeyList.add(' $key = ? ');
    }
    for (var v in where.values) {
      whereValList.add(v);
    }
    if (whereValList.length > 1) {
      whereStr = whereKeyList.join("AND");
    } else {
      whereStr = whereKeyList.first;
    }
    List<Map<String, dynamic>> result = await database.query(tableName,
        where: whereStr, whereArgs: whereValList, limit: limit, offset: offset);

    return result.map((e) => TaskModel.fromJson(e)).toList();
  }

  Future<int> getTaskCountByMap(LinkedHashMap<String, dynamic> where) async {
    Database database = await sqliteUtil.database;
    String whereStr = "";
    List<String> whereKeyList = [];
    List<dynamic> whereValList = [];
    for (var key in where.keys) {
      whereKeyList.add(' $key = ? ');
    }
    for (var v in where.values) {
      whereValList.add(v);
    }
    if (whereValList.length > 1) {
      whereStr = whereKeyList.join("AND");
    } else {
      whereStr = whereKeyList.first;
    }
    List<Map<String, dynamic>> result = await database.query(tableName,
        where: whereStr, whereArgs: whereValList);
    print('总数 ${result.length}');
    return result.length;
  }

  Future<TaskModel> getTaskById(int id) async {
    Database database = await sqliteUtil.database;
    List<Map<String, dynamic>> result =
        await database.query(tableName, where: "id = ?", whereArgs: [id]);
    print(result);
    return result.map((e) => TaskModel.fromJson(e)).first;
  }

  Future<int> deleteTaskById(int id) async {
    Database database = await sqliteUtil.database;
    int rowIndex =
        await database.delete(tableName, where: "id = ?", whereArgs: [id]);
    print(rowIndex);
    return rowIndex;
  }

  Future<void> updateTask(TaskModel taskModel) async {
    Database database = await sqliteUtil.database;
    database.update(tableName, taskModel.toJson(),
        where: "id = ?", whereArgs: [taskModel.id]);
  }

  close() {
    _database.close();
  }
}

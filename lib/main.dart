import 'dart:collection';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todo/sqlite_util.dart';
import 'package:intl/intl.dart';

import 'models.dart';

void main() async {
  runApp(MaterialApp(
    title: "Todo",
    debugShowCheckedModeBanner: false,
    home: MainPage(),
  ));
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TextEditingController _editingController = TextEditingController();

  LinkedHashMap<String, dynamic> selectMap = LinkedHashMap();
  List datal = [];
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    selectMap['isComplete'] = 0;
    for (int i = 0; i < 100; i++) {
      TaskModel t = TaskModel(
          content: "Task$i",
          isComplete: 0,
          updated: '2021-07-01 00:00:00',
          created: '2021-07-01 00:00:00');
      SqliteUtil.sqliteUtil.insertNewTask(t);
      datal.add(t);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _editingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TODO"),
        bottom: TabBar(
          tabs: <Widget>[
            Tab(text: "未完成"),
            Tab(text: "已完成"),
          ],
          controller: _tabController,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 40,
        ),
        onPressed: () {
          createDialog();
        },
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          FutureBuilder<List>(
            future: SqliteUtil.sqliteUtil.getTaskAll(),
            initialData: datal,
            builder: (context, snapshot) {
              return snapshot.hasData
                  ? new ListView.builder(
                      padding: const EdgeInsets.all(10.0),
                      itemCount: snapshot.data?.length ?? 0,
                      itemBuilder: (context, i) {
                        return _bulidRow(snapshot.data?[i]);
                      },
                    )
                  : Center(child: CircularProgressIndicator());
            },
          ),
          Center(
            child: Text("这是已完成列表"),
          ),
        ],
      ),
    );
  }

  Widget _bulidRow(TaskModel taskModel) {
    return ListTile(
      title: Text(taskModel.content),
    );
  }

  /// 弹框方法
  void createDialog() async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('新增事项'),
            content: SizedBox(
              height: 200,
              child: Card(
                elevation: 0.0,
                child: Column(
                  children: <Widget>[
                    TextField(
                      keyboardType: TextInputType.multiline,
                      autofocus: true,
                      controller: _editingController,
                      maxLines: null, //不限制行数
                      decoration: InputDecoration(
                        hintText: '输入待办事项',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('取消'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: Text('确定'),
                onPressed: () async {
                  DateTime now = DateTime.now();
                  String currentStr = _editingController.text;
                  DateFormat dateFormat = DateFormat(
                      "yyyy-MM-dd HH:mm:ss "); // how you want it to be formatted
                  String nowStr = dateFormat.format(now);
                  TaskModel taskModel = TaskModel.fromJson({
                    "content": currentStr,
                    "isComplete": 0,
                    "created": nowStr,
                    "updated": nowStr
                  });
                  await SqliteUtil.sqliteUtil.insertNewTask(taskModel);
                  Navigator.pop(context);
                  setState(() {});
                },
              ),
            ],
          );
        });
  }
}

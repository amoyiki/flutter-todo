import 'dart:collection';

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
  var _datas = <TaskModel>[];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // _retrieveData(1, 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    // _editingController.dispose();
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
          ListView.separated(
            itemCount: _datas.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(16.0),
                child: Text('====已经到达底线了==='),
              );
            },
            separatorBuilder: (context, index) => Divider(
              height: .0,
            ),
          ),
          Center(
            child: Text("这是已完成列表"),
          ),
        ],
      ),
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
                    "isComplete": false,
                    "created": nowStr,
                    "updated": nowStr
                  });
                  await SqliteUtil.sqliteUtil.insertNewTask(taskModel);
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  void _retrieveData(int limit, int offset) {
    LinkedHashMap map = new LinkedHashMap();
    map['isComplete'] = false;
    var taskByMap = SqliteUtil.sqliteUtil.getTaskByMap(map, limit, offset);
    for (var m in taskByMap) {
      _datas.add(TaskModel.fromJson(m));
    }
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todo/sqlite_util.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
          showDialog(
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
                        DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss "); // how you want it to be formatted
                        String nowStr = dateFormat.format(now); 
                        TaskModel taskModel = TaskModel.fromJson({"content": currentStr, "isComplete": false, "created": nowStr, "updated": nowStr});
                        await SqliteUtil.sqliteUtil.insertNewTask(taskModel);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
              });
        },
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          Center(
            child: Text("这是未完成列表"),
          ),
          Center(
            child: Text("这是已完成列表"),
          ),
        ],
      ),
    );
  }
}

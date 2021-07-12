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
  Future<List>? future;
  GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey<RefreshIndicatorState>();
  ScrollController _scrollController = ScrollController();
  int pageNum = 0;
  List list = [] as List;
  int total = 16;
  bool enableMore = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);    
    pageNum = 0;
    future = loadingData(pageNum);
    _scrollController.addListener(() {
      int offset = _scrollController.position.pixels.toInt();
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 50) {
          print('加载更多');
          _loadMore();
        }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _editingController.dispose();
    _scrollController.dispose();
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
            future: future,
            builder: (context, AsyncSnapshot<List> snapshot) {
              if(snapshot.connectionState == ConnectionState.active || snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.connectionState == ConnectionState.done) {
                print('done');
                if(snapshot.hasError) {
                  return Center(
                    child: Text('ERROR'),
                  );
                }else if (snapshot.hasData) {
                  if (pageNum == 0 ){
                    List? l = snapshot.data ?? [];
                    list.addAll(l);
                  }
                  if (total > 0 && total <= list.length) {
                    enableMore = false;
                  }else{
                    enableMore = true;
                  }
                  return RefreshIndicator(
                  
                    child: ListView.builder(
                      controller: enableMore ? _scrollController : null,
                      padding: const EdgeInsets.all(10.0),
                      itemCount: list.length,
                      itemBuilder: (context, i) {
                        return _bulidRow(list[i]);
                      },
                    ), 
                    onRefresh: _onRefresh
                    );
                }
              }
               return  Center(child: CircularProgressIndicator());
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

  // 下拉刷新
  Future<Null> _onRefresh() {
    return Future.delayed(Duration(seconds: 1), (){
      print('正在刷新...');
      list.clear();
      pageNum = 0;
      setState(() {
        future = loadingData(pageNum);
      });
    });
  }
  // 加载更多
  Future<Null> _loadMore(){
    return Future.delayed(Duration(seconds: 1), () {
      pageNum += 1;
      print('加载更多页面$pageNum');
       loadingData(pageNum).then((List value) => {
          setState(() {
            list.addAll(value);
        })
      });
      
    });
  }

  Future<List> loadingData(int pageNum) async {
    LinkedHashMap<String, dynamic> selectMap = LinkedHashMap();
    selectMap['isComplete'] = 0;
    int offset = (pageNum - 1) * 15;
    return SqliteUtil.sqliteUtil.getTaskByMap(selectMap, 15, offset);
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
                  _editingController.clear();
                  Navigator.pop(context);
                  setState(() {});
                },
              ),
            ],
          );
        });
  }
}

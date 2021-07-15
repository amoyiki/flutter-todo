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
  Future<List>? future;

  ScrollController _scrollController = ScrollController();
  int pageNum = 1;
  List list = [] as List;
  List completedIds = [] as List;
  bool isOff = true;
  int total = 0;
  bool enableMore = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    pageNum = 1;
    future = loadingData(pageNum);
    LinkedHashMap<String, dynamic> selectMap = LinkedHashMap();
    selectMap['isComplete'] = 0;
    SqliteUtil.sqliteUtil
        .getTaskCountByMap(selectMap)
        .then((value) => total = value);
    // _bulidList();
    _scrollController.addListener(() {
      int offset = _scrollController.position.pixels.toInt();
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (!isLoading) {
          isLoading = true;
          print('加载更多');
          _loadMore();
        }
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
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            tooltip: "编辑",
            onPressed: () {
              print('编辑');
            //   list.forEach((element) {
            //     element['select'] = false;
            //   });
            //   this.completedIds = [];
            //   setState(() {
            //     this.isOff = !this.isOff;
            //     this.list = list;
            //   });
            },
          ),
        ],
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
          _bulidList(),
          Center(
            child: Text("这是已完成列表"),
          ),
        ],
      ),
    );
  }

  // 单条记录样式
  Widget _bulidRow(TaskModel taskModel) {
    return ListTile(
      title: Text(taskModel.content),
    );
  }

  // 底部按钮组 全选/完成
  // Widget _bottomButton(){
  //   return Offstage(
  //     offstage: isOff,
  //     child: ,
  //   );
  // }

  // 下拉刷新
  Future<Null> _onRefresh() {
    if (isLoading) {
      return Future.value(null);
    }
    return Future.delayed(Duration(seconds: 1), () {
      print('正在刷新...');
      list.clear();
      setState(() {
        isLoading = true;
        pageNum = 1;
        future = loadingData(pageNum);
        _bulidList();
      });
    });
  }

  // 加载更多
  Future<bool> _loadMore() {
    pageNum += 1;
    var a = list.map((e) => e.getInfo).toList();
    print('当前页面$pageNum, 加载更多页面$a');
    loadingData(pageNum).then((List value) => {
          setState(() {
            isLoading = false;
            list.addAll(value);
            // _bulidList();
          })
        });
    return Future.value(true);
  }

  Future<List> loadingData(int pageNum) async {
    LinkedHashMap<String, dynamic> selectMap = LinkedHashMap();
    selectMap['isComplete'] = 0;
    int offset = (pageNum - 1) * 15;
    print('总数是$total');
    return Future.delayed(Duration(seconds: 1), () {
      return SqliteUtil.sqliteUtil.getTaskByMap(selectMap, 15, offset);
    });
  }

  // 构建一个FutureBuilder
  FutureBuilder<List> _bulidList() {
    return FutureBuilder<List>(
      future: future,
      builder: (context, AsyncSnapshot<List> snapshot) {
        if (snapshot.connectionState == ConnectionState.active ||
            snapshot.connectionState == ConnectionState.waiting) {
          isLoading = true;
          print('=========================');
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          print('done');
          isLoading = false;
          if (snapshot.hasError) {
            return Center(
              child: Text('ERROR'),
            );
          } else if (!snapshot.hasData || snapshot.data?.length == 0) {
            return EmptyItem();
          }else if (snapshot.hasData) {
            if (pageNum <= 1) {
              List? l = snapshot.data ?? [];
              list.addAll(l);
            }
            if (total > 0 && total <= list.length) {
              enableMore = false;
            } else {
              enableMore = true;
            }
            if (isLoading) {
              return Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
                child: ListView.separated(
                  physics: AlwaysScrollableScrollPhysics(),
                  controller: enableMore ? _scrollController : null,
                  padding: const EdgeInsets.all(10.0),
                  itemCount: list.length + (enableMore ? 1 : 0),
                  itemBuilder: (context, i) {
                    if (enableMore && i == list.length) {
                      print('~~~~~~~~~~~~~~~~');
                      return LoadMoreItem();
                    }
                    if (!enableMore && list.length >= total) {}
                    return _bulidRow(list[i]);
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider();
                  },
                ),
                onRefresh: _onRefresh);
          }
        }
        return Center(child: CircularProgressIndicator());
      },
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
                  _editingController.clear();
                  Navigator.pop(context);
                  setState(() {
                    
                  });
                },
              ),
            ],
          );
        });
  }
}

class EmptyItem extends StatelessWidget {
  const EmptyItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
     return Container(
      child: Center(
        child: Text('列表数据为空'),
      ),
    );
  }
}

class LoadMoreItem extends StatefulWidget {
  LoadMoreItem({Key? key}) : super(key: key);

  @override
  _LoadMoreItemState createState() => _LoadMoreItemState();
}

class _LoadMoreItemState extends State<LoadMoreItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}


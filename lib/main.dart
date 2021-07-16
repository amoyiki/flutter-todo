import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
  Future<List>? future2;

  ScrollController _scrollController = ScrollController();
  ScrollController _scrollController2 = ScrollController();
  int pageNum = 1;
  int pageNum2 = 1;
  int pageSize = 10;
  int pageSize2 = 10;
  List list = [] as List;
  List list2 = [] as List;
  List completedIds = [] as List;
  bool isOff = true;
  int total = 0;
  int total2 = 0;
  bool enableMore = false;
  bool enableMore2 = false;
  bool isLoading = false;
  bool isLoading2 = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    pageNum = 1;
    pageNum2 = 1;
    future = loadingData(pageNum);
    future2 = loadingData2(pageNum);
    LinkedHashMap<String, dynamic> selectMap = LinkedHashMap();
    selectMap['isComplete'] = 0;
    SqliteUtil.sqliteUtil
        .getTaskCountByMap(selectMap)
        .then((value) => total = value);
    LinkedHashMap<String, dynamic> selectMap1 = LinkedHashMap();
    selectMap1['isComplete'] = 1;
    SqliteUtil.sqliteUtil
        .getTaskCountByMap(selectMap1)
        .then((value) => total2 = value);

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
    _scrollController2.addListener(() {
      int offset = _scrollController2.position.pixels.toInt();
      if (_scrollController2.position.pixels ==
          _scrollController2.position.maxScrollExtent) {
        if (!isLoading2) {
          isLoading2 = true;
          print('加载更多');
          _loadMore2();
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
          _bulidList1(),
          _bulidList2(),
        ],
      ),
    );
  }

  // 单条记录样式
  Widget _bulidRow(TaskModel taskModel) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: ListTile(
        title: Text(taskModel.content),
      ),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'Done',
          color: Colors.green,
          icon: Icons.done,
          closeOnTap: true,
          onTap: () {
            print('=========向左滑点击完成按钮========');
            finishData(taskModel.id!);
            setState(() {
              total -= 1;
              list.remove(taskModel);
              if (list.length == 0) {
                _onRefresh();
              }
            });
          },
        ),
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          icon: Icons.delete,
          closeOnTap: false,
          onTap: () {
            print('=========向左滑点击删除按钮========');
            deleteData(taskModel.id!);
            setState(() {
              total -= 1;
              list.remove(taskModel);
              if (list.length == 0) {
                _onRefresh();
              }
            });
          },
        ),
      ],
    );
  }

  Widget _bulidRow2(TaskModel taskModel) {
    print('111111111111111111111111111111');
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: ListTile(
        title: Text(taskModel.content),
      ),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'Done',
          color: Colors.green,
          icon: Icons.done,
          closeOnTap: true,
          onTap: () {
            print('=========向左滑点击完成按钮========');
            finishData(taskModel.id!);
            setState(() {
              total2 -= 1;
              list2.remove(taskModel);
            });
          },
        ),
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          icon: Icons.delete,
          closeOnTap: false,
          onTap: () {
            print('=========向左滑点击删除按钮========');
            deleteData(taskModel.id!);
            setState(() {
              total2 -= 1;
              list2.remove(taskModel);
            });
          },
        ),
      ],
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
      });
    });
  }

  Future<Null> _onRefresh2() {
    if (isLoading2) {
      return Future.value(null);
    }
    return Future.delayed(Duration(seconds: 1), () {
      print('正在刷新...');
      list2.clear();
      setState(() {
        isLoading2 = true;
        pageNum2 = 1;
        future2 = loadingData2(pageNum);
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
          })
        });
    return Future.value(true);
  }

  Future<bool> _loadMore2() {
    pageNum += 1;
    var a = list2.map((e) => e.getInfo).toList();
    print('当前页面$pageNum, 加载更多页面$a');
    loadingData2(pageNum).then((List value) => {
          setState(() {
            isLoading = false;
            list2.addAll(value);
          })
        });
    return Future.value(true);
  }

  Future<List> loadingData(int pageNum) async {
    LinkedHashMap<String, dynamic> selectMap = LinkedHashMap();
    selectMap['isComplete'] = 0;
    int offset = (pageNum - 1) * pageSize;
    print('总数是$total');
    return Future.delayed(Duration(seconds: 1), () {
      return SqliteUtil.sqliteUtil.getTaskByMap(selectMap, pageSize, offset);
    });
  }

  Future<List> loadingData2(int pageNum) async {
    LinkedHashMap<String, dynamic> selectMap = LinkedHashMap();
    selectMap['isComplete'] = 1;
    int offset = (pageNum - 1) * pageSize;
    print('总数是2$total');
    return Future.delayed(Duration(seconds: 1), () {
      return SqliteUtil.sqliteUtil.getTaskByMap(selectMap, pageSize, offset);
    });
  }

  Future<int> deleteData(int id) async {
    return Future.delayed(Duration(seconds: 1), () {
      return SqliteUtil.sqliteUtil.deleteTaskById(id);
    });
  }

  Future<void> finishData(int id) async {
    return Future.delayed(Duration(seconds: 1), () async {
      TaskModel taskModel = await SqliteUtil.sqliteUtil.getTaskById(id);
      taskModel.isComplete = 1;
      return SqliteUtil.sqliteUtil.updateTask(taskModel);
    });
  }

  // 构建一个FutureBuilder
  FutureBuilder<List> _bulidList1() {
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
            print('===========错误==============${snapshot.error}');
            return Center(
              child: Text('ERROR'),
            );
          } else if (!snapshot.hasData || snapshot.data?.length == 0) {
            print('===========空数据==============');
            return EmptyItem();
          } else if (snapshot.hasData) {
            print('===========有数据==============');
            if (pageNum <= 1) {
              print(
                  '===========第一次加载数据==${pageNum}========${snapshot.data?.length}===========${list.length}===========');
              List? l = snapshot.data ?? [];
              if (list.length == 0) {
                list.addAll(l);
              }
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
                  // padding: const EdgeInsets.all(10.0),
                  itemCount: list.length + (enableMore ? 1 : 0),
                  itemBuilder: (context, i) {
                    if (enableMore &&
                        i == list.length &&
                        total != list.length) {
                      print('~~~~~~~~~~~~~~~~$total,--------${list.length}');
                      return LoadMoreItem();
                    }
                    if (!enableMore && list.length >= total) {}
                    return _bulidRow(list[i]);
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider(
                      height: 0.1,
                    );
                  },
                ),
                onRefresh: _onRefresh);
          }
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  // 构建一个FutureBuilder
  FutureBuilder<List> _bulidList2() {
    return FutureBuilder<List>(
      future: future2,
      builder: (context, AsyncSnapshot<List> snapshot) {
        if (snapshot.connectionState == ConnectionState.active ||
            snapshot.connectionState == ConnectionState.waiting) {
          isLoading2 = true;
          print('=============2============');
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          print('done2');
          isLoading2 = false;
          if (snapshot.hasError) {
            print('===========错误2==============${snapshot.error}');
            return Center(
              child: Text('ERROR'),
            );
          } else if (!snapshot.hasData || snapshot.data?.length == 0) {
            print('===========空数据2==============');
            return EmptyItem();
          } else if (snapshot.hasData) {
            print('===========有数据2==============');
            if (pageNum2 <= 1) {
              print(
                  '===========第一次加载数据2==${pageNum2}========${snapshot.data?.length}===========${list2.length}===========');
              List? l = snapshot.data ?? [];
              if (list2.length == 0) {
                list2.addAll(l);
              }
            }
             print(
                  '===========第一次加载数据2==${pageNum2}========${enableMore2}===========${list2.length}===========');
            if (total > 0 && total <= list2.length) {
              enableMore2 = false;
            } else {
              enableMore2 = true;
            }
            if (isLoading2) {
              return Center(child: CircularProgressIndicator());
            }
            print('~~~~~~~~~~~2~~~~~~~~~~~~~~~~~~~~~');
            return RefreshIndicator(
                child: ListView.separated(
                  physics: AlwaysScrollableScrollPhysics(),
                  controller: enableMore2 ? _scrollController2 : null,
                  // padding: const EdgeInsets.all(10.0),
                  itemCount: list2.length + (enableMore2 ? 1 : 0),
                  itemBuilder: (context, i) {
                    print('~~~~~~~~~~~~~2~~~$total2,----2----${list2}');
                    list2.forEach((element) {
                      print(element.toJson());
                    });
                    if (enableMore2 &&
                        i == list2.length &&
                        total2 != list2.length) {
                      return LoadMoreItem();
                    }
                    return _bulidRow2(list2[i]);
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    print('!!!!!!!!!!!!!!!!!!!!!');
                    return Divider(
                      height: 0.1,
                    );
                  },
                ),
                onRefresh: _onRefresh2);
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
                    total += 1;
                    list.add(taskModel);
                    _onRefresh();
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

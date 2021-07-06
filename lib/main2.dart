import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    title: "Todo",
    debugShowCheckedModeBanner: false,
    home: ButtonPage(),
  ));
}

class ButtonPage extends StatelessWidget {
  const ButtonPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("按钮页面"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              print("图标按钮");
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Colors.blue,
          size: 40,
        ),
        onPressed: () {
          print("浮动按钮");
        },
        backgroundColor: Colors.yellow,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            ElevatedButton(
              child: Text('普通按钮'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue),
                foregroundColor: MaterialStateProperty.all(Colors.white),
                elevation: MaterialStateProperty.all(10),
              ),
              onPressed: () {
                print('普通按钮');
              },
            ),
          ]),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                  onPressed: () {
                    print('图标按钮');
                  },
                  icon: Icon(Icons.search),
                  label: Text('图标按钮')),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            // 通过外层容器设置尺寸大小来控制按钮大小
            children: [
              Container(
                width: 140,
                height: 50,
                child: ElevatedButton(
                  child: Text('设置高宽'),
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.resolveWith(
                      (states) {
                        if (states.contains(MaterialState.pressed)) {
                          //按下时的颜色
                          return Colors.white;
                        }
                        //默认状态使用灰色
                        return Colors.black;
                      },
                    ),
                    backgroundColor: MaterialStateProperty.all(Colors.blue),
                    elevation: MaterialStateProperty.all(10),
                  ),
                  onPressed: () {
                    print('设置宽高');
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  height: 80,
                  margin: EdgeInsets.all(10),
                  child: ElevatedButton(
                    child: Text('自适应宽度按钮'),
                    onPressed: () {
                      print('自适应宽度按钮');
                    },
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      backgroundColor: MaterialStateProperty.all(Colors.black),
                      elevation: MaterialStateProperty.all(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                child: Text('圆角按钮'),
                onPressed: () {
                  print('圆角按钮');
                },
                style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all(Colors.black),
                    backgroundColor: MaterialStateProperty.all(Colors.blue),
                    elevation: MaterialStateProperty.all(10),
                    side: MaterialStateProperty.all(
                        BorderSide(width: 1, color: Color(0xffffffff))), //边框
                    shape: MaterialStateProperty.all(StadiumBorder(
                        side: BorderSide(
                      style: BorderStyle.solid,
                      color: Color(0xffFF7F24),
                    )))),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 80,
                child: ElevatedButton(
                  child: Text('圆形按钮'),
                  onPressed: () {
                    print('圆形按钮');
                  },
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.black12),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      side: MaterialStateProperty.all(
                          BorderSide(width: 1, color: Colors.black)),
                      shape: MaterialStateProperty.all(CircleBorder(
                          side: BorderSide(
                        color: Colors.green,
                        width: 280.0,
                        style: BorderStyle.none,
                      )))),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                child: Text('扁平按钮'),
                onPressed: () {
                  print('扁平按钮');
                },
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                child: Text('边框按钮'),
                onPressed: () {
                  print('边框按钮');
                },
              )
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ButtonBar(
                children: [
                  ElevatedButton(
                    child: Text('按钮组'),
                    onPressed: () {
                      print('按钮组');
                    },
                  ),
                  ElevatedButton(
                    child: Text('按钮组'),
                    onPressed: () {
                      print('按钮组');
                    },
                  ),
                  ElevatedButton(
                    child: Text('按钮组'),
                    onPressed: () {
                      print('按钮组');
                    },
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10),
          MyButton(
              text: '自定义按钮',
              width: 60.0,
              height: 40.0,
              pressed: () {
                print('自定义按钮');
              }),
        ],
      ),
    );
  }
}

class MyButton extends StatelessWidget {
  final text;
  final pressed;
  final width;
  final height;

  const MyButton(
      {this.text = '',
      this.width = 80.0,
      this.height = 30.0,
      this.pressed = 0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: this.width,
      height: this.height,
      child: ElevatedButton(
        child: Text(this.text),
        onPressed: this.pressed,
      ),
    );
  }
}

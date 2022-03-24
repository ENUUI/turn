import 'package:example/pages4/timeline.dart';
import 'package:flutter/material.dart';
import 'package:turn/turn.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Widget _buildButton(String title, VoidCallback onPressed) {
    return GestureDetector(
      onTap: () => onPressed(),
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFE3E3E3),
          border: Border.all(),
          borderRadius: BorderRadius.circular(22.0),
        ),
        child: Text(title),
      ),
    );
  }

  Widget _build0() => _buildButton('将[Map]数据传到下一个页面', () {
        Turn.to(
          context,
          '/page1/page_one',
          params: {
            "title": "接受到的Title",
            "message": "接受到的message",
          },
        );
      });

  Widget _build1() => _buildButton('未注册路由（未注册路由界面可自定义）', () {
        Turn.to(context, '/page1/page_one1');
      });

  Widget _build2() => _buildButton('传递query信息', () {
        Turn.to(context, '/page1/page_one?title=Navigator&message=pushNamed');
      });

  Widget _build3() => _buildButton('接收返回页面数据', () {
        Turn.to(context, '/page1/page_three').then((value) {
          print("接收返回页面数据: $value");
          print(value["name"]);
        });
      });

  Widget _build4() => _buildButton('传递对象参数[Query]', () {
        Turn.to(context, '/page4/timeline',
            express: TimelineQuery('这是从上一个页面传入的参数'));
      });

  Widget _build5() => _buildButton('会被拒绝执行', () {
        Turn.to(context, '/refuse');
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new Container(
          color: Color(0xFFD5DA96),
          padding: EdgeInsets.only(top: 100.0),
          child: ListView(
            padding: EdgeInsets.symmetric(vertical: 40),
            children: [
              _build0(),
              _build1(),
              _build2(),
              _build3(),
              _build4(),
              _build5()
            ],
          )),
    );
  }
}

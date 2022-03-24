import 'package:flutter/material.dart';
import 'package:turn/turn.dart';

class PageOne extends StatelessWidget {
  final Map<String, dynamic>? params;

  PageOne({this.params});

  Widget _buildGoBack(BuildContext context) => GestureDetector(
        onTap: () {
          Turn.pop(context);
        },
        child: _buildButton(Text(
          "点击退出",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.0,
            fontWeight: FontWeight.w300,
            decoration: TextDecoration.none,
            color: Colors.black87,
          ),
        )),
      );

  Widget _buildGoTwo(BuildContext context) => GestureDetector(
        onTap: () {
          Turn.to(context, '/page2/page_two', params: {
            "title": "页面 二",
            "message": "从上个页面来的数据",
          }).then((value) => print(value));
//              Navigator.pushNamed(context, '/page2/page_two');
        },
        child: _buildButton(Text(
          "页面一\ntitle: ${params?["title"] ?? "没有标题"} \n message: ${params?["message"] ?? "没有数据"}\n\n点击跳转到下一个界面",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.0,
            fontWeight: FontWeight.w300,
            decoration: TextDecoration.none,
            color: Colors.black87,
          ),
        )),
      );

  Widget _buildGoHome(BuildContext context) => GestureDetector(
        onTap: () {
          Turn.to(context, '/?name=TurnHome');
        },
        child: _buildButton(Text(
          'Go /',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.0,
            fontWeight: FontWeight.w300,
            decoration: TextDecoration.none,
            color: Colors.black87,
          ),
        )),
      );

  Widget _buildReplaceByHome(BuildContext context) => GestureDetector(
    onTap: () {
      Turn.to(context, '/?name=TurnHome', replace: true);
    },
    child: _buildButton(Text(
      'Replace by /',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 13.0,
        fontWeight: FontWeight.w300,
        decoration: TextDecoration.none,
        color: Colors.black87,
      ),
    )),
  );

  Widget _buildGoAsHome(BuildContext context) => GestureDetector(
    onTap: () {
      Turn.to(context, '/?name=TurnHome', clearStack: true);
    },
    child: _buildButton(Text(
      'Go as /',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 13.0,
        fontWeight: FontWeight.w300,
        decoration: TextDecoration.none,
        color: Colors.black87,
      ),
    )),
  );

  Widget _buildButton(Widget child) => new Container(
        height: 100,
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: Color(0x4d000000),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(width: 0.5),
        ),
        child: child,
      );

  @override
  Widget build(BuildContext context) => Scaffold(
          body: ListView(
        children: [
          _buildGoBack(context),
          _buildGoTwo(context),
          _buildGoHome(context),
          _buildReplaceByHome(context),
          _buildGoAsHome(context),
        ],
      ));
}

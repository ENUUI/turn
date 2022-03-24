import 'package:flutter/material.dart';
import 'package:turn/turn.dart';

class PageTwo extends StatelessWidget {
  final Map<String, dynamic> params;

  PageTwo({this.params});

  @override
  Widget build(BuildContext context) {
    var params = this.params != null ? this.params : {};

    return new Container(
      padding: EdgeInsets.only(top: 100.0),
      color: Color(0xFFFF33FF),
      child: new Center(
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: () {
                Turn.pop(context);
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 50.0),
                child: Text(
                  "点击退出",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w300,
                    decoration: TextDecoration.none,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Turn.to(context, '/page1/page_three', params: {
                  "title": "页面 三",
                  "message": "从上个页面来的数据",
                });
              },
              child: Text(
                "页面二\ntitle: ${params["title"] ?? "没有标题"} \n message: ${params["message"] ?? "没有数据"}\n\n点击跳转到下一个界面",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w300,
                  decoration: TextDecoration.none,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

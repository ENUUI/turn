import 'package:flutter/material.dart';
import 'package:turn/turn.dart';

class PageThree extends StatelessWidget {
  final Map<String, dynamic> params;

  PageThree({
    this.params,
  });

  @override
  Widget build(BuildContext context) {
    var params = this.params != null ? this.params : {};

    return new Container(
      padding: EdgeInsets.only(top: 100.0),
      color: Color(0xFF345638),
      child: new Center(
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: () {
                Turn.pop(context, {"name": "ENUUI"});
//              Navigator.pop(context, {"name": "Jack"});
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
//                Navigator.pushNamed(context, '/page2/page_two');
              },
              child: Text(
                "页面三\ntitle: ${params["title"] ?? "没有数据"} \n message: ${params["message"] ?? "未接收到数据"}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w300,
                  decoration: TextDecoration.none,
                  color: Colors.black87,
                ),
              ),
            ),
            FlatButton(
                onPressed: () {
                  var result = Mediator.perform("/page2/get_data");
                  print("从package: page2 获取的数据:\n --------- $result");
                },
                child: Text(
                  "点击获取 package: page2 的数据。",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w300,
                    decoration: TextDecoration.none,
                    color: Colors.black87,
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

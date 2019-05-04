import 'package:flutter/material.dart';
import 'package:turn/turn.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new Container(
        color: Color(0xFFD5DA96),
        padding: EdgeInsets.only(top: 100.0),
        child: new Center(
          child: Column(
            children: <Widget>[
              new Padding(
                padding: EdgeInsets.only(bottom: 50.0),
                child: new Text(
                  "TURN",
                  style: TextStyle(
                      color: Color(0xFFFF3333),
                      fontWeight: FontWeight.w600,
                      fontSize: 55.0,
                      letterSpacing: 5.0,
                      fontStyle: FontStyle.italic,
                      shadows: [
                        Shadow(
                          color: const Color(0xFF339933),
                          offset: Offset(2.0, 0.0),
                          blurRadius: 3.0,
                        ),
                        Shadow(
                          color: const Color(0xFF339933),
                          offset: Offset(-2.0, 0.0),
                          blurRadius: 3.0,
                        ),
                      ]),
                ),
              ),
              new FlatButton(
                  onPressed: () {
                    Turn.to(context, 'page1/page_one', params: {
                      "title": "接收数据页面",
                      "message": "接收到的信息",
                    });
                  },
                  child: Text("将数据传到下一个页面")),
              new FlatButton(
                  onPressed: () {
                    // 点击去了没有注册的界面
                    Turn.to(context, 'page1/page_one1');
                  },
                  child: Text("未注册路由（未注册路由界面可自定义）")),
              new FlatButton(
                  onPressed: () {
                    Navigator.pushNamed(context, 'page1/page_one');
                  },
                  child: Text("使用 Navigator")),
              new FlatButton(
                  onPressed: () {
                    Turn.to(context, 'page1/page_three').then((value) {
                      print("接收返回页面数据: $value");
                      print(value["name"]);
                    });
                  },
                  child: Text("接收返回页面数据")),
            ],
          ),
        ),
      ),
    );
  }
}

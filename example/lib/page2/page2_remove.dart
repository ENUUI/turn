import 'package:flutter/material.dart';
import 'package:turn/turn.dart';

class Page2Remove extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          FlatButton(
            onPressed: () {
              Turn.to(context, '/page1/page_one', clearStack: true);
            },
            child: new Text("Next And Clear"),
          ),
        ],
      ),
    );
  }
}

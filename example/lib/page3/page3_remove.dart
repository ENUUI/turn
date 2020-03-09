import 'package:flutter/material.dart';
import 'package:turn/turn.dart';

class Pages3Remove extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          child: AppBar(
            title: Text("Remove"),
          ),
          preferredSize: Size.fromHeight(44.0)),
      body: new Center(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new FlatButton(
              onPressed: () {
                Turn.to(context, '/action_three/page_t2', clearStack: true);
              },
              child: Text('CLEAR'),
            ),
            new FlatButton(
              onPressed: () {
                Turn.to(context, '/action_three/page_t2', replace: true);
              },
              child: Text('REPLACE'),
            )
          ],
        ),
      ),
    );
  }
}

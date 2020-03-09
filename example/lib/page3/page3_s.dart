import 'package:flutter/material.dart';
import 'package:turn/turn.dart';

class PageT1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          child: AppBar(
            title: Text("1"),
          ),
          preferredSize: Size.fromHeight(44.0)),
      body: new Center(
        child: new FlatButton(
          onPressed: () {
            Turn.to(context, '/action_three/page_t2');
          },
          child: Text('NEXT'),
        ),
      ),
    );
  }
}

class PageT2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          child: AppBar(
            title: Text("2"),
          ),
          preferredSize: Size.fromHeight(44.0)),
      body: new Center(
        child: new FlatButton(
          onPressed: () {
            Turn.to(context, '/action_three/page_t3');
          },
          child: Text('NEXT'),
        ),
      ),
    );
  }
}

class PageT3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          child: AppBar(
            title: Text("3"),
          ),
          preferredSize: Size.fromHeight(44.0)),
      body: new Center(
        child: new FlatButton(
          onPressed: () {
            Turn.to(context, '/action_three/page_t4');
          },
          child: Text('NEXT'),
        ),
      ),
    );
  }
}

class PageT4 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          child: AppBar(
            title: Text("4"),
          ),
          preferredSize: Size.fromHeight(44.0)),
      body: new Center(
        child: new FlatButton(
          onPressed: () {
            Turn.to(context, '/action_three/page_t5');
          },
          child: Text('NEXT'),
        ),
      ),
    );
  }
}

class PageT5 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          child: AppBar(
            title: Text("5"),
          ),
          preferredSize: Size.fromHeight(44.0)),
      body: new Center(
        child: new FlatButton(
          onPressed: () {
            Turn.to(context, '/action_three/page_t6');
          },
          child: Text('NEXT'),
        ),
      ),
    );
  }
}

class PageT6 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          child: AppBar(
            title: Text("6"),
          ),
          preferredSize: Size.fromHeight(44.0)),
      body: new Center(
        child: new FlatButton(
          onPressed: () {
            Turn.to(context, '/action_three/page_remove');
          },
          child: Text('NEXT'),
        ),
      ),
    );
  }
}

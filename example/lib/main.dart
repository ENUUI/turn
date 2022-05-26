import 'package:example/home.dart';
import 'package:flutter/material.dart';
import 'package:turn/turn.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Example",
      home: Home(),
    );
  }
}

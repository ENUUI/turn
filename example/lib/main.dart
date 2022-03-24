import 'package:flutter/material.dart';
import 'config/targets.dart' as Targets;
import 'package:turn/turn.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  _MyAppState() {
    Targets.registerTargets();

    var one = '/common/product/name';
    var result = one.split('/');
    print(result);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Example",
      navigatorObservers: [turnOb],
      onGenerateRoute: Turn.generator,
    );
  }
}

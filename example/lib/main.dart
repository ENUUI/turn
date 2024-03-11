import 'dart:async';

import 'package:example/routes/route.dart';
import 'package:flutter/material.dart';
import 'package:turn/turn.dart';

void main() {
  runZonedGuarded(() {
    initAppRoute();
    runApp(const MyApp());
  }, (err, s) {});
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Example",
      onGenerateRoute: Turn.generator,
      navigatorObservers: [TurnObserver()],
    );
  }
}

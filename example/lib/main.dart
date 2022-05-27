import 'dart:async';

import 'package:example/routes/route.dart';
import 'package:flutter/material.dart';

void main() {
  runZonedGuarded(() {
    initAppRoute();
    runApp(MyApp());
  }, (err, s) {});
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Example",
      onGenerateRoute: AppRoute.I.generator,
    );
  }
}

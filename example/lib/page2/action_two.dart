import 'page2.dart';
import 'package:turn/turn.dart';
import 'package:flutter/material.dart';

class ActionTwo extends Target {
  @override
  String get targetName => "page2";

  @override
  Widget task(String action, Map<String, dynamic> params) {
    if (action == "/${targetName}/page_two") {
      return PageTwo(
        params: params,
      );
    }
    return null;
  }
}

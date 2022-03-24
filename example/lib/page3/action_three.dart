import 'package:flutter/material.dart';
import 'package:turn/turn.dart';
import 'page3_s.dart';
import 'page3_remove.dart';

class ActionThree extends Target {
  @override
  response(BuildContext? context, Options options) {
    switch (options.path) {
      case '/action_three/page_t1':
        return PageT1();
      case '/action_three/page_t2':
        return PageT2();
      case '/action_three/page_t3':
        return PageT3();
      case '/action_three/page_t4':
        return PageT4();
      case '/action_three/page_t5':
        return PageT5();
      case '/action_three/page_t6':
        return PageT6();
      case '/action_three/page_remove':
        return Pages3Remove();
    }
    return null;
  }
}

class RouteModule4 extends RouteModule {
  @override
  List<Target> get targets => [ActionThree()];
}

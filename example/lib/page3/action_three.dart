import 'package:turn/turn.dart';
import 'page3_s.dart';
import 'page3_remove.dart';
class ActionThree extends Target {
  @override
  String get targetName => 'action_three';

  @override
  task(String action, Map<String, dynamic> params) {
    switch (action) {
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


import 'page2.dart';
import 'package:turn/turn.dart';

class ActionTwo extends Target {
  @override
  String get targetName => "page2";

  @override
  dynamic task(String action, Map<String, dynamic> params) {
    if (action == "/${targetName}/page_two") {
      return PageTwo(
        params: params,
      );
    } else if (action == "/${targetName}/get_data") {
      return "这是一条来自 page2 的消息。";
    }
    return null;
  }
}

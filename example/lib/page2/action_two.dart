import 'page2.dart';
import 'package:turn/turn.dart';

class ActionTwo extends Target {
  @override
  String get targeName => "page2";

  @override
  Widget task(String action, Map<String, dynamic> params) {
    if (action == "${targeName}/page_two") {
      return PageTwo(
        params: params,
      );
    }
  }
}

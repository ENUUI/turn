import 'package:flutter/material.dart';

import 'page2.dart';
import 'package:turn/turn.dart';

class ActionTwo extends Target {
  @override
  response(BuildContext context, Options options) {
    final action = options.path;
    if (action == "/page2/page_two") {
      return PageTwo(
        params: options.express.extraQuery,
      );
    } else if (action == "/page2/get_data") {
      return "这是一条来自 page2 的消息。";
    }
    return null;
  }
}

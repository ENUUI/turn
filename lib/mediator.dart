/**
 * ProjectName: turn
 * FileName: mediator
 * Author: ENUUI
 * Date: 2019/4/30 4:50 PM
 * Copyright (c) 2019 ENUUI. All rights reserved.
 */


import 'package:flutter/widgets.dart';
export 'package:flutter/widgets.dart';

abstract class Target {
  String get targeName;

  Widget task(String action, Map<String, dynamic> params);
}

class Mediator {
  static Widget Function(String action) notFound;
  static var _mediatorTarget = Map<String, Target>();

  static Widget Function() rootPage;

  static registerTarget({
    @required Target target,
  }) {
    assert(target != null && target != null);
    assert(target.targeName != null);
    _mediatorTarget[target.targeName] = target;
  }

  static Widget perform(String action, {Map<String, dynamic> params}) {
    var result = _perform(action, params);

    if (result == null && notFound != null) {
      return notFound(action);
    }

    return result;
  }

  /// ------ private
  static Widget _perform(String action, params) {
    if (action == null || action.length == 0) return null;

    if (action == "/") {
      return rootPage();
    }

    List<String> result = _resolveAction(action);

    // 没有找到 targetName
    if (result == null) return null;

    var taget = _mediatorTarget[result[0]];
    // 没有找到 target
    if (taget == null) return null;

    return taget.task(result[1], params);
  }

  static _resolveAction(String action) {
    int targetLen = action.indexOf('/', 0);
    if (targetLen < 0) return null;

    var targetName = action.substring(0, targetLen);

    return [targetName, action];
  }
}

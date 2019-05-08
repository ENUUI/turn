/// ProjectName: turn
/// FileName: mediator
/// Author: ENUUI
/// Date: 2019/4/30 4:50 PM
/// Copyright (c) 2019 ENUUI. All rights reserved.


abstract class Target {
  String get targeName;

  dynamic task(String action, Map<String, dynamic> params);
}

class Mediator {
  static dynamic Function(String action) notFound;
  static var _mediatorTarget = Map<String, Target>();

  static dynamic Function(Map<String, dynamic>) rootPage; // '/'

  static registerTarget({
    Target target,
  }) {
    assert(target != null && target != null);
    assert(target.targeName != null);
    _mediatorTarget[target.targeName] = target;
  }

  static dynamic perform(String action, {Map<String, dynamic> params}) {
    var result = _perform(action, params);

    if (result == null && notFound != null) {
      return notFound(action);
    }

    return result;
  }

  /// ------ private
  static dynamic _perform(String action, params) {
    if (action == null || action.length == 0) return null;

    if (action == "/") {
      if (rootPage != null) {
        return rootPage(params);
      } else {
        return null;
      }
    }

    return _resolveAction(action, params);
  }

  static dynamic _resolveAction(String action, Map<String, dynamic> params) {
    List<String> patterns = action.split('/');

    if (patterns == null || patterns.length == 0) {
      return null;
    }

    var targetName = '';

    if (patterns.length == 1) {
      targetName = action;
    }

    var targetIndex = 0;
    if (patterns[0].length == 0) {
      targetIndex = 1;
    }
    targetName = patterns[targetIndex];

    var taget = _mediatorTarget[targetName];
    // not found any target.
    if (taget == null) return null;

    return taget.task(action, params);
  }
}

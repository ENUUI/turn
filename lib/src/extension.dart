import 'package:flutter/material.dart';
import 'package:turn/src/turn.dart';

import 'transition_mode.dart';

extension ContextTurnExtension on BuildContext {
  Future turn(
    String path, {
    bool? rootNavigator,
    dynamic data,
    TransitionMode? mode,
    Object? result,
    String? package,
    bool fallthrough = true,
    bool replace = false,
    bool removeUntil = false,
    RoutePredicate? routePredicate,
  }) {
    return Turn.to(
      this,
      path,
      data: data,
      mode: mode,
      result: result,
      package: package,
      fallthrough: fallthrough,
      replace: replace,
      removeUntil: removeUntil,
      routePredicate: routePredicate,
    );
  }
}

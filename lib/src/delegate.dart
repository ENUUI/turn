import 'package:flutter/material.dart';

import 'argument.dart';
import 'transition_mode.dart';
import 'tree.dart';

abstract class TurnDelegate {
  /// 404 page
  WidgetBuilder? notFoundPage(BuildContext context, String route, Object? data) => null;

  /// Called immediately after the route address is found.
  /// If null is returned, [Turn.to] continues.
  /// Otherwise,
  ///   [Turn.to] will directly return the return value of this method.
  Future? willTurnTo(
    BuildContext context,
    TurnRoute turnRoute,
    Arguments arguments, {
    bool rootNavigator = false,
    TransitionMode? mode,
    Object? result,
    bool isReplace = false,
    bool isRemoveUntil = false,
    RoutePredicate? routePredicate,
  }) {
    return null;
  }

  /// It will not block [Turn.to] unless an exception is thrown.
  Future beforeTurnTo(
    BuildContext context,
    TurnRoute turnRoute,
    Arguments arguments,
  ) {
    return Future.value();
  }

  /// Called after [NavigatorState.pushAndRemoveUntil]/[NavigatorState.pushReplacement]/[NavigatorState.push] returns.
  /// If you want to change the return value of a route, do it here.
  Future turnCompleted(
    BuildContext context,
    Object? result,
    TurnRoute turnRoute,
    Arguments arguments,
  ) {
    return Future.value(result);
  }
}

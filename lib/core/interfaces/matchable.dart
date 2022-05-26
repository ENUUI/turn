import 'package:flutter/material.dart';

import '../routes/argument.dart';
import '../routes/transition_mode.dart';
import '../routes/tree.dart';
import '../routes/navigator_to.dart';

abstract class Matchable {
  void registerRoute(TurnRoute route);

  late final NavigatorTo navigatorTo = NavigatorTo(this);

  MatchResult? matchRoute(
    String route, {
    String? package,
    bool fallthrough = true,
  });

  WidgetBuilder? notFoundPage(
    BuildContext context,
    String routePath,
    Object? data,
  ) =>
      null;

  /// 在路由地址被找到后立即调用
  /// 如果返回null，正常[Turn.to()]
  /// 否则
  ///   [to] / [replace] / [toUntil] 将会被拦截
  /// 且以下方法都不会被调用
  ///   [willTransitionPage] / [shouldTransitionRoute]
  Future<T?>? willTurnTo<T extends Object?, TO extends Object?>(
    BuildContext context,
    TurnRoute turnRoute,
    Arguments arguments, {
    TransitionMode? mode,
    TO? result,
    bool isReplace = false,
    bool isRemoveUntil = false,
    RoutePredicate? routePredicate,
  }) =>
      null;

  Future<T?> turnCompleted<T extends Object?>(
    T? result,
    TurnRoute turnRoute,
    Arguments arguments,
  ) {
    return Future.value(result);
  }
}

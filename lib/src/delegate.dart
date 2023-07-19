import 'package:flutter/material.dart';

import 'argument.dart';
import 'transition_mode.dart';
import 'tree.dart';

abstract class TurnDelegate {
  WidgetBuilder? notFoundPage(BuildContext context, String route, Object? data) => null;
  /// 在路由地址被找到后立即调用
  /// 如果返回null，正常[Turn.to()]
  /// 否则
  ///   [to] / [replace] / [toUntil] 将会被拦截
  /// 且以下方法都不会被调用
  ///   [willTransitionPage] / [shouldTransitionRoute]
  /// 如果有对应的package，则会先尝试子module去执行
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

  /// 不会阻断最终push，除非 [beforeTurnTo] 抛出异常 转成英语
  Future beforeTureTo(
    BuildContext context,
    TurnRoute turnRoute,
    Arguments arguments,
  ) {
    return Future.value();
  }

  /// 在当前 push 事件结束后调用
  Future turnCompleted(
    BuildContext context,
    Object? result,
    TurnRoute turnRoute,
    Arguments arguments,
  ) {
    return Future.value(result);
  }
}

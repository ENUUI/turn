import 'package:flutter/material.dart';
import 'package:turn/src/worker.dart';

import 'transition_mode.dart';

class Turn {
  Turn._();

  static final TurnWorker worker = TurnWorker();

  static void pop<T extends Object>(BuildContext context, [T? result]) => Navigator.pop<T>(context, result);

  static Future<bool> maybePop<T extends Object>(BuildContext context, [T? result]) =>
      Navigator.maybePop<T>(context, result);

  static void popUntil(BuildContext context, String router) =>
      Navigator.popUntil(context, (route) => route.settings.name == router);

  static bool canPop(BuildContext context) => Navigator.canPop(context);

  static NavigatorState of(BuildContext context, {bool rootNavigator = false}) =>
      Navigator.of(context, rootNavigator: rootNavigator);

  static Future to(
    BuildContext context,
    String path, {
    bool? rootNavigator,
    dynamic data,
    TransitionMode? mode,
    Object? result,
    String? package,
    bool fallthrough = true,
    bool isReplace = false,
    bool isRemoveUntil = false,
    RoutePredicate? routePredicate,
  }) =>
      worker.to(
        context,
        path,
        rootNavigator: rootNavigator,
        data: data,
        mode: mode,
        result: result,
        package: package,
        fallthrough: fallthrough,
        isReplace: isReplace,
        isRemoveUntil: isRemoveUntil,
        routePredicate: routePredicate,
      );

  static Route<dynamic> generator(RouteSettings routeSettings) => worker.generator(routeSettings);
}

import 'package:flutter/material.dart';
import 'package:turn/core/extensions/navigateable.dart';
import 'package:turn/src/turn_deprecated.dart';
import '../core/interfaces/navigateable.dart';
import '../core/routes/navigator_to.dart';
import '../core/routes/transition_mode.dart';

class Turn {
  static Project get project {
    if (_project == null) {
      throw FlutterError('Set an instance of Project before use.');
    }
    return _project!;
  }

  static NavigatorTo get navigatorTo => project.navigatorTo;

  static Project? _project;

  static void setProject(Project project) {
    _project = project;
  }

  static void pop<T extends Object>(BuildContext context, [T? result]) =>
      project.pop<T>(context, result);

  static Future<bool> maybePop<T extends Object>(BuildContext context,
          [T? result]) =>
      project.maybePop<T>(context, result);

  static void popUntil(BuildContext context, String action) =>
      project.popUntil(context, action);

  static bool canPop(BuildContext context) => project.canPop(context);

  static Future to(
    BuildContext context,
    String action, {
    String? package,
    Object? data,
    bool replace = false,
    bool clearStack = false,
    TransitionMode? transitionMode,
    RoutePredicate? predicate, // clearStack = true
    @Deprecated('Use [TransitionMode] instead') TransitionType? transition,
    @Deprecated('Use [data] instead') Map<String, dynamic>? params,
    @Deprecated('Use [data] instead') Express? express,
    @Deprecated('Use [TransitionMode] instead')
        RouteTransitionsBuilder? transitionBuilder,
    @Deprecated('Use [TransitionMode] instead')
        Duration duration = const Duration(milliseconds: 250),
    @Deprecated('Use [TransitionMode] instead')
        TurnRouteBuilder? turnRouteBuilder,
  }) async {
    TransitionMode mode = transitionMode ??
        transition?.convertTo(
          transitionsBuilder: transitionBuilder,
          context: context,
          routeBuilder: turnRouteBuilder,
        ) ??
        TransitionMode.native;
    if (replace) {
      return project.replace(
        context,
        action,
        data: data ?? params ?? express,
        package: package,
        fallthrough: true,
        transitionMode: mode,
      );
    } else if (clearStack) {
      return project.pushUntil(
        context,
        action,
        data: data ?? params ?? express,
        package: package,
        fallthrough: true,
        transitionMode: mode,
        routePredicate: predicate,
      );
    } else {
      return project.push(
        context,
        action,
        data: data ?? params ?? express,
        package: package,
        fallthrough: true,
        transitionMode: mode,
      );
    }
  }

  static Route<dynamic> generator(RouteSettings routeSettings) {
    return project.generator(routeSettings);
  }
}

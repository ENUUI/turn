import 'dart:async';
import 'package:flutter/material.dart';
import 'package:turn/src/express.dart';
import 'package:turn/src/turn.dart';
import '../core/routes/navigator_to.dart';
import '../core/interfaces/project.dart';
import '../core/routes/transition_mode.dart';
import '../core/extensions/transition_type.dart';

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
      navigatorTo.pop<T>(context, result);

  static Future<bool> maybePop<T extends Object>(BuildContext context,
          [T? result]) =>
      navigatorTo.maybePop<T>(context, result);

  static void popUntil(BuildContext context, String action) =>
      navigatorTo.popUntil(context, action);

  static bool canPop(BuildContext context) => navigatorTo.canPop(context);

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
      return navigatorTo.replace(
        context,
        action,
        data: data ?? params ?? express,
        package: package,
        fallthrough: true,
        transitionMode: mode,
      );
    } else if (clearStack) {
      return navigatorTo.pushUntil(
        context,
        action,
        data: data ?? params ?? express,
        package: package,
        fallthrough: true,
        transitionMode: mode,
        routePredicate: predicate,
      );
    } else {
      return navigatorTo.push(
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

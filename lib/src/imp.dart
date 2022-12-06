import 'package:flutter/material.dart';
import 'package:turn/core/extensions/navigateable.dart';
import 'package:turn/src/turn_deprecated.dart';
import '../core/interfaces/navigateable.dart';
import '../core/routes/navigator_to.dart';
import '../core/routes/transition_mode.dart';

class Turn {
  static TurnTo get turnTo {
    if (_turnTo == null) {
      throw FlutterError('Set an instance of Project before use.');
    }
    return _turnTo!;
  }

  static TurnTo? _turnTo;

  static NavigatorTo get _navigatorTo => turnTo.navigatorTo;

  static void setProject(TurnTo project) {
    _turnTo = project;
  }

  static void pop<T extends Object>(BuildContext context, [T? result]) => _navigatorTo.pop<T>(context, result);

  static Future<bool> maybePop<T extends Object>(BuildContext context, [T? result]) =>
      _navigatorTo.maybePop<T>(context, result);

  static void popUntil(BuildContext context, String action) => _navigatorTo.popUntil(context, action);

  static bool canPop(BuildContext context) => _navigatorTo.canPop(context);

  static void rootPop<T extends Object>(BuildContext context, {bool rootNavigator = false, T? result}) =>
      _navigatorTo.rootPop<T>(context, rootNavigator: rootNavigator, result: result);

  static Future<bool> rootMaybePop<T extends Object>(BuildContext context, {bool rootNavigator = false, T? result}) =>
      _navigatorTo.rootMaybePop(context, rootNavigator: rootNavigator, result: result);

  static void rootPopUntil(BuildContext context, String action, {bool rootNavigator = false, String? package}) =>
      _navigatorTo.popUntil(context, action, rootNavigator: rootNavigator, package: package);

  static bool rootCanPop(BuildContext context, {bool rootNavigator = false}) =>
      _navigatorTo.canPop(context, rootNavigator: rootNavigator);

  static Future to(
    BuildContext context,
    String action, {
    String? package,
    Object? data,
    bool replace = false,
    bool clearStack = false,
    TransitionMode? transitionMode,
    bool? rootNavigator,
    RoutePredicate? predicate, // clearStack = true
    @Deprecated('Use [TransitionMode] instead') TransitionType? transition,
    @Deprecated('Use [data] instead') Map<String, dynamic>? params,
    @Deprecated('Use [data] instead') Express? express,
    @Deprecated('Use [TransitionMode] instead') RouteTransitionsBuilder? transitionBuilder,
    @Deprecated('Use [TransitionMode] instead') Duration duration = const Duration(milliseconds: 250),
    @Deprecated('Use [TransitionMode] instead') TurnRouteBuilder? turnRouteBuilder,
  }) async {
    final mode = transitionMode ??
        transition?.convertTo(
          transitionsBuilder: transitionBuilder,
          context: context,
          routeBuilder: turnRouteBuilder,
        );
    if (replace) {
      return _navigatorTo.replace(
        context,
        action,
        rootNavigator: rootNavigator,
        data: data ?? params ?? express,
        package: package,
        fallthrough: true,
        transitionMode: mode,
      );
    } else if (clearStack) {
      return _navigatorTo.pushUntil(
        context,
        action,
        rootNavigator: rootNavigator,
        data: data ?? params ?? express,
        package: package,
        fallthrough: true,
        transitionMode: mode,
        routePredicate: predicate,
      );
    } else {
      return _navigatorTo.push(
        context,
        action,
        rootNavigator: rootNavigator,
        data: data ?? params ?? express,
        package: package,
        fallthrough: true,
        transitionMode: mode,
      );
    }
  }

  static Route<dynamic> generator(RouteSettings routeSettings) {
    return turnTo.generator(routeSettings);
  }
}

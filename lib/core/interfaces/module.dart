import 'package:flutter/material.dart';

import '../../src/express.dart';
import '../../src/turn.dart';
import '../extensions/transition_type.dart';
import '../routes/transition_mode.dart';
import '../routes/tree.dart';
import 'matchable.dart';
import 'project.dart';

abstract class Module extends Matchable {
  String get package;

  Project get parent;

  @override
  void registerRoute(TurnRoute route) {
    parent.registerRoute(route, package: package);
  }

  @override
  MatchResult? matchRoute(
    String route, {
    String? package,
    bool fallthrough = true,
  }) =>
      matchPath(RoutePath.fromPath(
        route,
        package: package ?? this.package,
        fallthrough: fallthrough,
      ));

  @override
  MatchResult? matchPath(RoutePath path) {
    return parent.matchPath(path);
  }

  @override
  WidgetBuilder? notFoundPage<T extends Object?>(
      BuildContext context, String path, Object? data) {
    return parent.notFoundPage(context, path, data);
  }

  @Deprecated('Use [push] [pushUntil] [replace] instead')
  Future to(
    BuildContext context,
    String action, {
    String? package,
    @Deprecated('Use [data] instead') Map<String, dynamic>? params,
    @Deprecated('Use [data] instead') Express? express,
    Object? data,
    bool replace = false,
    bool clearStack = false,
    @Deprecated('Use [TransitionMode] instead') TransitionType? transition,
    TransitionMode? transitionMode,
    @Deprecated('Use [TransitionMode] instead')
        RouteTransitionsBuilder? transitionBuilder,
    @Deprecated('Use [TransitionMode] instead')
        Duration duration = const Duration(milliseconds: 250),
    @Deprecated('Use [TransitionMode] instead')
        TurnRouteBuilder? turnRouteBuilder,
    RoutePredicate? predicate, // clearStack = true
  }) async {
    TransitionMode mode = transitionMode ??
        transition?.convertTo(
          transitionsBuilder: transitionBuilder,
          context: context,
          routeBuilder: turnRouteBuilder,
        ) ??
        TransitionMode.native;
    if (replace) {
      return parent.replace(
        context,
        action,
        data: data ?? params ?? express,
        package: package,
        fallthrough: true,
        transitionMode: mode,
      );
    } else if (clearStack) {
      return parent.pushUntil(
        context,
        action,
        data: data ?? params ?? express,
        package: package,
        fallthrough: true,
        transitionMode: mode,
        routePredicate: predicate,
      );
    } else {
      return parent.push(
        context,
        action,
        data: data ?? params ?? express,
        package: package,
        fallthrough: true,
        transitionMode: mode,
      );
    }
  }
}

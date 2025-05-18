import 'package:flutter/material.dart';

import 'argument.dart';
import 'transition_mode.dart';
import 'tree.dart';

class Turn {
  Turn._();

  static final RouteTree _routeTree = RouteTree();

  static void addRoute(TurnRoute route) {
    assert(() {
      final package = route.package, path = route.route;
      if (package != null && package.isEmpty) {
        throw ArgumentError.value(package, 'package', 'if package is not null, package cannot be empty.');
      }
      if (path.isEmpty) {
        throw ArgumentError.value(path, 'path', 'path cannot be empty');
      }
      return true;
    }());
    _routeTree.addRoute(route);
  }

  /// Page not found.
  static WidgetBuilder Function(BuildContext context, String path, dynamic data)? notFoundPage;

  /// It will not block [Turn.to] unless an exception is thrown.
  static Future<void> Function(BuildContext context, TurnRoute route, dynamic data)? beforeTureTo;

  /// Called after [NavigatorState.pushAndRemoveUntil]/[NavigatorState.pushReplacement]/[NavigatorState.push] returns.
  /// If you want to change the return value of a route, do it here.
  static Future<void> Function(BuildContext context, Object? result, TurnRoute turnRoute, Arguments arguments)?
      turnCompleted;

  static NavigatorState of(BuildContext context, {bool rootNavigator = false}) =>
      Navigator.of(context, rootNavigator: rootNavigator);

  /// Turn to the given route onto the navigator.
  ///
  /// - [path]: The path of the route to turn to .
  /// - [rootNavigator]: If `rootNavigator` is set to true, the state from the furthest instance of
  ///     this class is given instead. Useful for pushing contents above all
  ///     subsequent instances of [Navigator].
  /// - [data]: The data to pass to the route.
  /// - [mode]: The route's transition.
  /// - [result]: When [replace] is true, it will be returned to the previous page.
  /// - [package]: The package of the route to turn to.
  /// - [fallthrough]: If the route is not found, whether to continue to find the route in the other package.
  /// - [replace]: [NavigatorState.pushReplacement] .
  /// - [removeUntil/routePredicate]: [NavigatorState.pushAndRemoveUntil].
  static Future to(
    BuildContext context,
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
  }) async {
    final matchResult = _routeTree.matchRoute(path, package: package, fallthrough: fallthrough);
    if (matchResult == null) {
      final page404Builder = notFoundPage?.call(context, path, data);
      if (page404Builder != null) {
        mode ??= TransitionMode.native;
        return Navigator.push(context, mode.generator(page404Builder, RouteSettings()));
      }
      return Future.error(FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('Page not found.'),
        ErrorDescription('path: $path, data: $data'),
      ]));
    }

    final useRoute = matchResult.route;
    final arguments = Arguments(useRoute.route, data: data, params: matchResult.params);
    final useRootNavigator = rootNavigator ?? useRoute.rootNavigator ?? false;

    await beforeTureTo?.call(context, useRoute, arguments);
    final route = _createRoute(useRoute, arguments, mode);

    dynamic pushResult;
    final navigatorState = Navigator.of(
      context,
      rootNavigator: useRootNavigator,
    );

    if (removeUntil) {
      pushResult = await navigatorState.pushAndRemoveUntil(
        route,
        routePredicate ?? (r) => false,
      );
    } else if (replace) {
      pushResult = await navigatorState.pushReplacement(route, result: result);
    } else {
      pushResult = await navigatorState.push(route);
    }
    final turnCompleted = Turn.turnCompleted;
    if (turnCompleted != null) {
      return turnCompleted(context, pushResult, useRoute, arguments);
    }
    return pushResult;
  }

  static Route<T> _createRoute<T extends Object?>(
    TurnRoute turnRoute,
    Arguments arguments,
    TransitionMode? mode,
  ) {
    mode ??= turnRoute.transitionMode ?? TransitionMode.native;
    return mode.generator<T>(
      (context) => turnRoute.builder(context, arguments),
      RouteSettings(
        name: turnRoute.route,
        arguments: arguments,
      ),
    );
  }

  /// Pop
  static void pop<T extends Object>(BuildContext context, [T? result]) => Navigator.pop<T>(context, result);

  /// maybePop
  static Future<bool> maybePop<T extends Object>(BuildContext context, [T? result]) =>
      Navigator.maybePop<T>(context, result);

  /// popUntil
  static void popUntil(BuildContext context, String router) =>
      Navigator.popUntil(context, (route) => route.settings.name == router);

  /// canPop
  static bool canPop(BuildContext context) => Navigator.canPop(context);

  /// generator
  static Route<dynamic> generator(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments;
    final name = routeSettings.name ?? '';
    final matchResult = _routeTree.matchRoute(name);

    if (matchResult == null) {
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (BuildContext context) {
          final page404Builder = notFoundPage?.call(context, '', arguments);
          if (page404Builder != null) return page404Builder(context);
          assert(() {
            throw FlutterError.fromParts(<DiagnosticsNode>[
              ErrorSummary('Page Not Found!'),
              ErrorDescription('routePath: $name, arguments: $arguments')
            ]);
          }());
          return const Scaffold();
        },
      );
    }

    final useRoute = matchResult.route;
    final args = Arguments(
      useRoute.route,
      data: arguments,
      params: matchResult.params,
    );
    return _createRoute(
      useRoute,
      args,
      useRoute.transitionMode ?? TransitionMode.native,
    );
  }
}
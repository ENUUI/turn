import 'package:flutter/material.dart';

import 'argument.dart';
import 'delegate.dart';
import 'transition_mode.dart';
import 'tree.dart';

class Turn {
  Turn._();

  static final _Navigation _nav = _Navigation();

  static _Worker get _worker {
    __worker ??= _Worker._(_nav);
    return __worker!;
  }

  static _Worker? __worker;

  static void addRoute(TurnRoute route) {
    _nav.addRoute(route);
  }

  static void setDelegate(TurnDelegate? delegate) {
    _nav.setDelegate(delegate);
  }

  /// Return a instance of [Turnable]
  /// - if [package] is null, will return the default instance of [Turnable].
  /// - if [package] is not null, will return a new instance of [Turnable].
  ///   When calling [Turnable.to], the routes set for this [package] will be prioritized
  ///   unless a different [package] is passed when calling [Turnable.to].
  static Turnable turn({String? package}) {
    if (package == null || package.isEmpty) {
      return _worker;
    }
    return _Worker._(_nav, package: package);
  }

  static void pop<T extends Object>(BuildContext context, [T? result]) => Navigator.pop<T>(context, result);

  static Future<bool> maybePop<T extends Object>(BuildContext context, [T? result]) =>
      Navigator.maybePop<T>(context, result);

  static void popUntil(BuildContext context, String router) =>
      Navigator.popUntil(context, (route) => route.settings.name == router);

  static bool canPop(BuildContext context) => Navigator.canPop(context);

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
  }) =>
      _worker.to(
        context,
        path,
        rootNavigator: rootNavigator,
        data: data,
        mode: mode,
        result: result,
        package: package,
        fallthrough: fallthrough,
        isReplace: replace,
        isRemoveUntil: removeUntil,
        routePredicate: routePredicate,
      );

  static Route<dynamic> generator(RouteSettings routeSettings) => _worker.generator(routeSettings);
}

class _Navigation {
  final RouteTree _routeTree = RouteTree();
  TurnDelegate? delegate;

  void addRoute(TurnRoute route) {
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

  void setDelegate(TurnDelegate? delegate) {
    if (delegate == null) {
      delegate = null;
      return;
    }
    assert(
      this.delegate == null,
      'Only one delegate can be added. '
      'If you want to add multiple delegates, please add them within the delegate you have set.',
    );
    if (this.delegate != null) return;
    this.delegate = delegate;
  }

  MatchResult? matchRoute(
    String route, {
    String? package,
    bool fallthrough = true,
  }) {
    return _routeTree.matchPath(RoutePath.fromPath(
      route,
      package: package,
      fallthrough: fallthrough,
    ));
  }
}

abstract class Turnable {
  Future to(
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
  });
}

class _Worker implements Turnable {
  _Worker._(this._navigation, {this.package});

  final _Navigation _navigation;
  final String? package;

  @override
  Future to(
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
  }) async {
    final matchResult = _navigation.matchRoute(
      path,
      package: package ?? this.package,
      fallthrough: fallthrough,
    );
    if (matchResult == null) {
      final page404Builder = notFoundPage(context, path, data);
      if (page404Builder != null) {
        mode ??= TransitionMode.native;
        return Navigator.push(
            context,
            mode.generator(
              page404Builder,
              RouteSettings(),
            ));
      }
      return Future.error(FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('Page not found.'),
        ErrorDescription('path: $path, data: $data'),
      ]));
    }
    final useRoute = matchResult.route;
    final arguments = Arguments(
      useRoute.route,
      data: data,
      params: matchResult.params,
    );
    final useRootNavigator = rootNavigator ?? useRoute.rootNavigator ?? false;
    final anyFuture = willTurnTo(
      context,
      useRoute,
      arguments,
      rootNavigator: useRootNavigator,
      mode: mode,
      result: result,
      isReplace: isReplace,
      isRemoveUntil: isRemoveUntil,
      routePredicate: routePredicate,
    );

    if (anyFuture != null) return anyFuture;

    await beforeTureTo(context, useRoute, arguments);
    final route = _createRoute(useRoute, arguments, mode);

    dynamic pushResult;
    final navigatorState = Navigator.of(
      context,
      rootNavigator: useRootNavigator,
    );

    if (isRemoveUntil) {
      pushResult = await navigatorState.pushAndRemoveUntil(
        route,
        routePredicate ?? (r) => false,
      );
    } else if (isReplace) {
      pushResult = await navigatorState.pushReplacement(route, result: result);
    } else {
      pushResult = await navigatorState.push(route);
    }

    return turnCompleted(context, pushResult, useRoute, arguments);
  }

  Route<T> _createRoute<T extends Object?>(
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

  Route<dynamic> generator(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments;
    final name = routeSettings.name ?? '';
    final matchResult = _navigation.matchRoute(name);

    if (matchResult == null) {
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (BuildContext context) {
          final page404Builder = notFoundPage(context, '', arguments);
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

extension on _Worker {
  WidgetBuilder? notFoundPage(BuildContext context, String route, Object? data) {
    return _navigation.delegate?.notFoundPage(context, route, data);
  }

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
    return _navigation.delegate?.willTurnTo(
      context,
      turnRoute,
      arguments,
      rootNavigator: rootNavigator,
      mode: mode,
      result: result,
      isReplace: isReplace,
      isRemoveUntil: isRemoveUntil,
      routePredicate: routePredicate,
    );
  }

  Future beforeTureTo(
    BuildContext context,
    TurnRoute turnRoute,
    Arguments arguments,
  ) {
    return _navigation.delegate?.beforeTurnTo(
          context,
          turnRoute,
          arguments,
        ) ??
        Future.value();
  }

  /// 在当前 push 事件结束后调用
  Future turnCompleted(
    BuildContext context,
    Object? result,
    TurnRoute turnRoute,
    Arguments arguments,
  ) {
    return _navigation.delegate?.turnCompleted(
          context,
          result,
          turnRoute,
          arguments,
        ) ??
        Future.value(result);
  }
}

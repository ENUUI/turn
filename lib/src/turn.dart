import 'package:flutter/material.dart';

import 'argument.dart';
import 'delegate.dart';
import 'transition_mode.dart';
import 'tree.dart';

class Turn {
  Turn._();

  static final _Worker worker = _Worker();

  static void addRoute(TurnRoute route) {
    worker.addRoute(route);
  }

  static void addDelegate(TurnDelegate delegate) {
    worker.addDelegate(delegate);
  }

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

class _Worker {
  final RouteTree _routeTree = RouteTree();

  TurnDelegate? _delegates;

  void addRoute(TurnRoute route) {
    _routeTree.addRoute(route);
  }

  void addDelegate(TurnDelegate delegate) {
    assert(
      _delegates == null,
      'Only one delegate can be added. '
      'If you want to add multiple delegates, please add them within the delegate you have set.',
    );
    if (_delegates != null) return;
    _delegates = delegate;
  }

  void removeDelegate() {
    _delegates = null;
  }

  MatchResult? _matchRoute(
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
    final matchResult = _matchRoute(
      path,
      package: package,
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
    final matchResult = _matchRoute(name);

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
    return _delegates?.notFoundPage(context, route, data);
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
    return _delegates?.willTurnTo(
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
    return _delegates?.beforeTureTo(
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
    return _delegates?.turnCompleted(
          context,
          result,
          turnRoute,
          arguments,
        ) ??
        Future.value(result);
  }
}

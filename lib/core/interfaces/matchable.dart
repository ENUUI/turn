import 'package:flutter/material.dart';

import '../routes/argument.dart';
import '../routes/transition_mode.dart';
import '../routes/tree.dart';

abstract class Matchable {
  void registerRoute(TurnRoute route);

  MatchResult? matchRoute(
    String route, {
    String? package,
    bool fallthrough = true,
  });

  MatchResult? matchPath(RoutePath path);

  Future<T?> push<T extends Object?>(
    BuildContext context,
    String routePath, {
    Object? data,
    String? package,
    bool fallthrough = true,
    TransitionMode? transitionMode,
  }) =>
      _next<T, void>(
        context,
        routePath,
        data: data,
        package: package,
        fallthrough: fallthrough,
        mode: transitionMode,
      );

  Future<T?> pushUntil<T extends Object?>(
    BuildContext context,
    String routePath, {
    Object? data,
    String? package,
    bool fallthrough = true,
    TransitionMode? transitionMode,
    RoutePredicate? routePredicate,
  }) =>
      _next<T, void>(
        context,
        routePath,
        data: data,
        package: package,
        fallthrough: fallthrough,
        mode: transitionMode,
        routePredicate: routePredicate,
        isRemoveUntil: true,
      );

  Future<T?> replace<T extends Object?, TO extends Object?>(
    BuildContext context,
    String routePath, {
    Object? data,
    String? package,
    bool fallthrough = true,
    TransitionMode? transitionMode,
    TO? result,
  }) =>
      _next<T, TO>(
        context,
        routePath,
        data: data,
        package: package,
        fallthrough: fallthrough,
        mode: transitionMode,
        result: result,
        isReplace: true,
      );

  Future<T?> _next<T extends Object?, TO extends Object?>(
    BuildContext context,
    String path, {
    dynamic data,
    TransitionMode? mode,
    TO? result,
    String? package,
    bool fallthrough = true,
    bool isReplace = false,
    bool isRemoveUntil = false,
    RoutePredicate? routePredicate,
  }) async {
    final routePath = RoutePath.fromPath(path);
    final matchResult = matchPath(routePath);
    if (matchResult == null) {
      final page404Builder = notFoundPage(context, routePath.path, data);
      if (page404Builder != null) {
        mode ??= TransitionMode.native;
        return Navigator.push<T>(
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
    final anyFuture = willTurnTo<T, TO>(
      context,
      useRoute,
      arguments,
      mode: mode,
      result: result,
      isReplace: isReplace,
      isRemoveUntil: isRemoveUntil,
      routePredicate: routePredicate,
    );

    if (anyFuture != null) return anyFuture;

    if (await shouldTransitionRoute(context, useRoute, arguments)) {
      return Future.error(FlutterError('Refused by [shouldTransitionRoute]'));
    }

    final route = createRoute<T>(useRoute, arguments, mode);

    T? pushResult;

    if (isRemoveUntil) {
      pushResult = await Navigator.pushAndRemoveUntil<T>(
        context,
        route,
        routePredicate ?? (r) => false,
      );
    } else if (isReplace) {
      pushResult = await Navigator.pushReplacement<T, TO>(context, route,
          result: result);
    } else {
      pushResult = await Navigator.push<T>(context, route);
    }

    return turnCompleted(pushResult, useRoute, arguments);
  }

  Route<T> createRoute<T extends Object?>(
    TurnRoute turnRoute,
    Arguments arguments,
    TransitionMode? mode,
  ) {
    mode ??= turnRoute.transitionMode ?? TransitionMode.native;
    return mode.generator<T>(
      (context) => willTransitionPage(context, turnRoute, arguments),
      RouteSettings(
        name: turnRoute.route,
        arguments: arguments,
      ),
    );
  }

  Future<bool> shouldTransitionRoute(
    BuildContext context,
    TurnRoute turnRoute,
    Arguments arguments,
  ) =>
      Future.value(true);

  Widget willTransitionPage(
    BuildContext context,
    TurnRoute turnRoute,
    Arguments arguments,
  ) {
    return turnRoute.builder(context, arguments);
  }

  WidgetBuilder? notFoundPage<T extends Object?>(
      BuildContext context, String path, Object? data) {
    return null;
  }

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

  /// Pop
  void pop<T extends Object>(BuildContext context, [T? result]) =>
      Navigator.pop<T>(context, result);

  Future<bool> maybePop<T extends Object>(BuildContext context, [T? result]) =>
      Navigator.maybePop<T>(context, result);

  void popUntil(BuildContext context, String routePath, {String? package}) {
    final matchResult = matchRoute(routePath);
    if (matchResult == null) {
      assert(() {
        throw FlutterError('RoutePath($routePath) is invalid!');
      }());
      return;
    }
    Navigator.popUntil(
      context,
      ModalRoute.withName(matchResult.route.route),
    );
  }

  bool canPop(BuildContext context) => Navigator.canPop(context);
}

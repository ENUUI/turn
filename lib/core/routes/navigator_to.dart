import 'package:flutter/material.dart';

import 'argument.dart';
import 'transition_mode.dart';
import 'tree.dart';
import '../interfaces/matchable.dart';

class NavigatorTo {
  NavigatorTo(this.project);

  final Project project;

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
    final matchResult = project.matchRoute(
      path,
      package: package,
      fallthrough: fallthrough,
    );
    if (matchResult == null) {
      final page404Builder = notFoundPage(context, path, data);
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
      (context) => turnRoute.builder(context, arguments),
      RouteSettings(
        name: turnRoute.route,
        arguments: arguments,
      ),
    );
  }
}

extension on NavigatorTo {
  WidgetBuilder? notFoundPage(
      BuildContext context, String route, Object? data) {
    return project.notFoundPage(context, route, data);
  }

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
      project.willTurnTo(
        context,
        turnRoute,
        arguments,
        mode: mode,
        result: result,
        isReplace: isReplace,
        isRemoveUntil: isRemoveUntil,
        routePredicate: routePredicate,
      );

  /// 在当前 push 事件结束后调用
  Future<T?> turnCompleted<T extends Object?>(
    T? result,
    TurnRoute turnRoute,
    Arguments arguments,
  ) {
    return project.turnCompleted<T>(result, turnRoute, arguments);
  }
}

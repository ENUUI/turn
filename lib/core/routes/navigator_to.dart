import 'package:flutter/material.dart';

import 'argument.dart';
import 'transition_mode.dart';
import 'tree.dart';
import '../interfaces/navigateable.dart';

class NavigatorTo {
  NavigatorTo(this.project);

  final TurnTo project;

  Future push(
    BuildContext context,
    String routePath, {
    bool? rootNavigator,
    Object? data,
    String? package,
    bool fallthrough = true,
    TransitionMode? transitionMode,
  }) =>
      _next(
        context,
        routePath,
        data: data,
        rootNavigator: rootNavigator,
        package: package,
        fallthrough: fallthrough,
        mode: transitionMode,
      );

  Future pushUntil(
    BuildContext context,
    String routePath, {
    bool? rootNavigator,
    Object? data,
    String? package,
    bool fallthrough = true,
    TransitionMode? transitionMode,
    RoutePredicate? routePredicate,
  }) =>
      _next(
        context,
        routePath,
        data: data,
        rootNavigator: rootNavigator,
        package: package,
        fallthrough: fallthrough,
        mode: transitionMode,
        routePredicate: routePredicate,
        isRemoveUntil: true,
      );

  Future replace(
    BuildContext context,
    String routePath, {
    bool? rootNavigator,
    Object? data,
    String? package,
    bool fallthrough = true,
    TransitionMode? transitionMode,
    Object? result,
  }) =>
      _next(
        context,
        routePath,
        data: data,
        rootNavigator: rootNavigator,
        package: package,
        fallthrough: fallthrough,
        mode: transitionMode,
        result: result,
        isReplace: true,
      );

  Future _next(
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
    final matchResult = project.matchRoute(
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

    final route = createRoute(useRoute, arguments, mode);

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

  void pop<T extends Object>(BuildContext context, [T? result]) => Navigator.pop<T>(context, result);

  void rootPop<T extends Object>(BuildContext context, {bool rootNavigator = false, T? result}) =>
      Navigator.of(context, rootNavigator: rootNavigator).pop<T>(result);

  Future<bool> rootMaybePop<T extends Object>(BuildContext context, {bool rootNavigator = false, T? result}) =>
      Navigator.of(context, rootNavigator: rootNavigator).maybePop<T>(result);

  Future<bool> maybePop<T extends Object>(BuildContext context, [T? result]) => Navigator.maybePop<T>(context, result);

  void popUntil(BuildContext context, String routePath, {bool rootNavigator = false, String? package}) {
    Navigator.of(context, rootNavigator: rootNavigator).popUntil(
      ModalRoute.withName(routePath),
    );
  }

  bool canPop(BuildContext context, {bool rootNavigator = false}) => Navigator.of(context).canPop();
}

extension on NavigatorTo {
  WidgetBuilder? notFoundPage(BuildContext context, String route, Object? data) {
    return project.notFoundPage(context, route, data);
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
  }) =>
      project.willTurnTo(
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

  Future beforeTureTo(
    BuildContext context,
    TurnRoute turnRoute,
    Arguments arguments,
  ) =>
      project.beforeTurnTo(context, turnRoute, arguments);

  /// 在当前 push 事件结束后调用
  Future turnCompleted(
    BuildContext context,
    Object? result,
    TurnRoute turnRoute,
    Arguments arguments,
  ) {
    return project.turnCompleted(context, result, turnRoute, arguments);
  }
}

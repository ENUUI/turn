import 'package:flutter/material.dart';

import '../../src/express.dart';
import '../../src/turn.dart';
import 'argument.dart';
import 'transition_mode.dart';
import '../extensions/transition_type.dart';
import 'tree.dart';
import '../interfaces/matchable.dart';

class NavigatorTo {
  NavigatorTo(this.matchable);

  final Matchable matchable;

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
    final matchResult = matchable.matchRoute(
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

  /// Pop
  void pop<T extends Object>(BuildContext context, [T? result]) =>
      Navigator.pop<T>(context, result);

  Future<bool> maybePop<T extends Object>(BuildContext context, [T? result]) =>
      Navigator.maybePop<T>(context, result);

  void popUntil(BuildContext context, String routePath, {String? package}) {
    final matchResult = matchable.matchRoute(routePath);
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

  Route<dynamic> generator(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments;
    final name = routeSettings.name ?? '';
    final matchResult = matchable.matchRoute(name);

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
    return createRoute(
      useRoute,
      args,
      useRoute.transitionMode ?? TransitionMode.native,
    );
  }
}

extension on NavigatorTo {
  WidgetBuilder? notFoundPage(
      BuildContext context, String route, Object? data) {
    return matchable.notFoundPage(context, route, data);
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
      matchable.willTurnTo(
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
    return matchable.turnCompleted<T>(result, turnRoute, arguments);
  }
}

extension NavigatorToDeprecated on NavigatorTo {
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
      return this.replace(
        context,
        action,
        data: data ?? params ?? express,
        package: package,
        fallthrough: true,
        transitionMode: mode,
      );
    } else if (clearStack) {
      return pushUntil(
        context,
        action,
        data: data ?? params ?? express,
        package: package,
        fallthrough: true,
        transitionMode: mode,
        routePredicate: predicate,
      );
    } else {
      return push(
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

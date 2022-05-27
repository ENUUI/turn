import 'package:flutter/material.dart';

import '../routes/argument.dart';
import '../routes/transition_mode.dart';
import '../routes/tree.dart';
import '../routes/navigator_to.dart';

abstract class Navigateable {
  NavigatorTo get navigatorTo;

  WidgetBuilder? notFoundPage(
    BuildContext context,
    String routePath,
    Object? data,
  ) =>
      null;

  /// 在路由地址被找到后立即调用
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

  ///
  ///
  ///
  Future<T?> push<T extends Object?>(
    BuildContext context,
    String routePath, {
    Object? data,
    String? package,
    bool fallthrough = true,
    TransitionMode? transitionMode,
  }) =>
      navigatorTo.push<T>(
        context,
        routePath,
        data: data,
        package: package,
        fallthrough: fallthrough,
        transitionMode: transitionMode,
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
      navigatorTo.pushUntil<T>(
        context,
        routePath,
        data: data,
        package: package,
        fallthrough: fallthrough,
        transitionMode: transitionMode,
        routePredicate: routePredicate,
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
      navigatorTo.replace<T, TO>(
        context,
        routePath,
        data: data,
        package: package,
        fallthrough: fallthrough,
        transitionMode: transitionMode,
        result: result,
      );

  void pop<T extends Object>(BuildContext context, [T? result]) =>
      Navigator.pop<T>(context, result);

  Future<bool> maybePop<T extends Object>(BuildContext context, [T? result]) =>
      Navigator.maybePop<T>(context, result);

  void popUntil(BuildContext context, String routePath, {String? package}) {
    Navigator.popUntil(
      context,
      ModalRoute.withName(routePath),
    );
  }

  bool canPop(BuildContext context) => Navigator.canPop(context);
}

///
///
///
abstract class Project extends Navigateable {
  Project();

  late final NavigatorTo navigatorTo = NavigatorTo(this);
  final RouteTree _routeTree = RouteTree();
  final Map<String, Module> _modulesMap = <String, Module>{};

  factory Project.base() => _BaseProject();

  @mustCallSuper
  void fire() {
    final modules = _modulesMap.values;
    if (modules.isEmpty) {
      assert(() {
        throw FlutterError('At least one instance of [Module] is required');
      }());
      return;
    }
    modules.forEach((e) => e.install());
  }

  void registerModule(Module module) {
    if (_modulesMap.containsKey(module.package)) {
      assert(() {
        throw FlutterError('Package `${module.package}` has already been set.');
      }());
      return;
    }
    module._parent = this;
    _modulesMap[module.package] = module;
  }

  void _registerRoute(TurnRoute route, {String? package}) {
    if (package != null && package.isNotEmpty) {
      route = route.copy(package: package);
    }
    _routeTree.addRoute(route);
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

  Route<dynamic> generator(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments;
    final name = routeSettings.name ?? '';
    final matchResult = matchRoute(name);

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
    return navigatorTo.createRoute(
      useRoute,
      args,
      useRoute.transitionMode ?? TransitionMode.native,
    );
  }

  /// 在路由地址被找到后立即调用
  /// 如果返回null，正常[Turn.to()]
  /// 否则
  ///   [to] / [replace] / [toUntil] 将会被拦截
  /// 且以下方法都不会被调用
  ///   [willTransitionPage] / [shouldTransitionRoute]
  /// 如果有对应的package，则会先尝试子module去执行
  @override
  Future<T?>? willTurnTo<T extends Object?, TO extends Object?>(
    BuildContext context,
    TurnRoute turnRoute,
    Arguments arguments, {
    TransitionMode? mode,
    TO? result,
    bool isReplace = false,
    bool isRemoveUntil = false,
    RoutePredicate? routePredicate,
  }) {
    final package = turnRoute.package;
    if (package != null && package.isNotEmpty) {
      return _modulesMap[package]?.willTurnTo(
        context,
        turnRoute,
        arguments,
        mode: mode,
        result: result,
        isReplace: isReplace,
        isRemoveUntil: isRemoveUntil,
        routePredicate: routePredicate,
      );
    }
    return null;
  }

  @override
  Future<T?> turnCompleted<T extends Object?>(
    T? result,
    TurnRoute turnRoute,
    Arguments arguments,
  ) {
    final package = turnRoute.package;
    if (package != null &&
        package.isNotEmpty &&
        _modulesMap.containsKey(package)) {
      return _modulesMap[package]!.turnCompleted(
        result,
        turnRoute,
        arguments,
      );
    }
    return Future.value(result);
  }
}

class _BaseProject extends Project {}

///
///
///
abstract class Module extends Navigateable {
  @override
  NavigatorTo get navigatorTo => parent.navigatorTo;

  String get package;

  Project get parent {
    assert(() {
      if (_parent == null) {
        throw FlutterError('Set a parent before use.');
      }
      return true;
    }());
    return _parent!;
  }

  Project? _parent;

  void registerRoute(TurnRoute route) {
    parent._registerRoute(route, package: package);
  }

  void install();

  /// ##
  ///
  ///
  @override
  Future<T?> push<T extends Object?>(
    BuildContext context,
    String routePath, {
    Object? data,
    String? package,
    bool fallthrough = true,
    TransitionMode? transitionMode,
  }) =>
      super.push<T>(
        context,
        routePath,
        data: data,
        package: package ?? this.package,
        fallthrough: fallthrough,
        transitionMode: transitionMode,
      );

  @override
  Future<T?> pushUntil<T extends Object?>(
    BuildContext context,
    String routePath, {
    Object? data,
    String? package,
    bool fallthrough = true,
    TransitionMode? transitionMode,
    RoutePredicate? routePredicate,
  }) =>
      super.pushUntil<T>(
        context,
        routePath,
        data: data,
        package: package ?? this.package,
        fallthrough: fallthrough,
        transitionMode: transitionMode,
        routePredicate: routePredicate,
      );

  @override
  Future<T?> replace<T extends Object?, TO extends Object?>(
    BuildContext context,
    String routePath, {
    Object? data,
    String? package,
    bool fallthrough = true,
    TransitionMode? transitionMode,
    TO? result,
  }) =>
      super.replace<T, TO>(
        context,
        routePath,
        data: data,
        package: package ?? this.package,
        fallthrough: fallthrough,
        transitionMode: transitionMode,
        result: result,
      );
}

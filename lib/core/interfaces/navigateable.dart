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
  Future? willTurnTo(
    BuildContext context,
    TurnRoute turnRoute,
    Arguments arguments, {
    TransitionMode? mode,
    Object? result,
    bool isReplace = false,
    bool isRemoveUntil = false,
    RoutePredicate? routePredicate,
  }) =>
      null;

  Future turnCompleted(
    Object? result,
    TurnRoute turnRoute,
    Arguments arguments,
  ) {
    return Future.value(result);
  }

  ///
  ///
  ///
  Future push(
    BuildContext context,
    String routePath, {
    Object? data,
    String? package,
    bool fallthrough = true,
    TransitionMode? transitionMode,
  }) =>
      navigatorTo.push(
        context,
        routePath,
        data: data,
        package: package,
        fallthrough: fallthrough,
        transitionMode: transitionMode,
      );

  Future pushUntil(
    BuildContext context,
    String routePath, {
    Object? data,
    String? package,
    bool fallthrough = true,
    TransitionMode? transitionMode,
    RoutePredicate? routePredicate,
  }) =>
      navigatorTo.pushUntil(
        context,
        routePath,
        data: data,
        package: package,
        fallthrough: fallthrough,
        transitionMode: transitionMode,
        routePredicate: routePredicate,
      );

  Future replace(
    BuildContext context,
    String routePath, {
    Object? data,
    String? package,
    bool fallthrough = true,
    TransitionMode? transitionMode,
    Object? result,
  }) =>
      navigatorTo.replace(
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

  bool _fired = false;

  /// Call when prepared.
  @mustCallSuper
  void fire() {
    if (_fired) {
      assert(() {
        throw FlutterError('Can only be called once');
      }());
      return;
    }
    _fired = true;

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
  Future? willTurnTo(
    BuildContext context,
    TurnRoute turnRoute,
    Arguments arguments, {
    TransitionMode? mode,
    Object? result,
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
  Future turnCompleted(
    Object? result,
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

  void registerRoutePath(
    String route,
    NextPageBuilder builder, {
    TransitionMode? transitionMode,
    Map<String, QueryType>? queryTypeMap,
  }) {
    return registerRoute(TurnRoute(
      route,
      builder,
      transitionMode: transitionMode,
      queryTypeMap: queryTypeMap,
    ));
  }

  /// If [Arguments.data] is not of Map<String, dynamic> type, it will be discarded.
  void registerRoutePathMapData(
    String route,
    Widget Function(BuildContext context, Map<String, dynamic>? params)
        builder, {
    TransitionMode? transitionMode,
    Map<String, QueryType>? queryTypeMap,
  }) {
    return registerRoute(TurnRoute(
      route,
      (context, arguments) => builder(context, arguments.commitDataAsMap()),
      transitionMode: transitionMode,
      queryTypeMap: queryTypeMap,
    ));
  }

  void install();

  /// ##
  ///
  ///
  @override
  Future push(
    BuildContext context,
    String routePath, {
    Object? data,
    String? package,
    bool fallthrough = true,
    TransitionMode? transitionMode,
  }) =>
      super.push(
        context,
        routePath,
        data: data,
        package: package ?? this.package,
        fallthrough: fallthrough,
        transitionMode: transitionMode,
      );

  @override
  Future pushUntil(
    BuildContext context,
    String routePath, {
    Object? data,
    String? package,
    bool fallthrough = true,
    TransitionMode? transitionMode,
    RoutePredicate? routePredicate,
  }) =>
      super.pushUntil(
        context,
        routePath,
        data: data,
        package: package ?? this.package,
        fallthrough: fallthrough,
        transitionMode: transitionMode,
        routePredicate: routePredicate,
      );

  @override
  Future replace(
    BuildContext context,
    String routePath, {
    Object? data,
    String? package,
    bool fallthrough = true,
    TransitionMode? transitionMode,
    Object? result,
  }) =>
      super.replace(
        context,
        routePath,
        data: data,
        package: package ?? this.package,
        fallthrough: fallthrough,
        transitionMode: transitionMode,
        result: result,
      );
}

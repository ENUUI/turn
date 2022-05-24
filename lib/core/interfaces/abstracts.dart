import 'package:flutter/material.dart'
    show FlutterError, DiagnosticsNode, ErrorSummary;
import 'package:turn/core/routes/tree.dart';

abstract class Matchable {
  MatchResult? matchRoute(
    String route, {
    String? package,
    bool innerPackage = false,
  });

  MatchResult? matchPath(
    RoutePath path, {
    String? package,
    bool innerPackage = false,
  });
}

abstract class Project implements Matchable {
  final Map<String, Module> _modulesMap = <String, Module>{};

  Iterable<Module> get modules => _modulesMap.values;
  Module? getModule(String package) => _modulesMap[package];

  void registerModule(String package, Module module) {
    assert(() {
      if (_modulesMap.containsKey(package)) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('Package($package) has been added.'),
        ]);
      }
      return true;
    }());
    if (_modulesMap.containsKey(package)) {
      return;
    }
    module._setValues(this, package);
    _modulesMap[package] = module;
  }

  @override
  MatchResult? matchRoute(
    String route, {
    String? package,
    bool innerPackage = false,
  }) =>
      matchPath(
        RoutePath.fromPath(route),
        package: package,
        innerPackage: innerPackage,
      );

  @override
  MatchResult? matchPath(
    RoutePath path, {
    String? package,
    bool innerPackage = false,
  }) {
    Module? module;
    if (package != null) {
      module = getModule(package);
      if (module != null) {
        final result = module.matchPath(path);
        if (result != null || innerPackage) {
          return result;
        }
      }
    }

    return _matchRoutePath(path, excludeModule: module);
  }

  MatchResult? _matchRoutePath(RoutePath routePath, {Module? excludeModule}) {
    assert(_debugCheck());
    MatchResult? result;
    for (final m in modules) {
      if (m == excludeModule) continue;
      result = m._matchRoutePath(routePath);
      if (result != null) break;
    }
    return result;
  }

  bool _debugCheck() {
    if (_modulesMap.isEmpty) {
      throw FlutterError('Register any instance of [Module] before use.');
    }
    return true;
  }
}

abstract class Module implements Matchable {
  final RouteTree _routeTree = RouteTree();

  String? get package => _package;
  String? _package;

  Project? get parent => _parent;
  Project? _parent;

  void _setValues(Project parent, String? package) {
    _parent = parent;
    _package = package;
  }

  bool get hasDefaultRoute => _routeTree.hasDefaultRoute;

  void registerRoute(TurnRoute route) {
    _routeTree.addRoute(route);
  }

  @override
  MatchResult? matchRoute(
    String route, {
    String? package,
    bool innerPackage = false,
  }) =>
      matchPath(
        RoutePath.fromPath(route),
        package: package,
        innerPackage: innerPackage,
      );

  @override
  MatchResult? matchPath(
    RoutePath path, {
    String? package,
    bool innerPackage = false,
  }) {
    Module? module;
    if (package != null && package.isNotEmpty) {
      assert(_parent != null);
      module = _parent?.getModule(package);
    } else {
      module = this;
    }
    MatchResult? result = module?._matchRoutePath(path);
    if (result != null || innerPackage) return result;

    return _parent?._matchRoutePath(path, excludeModule: module);
  }

  MatchResult? _matchRoutePath(RoutePath path) {
    return _routeTree.matchPath(path);
  }
}

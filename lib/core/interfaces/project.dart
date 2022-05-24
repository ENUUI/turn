import 'package:flutter/material.dart'
    show FlutterError, DiagnosticsNode, ErrorSummary;
import 'package:turn/core/routes/tree.dart';
import 'module.dart';

abstract class Project {
  final Map<Object, Module> _modulesMap = <Object, Module>{};

  Iterable<Module> get modules => _modulesMap.values;

  void registerModule(Object package, Module module) {
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
    _modulesMap[package] = module;
  }

  Module? getModule(Object package) => _modulesMap[package];

  MatchResult? matchRoute(
    String route, {
    Object? package,
    bool innerPackage = false,
  }) {
    final routePath = RoutePath.fromPath(route);
    Module? module;
    if (package != null) {
      module = getModule(package);
      if (module != null) {
        final result = module.matchPath(routePath);
        if (result != null || innerPackage) {
          return result;
        }
      }
    }
    return matchRoutePath(routePath, excludeModule: module);
  }

  MatchResult? matchRoutePath(RoutePath routePath, {Module? excludeModule}) {
    for (final m in modules) {
      if (m == excludeModule) continue;

      final result = m.matchPath(routePath);

      if (result != null) {
        break;
      }
    }
    return null;
  }
}

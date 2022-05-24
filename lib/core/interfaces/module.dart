import 'package:flutter/material.dart';

import '../routes/tree.dart';
import 'matchable.dart';
import 'project.dart';

abstract class Module extends Matchable {
  String get package;

  Project get parent;

  @override
  void registerRoute(TurnRoute route) {
    parent.registerRoute(route, package: package);
  }

  @override
  MatchResult? matchRoute(
    String route, {
    String? package,
    bool fallthrough = true,
  }) =>
      matchPath(RoutePath.fromPath(
        route,
        package: package ?? this.package,
        fallthrough: fallthrough,
      ));

  @override
  MatchResult? matchPath(RoutePath path) {
    return parent.matchPath(path);
  }

  @override
  WidgetBuilder? notFoundPage<T extends Object?>(
      BuildContext context, String path, Object? data) {
    return parent.notFoundPage(context, path, data);
  }
}

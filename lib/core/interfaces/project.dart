import 'package:flutter/material.dart';
import 'package:turn/core/routes/argument.dart';

import '../routes/transition_mode.dart';
import '../routes/tree.dart';
import 'matchable.dart';

abstract class Project extends Matchable {
  Project();

  final RouteTree _routeTree = RouteTree();

  factory Project.base() => _BaseProject();

  @override
  void registerRoute(TurnRoute route, {String? package}) {
    if (package != null && package.isNotEmpty) {
      route = route.copy(package: package);
    }
    _routeTree.addRoute(route);
  }

  @override
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
}

class _BaseProject extends Project {}

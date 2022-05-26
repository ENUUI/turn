import 'package:flutter/material.dart';
import 'package:turn/core/routes/argument.dart';

import '../routes/transition_mode.dart';
import '../routes/tree.dart';
import 'matchable.dart';

abstract class Project extends Matchable {
  final RouteTree _routeTree = RouteTree();

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
  }) =>
      matchPath(RoutePath.fromPath(
        route,
        package: package,
        fallthrough: fallthrough,
      ));

  @override
  MatchResult? matchPath(RoutePath path) {
    return _routeTree.matchPath(path);
  }

  Route<dynamic> generator(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments;
    final name = routeSettings.name ?? '';
    final matchResult = matchRoute(name);

    if (matchResult == null) {
      assert(() {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('Page Not Found!'),
          ErrorDescription('routePath: $name, arguments: $arguments')
        ]);
      }());
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (BuildContext context) {
          final page404Builder = notFoundPage(context, '', arguments);
          if (page404Builder != null) return page404Builder(context);
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

import '../routes/tree.dart';

abstract class Module {
  final RouteTree _routeTree = RouteTree();

  bool get hasDefaultRoute => _routeTree.hasDefaultRoute;

  void registerRoute(TurnRoute route) {
    _routeTree.addRoute(route);
  }

  MatchResult? matchRoute(
    String route, {
    Object? package,
    bool innerPackage = false,
  });

  MatchResult? matchPath(
    RoutePath path, {
    Object? package,
    bool innerPackage = false,
  });
}

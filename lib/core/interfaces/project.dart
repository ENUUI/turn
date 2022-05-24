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
}

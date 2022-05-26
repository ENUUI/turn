import '../routes/tree.dart';
import 'matchable.dart';
import 'project.dart';
import 'target.dart';

abstract class Module extends Matchable {
  Module({required this.package, required this.parent});

  final String package;

  final Project parent;

  @override
  void registerRoute(TurnRoute route) {
    parent.registerRoute(route, package: package);
  }

  void registerTargets(Iterable<Target> targets) {
    if (targets.isEmpty) return;
    targets.forEach((t) => t.registerTurnRoutes(this));
  }

  @override
  MatchResult? matchRoute(
    String route, {
    String? package,
    bool fallthrough = true,
  }) =>
      parent.matchRoute(
        route,
        package: package ?? this.package,
        fallthrough: fallthrough,
      );
}

import 'package:flutter/widgets.dart';

final NavigatorObserver turnOb = _TurnOb();

class TurnStack {
  TurnStack._();

  static final List<TurnNode> _turnRoutes = <TurnNode>[];

  static TurnNode top() {
    if (_turnRoutes.length == 0) return null;
    return _turnRoutes.last;
  }

  static bool contain(Route route) {
    if (route == null) return false;
    return _turnRoutes.any(((node) => node.route == route));
  }

  static List<TurnNode> find(Route route) {
    if (route == null) return null;
    return _turnRoutes.where((node) => TurnNode.isSame(node, route)).toList();
  }

  static bool pathIsOnTop(String path) {
    if (path == null || path.length == 0) return false;
    return top()?.route?.settings?.name == path;
  }

  /// if path is empty, return top [TurnNode].
  /// Otherwise, returns the top most match  or null
  static TurnNode lastNode([String path]) {
    final TurnNode node = top();

    if (path == null || path.length == 0) return node;

    TurnNode lastNodeMatch(String path, TurnNode node) {
      if (node == null) return null;

      if (node.route?.settings?.name == path)
        return node;
      else
        return lastNodeMatch(path, node.previous);
    }

    return lastNodeMatch(path, node);
  }

  static Route lastRoute([String path]) => lastNode(path)?.route;

  static Route lastPreviousRoute([String path]) =>
      lastNode(path)?.previous?.route;

  static String lastPreviousPath([String path]) =>
      lastPreviousRoute(path)?.settings?.name;

  /// private functions
  static void _push(Route next, {Route previous}) {
    final stackPrevious = top();

    if (!TurnNode.isSame(stackPrevious, previous)) {
// #warning...
    }

    final node = TurnNode._(route: next);
    node.previous = stackPrevious;
    stackPrevious?.next = node;

    _turnRoutes.add(node);
  }

  static void _remove(Route route) {
    final result = find(route);
    if (result?.isNotEmpty != true) return;

    result.forEach((n) {
      final previous = n.previous;
      final next = n.next;
      previous?.next = next;
      next?.previous = previous;
      _turnRoutes.remove(n);
    });
  }

  static TurnNode _pop() {
    final node = top();
    if (node != null) {
      node.previous?.next = null;
      _turnRoutes.removeLast();
    }
    return node;
  }
}

class TurnNode {
  TurnNode._({
    this.route,
  });

  TurnNode previous;
  TurnNode next;
  final Route route;

  String toString() {
    return '\ncurrent: ${route?.settings?.name}'
        '\nprevious: ${previous?.route?.settings?.name}'
        '\nnext: ${next?.route?.settings?.name}';
  }

  static bool equal(TurnNode node, TurnNode other) {
    return node?.route == other?.route;
  }

  static bool isSame(TurnNode node, Route otherRoute) {
    return node?.route == otherRoute;
  }
}

class _TurnOb extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    TurnStack._push(route, previous: previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    TurnStack._pop();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic> previousRoute) {
    TurnStack._remove(route);
  }

  @override
  void didReplace({Route<dynamic> newRoute, Route<dynamic> oldRoute}) {
    TurnStack._remove(oldRoute);
    TurnStack._push(newRoute);
  }

  @override
  void didStartUserGesture(
      Route<dynamic> route, Route<dynamic> previousRoute) {}

  @override
  void didStopUserGesture() {}
}

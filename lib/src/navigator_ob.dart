import 'package:flutter/widgets.dart';

final NavigatorObserver turnOb = _TurnOb();

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

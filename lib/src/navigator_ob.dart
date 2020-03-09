import 'package:flutter/widgets.dart';

final NavigatorObserver turnOb = _TurnOb();

class _TurnNode {
  _TurnNode({
    this.route,
  });

  _TurnNode previous;
  _TurnNode next;
  final Route route;

  String toString() {
    return '\ncurrent: ${route?.settings?.name}'
        '\nprevious: ${previous?.route?.settings?.name}'
        '\nnext: ${next?.route?.settings?.name}';
  }

  static bool equal(_TurnNode node, _TurnNode other) {
    return node?.route == other?.route;
  }

  static bool isSame(_TurnNode node, Route otherRoute) {
    return node?.route == otherRoute;
  }
}

class _TurnStack {
  static final List<_TurnNode> _turnRoutes = <_TurnNode>[];

  static _TurnNode top() {
    if (_turnRoutes.length == 0) return null;
    return _turnRoutes.last;
  }

  static bool contain(Route route) {
    if (route == null) return false;
    return _turnRoutes.any(((node) => node.route == route));
  }

  static List<_TurnNode> find(Route route) {
    if (route == null) return null;
    return _turnRoutes.where((node) => _TurnNode.isSame(node, route)).toList();
  }

  static void push(Route next, {Route previous}) {
    final stackPrevious = top();

    if (!_TurnNode.isSame(stackPrevious, previous)) {
// #warning...
    }

    final node = _TurnNode(route: next);
    node.previous = stackPrevious;
    stackPrevious?.next = node;

    _turnRoutes.add(node);
  }

  static void remove(Route route) {
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

  static _TurnNode pop() {
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
    _TurnStack.push(route, previous: previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    _TurnStack.pop();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic> previousRoute) {
    _TurnStack.remove(route);
  }

  @override
  void didReplace({Route<dynamic> newRoute, Route<dynamic> oldRoute}) {
    _TurnStack.remove(oldRoute);
    _TurnStack.push(newRoute);
  }

  @override
  void didStartUserGesture(
      Route<dynamic> route, Route<dynamic> previousRoute) {}

  @override
  void didStopUserGesture() {}
}

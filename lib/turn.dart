/// ProjectName: turn
/// FileName: turn
/// Author: ENUUI
/// Date: 2019/4/30 5:50 PM
/// Copyright (c) 2019 ENUUI. All rights reserved.
export 'mediator.dart';
export 'src/navigator_ob.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'mediator.dart';

enum TransitionType {
  native,
  nativeModal,
  inFromLeft,
  inFromRight,
  inFromBottom,
  fadeIn,
  custom, // Custom RouteTransitionsBuilder
  customRoute, // Custom Route
}

typedef TurnRouteBuilder = Route Function(
  BuildContext context,
  Widget Function() nextPageBuilder,
);

class Turn {
  Turn._();

  // Invoke when router is not found.
  // An error Widget can be returned at this time.
  static Widget Function() notFoundNextPage;

  static void Function(BuildContext context, String route) willPushRoute;

  static bool Function(BuildContext context, String route) shouldPushRoute;

  static void pop<T extends Object>(BuildContext context, [T result]) {
    Navigator.pop<T>(context, result);
  }

  static Future to(
    BuildContext context,
    String action, {
    Map<String, dynamic> params,
    bool replace = false,
    bool clearStack = false,
    TransitionType transition = TransitionType.native,
    RouteTransitionsBuilder transitionBuilder,
    Duration duration = const Duration(milliseconds: 250),
    TurnRouteBuilder turnRouteBuilder,
  }) {
    var route = _route(
      context,
      action,
      params: params,
      transition: transition,
      transitionBuilder: transitionBuilder,
      duration: duration,
      turnRouteBuilder: turnRouteBuilder,
    );

    Completer completer = new Completer();
    Future future = completer.future;

    if (route == null) {
      completer.complete("No registered action was found to handle '$action'.");
    } else {
      if (shouldPushRoute != null && shouldPushRoute(context, action) != true) {
        completer.complete("Refused by `shouldPushRoute`");
        return future;
      }

      if (willPushRoute != null) willPushRoute(context, action);

      if (clearStack) {
        future = Navigator.pushAndRemoveUntil(context, route, (c) => false);
      } else {
        if (replace) {
          future = Navigator.pushReplacement(context, route);
        } else {
          future = Navigator.push(context, route);
        }
      }
      completer.complete();
    }

    return future;
  }

  static Route _route(
    BuildContext context,
    String action, {
    Map<String, dynamic> params,
    RouteSettings routeSettings,
    TransitionType transition = TransitionType.native,
    RouteTransitionsBuilder transitionBuilder,
    Duration duration = const Duration(milliseconds: 250),
    TurnRouteBuilder turnRouteBuilder,
  }) {
    var _routeSettings = routeSettings;
    if (_routeSettings == null) {
      _routeSettings = new RouteSettings(name: action);
    }

    bool isNativeTransition = (transition == TransitionType.native ||
        transition == TransitionType.nativeModal);

    if (isNativeTransition) {
      return MaterialPageRoute<dynamic>(
          settings: _routeSettings,
          fullscreenDialog: transition == TransitionType.nativeModal,
          builder: (context) {
            return _nextPage(action, params);
          });
    } else if (transition == TransitionType.customRoute) {
      return turnRouteBuilder(context, () => _nextPage(action, params));
    } else {
      var transitionsBuilder;
      if (transition == TransitionType.custom) {
        transitionsBuilder = transitionBuilder;
      } else {
        transitionsBuilder = _standardTransitionsBuilder(transition);
      }

      return PageRouteBuilder<dynamic>(
        settings: _routeSettings,
        transitionDuration: duration,
        transitionsBuilder: transitionsBuilder,
        pageBuilder: (context, animation, secondaryAnimation) {
          return _nextPage(action, params);
        },
      );
    }
  }

  /// ------
  static Widget _nextPage(String action, Map<String, dynamic> params) {
    var next = Mediator.perform(action, params: params);

    //
    if ((next == null || next is! Widget) && notFoundNextPage != null) {
      next = notFoundNextPage();
    }

    return next;
  }

  /// https://github.com/theyakka/fluro/blob/master/lib/src/router.dart
  static RouteTransitionsBuilder _standardTransitionsBuilder(
      TransitionType transitionType) {
    return (BuildContext context, Animation<double> animation,
        Animation<double> secondaryAnimation, Widget child) {
      if (transitionType == TransitionType.fadeIn) {
        return new FadeTransition(opacity: animation, child: child);
      } else {
        const Offset topLeft = const Offset(0.0, 0.0);
        const Offset topRight = const Offset(1.0, 0.0);
        const Offset bottomLeft = const Offset(0.0, 1.0);
        Offset startOffset = bottomLeft;
        Offset endOffset = topLeft;
        if (transitionType == TransitionType.inFromLeft) {
          startOffset = const Offset(-1.0, 0.0);
          endOffset = topLeft;
        } else if (transitionType == TransitionType.inFromRight) {
          startOffset = topRight;
          endOffset = topLeft;
        }

        return new SlideTransition(
          position: new Tween<Offset>(
            begin: startOffset,
            end: endOffset,
          ).animate(animation),
          child: child,
        );
      }
    };
  }

  static Route<dynamic> generator(RouteSettings routeSettings) {
    Route route =
        _route(null, routeSettings.name, routeSettings: routeSettings);

    return route;
  }
}

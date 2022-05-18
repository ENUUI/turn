import 'package:flutter/material.dart';
import 'package:turn/src/turn.dart';

class NavigatorTo {
  NavigatorTo._();

  static Future to(
    BuildContext context,
    RouteSettings routeSettings,
    WidgetBuilder builder, {
    String? package,
    bool replace = false,
    bool clearStack = false,
    TransitionType transition = TransitionType.native,
    RouteTransitionsBuilder? transitionBuilder,
    Duration duration = const Duration(milliseconds: 250),
    TurnRouteBuilder? turnRouteBuilder,
    RoutePredicate? predicate, // clearStack = true
    bool innerPackage = false,
  }) {
    final route = _buildRoute(
      context,
      routeSettings,
      builder,
      transition: transition,
      transitionBuilder: transitionBuilder,
      duration: duration,
      turnRouteBuilder: turnRouteBuilder,
    );

    final Future future;
    if (clearStack) {
      future = Navigator.pushAndRemoveUntil(
        context,
        route,
        predicate ?? (route) => false,
      );
    } else {
      if (replace) {
        future = Navigator.pushReplacement(context, route);
      } else {
        future = Navigator.push(context, route);
      }
    }
    return future;
  }

  static Route _buildRoute(
    BuildContext context,
    RouteSettings _routeSettings,
    WidgetBuilder pageBuilder, {
    TransitionType transition = TransitionType.native,
    RouteTransitionsBuilder? transitionBuilder,
    Duration duration = const Duration(milliseconds: 250),
    TurnRouteBuilder? turnRouteBuilder,
  }) {
    bool isNativeTransition = (transition == TransitionType.native ||
        transition == TransitionType.nativeModal);

    assert(() {
      if (transition == TransitionType.customRoute &&
          turnRouteBuilder == null) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('Route build failure for path(${_routeSettings.name}) '),
          ErrorDescription(
              'If transition is [TransitionType.customRoute)], turnRouteBuilder must not be null.'),
        ]);
      }
      return true;
    }());

    if (isNativeTransition) {
      return MaterialPageRoute<dynamic>(
          settings: _routeSettings,
          fullscreenDialog: transition == TransitionType.nativeModal,
          builder: pageBuilder);
    } else if (transition == TransitionType.customRoute) {
      return turnRouteBuilder!(context, pageBuilder);
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
        pageBuilder: (context, animation, secondaryAnimation) =>
            pageBuilder(context),
      );
    }
  }

  static RouteTransitionsBuilder _standardTransitionsBuilder(
      TransitionType transitionType) {
    return (BuildContext context, Animation<double> animation,
        Animation<double> secondaryAnimation, Widget child) {
      if (transitionType == TransitionType.fadeIn) {
        return FadeTransition(opacity: animation, child: child);
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

        return SlideTransition(
          position: Tween<Offset>(
            begin: startOffset,
            end: endOffset,
          ).animate(animation),
          child: child,
        );
      }
    };
  }
}

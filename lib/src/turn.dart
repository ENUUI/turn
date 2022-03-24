import 'package:flutter/material.dart';

import 'express.dart';
import 'imp.dart';
import 'mediator.dart';
import 'opts.dart';

abstract class Module extends Adaptor {
  Widget? notFoundNextPage() => null;

  Widget rootPage(BuildContext context, Options options);

  void willTransitionRoute(BuildContext context, Options options) {}

  Future<bool> shouldTransitionRoute(
          BuildContext context, Options options) async =>
      true;

  Widget? willTransitionPage(BuildContext context, Options options) {
    return resolveAction<Widget>(context, options);
  }

  void pop<T extends Object>(BuildContext context, [T? result]) =>
      Navigator.pop<T>(context, result);

  Future<bool> maybePop<T extends Object>(BuildContext context, [T? result]) =>
      Navigator.maybePop<T>(context, result);

  void popUntil(BuildContext context, String action) => Navigator.popUntil(
        context,
        ModalRoute.withName(Options(action: action).path),
      );

  bool canPop(BuildContext context) => Navigator.canPop(context);

  Future to(
    BuildContext context,
    String action, {
    Map<String, dynamic>? params,
    Express? express,
    bool replace = false,
    bool clearStack = false,
    TransitionType transition = TransitionType.native,
    RouteTransitionsBuilder? transitionBuilder,
    Duration duration = const Duration(milliseconds: 250),
    TurnRouteBuilder? turnRouteBuilder,
    RoutePredicate? predicate, // clearStack = true
  }) async {
    final opts = Options(action: action, params: params, express: express);

    final route = _route(
      opts,
      context: context,
      transition: transition,
      transitionBuilder: transitionBuilder,
      duration: duration,
      turnRouteBuilder: turnRouteBuilder,
    );

    if (!await shouldTransitionRoute(context, opts)) {
      return Future.value('Refused by [Turn.shouldTransitionRoute]');
    }
    willTransitionRoute(context, opts);

    Future future;
    if (clearStack) {
      future = Navigator.pushAndRemoveUntil(
        context,
        route,
        predicate ?? (c) => false,
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

  Route _route(
    Options opts, {
    BuildContext? context,
    TransitionType transition = TransitionType.native,
    RouteTransitionsBuilder? transitionBuilder,
    Duration duration = const Duration(milliseconds: 250),
    TurnRouteBuilder? turnRouteBuilder,
  }) {
    final _routeSettings = RouteSettings(name: opts.path);
    bool isNativeTransition = (transition == TransitionType.native ||
        transition == TransitionType.nativeModal);

    if (isNativeTransition) {
      return MaterialPageRoute<dynamic>(
          settings: _routeSettings,
          fullscreenDialog: transition == TransitionType.nativeModal,
          builder: (context) {
            return _nextPage(context, opts)!;
          });
    } else if (transition == TransitionType.customRoute) {
      return turnRouteBuilder!(
        context,
        (context) => _nextPage(context, opts),
      );
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
          return _nextPage(context, opts)!;
        },
      );
    }
  }

  /// ------
  Widget? _nextPage(BuildContext context, Options opts) {
    var next;
    if (opts.path == Navigator.defaultRouteName) {
      next = rootPage(context, opts);
    } else {
      next = willTransitionPage(context, opts);
      if (next == null || next is! Widget) {
        next = notFoundNextPage();
      }
    }
    return next;
  }

  RouteTransitionsBuilder _standardTransitionsBuilder(
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

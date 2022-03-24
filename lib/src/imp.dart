import 'dart:async';
import 'package:flutter/material.dart';
import 'package:turn/src/express.dart';
import 'mediator.dart';
import 'opts.dart';

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
  BuildContext? context,
  Widget? Function(BuildContext context) nextPageBuilder,
);

class Turn {
  Turn._();

  static Widget Function()? notFoundNextPage;
  static Widget Function(BuildContext context, Options)? rootPage;

  @Deprecated(
      'Use imp [Turn.willTransitionRoute] instead. Will be removed in Turn 1.0.0')
  static set willPushRoute(
      void Function(BuildContext context, String route)? value) {
    assert(() {
      print('''
      [willPushRoute] is deprecated!!!
      Use imp [Turn.willTransitionRoute] instead. Will be removed in Turn 1.0.0
      ''');
      return true;
    }());

    if (value != null && Turn.willTransitionRoute == null) {
      Turn.willTransitionRoute = (context, opts) {
        return value(context, opts.action);
      };
    }
  }

  @Deprecated(
      'Use imp [Turn.shouldTransitionRoute] instead. Will be removed in Turn 1.0.0')
  static set shouldPushRoute(
      bool Function(BuildContext context, String route)? value) {
    assert(() {
      print('''
      [shouldPushRoute] is deprecated!!!
      Use imp [Turn.shouldTransitionRoute] instead. Will be removed in Turn 1.0.0
      ''');
      return true;
    }());
    if (value != null && Turn.shouldTransitionRoute == null) {
      Turn.shouldTransitionRoute = (context, opts) async {
        return value(context, opts.action);
      };
    }
  }

  static void Function(BuildContext context, Options)? willTransitionRoute;
  static Future<bool> Function(BuildContext context, Options)?
      shouldTransitionRoute;

  static void pop<T extends Object>(BuildContext context, [T? result]) =>
      Navigator.pop<T>(context, result);

  static Future<bool> maybePop<T extends Object>(BuildContext context,
          [T? result]) =>
      Navigator.maybePop<T>(context, result);

  static void popUntil(BuildContext context, String action) =>
      Navigator.popUntil(
        context,
        ModalRoute.withName(Options(action: action).path),
      );

  static bool canPop(BuildContext context) => Navigator.canPop(context);

  static Future to(
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

    if (shouldTransitionRoute != null &&
        !await shouldTransitionRoute!(context, opts)) {
      return Future.value('Refused by [Turn.shouldTransitionRoute]');
    }
    if (willTransitionRoute != null) {
      willTransitionRoute!(context, opts);
    }

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

  static Route _route(
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
  static Widget? _nextPage(BuildContext context, Options opts) {
    Widget? next;

    if (opts.path == Navigator.defaultRouteName && rootPage != null) {
      next = rootPage!(context, opts);
    } else {
      next = Mediator.performOptions(context, opts);
      if ((next == null || next is! Widget) && notFoundNextPage != null) {
        next = notFoundNextPage!();
      }
    }
    return next;
  }

  /// https://github.com/theyakka/fluro/blob/master/lib/src/router.dart
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

  static Route<dynamic> generator(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments;
    Map<String, dynamic>? params;
    Express? express;

    if (arguments is Map<String, dynamic>) {
      params = arguments;
    } else if (arguments is Express) {
      express = arguments;
    }
    final Options opts = Options(
      action: routeSettings.name ?? '',
      params: params,
      express: express,
    );

    return _route(opts);
  }
}

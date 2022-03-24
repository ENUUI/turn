import 'package:flutter/material.dart';

import 'mediator.dart';
import 'express.dart';
import 'imp.dart';
import 'opts.dart';

abstract class Target {
  dynamic task(String action, Map<String, dynamic>? params) {}

  dynamic response(BuildContext? context, Options options) {
    return task(options.path, options.params);
  }
}

abstract class Adaptor {
  List<Target> get targets;

  T? resolveAction<T>(BuildContext? context, Options opts) {
    T? result;
    int i = 0;
    for (; i < targets.length; i++) {
      result = targets[i].response(context, opts);
      if (result != null) break;
    }
    assert(() {
      i++;
      final responseTargets = <Target>[];
      Target t;
      for (; i < targets.length; i++) {
        t = targets[i];
        if (t.response(context, opts) != null) responseTargets.add(t);
      }
      if (responseTargets.length > 0) {
        final msg = responseTargets..map((e) => '[${e.toString()}]').join(',');
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('One action got the response of multiple targets'),
          ErrorDescription('${opts.path}: $msg')
        ]);
      }
      return true;
    }());
    return result;
  }
}

abstract class RouteAdaptorHooks extends Adaptor {
  Widget? notFoundNextPage(BuildContext context, Options options) {
    if (Turn.notFoundNextPage != null) {
      return Turn.notFoundNextPage!(context, options);
    }
    return null;
  }

  void willTransitionRoute(BuildContext context, Options options) {
    if (Turn.willTransitionRoute != null) {
      Turn.willTransitionRoute!(context, options);
    }
  }

  Future<bool> shouldTransitionRoute(BuildContext context, Options options) {
    if (Turn.shouldTransitionRoute != null) {
      return Turn.shouldTransitionRoute!(context, options);
    }
    return Future.value(true);
  }

  Widget? willTransitionPage(BuildContext context, Options options) {
    var result;
    if (Turn.onWillTransitionPage != null) {
      result = Turn.onWillTransitionPage!(context, options);
    }
    if (result == null) {
      result = resolveAction<Widget>(context, options);
    }
    if (result == null) {
      result = Mediator.performOptions(context, options, this);
    }
    return result;
  }
}

abstract class Module extends RouteAdaptorHooks {
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

    final route = buildRoute(
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

  Route buildRoute(
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
    var next = willTransitionPage(context, opts);
    if (next == null) {
      next = notFoundNextPage(context, opts);
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

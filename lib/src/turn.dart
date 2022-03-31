import 'package:flutter/material.dart';

import 'mediator.dart';
import 'express.dart';
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

abstract class Target {
  dynamic task(String action, Map<String, dynamic>? params) {}

  dynamic response(BuildContext? context, Options options) {
    return task(options.path, options.params);
  }
}

abstract class AdaptorDelegate {
  Widget? notFoundNextPage(BuildContext context, Options options);

  void willTransitionRoute(BuildContext context, Options options);

  Future<bool> shouldTransitionRoute(BuildContext context, Options options);

  Widget? willTransitionPage(BuildContext context, Options options);
}

abstract class Adaptor {
  List<Target> get targets;

  AdaptorDelegate? get adaptorDelegate => null;

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

  T? perform<T>(
    String action, {
    Map<String, dynamic>? params,
    BuildContext? context,
    Express? express,
    bool innerPackage = false,
  }) {
    final options = Options(action: action, params: params, express: express);
    return performOptions<T>(
      options,
      context: context,
      innerPackage: innerPackage,
    );
  }

  T? performOptions<T>(
    Options options, {
    BuildContext? context,
    bool innerPackage = false,
  }) {
    final result = resolveAction<T>(context, options);
    if (result != null || innerPackage) {
      return result;
    }
    return Mediator.performOptions<T>(context, options, this);
  }
}

abstract class RouteAdaptor extends Adaptor {
  Widget? notFoundNextPage(BuildContext context, Options options) {
    return adaptorDelegate?.notFoundNextPage(context, options);
  }

  void willTransitionRoute(BuildContext context, Options options) {
    adaptorDelegate?.willTransitionRoute(context, options);
  }

  Future<bool> shouldTransitionRoute(BuildContext context, Options options) {
    return adaptorDelegate?.shouldTransitionRoute(context, options) ??
        Future.value(true);
  }

  Widget? willTransitionPage(BuildContext context, Options options) {
    final nextPage = adaptorDelegate?.willTransitionPage(context, options);
    if (nextPage != null) return nextPage;
    return performOptions<Widget>(options, context: context);
  }
}

abstract class RouteModule extends RouteAdaptor {
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

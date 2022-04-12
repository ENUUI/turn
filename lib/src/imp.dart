import 'dart:async';
import 'package:flutter/material.dart';
import 'package:turn/src/express.dart';
import 'package:turn/src/turn.dart';
import 'mediator.dart';
import 'opts.dart';

class Turn {
  Turn._();

  static RouteModule get _adaptor => Mediator.adaptor;

  static void pop<T extends Object>(BuildContext context, [T? result]) =>
      _adaptor.pop<T>(context, result);

  static Future<bool> maybePop<T extends Object>(BuildContext context,
          [T? result]) =>
      _adaptor.maybePop<T>(context, result);

  static void popUntil(BuildContext context, String action) =>
      _adaptor.popUntil(context, action);

  static bool canPop(BuildContext context) => _adaptor.canPop(context);

  static Future to(
    BuildContext context,
    String action, {
    Map<String, dynamic>? params,
    String? package,
    Express? express,
    bool replace = false,
    bool clearStack = false,
    TransitionType transition = TransitionType.native,
    RouteTransitionsBuilder? transitionBuilder,
    Duration duration = const Duration(milliseconds: 250),
    TurnRouteBuilder? turnRouteBuilder,
    RoutePredicate? predicate, // clearStack = true
  }) async {
    return Mediator.adaptor.to(
      context,
      action,
      params: params,
      package: package,
      express: express,
      replace: replace,
      clearStack: clearStack,
      transition: transition,
      transitionBuilder: transitionBuilder,
      duration: duration,
      turnRouteBuilder: turnRouteBuilder,
      predicate: predicate,
    );
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
    return MaterialPageRoute(builder: (context) {
      final page = Mediator.perform<Widget>(context, opts);
      if (page != null) return page;
      final page404 = Mediator.notFound?.call(context, opts);
      if (page404 != null && page404 is Widget) return page404;
      assert(() {
        throw throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('Page Not Found!'),
          ErrorDescription('${opts.toString()}')
        ]);
      }());
      return const Scaffold();
    });
  }
}

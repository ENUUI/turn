import 'package:flutter/material.dart';
import 'package:turn/src/express.dart';
import 'package:turn/src/opts.dart';
import 'package:turn/src/turn.dart';

abstract class TurnAbility {
  Future to(
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
    bool innerPackage = false,
  });

  void pop<T extends Object>(BuildContext context, [T? result]) =>
      Navigator.pop<T>(context, result);

  Future<bool> maybePop<T extends Object>(BuildContext context, [T? result]) =>
      Navigator.maybePop<T>(context, result);

  void popUntil(BuildContext context, String action) => Navigator.popUntil(
        context,
        ModalRoute.withName(Options(action: action).path),
      );

  bool canPop(BuildContext context) => Navigator.canPop(context);
}

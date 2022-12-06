import 'package:example/home.dart';
import 'package:example/pages/me/index.dart';
import 'package:example/sub_module/routes/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:turn/turn.dart';

import '../pages/discovery/index.dart';

class AppRoute extends TurnTo {
  AppRoute._();

  static final AppRoute I = AppRoute._();

  final MainModule main = MainModule();
  final SubModule sub = SubModule();
}

class MainModule extends Package {
  @override
  String get package => 'main';

  @override
  void install() {
    registerRoute(TurnRoute(
      Navigator.defaultRouteName,
      (context, args) => Home(),
    ));
    registerRoute(TurnRoute(
      'discovery',
      (context, args) => DiscoveryPage(),
    ));
    registerRoute(TurnRoute(
      'me/:id',
      (context, args) => MePage(),
      transitionMode: TransitionMode.modal,
      queryTypeMap: {'id': QueryType.integer},
    ));
  }

  @override
  Future? willTurnTo(BuildContext context, TurnRoute turnRoute, Arguments arguments,
      {TransitionMode? mode,
      bool rootNavigator = false,
      Object? result,
      bool isReplace = false,
      bool isRemoveUntil = false,
      RoutePredicate? routePredicate}) {
    return super.willTurnTo(
      context,
      turnRoute,
      arguments,
      rootNavigator: rootNavigator,
      mode: mode,
      result: result,
      isReplace: isReplace,
      isRemoveUntil: isRemoveUntil,
      routePredicate: routePredicate,
    );
  }

  @override
  Future beforeTurnTo(BuildContext context, TurnRoute turnRoute, Arguments arguments) {
    return super.beforeTurnTo(context, turnRoute, arguments);
  }
}

void initAppRoute() {
  AppRoute.I.registerPackage(AppRoute.I.main);
  AppRoute.I.registerPackage(AppRoute.I.sub);
  AppRoute.I.fire();
}

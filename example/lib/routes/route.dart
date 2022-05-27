import 'package:example/home.dart';
import 'package:example/pages/me/index.dart';
import 'package:example/sub_module/routes/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:turn/turn.dart';

import '../pages/discovery/index.dart';

class AppRoute extends Project {
  AppRoute._();

  static final AppRoute I = AppRoute._();

  final MainModule main = MainModule();
  final SubModule sub = SubModule();
}

class MainModule extends Module {
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
}

void initAppRoute() {
  AppRoute.I.registerModule(AppRoute.I.main);
  AppRoute.I.registerModule(AppRoute.I.sub);
  AppRoute.I.fire();
}

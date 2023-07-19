import 'package:example/home.dart';
import 'package:example/pages/me/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:turn/turn.dart';

import '../pages/discovery/index.dart';
import '../sub_module/pages/discovery/index.dart';
import '../sub_module/pages/index/index.dart';

class MainModule extends TurnDelegate {}

void initAppRoute() {
  final worker = Turn.worker;
  worker.addRoute(TurnRoute(
    Navigator.defaultRouteName,
    (context, args) => Home(),
  ));
  worker.addRoute(TurnRoute(
    'discovery',
    (context, args) => DiscoveryPage(),
  ));
  worker.addRoute(TurnRoute(
    'me/:id',
    (context, args) => MePage(),
    transitionMode: TransitionMode.modal,
    queryTypeMap: {'id': QueryType.integer},
  ));

  worker.addRoute(TurnRoute(
    'sub/page',
    (context, args) => SubIndex(),
    package: 'sub',
  ));
  worker.addRoute(TurnRoute(
    'discovery',
    (context, args) => Discovery(),
    package: 'sub',
  ));
}

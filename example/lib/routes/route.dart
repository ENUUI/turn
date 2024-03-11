import 'package:example/home.dart';
import 'package:example/pages/me/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:turn/turn.dart';

import '../pages/discovery/index.dart';
import '../sub_module/pages/discovery/index.dart';
import '../sub_module/pages/index/index.dart';

class MainModule extends TurnDelegate {}

void initAppRoute() {
  Turn.addRoute(TurnRoute(
    Navigator.defaultRouteName,
    (context, args) => const Home(),
  ));
  Turn.addRoute(TurnRoute(
    'discovery',
    (context, args) => const DiscoveryPage(),
  ));
  Turn.addRoute(TurnRoute(
    'me/:id',
    (context, args) => const MePage(),
    transitionMode: TransitionMode.modal,
    queryTypeMap: {'id': QueryType.integer},
  ));

  Turn.addRoute(TurnRoute(
    'sub/page',
    (context, args) => const SubIndex(),
    package: 'sub',
  ));
  Turn.addRoute(TurnRoute(
    'discovery',
    (context, args) => const Discovery(),
    package: 'sub',
  ));
}

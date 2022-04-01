import 'package:example/pages4/trun_target.dart';
import 'package:flutter/material.dart';
import 'package:turn/turn.dart';
import '../page1/action_one.dart';
import '../page2/action_two.dart';
import '../page3/action_three.dart';

void registerTargets() {
  // Turn.shouldTransitionRoute = (ctx, opts) async {
  //   if (opts.path == '/refuse') {
  //     print('''${opts.action} will be refused by shouldTransitionRoute.
  //     参数：
  //     $opts''');
  //     return false;
  //   }
  //   return true;
  // };
  //
  // Turn.willTransitionRoute = (ctx, opts) {
  //   print("Turn will push `$opts`.");
  // };
  //
  // Turn.notFoundNextPage = (c, p) {
  //   return Scaffold(
  //     body: Center(
  //       child: Text(
  //         '''
  //         404 NOT FOUND!
  //         ''',
  //         style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
  //         textAlign: TextAlign.center,
  //       ),
  //     ),
  //   );
  // };

  Mediator.registerTarget(target: ActionOne());
  Mediator.registerTarget(target: ActionTwo());
  // Mediator.registerTarget(target: ActionThree());
  Mediator.registerTarget(target: Target4());

  Mediator.registerModule('p', RouteModule4());
}

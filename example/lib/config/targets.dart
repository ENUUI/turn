import 'package:turn/turn.dart';
import '../home.dart';
import '../page1/action_one.dart';
import '../page2/action_two.dart';

void registerTargets() {
  Turn.shouldPushRoute = (ctx, route) {
    print(
        "If [shouldPushRoute] return false, turn to `$route` will be stopped.");
    return true;
  };

  Turn.willPushRoute = (ctx, route) {
    print("Turn will push `$route`.");
  };

  Mediator.rootPage = (params) {
    return Home();
  };

  Mediator.registerTarget(target: ActionOne());
  Mediator.registerTarget(target: ActionTwo());
}

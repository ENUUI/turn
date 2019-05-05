import 'package:turn/turn.dart';
import '../home.dart';
import '../page1/action_one.dart';
import '../page2/action_two.dart';


void registerTargets() {
  Mediator.rootPage = (params) {
    return Home();
  };

  Mediator.registerTarget(target: ActionOne());
  Mediator.registerTarget(target: ActionTwo());
}

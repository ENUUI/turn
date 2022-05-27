import 'package:example/sub_module/pages/discovery/index.dart';
import 'package:turn/turn.dart';

import '../pages/index/index.dart';

class SubModule extends Module {
  SubModule();

  @override
  String get package => 'sub';

  @override
  void install() {
    registerRoute(TurnRoute('sub/page', (context, args) => SubIndex()));
    registerRoute(TurnRoute('discovery', (context, args) => Discovery()));
  }
}

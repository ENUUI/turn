import 'package:flutter/material.dart';

import '../../src/turn_deprecated.dart';
import 'matchable.dart';

abstract class Target {
  @Deprecated('Use [registerTurnRoutes] instead.')
  dynamic task(String action, Map<String, dynamic>? params) {}

  @Deprecated('Use [registerTurnRoutes] instead.')
  dynamic response(BuildContext? context, Options options) {
    return task(options.path, options.params);
  }

  void registerTurnRoutes(Module module) {}
}

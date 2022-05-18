import 'package:flutter/foundation.dart';

import 'module.dart';

abstract class Project {
  final Map<Object, Module> _modulesMap = <Object, Module>{};

  Iterable<Module> get modules => _modulesMap.values;

  void registerModule(Object package, Module module) {
    assert(() {
      if (_modulesMap.containsKey(package)) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('Package($package) has been added.'),
        ]);
      }
      return true;
    }());
    if (_modulesMap.containsKey(package)) {
      return;
    }
    _modulesMap[package] = module;
  }

  Module? getModule(Object package) => _modulesMap[package];

  void forEach(bool Function(Object package, Module module) action,
      [Module? excludeModule, Object? excludePackage]) {
    for (final package in _modulesMap.keys) {
      final module = _modulesMap[package];
      if (package == excludePackage || module == excludeModule) {
        continue;
      }
      if (action(package, module!)) {
        break;
      }
    }
  }
}

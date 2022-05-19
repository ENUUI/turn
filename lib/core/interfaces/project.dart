import 'package:flutter/material.dart';
import 'package:turn/src/express.dart';
import 'package:turn/src/opts.dart';
import 'package:turn/src/turn.dart';

import '../impl/navigator_to.dart';
import 'module.dart';
import 'turn_ability.dart';

abstract class Project extends TurnAbility {
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

  @override
  Future to(
    BuildContext context,
    String action, {
    Map<String, dynamic>? params,
    Object? package,
    Express? express,
    bool replace = false,
    bool clearStack = false,
    TransitionType transition = TransitionType.native,
    RouteTransitionsBuilder? transitionBuilder,
    Duration duration = const Duration(milliseconds: 250),
    TurnRouteBuilder? turnRouteBuilder,
    RoutePredicate? predicate,
    bool innerPackage = false, // 当指定 package 时有效
  }) {
    final options = Options(
      action: action,
      params: params,
      express: express,
    );

    Module? module;
    NextPageBuilder? builder;
    if (package != null) {
      module = getModule(package);
      assert(() {
        if (module == null) {
          throw FlutterError('None module matched package($package)!');
        }
        return true;
      } ());
      // builder = module?.fetch(options);
      if (builder == null && !innerPackage) {

      }
    }
    return NavigatorTo.to(
      context,
      RouteSettings(name: options.path),
      (context) => Container(),
      replace: replace,
      clearStack: clearStack,
      transition: transition,
      transitionBuilder: transitionBuilder,
      duration: duration,
      turnRouteBuilder: turnRouteBuilder,
      predicate: predicate,
    );
  }
}

import 'package:flutter/widgets.dart';

import 'opts.dart';
import 'turn.dart';



class Mediator {
  static String defaultAdaptorPackage = '/';

  static T Function<T>(BuildContext context, Options options)? notFound;

  static RouteModule get adaptor => _adaptor;
  static final _DefaultAdaptor _adaptor = _DefaultAdaptor();

  static final Map<String, RouteModule> _modules = <String, RouteModule>{
    defaultAdaptorPackage: adaptor
  };

  static void registerTarget<T extends Target>({required T target}) {
    _adaptor.registerTarget(target);
  }

  static RouteModule? moduleOf(String package) {
    assert(package.isNotEmpty);
    return _modules[package];
  }

  static void registerModule<T extends RouteModule>(String package, T module) {
    assert(package.isNotEmpty);
    assert(() {
      if (_modules.containsKey(package)) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('Package($package) has been added.'),
        ]);
      }

      return true;
    }());

    if (_modules.containsKey(package)) return;

    _modules[package] = module;
  }

  static T? perform<T>(
    BuildContext? context,
    Options opts, [
    Adaptor? excludeModule,
  ]) {
    T? result;
    for (final module in _modules.values) {
      if (excludeModule == module) {
        continue;
      }
      result = module.resolveAction(context, opts);
      if (result != null) {
        break;
      }
    }
    return result;
  }
}

class _DefaultAdaptor extends RouteModule {
  @override
  final List<Target> targets = <Target>[];

  final List<RouteAdaptor> subModules = <RouteAdaptor>[];

  void registerTarget<T extends Target>(T target) {
    if (targets.contains(target)) return;
    assert(_debugDuplicateCheck(targets, target));
    targets.add(target);
  }

  void registerModule<T extends RouteAdaptor>(T module) {
    if (subModules.contains(module)) return;
    assert(_debugDuplicateCheck(subModules, module));
    subModules.add(module);
  }
}

bool _debugDuplicateCheck(List source, Object object) {
  assert(() {
    source.forEach((e) {
      if (e.runtimeType == object.runtimeType) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
              'Multiple targets is same type [${object.runtimeType}].'),
          ErrorDescription(
              'Only one target inserted early will be found out to run a task')
        ]);
      }
    });
    return true;
  }());
  return true;
}

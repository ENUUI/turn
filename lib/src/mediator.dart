import 'package:flutter/widgets.dart';

import 'opts.dart';
import 'turn.dart';

class Mediator {
  static RouteModule get adaptor => _adaptor;
  static final _DefaultAdaptor _adaptor = _DefaultAdaptor();

  static void registerTarget<T extends Target>({required T target}) {
    _adaptor.registerTarget(target);
  }

  static void registerModule<T extends RouteAdaptor>(T module) {
    _adaptor.registerModule(module);
  }

  static T? performOptions<T>(
    BuildContext? context,
    Options opts, [
    Adaptor? excludeModule,
  ]) {
    return _adaptor.resolveFallThroughAction<T>(context, opts, excludeModule);
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

  T? resolveFallThroughAction<T>(
    BuildContext? context,
    Options opts, [
    Adaptor? excludeModule,
  ]) {
    var result = resolveAction<T>(context, opts);

    if (result == null && subModules.isNotEmpty) {
      for (final m in subModules) {
        if (excludeModule == m) {
          continue;
        }

        result = m.resolveAction<T>(context, opts);
        if (result != null) {
          break;
        }
      }
    }
    return result;
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
}

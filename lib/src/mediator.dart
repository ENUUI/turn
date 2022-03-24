import 'package:flutter/widgets.dart';

import 'express.dart';
import 'opts.dart';
import 'turn.dart';

class _DefaultAdaptor extends RouteModule {
  @override
  final List<Target> targets = <Target>[];

  final List<RouteAdaptorHooks> subModules = <RouteAdaptorHooks>[];

  void registerTarget<T extends Target>(T target) {
    if (targets.contains(target)) return;
    assert(_debugDuplicateCheck(targets, target));
    targets.add(target);
  }

  void registerModule<T extends RouteAdaptorHooks>(T module) {
    if (subModules.contains(module)) return;
    assert(_debugDuplicateCheck(subModules, module));
    subModules.add(module);
  }

  T? resolveFallThroughAction<T>(
    BuildContext? context,
    Options opts, [
    RouteAdaptorHooks? excludeModule,
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

class Mediator {
  static dynamic Function(String? action)? notFound;

  static RouteModule get adaptor => _adaptor;
  static final _DefaultAdaptor _adaptor = _DefaultAdaptor();

  static void registerTarget<T extends Target>({required T target}) {
    _adaptor.registerTarget(target);
  }

  static void registerModule<T extends RouteAdaptorHooks>(T module) {
    _adaptor.registerModule(module);
  }

  static T? perform<T>(
    String action, {
    BuildContext? context,
    Map<String, dynamic>? params,
    Express? express,
  }) {
    assert(action.isNotEmpty, 'action can not be empty!');
    final opts = Options(action: action, params: params, express: express);

    return performOptions(context, opts);
  }

  static T? performOptions<T>(
    BuildContext? context,
    Options opts, [
    RouteAdaptorHooks? excludeModule,
  ]) {
    T? result = _adaptor.resolveFallThroughAction(context, opts, excludeModule);
    if (result == null && notFound != null) {
      result = notFound!(opts.path);
    }
    return result;
  }
}

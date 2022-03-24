import 'package:flutter/widgets.dart';
import 'opts.dart';

abstract class Target {
  dynamic task(String action, Map<String, dynamic>? params) {}

  dynamic response(BuildContext? context, Options options) {
    return task(options.path, options.params);
  }
}

abstract class Adaptor {
  List<Target> get targets;

  T? resolveAction<T>(BuildContext? context, Options opts) {
    T? result;
    int i = 0;
    for (; i < targets.length; i++) {
      result = targets[i].response(context, opts);
      if (result != null) break;
    }
    assert(() {
      i++;
      final responseTargets = <Target>[];
      Target t;
      for (; i < targets.length; i++) {
        t = targets[i];
        if (t.response(context, opts) != null) responseTargets.add(t);
      }
      if (responseTargets.length > 0) {
        final msg = responseTargets..map((e) => '[${e.toString()}]').join(',');
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('One action got the response of multiple targets'),
          ErrorDescription('${opts.path}: $msg')
        ]);
      }
      return true;
    }());
    return result;
  }
}

class _DefaultAdaptor extends Adaptor {
  @override
  final List<Target> targets = <Target>[];

  void registerTarget(Target target) {
    if (targets.contains(target)) return;
    assert(() {
      targets.forEach((e) {
        if (e.runtimeType == target.runtimeType) {
          throw FlutterError.fromParts(<DiagnosticsNode>[
            ErrorSummary(
                'Multiple targets is same type [${target.runtimeType}].'),
            ErrorDescription(
                'Only one target inserted early will be found out to run a task')
          ]);
        }
      });

      return true;
    }());
    targets.add(target);
  }
}

class Mediator {
  static dynamic Function(String? action)? notFound;
  static final _DefaultAdaptor _adaptor = _DefaultAdaptor();

  static void registerTarget({required Target target}) {
    _adaptor.registerTarget(target);
  }

  static T? performOptions<T>(BuildContext? context, Options opts) {
    return _adaptor.resolveAction(context, opts);
  }
}

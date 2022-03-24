import 'package:flutter/widgets.dart';
import 'package:turn/src/express.dart';

import 'opts.dart';

abstract class Target {
  dynamic task(String action, Map<String, dynamic>? params) {}

  dynamic response(BuildContext? context, Options options) {
    return task(options.path, options.params);
  }
}

class Mediator {
  static dynamic Function(String? action)? notFound;
  static List<Target> _mediatorTargets = <Target>[];

  static registerTarget({required Target target}) {
    if (_mediatorTargets.contains(target)) return;
    assert(() {
      _mediatorTargets.forEach((e) {
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
    _mediatorTargets.add(target);
  }

  static dynamic perform(
    String action, {
    BuildContext? context,
    Map<String, dynamic>? params,
    Express? express,
  }) {
    assert(action.isNotEmpty, 'action can not be empty!');
    final opts = Options(action: action, params: params, express: express);

    return performOptions(context, opts);
  }

  static dynamic performOptions(BuildContext? context, Options opts) {
    final result = _resolveAction(context, opts);
    if (result == null && notFound != null) return notFound!(opts.action);

    return result;
  }

  static dynamic _resolveAction(BuildContext? context, Options opts) {
    var result;
    int i = 0;
    for (; i < _mediatorTargets.length; i++) {
      result = _mediatorTargets[i].response(context, opts);
      if (result != null) break;
    }
    assert(() {
      i++;
      final responseTargets = <Target>[];
      Target t;
      for (; i < _mediatorTargets.length; i++) {
        t = _mediatorTargets[i];
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

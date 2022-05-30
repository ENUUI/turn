import 'package:flutter/material.dart';

import '../core/interfaces/navigateable.dart';
import '../core/routes/transition_mode.dart';

@Deprecated('Use [TransitionMode] instead')
enum TransitionType {
  native,
  nativeModal,
  inFromLeft,
  inFromRight,
  inFromBottom,
  fadeIn,
  custom, // Custom RouteTransitionsBuilder
  customRoute, // Custom Route
}

@Deprecated('')
typedef TurnPageBuilder = Widget? Function(
    BuildContext context, Options options);

@Deprecated('')
typedef TurnRouteBuilder = Route<T> Function<T extends Object?>(
  BuildContext? context,
  WidgetBuilder nextPageBuilder,
);

@Deprecated('')
typedef TurnToRouteBuilder = Future Function(
  BuildContext context,
  Options options, {
  TransitionType transition,
  RouteTransitionsBuilder? transitionBuilder,
  Duration duration,
  TurnRouteBuilder? turnRouteBuilder,
  bool innerPackage,
  bool replace,
  bool clearStack,
});

@Deprecated('')
abstract class Express {
  /// Do not set any data to [extraQuery]
  /// [extraQuery] will be covered when parsing [params] and [action]
  Map<String, dynamic>? extraQuery;

  @override
  String toString() {
    return '''
    Instance of $runtimeType
    extraQuery: $extraQuery
    ''';
  }
}

@Deprecated('已过时')
class Options {
  Options({
    required this.action,
    Map<String, dynamic>? params,
    this.express,
    this.data,
  }) {
    _setOpts(params);
  }

  @Deprecated('过时，使用data代替')
  final Express? express;
  final String action;
  final Object? data;

  Map<String, dynamic>? get params => _params;
  Map<String, dynamic>? _params;

  String get path => _path;
  String _path = '';

  List<String>? get components => _components;
  List<String>? _components;

  String? operator [](int depth) {
    if (_components == null ||
        _components!.isEmpty ||
        _components!.length <= depth) return null;
    return _components![depth];
  }

  void _setOpts(Map<String, dynamic>? params) {
    if (action == Navigator.defaultRouteName) {
      _path = Navigator.defaultRouteName;
      express?.extraQuery = params;
      this._params = params;
      return;
    }
    String actionPath = action;
    Map<String, dynamic>? _params = params != null ? Map.of(params) : null;
    if (actionPath.contains('?')) {
      final splits = actionPath.split('?');
      actionPath = splits[0];
      final componentParams = _separateQuery(splits[1]);
      if (componentParams.isNotEmpty) {
        _params ??= <String, dynamic>{};
        _params.addAll(componentParams);
      }
    }

    if (_params != null) {
      express?.extraQuery = _params;
      this._params = _params;
    }

    if (actionPath.isEmpty) return;

    _path = actionPath;
    if (!_path.startsWith('/')) _path = '/' + _path;

    if (actionPath != '/') _components = actionPath.split('/');
  }

  @override
  String toString() => '''
    $runtimeType
    path: $path,
    params: $express
    ''';
}

Map<String, dynamic> _separateQuery(String query) {
  final search = RegExp('([^&=]+)=?([^&]*)');
  final params = Map<String, dynamic>();

  if (query.startsWith('?')) query = query.substring(1);

  decode(String s) => Uri.decodeComponent(s.replaceAll('+', ' '));

  for (Match match in search.allMatches(query)) {
    String key = decode(match.group(1)!);
    String value = decode(match.group(2)!);

    if (params.containsKey(key) && params[key] != null) {
      final beforeValue = params[key];
      if (beforeValue is List) {
        beforeValue.add(value);
      } else {
        params[key] = <dynamic>[beforeValue, value];
      }
    } else {
      params[key] = value;
    }
  }
  return params;
}

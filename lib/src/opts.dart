import 'package:flutter/widgets.dart';
import 'package:turn/src/express.dart';

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

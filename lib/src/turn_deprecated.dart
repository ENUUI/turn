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

extension NavigatorToDeprecated on Navigateable {
  @Deprecated('Use [push] [pushUntil] [replace] instead')
  Future to(
    BuildContext context,
    String action, {
    String? package,
    @Deprecated('Use [data] instead') Map<String, dynamic>? params,
    @Deprecated('Use [data] instead') Express? express,
    Object? data,
    bool replace = false,
    bool clearStack = false,
    @Deprecated('Use [TransitionMode] instead') TransitionType? transition,
    TransitionMode? transitionMode,
    @Deprecated('Use [TransitionMode] instead')
        RouteTransitionsBuilder? transitionBuilder,
    @Deprecated('Use [TransitionMode] instead')
        Duration duration = const Duration(milliseconds: 250),
    @Deprecated('Use [TransitionMode] instead')
        TurnRouteBuilder? turnRouteBuilder,
    RoutePredicate? predicate, // clearStack = true
  }) async {
    TransitionMode mode = transitionMode ??
        transition?.convertTo(
          transitionsBuilder: transitionBuilder,
          context: context,
          routeBuilder: turnRouteBuilder,
        ) ??
        TransitionMode.native;
    if (replace) {
      return this.replace(
        context,
        action,
        data: data ?? params ?? express,
        package: package,
        fallthrough: true,
        transitionMode: mode,
      );
    } else if (clearStack) {
      return pushUntil(
        context,
        action,
        data: data ?? params ?? express,
        package: package,
        fallthrough: true,
        transitionMode: mode,
        routePredicate: predicate,
      );
    } else {
      return push(
        context,
        action,
        data: data ?? params ?? express,
        package: package,
        fallthrough: true,
        transitionMode: mode,
      );
    }
  }
}

extension TransitionTypeToMode on TransitionType {
  TransitionMode convertTo({
    RouteTransitionsBuilder? transitionsBuilder,
    BuildContext? context,
    TurnRouteBuilder? routeBuilder,
  }) {
    switch (this) {
      case TransitionType.native:
        return TransitionMode.native;
      case TransitionType.nativeModal:
        return TransitionMode.modal;
      case TransitionType.inFromLeft:
        return TransitionMode.inFromLeft;
      case TransitionType.inFromRight:
        return TransitionMode.inFromRight;
      case TransitionType.inFromBottom:
        return TransitionMode.inFromBottom;
      case TransitionType.fadeIn:
        return TransitionMode.fadeIn;
      case TransitionType.custom:
        assert(
          transitionsBuilder != null,
          'Case [TransitionType.custom], transitionsBuilder should not be empty',
        );
        if (transitionsBuilder == null) {
          return TransitionMode.native;
        }
        return _CustomTransitionMode(transitionsBuilder);
      case TransitionType.customRoute:
        assert(
          context != null && routeBuilder != null,
          'Case TransitionType.customRoute, context and routeBuilder should not be empty.',
        );
        if (context == null || routeBuilder == null) {
          return TransitionMode.native;
        }
        return _CustomRouteTransitionMode(context, routeBuilder);
    }
  }
}

class _CustomTransitionMode extends TransitionMode {
  _CustomTransitionMode(this.transitionsBuilder);

  final RouteTransitionsBuilder transitionsBuilder;

  @override
  Route<T> generator<T extends Object?>(
      WidgetBuilder builder, RouteSettings? settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, _, __) => builder(context),
      transitionsBuilder: transitionsBuilder,
    );
  }
}

class _CustomRouteTransitionMode extends TransitionMode {
  _CustomRouteTransitionMode(this.context, this.routeBuilder);

  BuildContext context;
  TurnRouteBuilder routeBuilder;

  @override
  Route<T> generator<T extends Object?>(
      WidgetBuilder builder, RouteSettings? settings) {
    return routeBuilder<T>(context, builder);
  }
}

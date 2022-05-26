import 'dart:async';
import 'package:flutter/material.dart';
import 'package:turn/src/express.dart';
import 'package:turn/src/turn.dart';
import '../core/interfaces/project.dart';
import '../core/routes/transition_mode.dart';

class Turn {
  static Project get project {
    if (_project == null) {
      throw FlutterError('Set an instance of Project before use.');
    }
    return _project!;
  }

  static Project? _project;

  static void setProject(Project project) {
    _project = project;
  }

  static void pop<T extends Object>(BuildContext context, [T? result]) =>
      project.pop<T>(context, result);

  static Future<bool> maybePop<T extends Object>(BuildContext context,
          [T? result]) =>
      project.maybePop<T>(context, result);

  static void popUntil(BuildContext context, String action) =>
      project.popUntil(context, action);

  static bool canPop(BuildContext context) => project.canPop(context);

  static Future to(
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
      return project.replace(
        context,
        action,
        data: data ?? params ?? express,
        package: package,
        fallthrough: true,
        transitionMode: mode,
      );
    } else if (clearStack) {
      return project.pushUntil(
        context,
        action,
        data: data ?? params ?? express,
        package: package,
        fallthrough: true,
        transitionMode: mode,
        routePredicate: predicate,
      );
    } else {
      return project.push(
        context,
        action,
        data: data ?? params ?? express,
        package: package,
        fallthrough: true,
        transitionMode: mode,
      );
    }
  }

  static Route<dynamic> generator(RouteSettings routeSettings) {
    return project.generator(routeSettings);
  }
}

extension on TransitionType {
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

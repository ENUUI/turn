import 'package:flutter/material.dart';

import '../../src/turn.dart';
import '../routes/transition_mode.dart';

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

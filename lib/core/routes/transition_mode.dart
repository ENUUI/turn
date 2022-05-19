import 'package:flutter/material.dart';

const Duration kTransitionDuration = Duration(milliseconds: 300);

abstract class TransitionMode {
  static const TransitionMode native = _Native();
  static const TransitionMode modal = _NativeModal();
  static const TransitionMode fadeIn = _FadeIn();
  static const TransitionMode inFromTop = _InFromLeft(Offset(0.0, -1.0));
  static const TransitionMode inFromRight = _InFromLeft(Offset(1.0, 0.0));
  static const TransitionMode inFromBottom = _InFromLeft(Offset(0.0, 1.0));
  static const TransitionMode inFromLeft = _InFromLeft(Offset(-1.0, 0.0));

  Route<T> generator<T extends Object?>(
    WidgetBuilder builder,
    RouteSettings? settings,
  );
}

class _Native implements TransitionMode {
  const _Native();

  @override
  Route<T> generator<T extends Object?>(
      WidgetBuilder builder, RouteSettings? settings) {
    return MaterialPageRoute<T>(
      settings: settings,
      builder: builder,
    );
  }
}

class _NativeModal implements TransitionMode {
  const _NativeModal();

  @override
  Route<T> generator<T extends Object?>(
      WidgetBuilder builder, RouteSettings? settings) {
    return MaterialPageRoute<T>(
      fullscreenDialog: true,
      settings: settings,
      builder: builder,
    );
  }
}

class _FadeIn implements TransitionMode {
  const _FadeIn();

  @override
  Route<T> generator<T extends Object?>(
      WidgetBuilder builder, RouteSettings? settings) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: kTransitionDuration,
      pageBuilder: (context, _, __) => builder(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}

class _InFromLeft implements TransitionMode {
  const _InFromLeft(this.begin);

  final Offset begin;

  @override
  Route<T> generator<T extends Object?>(
      WidgetBuilder builder, RouteSettings? settings) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: kTransitionDuration,
      pageBuilder: (context, _, __) => builder(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: begin,
            end: const Offset(0.0, 0.0),
          ).animate(animation),
          child: child,
        );
      },
    );
  }
}

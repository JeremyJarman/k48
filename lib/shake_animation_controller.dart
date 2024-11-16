import 'package:flutter/material.dart';

class ShakeAnimationController {
  final AnimationController controller;
  late final Animation<double> animation;

  ShakeAnimationController({required TickerProvider vsync})
      : controller = AnimationController(
          duration: const Duration(milliseconds: 500),
          vsync: vsync,
        ) {
    animation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 10.0), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 25),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: 0.0), weight: 25),
    ]).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.fastOutSlowIn,
    ));
  }

  void shake() {
    controller.forward(from: 0.0);
  }

  void dispose() {
    controller.dispose();
  }
}
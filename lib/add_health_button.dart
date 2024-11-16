import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'my_app_state.dart';
import 'shake_animation_controller.dart';

class AddHealthButton extends StatelessWidget {
  final ShakeAnimationController shakeController;

  AddHealthButton({required this.shakeController});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return AnimatedBuilder(
      animation: shakeController.animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(shakeController.animation.value, 0),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: appState.mana >= 100 ? () {
          appState.addHealth();
          appState.mana = 0; // Reset mana after using the heart button
        } : null,
        child: Icon(
          Icons.favorite,
          color: appState.mana >= 100 ? Theme.of(context).primaryColor : Colors.white,
          size: 36,
        ),
      ),
    );
  }
}
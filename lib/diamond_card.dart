import 'package:flutter/material.dart';
import 'shake_animation_controller.dart';

class DiamondCard extends StatefulWidget {
  final int score;
  final int mana;
  final ShakeAnimationController shakeController;

  DiamondCard({required this.score, required this.mana, required this.shakeController});

  @override
  _DiamondCardState createState() => _DiamondCardState();
}

class _DiamondCardState extends State<DiamondCard> {
  @override
  Widget build(BuildContext context) {
    double progress = (widget.mana / 100).clamp(0.0, 1.0);
    Color borderColor = Theme.of(context).primaryColor.withOpacity(progress);

    return AnimatedBuilder(
      animation: widget.shakeController.animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(widget.shakeController.animation.value, 0),
          child: child,
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: 0.785398, // 45 degrees in radians
            child: Card(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3), // Set the card color to primary container with 60% transparency
              shape: RoundedRectangleBorder(
                side: BorderSide(color: borderColor, width: 4), // Set the border color based on mana
                borderRadius: BorderRadius.circular(8),
              ),
              child: Container(
                width: 90,
                height: 90,
                alignment: Alignment.center,
                child: Transform.rotate(
                  angle: -0.785398, // Rotate text back to normal
                  child: Text(
                    '${widget.score}',
                    style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold), // Set text color to white and bold
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
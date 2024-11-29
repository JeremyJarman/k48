import 'package:flutter/material.dart';

class DiamondCard extends StatelessWidget {
  final int score;
  final int mana;

  DiamondCard({required this.score, required this.mana});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 100,
        height: 100,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              'assets/WarpFrame.png',
              width: 100,
              height: 100,
              fit: BoxFit.contain,
            ),
            Text(
              '$score',
              style: TextStyle(fontSize: 24, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
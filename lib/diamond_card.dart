import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'my_app_state.dart';

class DiamondCard extends StatelessWidget {
  final int score;
  final int mana;

  DiamondCard({required this.score, required this.mana});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 150,
        height: 150,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              'assets/WarpFrame.png',
              width: 150,
              height: 150,
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
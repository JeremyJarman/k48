import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'my_app_state.dart';

class AddHealthButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return GestureDetector(
      onTap: appState.mana >= 100 ? () {
        appState.addHealth();
        appState.mana = 0; // Reset mana after using the heart button
      } : null,
      child: Icon(
        Icons.favorite,
        color: appState.mana >= 100 ? Colors.red : Colors.grey,
        size: 50,
      ),
    );
  }
}
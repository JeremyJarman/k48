import 'package:flutter/material.dart';

class AddHealthButton extends StatelessWidget {
  final int mana;
  final VoidCallback onPressed;

  const AddHealthButton({super.key, required this.mana, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: mana == 10 ? onPressed : null, // Activate button only if mana is 10
      backgroundColor: Colors.transparent, // No background color
      elevation: 0, // Remove shadow
      child: Icon(Icons.favorite, color: mana == 10 ? Colors.white : Colors.grey, size: 50),
    );
  }
}
import 'package:flutter/material.dart';

class OptionCard extends StatelessWidget {
  final String text;
  final String letter;
  final VoidCallback onPressed;

  OptionCard({required this.text, required this.letter, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.3),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        ),
        onPressed: onPressed,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('($letter) '),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }
}
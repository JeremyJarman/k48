import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'my_app_state.dart';

class AdminPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await Provider.of<MyAppState>(context, listen: false).loadNounsFromAssets();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Nouns uploaded successfully')),
                );
              },
              child: Text('Upload Nouns'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await Provider.of<MyAppState>(context, listen: false).loadAdjectivesFromAssets();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Adjectives uploaded successfully')),
                );
              },
              child: Text('Upload Adjectives'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await Provider.of<MyAppState>(context, listen: false).uploadStarsToFirestore();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Stars uploaded successfully')),
                );
              },
              child: Text('Upload Stars'),
            ),
          ],
        ),
      ),
    );
  }
}
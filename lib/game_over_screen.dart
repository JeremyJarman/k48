import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'main.dart';
import 'review_screen.dart';
import 'my_app_state.dart';
import 'home_page.dart';

class GameOverScreen extends StatelessWidget {
  final int score;
  final List<Map<String, String>> failedPairs; // Add a parameter for the failed pairs

  GameOverScreen({required this.score, required this.failedPairs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Extend the body behind the app bar
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.3), // Set the app bar to be 30% transparent
        title: Text('Game Over', style: TextStyle(color: Colors.white)), // Set the app bar text to white
        iconTheme: IconThemeData(color: Colors.white), // Set the app bar icon to white
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/galaxy.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: 1.5, // Adjust the scale factor as needed
                child: SvgPicture.asset(
                  'assets/GameOverFrame.svg',
                  width: 300, // Adjust the width as needed
                  height: 300, // Adjust the height as needed
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 120), // Add some space at the top
                  Text(
                    'Your ship is damaged\nbeyond repair!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center, // Center the text
                  ),
                  SizedBox(height: 350),
                  Text(
                    'Distance traveled:',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                    textAlign: TextAlign.center, // Center the text
                  ),
                  Text(
                    '$score ly',
                    style: TextStyle(fontSize: 30, color: Colors.white),
                    textAlign: TextAlign.center, // Center the text
                  ),
                  SizedBox(height: 90),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ReviewScreen(failedPairs: failedPairs)),
                      );
                    },
                    child: Text('Review'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => MyHomePage()),
                        (route) => false,
                      );
                    },
                    child: Text('Admit Defeat'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      //Provider.of<MyAppState>(context, listen: false).resetToLastStar();
                      Navigator.of(context).pop(); // Go back to the main game screen
                    },
                    child: Text('Return to Last Star'),
                  ),
                  SizedBox(height: 50), // Add some space at the bottom
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
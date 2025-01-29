import 'package:flutter/material.dart';
//import 'package:provider/provider.dart';
//import 'my_app_state.dart';
import 'german_noun_quiz.dart';

class DifficultySelection extends StatelessWidget {
  final String agent;

  DifficultySelection({required this.agent});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Extend the body behind the app bar
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.6), // Set the app bar to be 60% transparent
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // Make the back arrow white
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Select Difficulty',
          style: TextStyle(color: Colors.white), // Make the text white
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/galaxy.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  //Provider.of<MyAppState>(context, listen: false).setDifficulty('Easy');
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GermanNounQuiz()),
                  );
                },
                child: Text('Easy'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  //Provider.of<MyAppState>(context, listen: false).setDifficulty('Intermediate');
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GermanNounQuiz()),
                  );
                },
                child: Text('Intermediate'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  //Provider.of<MyAppState>(context, listen: false).setDifficulty('Hardcore');
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GermanNounQuiz()),
                  );
                },
                child: Text('Hardcore'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'my_app_state.dart';
import 'custom_app_bar.dart';
import 'diamond_card.dart';
import 'noun_card.dart';
import 'add_health_button.dart';

class GermanNounQuiz extends StatefulWidget {
  int _mana = 0; // Track the mana points

  GermanNounQuiz();

  @override
  _GermanNounQuizState createState() => _GermanNounQuizState();
}

class _GermanNounQuizState extends State<GermanNounQuiz> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late FixedExtentScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scrollController = FixedExtentScrollController();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBody: true, // Extend the body behind the bottom app bar
      extendBodyBehindAppBar: true, // Extend the body behind the app bar
      appBar: AppBar(
        title: Text('German Noun Quiz'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              appState.saveProgress();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Progress saved successfully')),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/galaxy.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.1), // Adjust the spacing to account for the app bar
              Center(child: DiamondCard(score: appState.score, mana: appState.mana)),
              SizedBox(height: screenHeight * 0.02), // Adjust the spacing as needed
             // Center(
             //   child: NounCard(
             //     noun: appState.nouns[appState.currentIndex]['noun']!,
             //     selectedArticle: appState.selectedArticle,
             //     adjectives: appState.adjectives,
             //   ),
             // ),
              SizedBox(height: screenHeight * 0.02),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    appState.checkAnswer(context);
                    appState.checkProgress(context); // Check progress when the button is pressed
                  },
                  child: Text('Enter Gate'),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    appState.incrementScoreBy10(context); // Increment score by 10 for testing
                  },
                  child: Text('Add 10 Points'),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Expanded(
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black, Colors.black, Colors.transparent],
                      stops: [0.0, 0.2, 0.8, 1.0],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.dstIn,
                  child: ListWheelScrollView(
                    controller: _scrollController,
                    physics: FixedExtentScrollPhysics(),
                    diameterRatio: 2.0,
                    itemExtent: screenHeight * 0.1,
                    onSelectedItemChanged: (index) {
                      appState.selectArticle(appState.articles[index]);
                    },
                    children: appState.articles.map((article) {
                      return Container(
                        alignment: Alignment.center,
                        child: Text(
                          article,
                          style: TextStyle(
                            fontSize: screenHeight * 0.03,
                            color: appState.selectedArticle == article ? Colors.blue : Colors.white,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02), // Spacer to bring the scroll view closer to the button
            ],
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      //floatingActionButton: AddHealthButton(
      //  mana: _mana,
      //  onPressed: _addHealth,
      //  ), // Heart icon button
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).primaryColor.withOpacity(0.3), // Set color with 60% transparency
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0), // Reduced vertical padding
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.favorite, color: Colors.white, size: 24),
                  SizedBox(width: 5),
                  Text(
                    '${appState.healthPoints}',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    '${appState.correctStreak}',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 5),
                  Icon(Icons.whatshot, color: Colors.white, size: 24), // Small white flame icon
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

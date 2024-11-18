import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'my_app_state.dart';
import 'custom_app_bar.dart';
import 'diamond_card.dart';
import 'noun_card.dart';
import 'shake_animation_controller.dart';
import 'add_health_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'main.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class GermanNounQuiz extends StatefulWidget {
  final String agent;
  
  GermanNounQuiz({required this.agent});

  @override
  _GermanNounQuizState createState() => _GermanNounQuizState();
}

class _GermanNounQuizState extends State<GermanNounQuiz> with TickerProviderStateMixin {
  late ShakeAnimationController _shakeController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _shakeController = ShakeAnimationController(vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.nouns.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('German Noun Quiz'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    IconData abilityIcon;
    
    if (widget.agent == 'Nexar') {
      abilityIcon = MdiIcons.shield;
    } else if (widget.agent == 'Aevone') {
      abilityIcon = MdiIcons.magnify;
    } else {
      abilityIcon = Icons.help; // Default icon if no agent is selected
    }

    if (appState.mana >= 10) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }

    return Scaffold(
      extendBodyBehindAppBar: true, // Extend the body behind the app bar
      appBar: CustomAppBar(), // Use the custom app bar
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/galaxy.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 120), // Adjust the spacing to account for the app bar
            Center(child: DiamondCard(score: appState.score, mana: appState.mana, shakeController: _shakeController)),
            SizedBox(height: 40), // Adjust the spacing as needed
            Center(
              child: NounCard(
                noun: appState.nouns[appState.currentIndex]['noun']!,
                selectedArticle: appState.selectedArticle,
                adjectives: appState.adjectives,
              ),
            ),
            SizedBox(height: 40),
            Center(
              child: SizedBox(
                height: 180, // Set a fixed height for the ListWheelScrollView
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black,
                        Colors.black,
                        Colors.transparent,
                      ],
                      stops: [0.0, 0.3, 0.7, 1.0],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.dstIn,
                  child: ListWheelScrollView.useDelegate(
                    controller: FixedExtentScrollController(),
                    itemExtent: 60,
                    onSelectedItemChanged: (index) {
                      appState.selectArticle(['der', 'die', 'das'][index]);
                    },
                    physics: FixedExtentScrollPhysics(),
                    useMagnifier: true,
                    magnification: 1.2,
                    childDelegate: ListWheelChildBuilderDelegate(
                      builder: (context, index) {
                        return Center(
                          child: Text(
                            ['der', 'die', 'das'][index],
                            style: TextStyle(fontSize: 24, color: Colors.white), // Set the text color to white
                          ),
                        );
                      },
                      childCount: 3,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Dismissible(
                key: UniqueKey(),
                direction: DismissDirection.startToEnd, // Change swipe direction to left to right
                onDismissed: (direction) {
                  appState.checkAnswer(context);
                  if (!appState.isCorrect) {
                    _shakeController.shake();
                  }
                  if (appState.isCorrect) {
                    appState.nextNoun();
                  }
                },
                background: Container(
                  color: Theme.of(context).colorScheme.secondary,
                  alignment: Alignment.centerLeft, // Align the icon to the left
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    appState.checkAnswer(context);
                    if (!appState.isCorrect) {
                      _shakeController.shake();
                    }
                    if (appState.isCorrect) {
                      appState.nextNoun();
                    }
                  },
                  child: Text('Enter Gate'),
                ),
              ),
            ),
            Center(
              child: Column(
                children: [
                  Text('Correct Streak: ${appState.correctStreak}'),
                  Text('Score: ${appState.score}'), // Display the score
                  Text('High Score: ${appState.highScore}'),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Stack(
        children: [
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 40.0, bottom: 20.0),
              child: Row(
                children: [
                  
                  Icon(Icons.favorite, color: Colors.white, size: 24), // Small white heart icon
                  SizedBox(width: 5),
                  Text(
                    '${appState.healthPoints}',
                    style: TextStyle(
                      fontSize: 24,
                      color: appState.healthPoints < 40 ? Colors.red : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom:20.0),
            child: Row(
              
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AddHealthButton(shakeController: _shakeController,), // Heart icon button
                  SizedBox(width: 35),
                  Icon(
                    abilityIcon,
                    color: Colors.white,
                    size: 35,
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 40.0, bottom: 20.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  
                  Text(
                    '${appState.correctStreak}',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 5),
                  Icon(Icons.whatshot, color: Colors.white, size: 24), // Small white flame icon
                  ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}


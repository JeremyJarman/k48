import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'csv_loader.dart';
import 'my_app_state.dart';
import 'add_health_button.dart';
import 'option_card.dart'; // Import the custom option card widget
import 'package:vibration/vibration.dart'; // Import vibration package
import 'end_screen.dart'; // Import the end screen

class GameplayScreen extends StatefulWidget {
  final String dataset;
  final String title;
  final void Function(int) onDatasetCompleted; // Update the callback type

  GameplayScreen({
    required this.dataset,
    required this.title,
    required this.onDatasetCompleted, // Update the callback type
  });

  @override
  _GameplayScreenState createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen> with SingleTickerProviderStateMixin {
  List<List<dynamic>> _data = [];
  int _currentIndex = 0;
  int _healthPoints = 100;
  int _correctStreak = 0;
  int _correctAnswers = 0; // Track the number of correct answers
  int _mana = 0; // Track the mana points
  List<int> _wrongAnswerIndices = []; // Store indices of wrong answers
  List<String> _definitions = [];
  List<String> _translations = [];
  bool _showDefinitions = true;
  final List<String> _letters = ['A', 'B', 'C', 'D', 'E'];
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  bool _showRedFlash = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.1, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticIn,
    ));
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    _data = await loadCsv('assets/${widget.dataset}');
    _generateOptions();
    setState(() {});
  }

  void _generateOptions() {
    if (_data.isEmpty) return;

    final currentWord = _data[_currentIndex];
    final correctDefinition = currentWord[5];
    final correctTranslation = currentWord[4];

    // Get four random definitions and translations
    final random = Random();
    final randomDefinitions = <String>{};
    final randomTranslations = <String>{};
    while (randomDefinitions.length < 4) {
      final randomIndex = random.nextInt(_data.length);
      if (randomIndex != _currentIndex) {
        randomDefinitions.add(_data[randomIndex][5]);
        randomTranslations.add(_data[randomIndex][4]);
      }
    }

    // Combine correct definition and translation with random ones and shuffle
    _definitions = [correctDefinition, ...randomDefinitions.toList()];
    _translations = [correctTranslation, ...randomTranslations.toList()];
    _definitions.shuffle();
    _translations.shuffle();
  }

  void _checkAnswer(String selectedOption) async {
    final currentWord = _data[_currentIndex];
    final correctOption = _showDefinitions ? currentWord[5] : currentWord[4];

    if (selectedOption == correctOption) {
      setState(() {
        _correctStreak++;
        _correctAnswers++; // Increment the number of correct answers
        _mana = (_mana + 1).clamp(0, 10); // Increment mana, max out at 10
        _currentIndex++;
        if (_currentIndex >= _data.length) {
          widget.onDatasetCompleted((_correctAnswers / _data.length * 100).round()); // Call the callback with score
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => EndScreen(
                datasetPassed: true,
                correctAnswers: _correctAnswers,
                wrongAnswerIndices: _wrongAnswerIndices.toSet().toList(), // Remove duplicates
                data: _data,
                dataset: widget.dataset,
              ),
            ),
          );
        } else {
          _generateOptions();
        }
      });
    } else {
      setState(() {
        _correctStreak = 0;
        _healthPoints = (_healthPoints - 10).clamp(0, 100); // Adjust damage as needed, max out at 100
        _mana = 0; // Reset mana to 0
        _wrongAnswerIndices.add(_currentIndex); // Store the index of the wrong answer
        _showRedFlash = true;
        _controller.forward(from: 0); // Start the shake animation
        if (_healthPoints <= 0) {
          widget.onDatasetCompleted((_correctAnswers / _data.length * 100).round()); // Call the callback with score
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => EndScreen(
                datasetPassed: false,
                correctAnswers: _correctAnswers,
                wrongAnswerIndices: _wrongAnswerIndices.toSet().toList(), // Remove duplicates
                data: _data,
                dataset: widget.dataset,
              ),
            ),
          );
        } else {
          // Do not increment _currentIndex to present the same word again
          _generateOptions();
        }
      });
      bool? hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        Vibration.vibrate(duration: 100);
      }
      Future.delayed(Duration(milliseconds: 300), () {
        setState(() {
          _showRedFlash = false;
        });
      });
    }
  }

  void _addHealth() {
    setState(() {
      _healthPoints = (_healthPoints + 50).clamp(0, 100); // Add 50 health points, max out at 100
      _mana = 0; // Reset mana to 0
    });
  }

  void _addScoreAndAdvance() {
    setState(() {
      _correctStreak += 10; // Add 10 points to the score
      _currentIndex = (_currentIndex + 10).clamp(0, _data.length - 1); // Move forward by 10 words
      if (_currentIndex >= _data.length) {
        widget.onDatasetCompleted((_correctAnswers / _data.length * 100).round()); // Call the callback with score
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EndScreen(
              datasetPassed: true,
              correctAnswers: _correctAnswers,
              wrongAnswerIndices: _wrongAnswerIndices.toSet().toList(), // Remove duplicates
              data: _data,
              dataset: widget.dataset,
            ),
          ),
        );
      } else {
        _generateOptions();
      }
    });
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Game Over'),
          content: Text('You have run out of health points.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Go back to home page
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_data.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.3),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: TextStyle(color: Colors.white),
              ),
             
            ],
          ),
          iconTheme: IconThemeData(color: Colors.white), // Set back arrow color to white
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final currentWord = _data[_currentIndex];
    final word = currentWord[2];
    final example = currentWord[6];
    final wordType = currentWord[0]; // Assuming the word type is in the first column
    final prefix = currentWord[1]; // Assuming the prefix is in the second column
    final suffix = currentWord[3]; // Assuming the suffix is in the fourth column
    final options = _showDefinitions ? _definitions : _translations;
    final remainingWords = _data.length - _currentIndex; // Calculate remaining words

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.3),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.title,
              style: TextStyle(color: Colors.white),
            ),
          
          ],
        ),
        iconTheme: IconThemeData(color: Colors.white), // Set back arrow color to white
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
          if (_showRedFlash)
            Container(
              color: Colors.red.withOpacity(0.5),
            ),
          SlideTransition(
            position: _offsetAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                Center(
                  child: IntrinsicWidth(
                    child: Stack(
                      children: [
                        Card(
                          color: Theme.of(context).primaryColor.withOpacity(0.3),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  wordType,
                                  style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: Colors.white),
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (prefix.isNotEmpty) Text('$prefix ', style: TextStyle(fontSize: 26, color: Colors.white)),
                                    Text('$word', style: TextStyle(fontSize: 26, color: Colors.white)),
                                    if (suffix.isNotEmpty) Text(' ($suffix)', style: TextStyle(fontSize: 26, color: Colors.white)),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Text('$example', style: TextStyle(fontSize: 16, color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Row(
                            children: [
                              Icon(Icons.list, color: Colors.white, size: 24),
                              SizedBox(width: 5),
                              Text(
                                '$remainingWords',
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ListView.builder(
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        return OptionCard(
                          text: options[index],
                          letter: _letters[index],
                          onPressed: () {
                            _checkAnswer(options[index]);
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).primaryColor.withOpacity(0.6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.favorite, color: Colors.white, size: 24),
                  SizedBox(width: 5),
                  Text(
                    '$_healthPoints',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              AddHealthButton(
                mana: _mana,
                onPressed: _addHealth,
              ),
              FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _showDefinitions = !_showDefinitions;
                  });
                },
                child: Icon(Icons.swap_horiz),
              ),
              FloatingActionButton(
                onPressed: _addScoreAndAdvance,
                child: Icon(Icons.arrow_forward),
              ),
              Row(
                children: [
                  Text(
                    '$_correctStreak',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 5),
                  Icon(Icons.whatshot, color: Colors.white, size: 24),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
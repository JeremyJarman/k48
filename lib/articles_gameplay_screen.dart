import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'csv_loader.dart';
import 'my_app_state.dart';
import 'add_health_button.dart';
import 'noun_card.dart'; // Import the NounCard widget
import 'package:vibration/vibration.dart'; // Import vibration package
import 'end_screen.dart'; // Import the end screen

class ArticlesGameplayScreen extends StatefulWidget {
  final String dataset;
  final String title;
  final void Function(int) onDatasetCompleted; // Update the callback type

  ArticlesGameplayScreen({
    required this.dataset,
    required this.title,
    required this.onDatasetCompleted, // Update the callback type
  });

  @override
  _ArticlesGameplayScreenState createState() => _ArticlesGameplayScreenState();
}

class _ArticlesGameplayScreenState extends State<ArticlesGameplayScreen> with SingleTickerProviderStateMixin {
  List<List<dynamic>> _data = [];
  List<String> _adjectives = [];
  int _currentIndex = 0;
  int _healthPoints = 100;
  int _correctStreak = 0;
  int _correctAnswers = 0; // Track the number of correct answers
  int _mana = 0; // Track the mana points
  List<int> _wrongAnswerIndices = []; // Store indices of wrong answers
  final List<String> _articles = ['der', 'die', 'das'];
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  bool _showRedFlash = false;
  late FixedExtentScrollController _scrollController;
  int _selectedArticleIndex = 0; // Track the selected article index

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadAdjectives();
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
    _scrollController = FixedExtentScrollController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    _data = await loadCsv('assets/${widget.dataset}');
    setState(() {});
  }

  Future<void> _loadAdjectives() async {
    final adjectivesData = await loadCsv('assets/adjectives.csv');
    _adjectives = adjectivesData.map((row) => row[0].toString()).toList();
    setState(() {});
  }

  void _checkAnswer() async {
    final selectedOption = _articles[_selectedArticleIndex];
    final currentWord = _data[_currentIndex];
    final correctOption = currentWord[1]; // Assuming the article is in the second column

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
                isArticleReview: true, // Article review
              ),
            ),
          );
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
                isArticleReview: true, // Article review
              ),
            ),
          );
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
              isArticleReview: true, // Article review
            ),
          ),
        );
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    if (_data.isEmpty || _adjectives.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.3),
          title: Text(
            widget.title,
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: IconThemeData(color: Colors.white), // Set back arrow color to white
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final currentWord = _data[_currentIndex];
    final noun = currentWord[2]; // Assuming the noun is in the first column
    final selectedArticle = _articles[_selectedArticleIndex]; // Get the currently selected article
    final randomAdjective = _adjectives[Random().nextInt(_adjectives.length)]; // Get a random adjective
    final remainingNouns = _data.length - _currentIndex; // Calculate remaining nouns

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.3),
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white), // Set back arrow color to white
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Icon(Icons.list, color: Colors.white),
                SizedBox(width: 5),
                Text(
                  '$remainingNouns',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
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
                    child: NounCard(
                      noun: noun,
                      selectedArticle: selectedArticle, // Pass the selected article to the NounCard
                      adjective: randomAdjective, // Pass the random adjective to the NounCard
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ListWheelScrollView(
                      controller: _scrollController,
                      itemExtent: 100,
                      physics: FixedExtentScrollPhysics(),
                      diameterRatio: 1.5,
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _selectedArticleIndex = index;
                        });
                      },
                      children: _articles.map((article) {
                        final isSelected = _articles[_selectedArticleIndex] == article;
                        return GestureDetector(
                          onTap: _checkAnswer,
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.5) : Colors.transparent, // Highlight selected option
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              article,
                              style: TextStyle(
                                fontSize: 24,
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
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
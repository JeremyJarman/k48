import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'my_app_state.dart';
import 'add_health_button.dart';
import 'noun_card.dart';
import 'end_screen.dart'; // Import the end screen
import 'package:confetti/confetti.dart';
import 'dart:developer' as developer;
import 'dataset_service.dart'; // For DatasetType enum
//import 'csv_loader.dart';
//import 'package:vibration/vibration.dart'; // Import vibration package

class ArticlesGameplayScreen extends StatefulWidget {
  final String dataset;
  final String title; // Add title property
  final Function(int) onDatasetCompleted;

  const ArticlesGameplayScreen({
    super.key,
    required this.dataset,
    required this.title,
    required this.onDatasetCompleted,
  });

  @override
  ArticlesGameplayScreenState createState() => ArticlesGameplayScreenState();
}

class ArticlesGameplayScreenState extends State<ArticlesGameplayScreen> with SingleTickerProviderStateMixin {
  final List<int> _wrongAnswerIndices = [];
  List<List<dynamic>> _data = [];
  final List<String> _articles = ['der', 'die', 'das']; // Example articles
  List<String> _adjectives = []; // Add adjectives list
  int _currentIndex = 0;
  int _correctAnswers = 0;
  int _healthPoints = 100;
  int _mana = 0;
  int _correctStreak = 0;
  bool _showTranslations = false;
  bool _showRedFlash = false;
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late FixedExtentScrollController _scrollController;
  int _selectedArticleIndex = 0;
  String? _currentAdjective;
  Color? _highlightColor;
  ConfettiController? _confettiController;
  final DatasetType datasetType = DatasetType.article;

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
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          _showRedFlash = false;
        });
      }
    });
    _scrollController = FixedExtentScrollController();
    _confettiController = ConfettiController(duration: const Duration(milliseconds: 200));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _confettiController?.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final datasetService = Provider.of<MyAppState>(context, listen: false).datasetService;
    final path = 'assets/${widget.dataset}';
    developer.log('Loading dataset from path: $path');

    try {
      final csvData = await datasetService.loadCsv(path);
      _data = csvData;
      _data.shuffle();
      setState(() {});
      developer.log('Loaded dataset from assets: ${widget.dataset}');
    } catch (e) {
      developer.log('Error loading dataset: $e');
    }
  }

  Future<void> _loadAdjectives() async {
  final datasetService = Provider.of<MyAppState>(context, listen: false).datasetService;
  final path = 'assets/adjectives.csv';
  developer.log('Loading adjectives from path: $path'); // Debug print
  try {
    final adjectivesData = await datasetService.loadCsv(path);
    //print('Adjectives loaded: $adjectivesData'); // Debug print
    _adjectives = adjectivesData.map((row) => row[0].toString()).toList();
    setState(() {});
  } catch (e) {
    developer.log('Error loading adjectives: $e'); // Debug print
  }
}

  void _onAnswerSelected(bool isCorrect) async {
    if (isCorrect) {
      // Set highlight color based on article
      final article = _articles[_selectedArticleIndex];
      setState(() {
        if (article == 'der') {
          _highlightColor = Colors.blue;
        } else if (article == 'die') {
          _highlightColor = Colors.red;
        } else if (article == 'das') {
          _highlightColor = Colors.green;
        } else {
          _highlightColor = null;
        }
        _confettiController?.play();
      });
      // Wait briefly before proceeding
      await Future.delayed(Duration(milliseconds: 700));
      setState(() {
        _highlightColor = null;
      });
      _correctAnswers++;
      _correctStreak++;
      _mana = (_mana + 1).clamp(0, 10);
      if (_correctStreak >= 3) {
        _healthPoints = (_healthPoints + 1).clamp(0, 100);
      }
      if (_currentIndex >= _data.length - 1) {
        _endGame();
      } else {
        setState(() {
          _currentIndex++;
          // Pick a new adjective for the new word
          _currentAdjective = _adjectives.isNotEmpty ? _adjectives[Random().nextInt(_adjectives.length)] : null;
        });
      }
    } else {
      _correctStreak = 0;
      _healthPoints = (_healthPoints - 10).clamp(0, 100);
      _mana = 0;
      _wrongAnswerIndices.add(_currentIndex);
      _showRedFlash = true;
      _controller.forward(from: 0);
      if (_healthPoints <= 0) {
        _endGame();
      } else {
        setState(() {});
      }
    }
  }

  void _endGame() async {
    final appState = Provider.of<MyAppState>(context, listen: false);
    final uniqueWrongIndices = _wrongAnswerIndices.toSet().toList();
    final uniqueWrongCount = uniqueWrongIndices.length;
    final firstAttemptCorrect = _correctAnswers - uniqueWrongCount;
    final percent = ((firstAttemptCorrect / _data.length) * 100).clamp(0, 100).toDouble();
    final percentRounded = percent.roundToDouble();
    final currentElo = appState.elo;
    final datasetPassed = percentRounded > 50.0;
    print('DEBUG: Articles_GamePlay endGame: correctAnswers=$_correctAnswers, uniqueWrongCount=$uniqueWrongCount, firstAttemptCorrect=$firstAttemptCorrect, percent=$percentRounded, currentElo=$currentElo, datasetPassed=$datasetPassed');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => EndScreen(
          datasetPassed: datasetPassed,
          correctAnswers: _correctAnswers,
          uniqueWrongIndices: uniqueWrongIndices,
          percent: percentRounded,
          currentElo: currentElo,
          data: _data,
          datasetName: widget.dataset,
          datasetType: datasetType,
        ),
      ),
    );
  }


 void _addHealth() {
    setState(() {
      _healthPoints = (_healthPoints + 50).clamp(0, 100);
      _mana = 0;
    });
  }

  void _toggleTranslations() {
    setState(() {
      _showTranslations = !_showTranslations;
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
    // Only pick a new adjective when the word changes
    _currentAdjective ??= _adjectives.isNotEmpty ? _adjectives[Random().nextInt(_adjectives.length)] : null;
    final randomAdjective = _currentAdjective;
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
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      IntrinsicWidth(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: NounCard(
                            noun: noun,
                            selectedArticle: selectedArticle, // Pass the selected article to the NounCard
                            adjective: randomAdjective, // Pass the random adjective to the NounCard
                            highlightColor: _highlightColor,
                          ),
                        ),
                      ),
                      if (_confettiController != null)
                        ...[
                          // Top-left confetti
                          Positioned(
                            left: 0,
                            bottom: 0,
                            child: IgnorePointer(
                              child: ConfettiWidget(
                                confettiController: _confettiController!,
                                blastDirection: -pi / 4, // Up-right 
                                blastDirectionality: BlastDirectionality.directional,
                                shouldLoop: false,
                                emissionFrequency: 0.05,
                                numberOfParticles: 10,
                                maxBlastForce: 12,
                                minBlastForce: 6,
                                gravity: 0.3,
                                colors: const [Colors.white],
                                createParticlePath: (size) {
                                  return Path()..addOval(Rect.fromCircle(center: Offset.zero, radius: 2));
                                },
                              ),
                            ),
                          ),
                          // Top-right confetti
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: IgnorePointer(
                              child: ConfettiWidget(
                                confettiController: _confettiController!,
                                blastDirection: -3 * pi / 4, // Up-left
                                blastDirectionality: BlastDirectionality.directional,
                                shouldLoop: false,
                                emissionFrequency: 0.05,
                                numberOfParticles: 10,
                                maxBlastForce: 12,
                                minBlastForce: 6,
                                gravity: 0.3,
                                colors: const [Colors.white],
                                createParticlePath: (size) {
                                  return Path()..addOval(Rect.fromCircle(center: Offset.zero, radius: 2));
                                },
                              ),
                            ),
                          ),
                        ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).padding.bottom + 150,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _articles.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final article = entry.value;
                  final isSelected = _selectedArticleIndex == idx;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedArticleIndex = idx;
                        });
                        // On web, also allow tap-to-commit if already selected
                        if (isSelected) {
                          _onAnswerSelected(article == currentWord[1]);
                        }
                      },
                      onHorizontalDragStart: (_) {
                        setState(() {
                          _selectedArticleIndex = idx;
                        });
                      },
                      onHorizontalDragEnd: (details) {
                        // Only allow swipe-to-commit on the selected button and only for right swipes
                        if (_selectedArticleIndex == idx && details.primaryVelocity != null && details.primaryVelocity! > 0) {
                          _onAnswerSelected(article == currentWord[1]);
                        }
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        width: MediaQuery.of(context).size.width * 0.8,
                        padding: EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).primaryColor.withOpacity(0.7)
                              : Theme.of(context).primaryColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: isSelected
                              ? [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.3), blurRadius: 8, offset: Offset(0, 2))]
                              : [],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Center(
                              child: Text(
                                article,
                                style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.white,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            if (isSelected)
                              Positioned(
                                right: 24,
                                child: Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                          ],
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
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).primaryColor.withOpacity(0.6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
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
              SizedBox(
                height: 60,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    AddHealthButton(
                      mana: _mana,
                      onPressed: _addHealth,
                    ),
                    if (_mana == 10)
                      Positioned(
                        top: -28,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                          ),
                          child: Text(
                            'Ready',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
             // FloatingActionButton(
             //   onPressed: _addScoreAndAdvance,
             //   child: Icon(Icons.arrow_forward),
            //  ),
              Center(
                child: IconButton(
                  icon: Icon(_showTranslations ? Icons.translate : Icons.text_fields, color: Colors.white, size: 30),
                  onPressed: _toggleTranslations,
                  iconSize: 30,
                ),
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
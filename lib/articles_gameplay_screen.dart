import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'my_app_state.dart';
import 'add_health_button.dart';
import 'noun_card.dart'; 
import 'end_screen.dart'; // Import the end screen
import 'dataset_service.dart';
//import 'csv_loader.dart';
//import 'package:vibration/vibration.dart'; // Import vibration package

class ArticlesGameplayScreen extends StatefulWidget {
  final String dataset;
  final String title; // Add title property
  final Function(int) onDatasetCompleted;

  ArticlesGameplayScreen({required this.dataset, required this.title, required this.onDatasetCompleted});

  @override
  _ArticlesGameplayScreenState createState() => _ArticlesGameplayScreenState();
}

class _ArticlesGameplayScreenState extends State<ArticlesGameplayScreen> with SingleTickerProviderStateMixin {
  List<int> _wrongAnswerIndices = [];
  List<List<dynamic>> _data = [];
  List<String> _articles = ['der', 'die', 'das']; // Example articles
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
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final datasetService = Provider.of<DatasetService>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    final path = 'assets/${widget.dataset}';
    print('Loading dataset from path: $path'); // Debug print

    try {
      final localData = prefs.getString('Articles_${widget.dataset}');
      if (localData != null) {
        List<Map<String, dynamic>> decodedData = List<Map<String, dynamic>>.from(json.decode(localData));
        _data = decodedData.map((row) => [
          row['index'],
          row['article'],
          row['noun'],
          row['translation']
        ]).toList();
        print('Loaded dataset from local storage: ${widget.dataset}'); // Debug print
      } else {
        await datasetService.downloadArticleDatasetsFromFirestore();
        final updatedLocalData = prefs.getString('Articles_${widget.dataset}');
        if (updatedLocalData != null) {
          List<Map<String, dynamic>> decodedData = List<Map<String, dynamic>>.from(json.decode(updatedLocalData));
          _data = decodedData.map((row) => [
            row['index'],
            row['article'],
            row['noun'],
            row['translation']
          ]).toList();
          print('Downloaded and loaded dataset: ${widget.dataset}'); // Debug print
        }
      }
      _data.shuffle();
      setState(() {});
    } catch (e) {
      print('Error loading dataset: $e'); // Debug print
    }
  }

  Future<void> _loadAdjectives() async {
  final datasetService = Provider.of<DatasetService>(context, listen: false);
  final path = 'assets/adjectives.csv';
  print('Loading adjectives from path: $path'); // Debug print
  try {
    final adjectivesData = await datasetService.loadCsv(path);
    //print('Adjectives loaded: $adjectivesData'); // Debug print
    _adjectives = adjectivesData.map((row) => row[0].toString()).toList();
    setState(() {});
  } catch (e) {
    print('Error loading adjectives: $e'); // Debug print
  }
}

  void _onAnswerSelected(bool isCorrect) async {
    if (isCorrect) {
      _correctAnswers++;
      _correctStreak++;
      _mana = (_mana + 1).clamp(0, 10);
      if (_correctStreak >= 3) {
        _healthPoints = (_healthPoints + 1).clamp(0, 100);
      }
      if (_currentIndex >= _data.length - 1) {
        _endGame(true);
      } else {
        setState(() {
          _currentIndex++;
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
        _endGame(false);
      } else {
        setState(() {});
      }
    }
  }

  void _endGame(bool datasetPassed) async {
    //final datasetService = Provider.of<DatasetService>(context, listen: false);
    final appState = Provider.of<MyAppState>(context, listen: false);
    final eloChange = (_correctAnswers / _data.length * 100).round();
    appState.updateElo(appState.elo + eloChange);
    appState.updateDatasetPassPercentage(widget.dataset, (_correctAnswers / _data.length * 100).toDouble());
    widget.onDatasetCompleted((_correctAnswers / _data.length * 100).round());
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => EndScreen(
          datasetPassed: datasetPassed,
          correctAnswers: _correctAnswers,
          wrongAnswerIndices: _wrongAnswerIndices,
          data: _data,
          isArticleReview: true,
          eloChange: eloChange,
          datasetName: widget.dataset,
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
  void _addScoreAndAdvance() async {
    _correctStreak += 10;
    _currentIndex = (_currentIndex + 10).clamp(0, _data.length - 1);
    if (_currentIndex >= _data.length) {
      _endGame(true);
    } else {
      setState(() {});
    }
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
                          onTap: () => _onAnswerSelected(article == currentWord[1]),
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
              AddHealthButton(
                mana: _mana,
                onPressed: _addHealth,
              ),
             // FloatingActionButton(
             //   onPressed: _addScoreAndAdvance,
             //   child: Icon(Icons.arrow_forward),
            //  ),
              IconButton(
                icon: Icon(_showTranslations ? Icons.translate : Icons.text_fields, color: Colors.white),
                onPressed: _toggleTranslations,
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
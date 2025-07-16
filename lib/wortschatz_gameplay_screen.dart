import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'my_app_state.dart';
import 'add_health_button.dart';
import 'end_screen.dart';
import 'dart:developer' as developer;
import 'dataset_service.dart'; // For DatasetType enum

class WortschatzGameplayScreen extends StatefulWidget {
  final String dataset;
  final Function onDatasetCompleted;
  final String title;

  const WortschatzGameplayScreen({
    super.key,
    required this.dataset,
    required this.onDatasetCompleted,
    required this.title,
  });

  @override
  WortschatzGameplayScreenState createState() => WortschatzGameplayScreenState();
}

class WortschatzGameplayScreenState extends State<WortschatzGameplayScreen> with SingleTickerProviderStateMixin {
  List<List<dynamic>> _data = [];
  int _currentIndex = 0;
  int _healthPoints = 100;
  int _correctStreak = 0;
  int _correctAnswers = 0;
  int _mana = 0;
  final List<int> _wrongAnswerIndices = [];
  final List<String> _letters = ['A', 'B', 'C', 'D', 'E'];
  bool _showTranslations = false;
  bool _showRedFlash = false;
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  final DatasetType datasetType = DatasetType.wortschatz;
  

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
      end: Offset(0.1, 0.0),
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

  }

  @override
  void dispose() {
    _controller.dispose();
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

  void _onAnswerSelected(bool isCorrect) async {
    if (isCorrect) {
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
    print('DEBUG: Wortschatz_GamePlay endGame: correctAnswers=$_correctAnswers, uniqueWrongCount=$uniqueWrongCount, firstAttemptCorrect=$firstAttemptCorrect, percent=$percentRounded, currentElo=$currentElo, datasetPassed=$datasetPassed');
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
    if (_data.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final currentWord = _data[_currentIndex];
    final wordType = currentWord[0];
    final prefix = currentWord[1];
    final word = currentWord[2];
    final suffix = currentWord[3];
    final correctDefinition = currentWord[5];
    final correctTranslation = currentWord[4];
    final example = currentWord[6];
    final remainingWords = _data.length - _currentIndex;

    final sameTypeWords = _data.where((item) => item[0] == wordType && item != currentWord).toList();
    sameTypeWords.shuffle();
    final options = sameTypeWords.take(4).map((item) => _showTranslations ? item[4] : item[5]).toList();

    if (options.length < 4) {
      final remainingOptions = _data.where((item) => item != currentWord).toList();
      remainingOptions.shuffle();
      options.addAll(remainingOptions.take(4 - options.length).map((item) => _showTranslations ? item[4] : item[5]));
    }

    options.add(_showTranslations ? correctTranslation : correctDefinition);
    options.shuffle();

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.3),
        title: Row(
          children: [
            Text(
              widget.title,
              style: TextStyle(color: Colors.white),
            ),
            Spacer(),
            Icon(Icons.list, color: Colors.white),
            SizedBox(width: 5),
            Text(
              '$remainingWords',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
          ],
        ),
        iconTheme: IconThemeData(color: Colors.white),
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            wordType,
                            style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.white),
                          ),
                          SizedBox(height: 10),
                          Text(
                            suffix.isNotEmpty ? '$prefix $word ($suffix)' : '$prefix $word',
                            style: TextStyle(fontSize: 26, color: Colors.white),
                          ),
                          SizedBox(height: 10),
                          Text(
                            example,
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ListView.builder(
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        return Card(
                          color: Theme.of(context).primaryColor.withOpacity(0.3),
                          child: ListTile(
                            leading: Text(
                              _letters[index],
                              style: TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            title: Text(options[index], style: TextStyle(color: Colors.white)),
                            onTap: () => _onAnswerSelected(options[index] == (_showTranslations ? correctTranslation : correctDefinition)),
                          ),
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
        color: Theme.of(context).primaryColor.withOpacity(0.3),
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
                    ),
                  ),
                ],
              ),
              AddHealthButton(
                mana: _mana, 
                onPressed: _addHealth
              ),
              //FloatingActionButton(
              //  onPressed: _addScoreAndAdvance,
              //  child: Icon(Icons.arrow_forward),
              //),
              IconButton(
                icon: Icon(_showTranslations ? Icons.translate : Icons.text_fields, 
                color: Colors.white),
                onPressed: _toggleTranslations,
              ),
              Row(
                children: [
                  Text(
                    '$_correctStreak',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
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
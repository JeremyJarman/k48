import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'my_app_state.dart';
import 'add_health_button.dart';
import 'end_screen.dart';
import 'package:confetti/confetti.dart';
import 'dataset_service.dart'; // For DatasetType enum

class VerbsGameplayScreen extends StatefulWidget {
  final String dataset;
  final String title;
  final Function(int) onDatasetCompleted;

  VerbsGameplayScreen({required this.dataset, required this.title, required this.onDatasetCompleted});

  @override
  _VerbsGameplayScreenState createState() => _VerbsGameplayScreenState();
}

class _VerbsGameplayScreenState extends State<VerbsGameplayScreen> with SingleTickerProviderStateMixin {
  List<int> _wrongAnswerIndices = [];
  List<List<dynamic>> _data = [];
  int _currentIndex = 0;
  int _correctAnswers = 0;
  int _healthPoints = 100;
  int _mana = 0;
  int _correctStreak = 0;
  bool _showRedFlash = false;
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  ConfettiController? _confettiController;
  List<String> _letters = ['A', 'B', 'C', 'D', 'E'];
  
  // Store current question options
  List<String> _currentOptions = [];
  String _currentCorrectAnswer = '';
  String _currentQuestionText = '';
  String _currentAnswerText = '';
  final DatasetType datasetType = DatasetType.verb;

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
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          _showRedFlash = false;
        });
      }
    });
    _confettiController = ConfettiController(duration: const Duration(milliseconds: 200));
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController?.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final datasetService = Provider.of<MyAppState>(context, listen: false).datasetService;
    final path = 'assets/${widget.dataset}';
    print('Loading verb dataset from path: $path');

    try {
      final csvData = await datasetService.loadCsv(path);
      _data = csvData;
      _data.shuffle();
      setState(() {});
      _generateCurrentQuestionOptions(); // Generate initial options
      print('Loaded verb dataset from assets: ${widget.dataset}');
    } catch (e) {
      print('Error loading verb dataset: $e');
    }
  }

  // Levenshtein distance for similarity
  int _levenshtein(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;
    List<List<int>> d = List.generate(s.length + 1, (_) => List.filled(t.length + 1, 0));
    for (int i = 0; i <= s.length; i++) d[i][0] = i;
    for (int j = 0; j <= t.length; j++) d[0][j] = j;
    for (int i = 1; i <= s.length; i++) {
      for (int j = 1; j <= t.length; j++) {
        int cost = s[i - 1] == t[j - 1] ? 0 : 1;
        d[i][j] = [
          d[i - 1][j] + 1,
          d[i][j - 1] + 1,
          d[i - 1][j - 1] + cost
        ].reduce((a, b) => a < b ? a : b);
      }
    }
    return d[s.length][t.length];
  }

  void _generateCurrentQuestionOptions() {
    if (_data.isEmpty || _currentIndex >= _data.length) return;
    final currentWord = _data[_currentIndex];
    final verb = currentWord[1]; // German verb
    final correctTranslation = currentWord[2]; // English translation

    // Find 4 most similar German verbs (excluding the correct one)
    final otherVerbs = _data.where((item) => item[1] != verb).toList();
    otherVerbs.sort((a, b) => _levenshtein(a[1], verb).compareTo(_levenshtein(b[1], verb)));
    final distractors = otherVerbs.take(4).map((item) => item[1].toString()).toList();

    _currentOptions = [...distractors, verb];
    _currentOptions.shuffle();
    _currentCorrectAnswer = verb;
    _currentQuestionText = correctTranslation; // Show English as the question
    _currentAnswerText = 'Select the correct German verb:';
  }

  void _showTranslationDialog() {
    final currentWord = _data[_currentIndex];
    final translations = {
      'English': currentWord[2],
      'Українська': '—', // Placeholder
      'Română': '—',
      'Español': '—',
      '中文': '—',
      'Српски': '—',
    };
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Translations'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: translations.entries.map((e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Text('${e.key}: ${e.value}'),
          )).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _onAnswerSelected(bool isCorrect) async {
    if (isCorrect) {
      setState(() {
        _confettiController?.play();
      });
      await Future.delayed(Duration(milliseconds: 700));
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
          _generateCurrentQuestionOptions();
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

  void _addHealth() {
    if (_mana >= 3) {
      setState(() {
        _healthPoints = (_healthPoints + 20).clamp(0, 100);
        _mana = (_mana - 3).clamp(0, 10);
      });
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
    print('DEBUG: Verbs_GamePlay endGame: correctAnswers=$_correctAnswers, uniqueWrongCount=$uniqueWrongCount, firstAttemptCorrect=$firstAttemptCorrect, percent=$percentRounded, currentElo=$currentElo, datasetPassed=$datasetPassed');
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

  @override
  Widget build(BuildContext context) {
    if (_data.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.3),
          title: Text(
            widget.title,
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final remainingVerbs = _data.length - _currentIndex;
    final options = _currentOptions;
    final correctAnswer = _currentCorrectAnswer;
    final questionText = _currentQuestionText;
    final answerText = _currentAnswerText;

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
              '$remainingVerbs',
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
                            'Verb',
                            style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.white),
                          ),
                          SizedBox(height: 10),
                          Text(
                            questionText,
                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          SizedBox(height: 10),
                          Text(
                            answerText,
                            style: TextStyle(fontSize: 16, color: Colors.white),
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
                              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            title: Text(
                              options[index], 
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            onTap: () => _onAnswerSelected(options[index] == correctAnswer),
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
              IconButton(
                icon: Icon(Icons.translate, color: Colors.white),
                onPressed: _showTranslationDialog,
                tooltip: 'Show translations',
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
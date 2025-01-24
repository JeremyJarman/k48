import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'csv_loader.dart';
import 'my_app_state.dart';
import 'add_health_button.dart';
import 'option_card.dart'; // Import the custom option card widget

class GameplayScreen extends StatefulWidget {
  final String dataset;
  final String title;

  GameplayScreen({required this.dataset, required this.title});

  @override
  _GameplayScreenState createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen> {
  List<List<dynamic>> _data = [];
  int _currentIndex = 0;
  int _healthPoints = 100;
  int _correctStreak = 0;
  List<String> _definitions = [];
  List<String> _translations = [];
  bool _showDefinitions = true;
  final List<String> _letters = ['A', 'B', 'C', 'D', 'E'];

  @override
  void initState() {
    super.initState();
    _loadData();
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

  void _checkAnswer(String selectedOption) {
    final currentWord = _data[_currentIndex];
    final correctOption = _showDefinitions ? currentWord[5] : currentWord[4];

    if (selectedOption == correctOption) {
      setState(() {
        _correctStreak++;
        _currentIndex++;
        if (_currentIndex >= _data.length) {
          _currentIndex = 0; // Reset for now, you can handle end of dataset differently
        }
        _generateOptions();
      });
    } else {
      setState(() {
        _correctStreak = 0;
        _healthPoints -= 10; // Adjust damage as needed
        if (_healthPoints <= 0) {
          _showGameOverDialog();
        } else {
          _currentIndex++;
          if (_currentIndex >= _data.length) {
            _currentIndex = 0; // Reset for now, you can handle end of dataset differently
          }
          _generateOptions();
        }
      });
    }
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
    final word = currentWord[2];
    final example = currentWord[6];
    final wordType = currentWord[0]; // Assuming the word type is in the first column
    final prefix = currentWord[1]; // Assuming the prefix is in the second column
    final suffix = currentWord[3]; // Assuming the suffix is in the fourth column
    final options = _showDefinitions ? _definitions : _translations;

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
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              // Save progress logic here
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
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              Center(
                child: IntrinsicWidth(
                  child: Card(
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
              Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 120.0),
                child: Center(
                  child: FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        _showDefinitions = !_showDefinitions;
                      });
                    },
                    child: Icon(Icons.swap_horiz),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: AddHealthButton(),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).primaryColor.withOpacity(0.6),
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
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
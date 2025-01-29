import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:csv/csv.dart';
//import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'login_page.dart'; // Import the login page

void customPrint(Object? object) => debugPrint(object.toString());

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: GermanNounApp(),
    ),
  );
}

class GermanNounApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'German Noun App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthWrapper(), // Use AuthWrapper to handle authentication
    );
  }
}

class MyAppState extends ChangeNotifier {
  List<Map<String, String>> nouns = [];
  int currentIndex = 0;
  String? selectedArticle;
  bool isCorrect = false;
  int correctStreak = 0;
  int highScore = 0;
  int score = 0; // Add score variable
  int healthPoints = 100; // Initialize health points to 100
  int damageAmount = 10; // Default damage amount
  int mana = 0; // Initialize mana to 0
  String difficulty = 'Intermediate'; // Default difficulty

  MyAppState() {
    fetchNouns();
  }

  Future<void> fetchNouns() async {
    try {
      customPrint('Fetching nouns from Firestore...');
      final doc = await FirebaseFirestore.instance.collection('Nouns').doc('allPairs').get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final pairs = data['pairs'] as List<dynamic>;
        nouns = pairs.map((pair) {
          return {
            'noun': pair['noun'] as String? ?? '',
            'article': pair['article'] as String? ?? '',
          };
        }).toList();
        customPrint('Nouns fetched successfully');
        notifyListeners();
      } else {
        customPrint('No data found');
      }
    } catch (e) {
      customPrint('Error fetching nouns: $e');
    }
  }

  Future<void> loadNounsFromAssets() async {
    try {
      final csvData = await rootBundle.loadString('assets/ArticleNounPairs.csv');
      List<List<dynamic>> rows = const CsvToListConverter().convert(csvData);

      List<Map<String, String>> nounArticlePairs = [];

      for (var row in rows) {
        final article = row[0] as String;
        final noun = row[1] as String;

        nounArticlePairs.add({
          'noun': noun,
          'article': article,
        });
      }

      // Store all pairs in a single document
      await FirebaseFirestore.instance.collection('Nouns').doc('allPairs').set({
        'pairs': nounArticlePairs,
      });
    } catch (e) {
      customPrint('Error loading nouns from assets: $e');
    }
  }

  Future<void> fetchHighScore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final difficultyDoc = 'Nouns_${difficulty.toLowerCase()}';
    final docRef = FirebaseFirestore.instance.collection('scores').doc(difficultyDoc);

    final doc = await docRef.get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      highScore = data[user.uid] as int? ?? 0;
    } else {
      highScore = 0;
    }
    notifyListeners();
  }

  void setDifficulty(String difficulty) {
    this.difficulty = difficulty;
    score = 0; // Reset score at the beginning of a new quiz
    mana = 0; // Reset mana at the beginning of a new quiz
    fetchHighScore(); // Fetch high score from database
    switch (difficulty) {
      case 'Easy':
        damageAmount = 10;
        healthPoints = 100;
        break;
      case 'Intermediate':
        damageAmount = 30;
        healthPoints = 100;
        break;
      case 'Hardcore':
        damageAmount = 50;
        healthPoints = 1;
        break;
      default:
        damageAmount = 10;
        healthPoints = 100;
    }
    notifyListeners();
  }

  void selectArticle(String article) {
    selectedArticle = article;
    notifyListeners();
  }

  Future<void> checkAnswer(BuildContext context) async {
    if (selectedArticle == null) {
      customPrint('No article selected');
      return;
    }
    if (nouns[currentIndex]['article'] == selectedArticle) {
      isCorrect = true;
      correctStreak++;
      score++; // Increment score
      mana = (mana + 10).clamp(0, 100); // Increment mana
      if (correctStreak > highScore) {
        highScore = correctStreak;
      }
    } else {
      isCorrect = false;
      correctStreak = 0;
      healthPoints -= damageAmount; // Deduct health points
      mana = 0; // Reset mana on incorrect answer
      if (healthPoints <= 0) {
        healthPoints = 0;
        customPrint('Game Over');
        // Handle game over logic here
        await updateHighScore();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GameOverScreen(score: score)),
        );
      }
    }
    notifyListeners();
  }

  Future<void> updateHighScore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final difficultyDoc = 'Nouns_${difficulty.toLowerCase()}';
    final docRef = FirebaseFirestore.instance.collection('scores').doc(difficultyDoc);

    final doc = await docRef.get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      final userHighScore = data[user.uid] as int? ?? 0;
      if (score > userHighScore) {
        await docRef.update({user.uid: score});
      }
    } else {
      await docRef.set({user.uid: score});
    }
  }

  void nextNoun() {
    currentIndex = (currentIndex + 1) % nouns.length;
    isCorrect = false; // Reset the correctness flag
    notifyListeners();
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          return MyHomePage(); // User is logged in
        } else {
          return LoginPage(); // User is not logged in
        }
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('German Noun App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome to the German Noun App!'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DifficultySelection()),
                );
              },
              child: Text('Start Quiz'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminPanel()),
                );
              },
              child: Text('Admin Panel'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await Provider.of<MyAppState>(context, listen: false).loadNounsFromAssets();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Nouns uploaded successfully')),
            );
          },
          child: Text('Upload Nouns'),
        ),
      ),
    );
  }
}

class GermanNounQuiz extends StatelessWidget {
  final FixedExtentScrollController _controller = FixedExtentScrollController();

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

    return Scaffold(
      appBar: CustomAppBar(), // Use the custom app bar
      body: Container(
        color: Theme.of(context).colorScheme.primaryContainer, // Set the background color to primary container
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 60),
            Center(child: DiamondCard(score: appState.score, mana: appState.mana)),
            SizedBox(height: 100), // Adjust the spacing as needed
            Center(child: NounCard(noun: appState.nouns[appState.currentIndex]['noun']!, selectedArticle: appState.selectedArticle)),
            SizedBox(height: 60),
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
                    controller: _controller,
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
                            style: TextStyle(fontSize: 24),
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
                    if (appState.isCorrect) {
                      appState.nextNoun();
                    }
                  },
                  child: Text('Check Answer'),
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
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Text(
            'Best: ${appState.highScore}',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
      title: Center(
        child: Text(
          appState.difficulty,
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              '${appState.healthPoints}',
              style: TextStyle(
                color: appState.healthPoints < 40 ? Colors.red : Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DiamondCard extends StatelessWidget {
  final int score;
  final int mana;

  DiamondCard({required this.score, required this.mana});

  @override
  Widget build(BuildContext context) {
    double progress = (mana / 100).clamp(0.0, 1.0);
    Color borderColor = Theme.of(context).primaryColor.withOpacity(progress);

    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.rotate(
          angle: 0.785398, // 45 degrees in radians
          child: Card(
            color: Theme.of(context).colorScheme.primaryContainer, // Set the card color to primary container
            shape: RoundedRectangleBorder(
              side: BorderSide(color: borderColor, width: 4), // Set the border color based on mana
              borderRadius: BorderRadius.circular(8),
            ),
            child: Container(
              width: 100,
              height: 100,
              alignment: Alignment.center,
              child: Transform.rotate(
                angle: -0.785398, // Rotate text back to normal
                child: Text(
                  '$score',
                  style: TextStyle(fontSize: 24, color: Theme.of(context).colorScheme.onPrimaryContainer), // Set text color to be suitable for the container color
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class NounCard extends StatelessWidget {
  final String noun;
  final String? selectedArticle;

  NounCard({required this.noun, required this.selectedArticle});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).primaryColor, // Set the background color to the primary color
      child: Container(
        width: 200, // Set a fixed width
        height: 100, // Set a fixed height
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            '${selectedArticle ?? ''} $noun',
            style: TextStyle(fontSize: 24, color: Colors.white), // Set text color to white for better contrast
          ),
        ),
      ),
    );
  }
}

class HealthPointsIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Center(
      child: Text(
        '${appState.healthPoints}',
        style: TextStyle(
          color: appState.healthPoints < 40 ? Colors.red : Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class DifficultySelection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Difficulty'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Provider.of<MyAppState>(context, listen: false).setDifficulty('Easy');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GermanNounQuiz()),
                );
              },
              child: Text('Easy'),
            ),
            ElevatedButton(
              onPressed: () {
                Provider.of<MyAppState>(context, listen: false).setDifficulty('Intermediate');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GermanNounQuiz()),
                );
              },
              child: Text('Intermediate'),
            ),
            ElevatedButton(
              onPressed: () {
                Provider.of<MyAppState>(context, listen: false).setDifficulty('Hardcore');
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
    );
  }
}

class GameOverScreen extends StatelessWidget {
  final int score;

  GameOverScreen({required this.score});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Game Over'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'You Lost!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Your Score: $score',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => MyHomePage()),
                  (route) => false,
                );
              },
              child: Text('Return to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
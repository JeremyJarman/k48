import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'game_over_screen.dart';

class MyAppState extends ChangeNotifier {
  List<Map<String, String>> nouns = [];
  List<Map<String, dynamic>> adjectives = [];
  List<Map<String, String>> failedPairs = [];
  int currentIndex = 0;
  String? selectedArticle;
  bool isCorrect = false;
  int correctStreak = 0;
  int highScore = 0;
  int score = 0;
  int healthPoints = 100;
  int damageAmount = 10;
  int mana = 0;
  String difficulty = 'Intermediate';
  int elo = 0; // Replace rating with elo
  String alias = ''; // Add alias variable
  String lastStar = 'Home'; // Track the last star the user reached
  List<String> _articles = ['der', 'die', 'das']; // Example articles

  List<Map<String, dynamic>> stars = [
    {'name': 'SRC 1826', 'constellation': 'Pavo', 'distance': 30},
    // Add more stars here
  ];

  MyAppState() {
    fetchNouns();
    fetchAdjectives();
    loadElo(); // Load elo when the app state is initialized
    loadAlias(); // Load alias when the app state is initialized
    fetchHighScore(); // Load high score when the app state is initialized
    loadProgress(); // Load progress when the app state is initialized
  }

  Future<void> fetchNouns() async {
    try {
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
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching nouns: $e');
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

      await FirebaseFirestore.instance.collection('Nouns').doc('allPairs').set({
        'pairs': nounArticlePairs,
      });
      print('Loaded nouns from assets: $nounArticlePairs'); // Debugging information
    } catch (e) {
      print('Error loading nouns from assets: $e');
    }
  }

  Future<void> fetchAdjectives() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('adjectives').doc('allAdjectives').get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final pairs = data['adjectives'] as List<dynamic>;
        adjectives = pairs.map((pair) {
          return {
            'adjective': pair['adjective'] as String? ?? '',
            'use': pair['use'] as bool? ?? false,
            'translation': pair['translation'] as String? ?? '',
          };
        }).toList();
        print('Fetched adjectives Successful'); // Debugging information
        notifyListeners();
      } else {
        print('No document found for adjectives/allAdjectives');
      }
    } catch (e) {
      print('Error fetching adjectives: $e');
    }
  }

  Future<void> loadAdjectivesFromAssets() async {
    try {
      final csvData = await rootBundle.loadString('assets/adjectives.csv');
      List<List<dynamic>> rows = const CsvToListConverter().convert(csvData);

      List<Map<String, dynamic>> adjectivePairs = [];

      for (var row in rows) {
        final adjective = row[0] as String;
        final use = row[1] == 'y';
        final translation = row[2] as String;

        adjectivePairs.add({
          'adjective': adjective,
          'use': use,
          'translation': translation,
        });
      }

      await FirebaseFirestore.instance.collection('adjectives').doc('allAdjectives').set({
        'adjectives': adjectivePairs,
      });
      print('Loaded adjectives from assets: $adjectivePairs'); // Debugging information
    } catch (e) {
      print('Error loading adjectives from assets: $e');
    }
  }

  Future<void> fetchHighScore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    final doc = await docRef.get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      switch (difficulty) {
        case 'Easy':
          highScore = data['score_easy'] as int? ?? 0;
          break;
        case 'Intermediate':
          highScore = data['score_intermediate'] as int? ?? 0;
          break;
        case 'Hardcore':
          highScore = data['score_hardcore'] as int? ?? 0;
          break;
      }
    } else {
      highScore = 0;
    }
    notifyListeners();
  }

  void setDifficulty(String difficulty) {
    this.difficulty = difficulty;
    score = 0;
    mana = 0;
    correctStreak = 0;
    failedPairs.clear();
    fetchHighScore();
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
      print('No article selected');
      return;
    }
    if (nouns[currentIndex]['article'] == selectedArticle) {
      isCorrect = true;
      correctStreak++;
      score++;
      mana = (mana + 10).clamp(0, 100);
      if (correctStreak > highScore) {
        highScore = correctStreak;
      }
      // Increase elo points based on difficulty
      switch (difficulty) {
        case 'Easy':
          elo += 10;
          break;
        case 'Intermediate':
          elo += 20;
          break;
        case 'Hardcore':
          elo += 30;
          break;
      }
      // Check if the user has reached a new star
      for (var star in stars) {
        if (score >= star['distance'] && lastStar != star['name']) {
          lastStar = star['name'];
          saveProgress();
          break;
        }
      }
      // Move to the next noun only if the answer is correct
      currentIndex = (currentIndex + 1) % nouns.length;
    } else {
      isCorrect = false;
      correctStreak = 0;
      healthPoints -= damageAmount;
      mana = 0;
      if (!failedPairs.any((pair) => pair['noun'] == nouns[currentIndex]['noun'] && pair['article'] == nouns[currentIndex]['article'])) {
        failedPairs.add(nouns[currentIndex]);
      }
      if (healthPoints <= 0) {
        healthPoints = 0;
        print('Game Over');
        await updateHighScore();
        await saveElo(); // Save elo when the player dies
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GameOverScreen(score: score, failedPairs: failedPairs)),
        );
      }
    }
    // Retain the selected article
    notifyListeners();
  }

  Future<void> updateHighScore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    final doc = await docRef.get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      int currentHighScore;
      switch (difficulty) {
        case 'Easy':
          currentHighScore = data['score_easy'] as int? ?? 0;
          if (score > currentHighScore) {
            await docRef.update({'score_easy': score});
          }
          break;
        case 'Intermediate':
          currentHighScore = data['score_intermediate'] as int? ?? 0;
          if (score > currentHighScore) {
            await docRef.update({'score_intermediate': score});
          }
          break;
        case 'Hardcore':
          currentHighScore = data['score_hardcore'] as int? ?? 0;
          if (score > currentHighScore) {
            await docRef.update({'score_hardcore': score});
          }
          break;
      }
    } else {
      switch (difficulty) {
        case 'Easy':
          await docRef.set({'score_easy': score}, SetOptions(merge: true));
          break;
        case 'Intermediate':
          await docRef.set({'score_intermediate': score}, SetOptions(merge: true));
          break;
        case 'Hardcore':
          await docRef.set({'score_hardcore': score}, SetOptions(merge: true));
          break;
      }
    }
  }

  void nextNoun() {
    currentIndex = (currentIndex + 1) % nouns.length;
    isCorrect = false;
    notifyListeners();
  }

  void addHealth() {
    switch (difficulty) {
      case 'Easy':
        healthPoints = (healthPoints + 20).clamp(0, 100);
        break;
      case 'Intermediate':
        healthPoints = (healthPoints + 10).clamp(0, 100);
        break;
      case 'Hardcore':
        healthPoints = (healthPoints + 5).clamp(0, 100);
        break;
      default:
        healthPoints = (healthPoints + 10).clamp(0, 100);
    }
    mana = 0;
    notifyListeners();
  }

  Future<void> saveElo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'elo': elo,
      }, SetOptions(merge: true));
    }
  }

  Future<void> loadElo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        elo = doc.data()?['elo'] ?? 0;
        notifyListeners();
      }
    }
  }

  Future<void> loadAlias() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        alias = doc.data()?['alias'] ?? '';
        notifyListeners();
      }
    }
  }

  Future<void> saveProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'lastStar': lastStar,
      }, SetOptions(merge: true));
    }
  }

  Future<void> loadProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        lastStar = doc.data()?['lastStar'] ?? 'Home';
        notifyListeners();
      }
    }
  }

  int getDistanceToNearestStar() {
    for (var star in stars) {
      if (score < star['distance']) {
        return star['distance'] - score;
      }
    }
    return 0; // If all stars are reached
  }

  String getRank() {
    if (elo < 300) return 'Intern';
    if (elo < 600) return 'Navigator';
    if (elo < 900) return 'Explorer';
    if (elo < 1200) return 'Pilot';
    if (elo < 1500) return 'Scholar';
    if (elo < 1800) return 'Voyager';
    if (elo < 2100) return 'Pioneer';
    return 'Legend';
  }

  String getLevel() {
    int level = (elo % 300) ~/ 100;
    switch (level) {
      case 0:
        return '1';
      case 1:
        return '2';
      case 2:
        return '3';
      default:
        return '1';
    }
  }

  String getTagline() {
    String rank = getRank();
    String level = getLevel();
    Map<String, Map<String, String>> taglines = {
      'Intern': {
        '1': 'Gate Grunt',
        '2': 'Code Cracker',
        '3': 'Article Apprentice',
      },
      'Navigator': {
        '1': 'Directionally Challenged',
        '2': 'Warp Wannabe',
        '3': 'Almost Lost',
      },
      'Explorer': {
        '1': 'Star Stumbler',
        '2': 'Galaxy Glider',
        '3': 'Space Surveyor',
      },
      'Pilot': {
        '1': 'Momentum Miser',
        '2': 'Deceleration Dodger',
        '3': 'Gravity Gambler',
      },
      'Scholar': {
        '1': 'Noun Novice',
        '2': 'Article Adept',
        '3': 'Grammar Gladiator',
      },
      'Voyager': {
        '1': 'Void Venturer',
        '2': 'Nebula Navigator',
        '3': 'Stellar Specialist',
      },
      'Pioneer': {
        '1': 'Warp Wizard',
        '2': 'Star Streamliner',
        '3': 'Cosmic Commander',
      },
      'Legend': {
        '1': 'Linguistic Luminary',
        '2': 'Universal Gatekeeper',
        '3': 'Warp Guardian',
      },
    };
    return taglines[rank]?[level] ?? '';
  }

  String getRankFromElo(int elo) {
    if (elo < 300) return 'Intern';
    if (elo < 600) return 'Navigator';
    if (elo < 900) return 'Explorer';
    if (elo < 1200) return 'Pilot';
    if (elo < 1500) return 'Scholar';
    if (elo < 1800) return 'Voyager';
    if (elo < 2100) return 'Pioneer';
    return 'Legend';
  }

  String getLevelFromElo(int elo) {
    int level = (elo % 300) ~/ 100;
    switch (level) {
      case 0:
        return '1';
      case 1:
        return '2';
      case 2:
        return '3';
      default:
        return '1';
    }
  }

  List<String> get articles => _articles;
}
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
  int rating = 0; // Add rating variable
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
    loadRating(); // Load rating when the app state is initialized
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
        print('Fetched nouns: $nouns'); // Debugging information
        notifyListeners();
      } else {
        print('No document found for Nouns/allPairs');
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
        print('Fetched adjectives: $adjectives'); // Debugging information
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
      // Increase rating points based on difficulty
      switch (difficulty) {
        case 'Easy':
          rating += 10;
          break;
        case 'Intermediate':
          rating += 20;
          break;
        case 'Hardcore':
          rating += 30;
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
        await saveRating(); // Save rating when the player dies
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GameOverScreen(score: score, failedPairs: failedPairs)),
        );
      }
    }
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

  Future<void> saveRating() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'rating': rating,
      }, SetOptions(merge: true));
    }
  }

  Future<void> loadRating() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        rating = doc.data()?['rating'] ?? 0;
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
    if (rating < 300) return 'Warp Gate Intern';
    if (rating < 600) return 'Junior Navigator';
    if (rating < 900) return 'Gate Explorer';
    if (rating < 1200) return 'Dimensional Pilot';
    if (rating < 1500) return 'Ancient Scholar';
    if (rating < 1800) return 'Astro Voyager';
    if (rating < 2100) return 'Interstellar Pioneer';
    return 'Galactic Legend';
  }

  String getLevel() {
    int level = (rating % 300) ~/ 100;
    switch (level) {
      case 0:
        return 'Bronze';
      case 1:
        return 'Silver';
      case 2:
        return 'Gold';
      default:
        return 'Bronze';
    }
  }

  String getTagline() {
    String rank = getRank();
    String level = getLevel();
    Map<String, Map<String, String>> taglines = {
      'Warp Gate Intern': {
        'Bronze': 'Gate Grunt',
        'Silver': 'Code Cracker',
        'Gold': 'Article Apprentice',
      },
      'Junior Navigator': {
        'Bronze': 'Directionally Challenged',
        'Silver': 'Warp Wannabe',
        'Gold': 'Almost Lost',
      },
      'Gate Explorer': {
        'Bronze': 'Star Stumbler',
        'Silver': 'Galaxy Glider',
        'Gold': 'Space Surveyor',
      },
      'Dimensional Pilot': {
        'Bronze': 'Momentum Miser',
        'Silver': 'Deceleration Dodger',
        'Gold': 'Gravity Gambler',
      },
      'Ancient Scholar': {
        'Bronze': 'Noun Novice',
        'Silver': 'Article Adept',
        'Gold': 'Grammar Gladiator',
      },
      'Astro Voyager': {
        'Bronze': 'Void Venturer',
        'Silver': 'Nebula Navigator',
        'Gold': 'Stellar Specialist',
      },
      'Interstellar Pioneer': {
        'Bronze': 'Warp Wizard',
        'Silver': 'Star Streamliner',
        'Gold': 'Cosmic Commander',
      },
      'Galactic Legend': {
        'Bronze': 'Linguistic Luminary',
        'Silver': 'Universal Gatekeeper',
        'Gold': 'Warp Guardian',
      },
    };
    return taglines[rank]?[level] ?? '';
  }

  List<String> get articles => _articles;
}
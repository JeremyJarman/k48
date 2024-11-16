import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'game_over_screen.dart';

class MyAppState extends ChangeNotifier {
  List<Map<String, String>> nouns = [];
  List<Map<String, dynamic>> adjectives = [];
  List<Map<String, String>> failedPairs = []; // Add a list to store failed pairs
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
    fetchAdjectives();
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

      // Store all pairs in a single document
      await FirebaseFirestore.instance.collection('Nouns').doc('allPairs').set({
        'pairs': nounArticlePairs,
      });
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
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching adjectives: $e');
    }
  }

  Future<void> loadAdjectivesFromAssets() async {
    try {
      final csvData = await rootBundle.loadString('assets/Adjectives.csv');
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

      // Store all pairs in a single document
      await FirebaseFirestore.instance.collection('adjectives').doc('allAdjectives').set({
        'adjectives': adjectivePairs,
      });
    } catch (e) {
      print('Error loading adjectives from assets: $e');
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
    correctStreak = 0; // Reset correct streak at the beginning of a new quiz
    failedPairs.clear(); // Clear the list of failed pairs at the beginning of a new quiz
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
      print('No article selected');
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
      correctStreak = 0; // Reset correct streak on wrong answer
      healthPoints -= damageAmount; // Deduct health points
      mana = 0; // Reset mana on incorrect answer
      // Ensure the failed pair is not already in the list
      if (!failedPairs.any((pair) => pair['noun'] == nouns[currentIndex]['noun'] && pair['article'] == nouns[currentIndex]['article'])) {
        failedPairs.add(nouns[currentIndex]); // Add the failed pair to the list if it's not already there
      }
      if (healthPoints <= 0) {
        healthPoints = 0;
        print('Game Over');
        // Handle game over logic here
        await updateHighScore();
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
    mana = 0; // Reset mana after using the heart button
    notifyListeners();
  }
}
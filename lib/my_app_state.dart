import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dataset_service.dart';
//import 'package:flutter/services.dart' show rootBundle;
//import 'package:csv/csv.dart';
//import 'package:shared_preferences/shared_preferences.dart';
//import 'game_over_screen.dart';



class MyAppState extends ChangeNotifier {
  
  //List<String> _articles = ['der', 'die', 'das']; // Example articles
  DatasetService datasetService = DatasetService(); // Use DatasetService

  List<Map<String, dynamic>> stars = [];

  int _elo = 0; // Default ELO
  String _alias = 'UserAlias'; // Default alias
  int _healthPoints = 100; // Default health points

  int get elo => _elo;
  String get alias => _alias;
  int get healthPoints => _healthPoints;

  static const List<Map<String, dynamic>> ranks = [
    {'name': 'Intern', 'minElo': 0, 'maxElo': 299},
    {'name': 'Navigator', 'minElo': 300, 'maxElo': 599},
    {'name': 'Explorer', 'minElo': 600, 'maxElo': 899},
    {'name': 'Pilot', 'minElo': 900, 'maxElo': 1199},
    {'name': 'Scholar', 'minElo': 1200, 'maxElo': 1499},
    {'name': 'Voyager', 'minElo': 1500, 'maxElo': 1799},
    {'name': 'Pioneer', 'minElo': 1800, 'maxElo': 2099},
    {'name': 'Legend', 'minElo': 2100, 'maxElo': double.infinity},
  ];

  MyAppState() {
    _loadState();
  }

  Future<void> _loadState() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _elo = (data['elo'] ?? 0).clamp(0, double.infinity).toInt();
        _alias = data['alias'] ?? 'UserAlias';
        datasetService.unlockedWortschatzDatasets = List<String>.from(data['unlockedDatasets'] ?? ['WordLists_01.csv']);
        datasetService.unlockedArticleDatasets = List<String>.from(data['unlockedArticleDatasets'] ?? ['d1.csv']);
        datasetService.datasetScores = Map<String, double>.from(data['datasetPassPercentages'] ?? {});
        notifyListeners();
      }
    }
  }

  Future<void> _saveState() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'elo': _elo,
        'alias': _alias,
        'unlockedDatasets': datasetService.unlockedWortschatzDatasets,
        'unlockedArticleDatasets': datasetService.unlockedArticleDatasets,
        'datasetPassPercentages': datasetService.datasetScores,
      }, SetOptions(merge: true));
    }
  }

  void updateElo(int newElo) {
    _elo = newElo.clamp(0, double.infinity).toInt();
    _saveState();
    notifyListeners();
  }

  void updateAlias(String newAlias) {
    _alias = newAlias;
    _saveState();
    notifyListeners();
  }

  void unlockDataset(String dataset, bool isArticle) {
    datasetService.unlockDataset(dataset, isArticle);
    _saveState();
    notifyListeners();
  }

  void unlockNextDataset(bool isArticle) {
    datasetService.unlockNextDataset(isArticle);
    _saveState();
    notifyListeners();
  }

  void updateDatasetPassPercentage(String dataset, double percentage) {
    datasetService.updateDatasetScore(dataset, percentage);
    _saveState();
    notifyListeners();
  }

  void updateHealthPoints(int newHealthPoints) {
    _healthPoints = newHealthPoints;
    notifyListeners();
  }

  String getRankBadge() {
    final currentRank = ranks.firstWhere((rank) => _elo >= rank['minElo'] && _elo <= rank['maxElo']);
    final levelWithinRank = ((_elo - currentRank['minElo']) / 100).floor() + 1;
    return '${currentRank['name']}$levelWithinRank.svg';
  }

  String getRank(int elo) {
    for (var rank in ranks) {
      if (elo >= rank['minElo'] && elo <= rank['maxElo']) {
        return rank['name'];
      }
    }
    return 'Unknown';
  }

  int getLevel(int elo) {
    for (var rank in ranks) {
      if (elo >= rank['minElo'] && elo <= rank['maxElo']) {
        int range = rank['maxElo'] - rank['minElo'] + 1;
        int levelRange = range ~/ 3;
        if (elo < rank['minElo'] + levelRange) return 1;
        if (elo < rank['minElo'] + 2 * levelRange) return 2;
        return 3;
      }
    }
    return 0;
  }

  double getProgress(int elo) {
    for (var rank in ranks) {
      if (elo >= rank['minElo'] && elo <= rank['maxElo']) {
        int range = rank['maxElo'] - rank['minElo'] + 1;
        return (elo - rank['minElo']) / range;
      }
    }
    return 0.0;
  }
}

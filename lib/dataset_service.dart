//import 'package:shared_preferences/shared_preferences.dart';
//import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatasetService extends ChangeNotifier {
  List<Map<String, dynamic>> allWortschatzDatasets = [
    {'filename': 'WordLists_01.csv', 'title': 'Menschen', 'elo': 1000},
    {'filename': 'WordLists_02.csv', 'title': 'Station im Leben', 'elo': 1050},
    {'filename': 'WordLists_03.csv', 'title': 'Wohnen', 'elo': 1100},
    {'filename': 'WordLists_04.csv', 'title': 'Freizeit und Kultur', 'elo': 1100},
  ]; // Example datasets

  List<Map<String, dynamic>> allArticleDatasets = [
    {'filename': 'd1.csv', 'title': 'Top 100', 'elo': 1100},
    {'filename': 'd2.csv', 'title': '101 - 200', 'elo': 1200},
    {'filename': 'd3.csv', 'title': '201 - 300', 'elo': 1300}, 
    {'filename': 'd4.csv', 'title': '301 - 400', 'elo': 1400},
    {'filename': 'd5.csv', 'title': '401 - 500', 'elo': 1500},
    {'filename': 'd6.csv', 'title': '501 - 600', 'elo': 1600}, 
  ]; // Example datasets

  List<String> unlockedWortschatzDatasets = [];
  List<String> unlockedArticleDatasets = [];

  Map<String, double> datasetScores = {};

  DatasetService() {
    _initializeDefaults();
    _loadState();
  }

  void _initializeDefaults() {
    if (allWortschatzDatasets.isNotEmpty) {
      unlockedWortschatzDatasets = [allWortschatzDatasets.first['filename']];
    }
    if (allArticleDatasets.isNotEmpty) {
      unlockedArticleDatasets = [allArticleDatasets.first['filename']];
    }
  }

  Future<void> loadStateAtLogin(String uid) async {
    final userID = uid;
    final doc = await FirebaseFirestore.instance.collection('users').doc(userID).get();
      if (doc.exists) {
        final data = doc.data()!;
        unlockedWortschatzDatasets = List<String>.from(data['unlockedDatasets'] ?? [allWortschatzDatasets.first['filename']]);
        unlockedArticleDatasets = List<String>.from(data['unlockedArticleDatasets'] ?? [allArticleDatasets.first['filename']]);
        datasetScores = Map<String, double>.from(data['datasetPassPercentages'] ?? {});
        notifyListeners();
      }
    
  }

  Future<void> _loadState() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        unlockedWortschatzDatasets = List<String>.from(data['unlockedDatasets'] ?? [allWortschatzDatasets.first['filename']]);
        unlockedArticleDatasets = List<String>.from(data['unlockedArticleDatasets'] ?? [allArticleDatasets.first['filename']]);
        datasetScores = Map<String, double>.from(data['datasetPassPercentages'] ?? {});
        notifyListeners();
      }
    }
  }

  Future<void> _saveState() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'unlockedDatasets': unlockedWortschatzDatasets,
        'unlockedArticleDatasets': unlockedArticleDatasets,
        'datasetPassPercentages': datasetScores,
      }, SetOptions(merge: true));
    }
  }

  bool isDatasetUnlocked(String dataset, bool isArticle) {
    return isArticle ? unlockedArticleDatasets.contains(dataset) : unlockedWortschatzDatasets.contains(dataset);
  }

  void unlockDataset(String dataset, bool isArticle) {
    if (isArticle) {
      if (!unlockedArticleDatasets.contains(dataset)) {
        unlockedArticleDatasets.add(dataset);
      }
    } else {
      if (!unlockedWortschatzDatasets.contains(dataset)) {
        unlockedWortschatzDatasets.add(dataset);
      }
    }
    _saveState();
    notifyListeners();
  }

  void unlockNextDataset(bool isArticle) {
    if (isArticle) {
      final nextDatasetIndex = unlockedArticleDatasets.length;
      if (nextDatasetIndex < allArticleDatasets.length) {
        unlockedArticleDatasets.add(allArticleDatasets[nextDatasetIndex]['filename']);
        print('Unlocked next article dataset: ${allArticleDatasets[nextDatasetIndex]['filename']}'); // Debugging statement
      }
    } else {
      final nextDatasetIndex = unlockedWortschatzDatasets.length;
      if (nextDatasetIndex < allWortschatzDatasets.length) {
        unlockedWortschatzDatasets.add(allWortschatzDatasets[nextDatasetIndex]['filename']);
        print('Unlocked next wortschatz dataset: ${allWortschatzDatasets[nextDatasetIndex]['filename']}'); // Debugging statement
      }
    }
    _saveState();
    notifyListeners();
  }

  void updateDatasetScore(String dataset, double score) {
    datasetScores[dataset] = score;
    _saveState();
    notifyListeners();
  }

  double getDatasetScore(String dataset) {
    return datasetScores[dataset] ?? 0.0;
  }

  Future<List<List<dynamic>>> loadCsv(String path) async {
    final data = await rootBundle.loadString(path);
    List<List<dynamic>> csvTable = const CsvToListConverter().convert(data);
    return csvTable;
  }
}
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

enum DatasetType { wortschatz, article, verb }

class DatasetService extends ChangeNotifier {
  bool isGuest = false;
  List<Map<String, dynamic>> allWortschatzDatasets = [
    {'filename': 'WordLists_01.csv', 'title': 'Menschen', 'elo': 100},
    {'filename': 'WordLists_02.csv', 'title': 'Station im Leben', 'elo': 100},
    {'filename': 'WordLists_03.csv', 'title': 'Wohnen', 'elo': 100},
    {'filename': 'WordLists_04.csv', 'title': 'Freizeit und Kultur', 'elo': 100},
  ];

  List<Map<String, dynamic>> allArticleDatasets = [
    {'filename': 'd1.csv', 'title': 'Top 100', 'elo': 100},
    {'filename': 'd2.csv', 'title': '101 - 200', 'elo': 100},
    {'filename': 'd3.csv', 'title': '201 - 300', 'elo': 100}, 
    {'filename': 'd4.csv', 'title': '301 - 400', 'elo': 100},
    {'filename': 'd5.csv', 'title': '401 - 500', 'elo': 100},
    {'filename': 'd6.csv', 'title': '501 - 600', 'elo': 100},
    {'filename': 'd7.csv', 'title': '601 - 700', 'elo': 100},
    {'filename': 'd8.csv', 'title': '701 - 800', 'elo': 100},
    {'filename': 'd9.csv', 'title': '801 - 900', 'elo': 100},
    {'filename': 'd10.csv', 'title': '901 - 1000', 'elo': 100},
    {'filename': 'd11.csv', 'title': '1001 - 1100', 'elo': 100},
    {'filename': 'd12.csv', 'title': '1101 - 1200', 'elo': 100},
    {'filename': 'd13.csv', 'title': '1201 - 1300', 'elo': 100},
    {'filename': 'd14.csv', 'title': '1301 - 1400', 'elo': 100},
    {'filename': 'd15.csv', 'title': '1401 - 1500', 'elo': 100},
    {'filename': 'd16.csv', 'title': '1501 - 1600', 'elo': 100},
    {'filename': 'd17.csv', 'title': '1601 - 1700', 'elo': 100},
    {'filename': 'd18.csv', 'title': '1701 - 1781', 'elo': 100},
  ];

  List<Map<String, dynamic>> allVerbDatasets = [
    {'filename': 'v1.csv', 'title': 'Top 100', 'elo': 100},
    {'filename': 'v2.csv', 'title': '101 - 200', 'elo': 100},
    {'filename': 'v3.csv', 'title': '201 - 300', 'elo': 100},
    {'filename': 'v4.csv', 'title': '301 - 400', 'elo': 100},
    {'filename': 'v5.csv', 'title': '401 - 500', 'elo': 100},
    {'filename': 'v6.csv', 'title': '501 - 600', 'elo': 100},
    {'filename': 'v7.csv', 'title': '601 - 700', 'elo': 100},
    {'filename': 'v8.csv', 'title': '701 - 800', 'elo': 100},
    {'filename': 'v9.csv', 'title': '801 - 900', 'elo': 100},
    {'filename': 'v10.csv', 'title': '901 - 1000', 'elo': 100},
    {'filename': 'v11.csv', 'title': '1001 - 1055', 'elo': 100},
  ];

  List<String> unlockedWortschatzDatasets = [];
  List<String> unlockedArticleDatasets = [];
  List<String> unlockedVerbDatasets = [];
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
    if (allVerbDatasets.isNotEmpty) {
      unlockedVerbDatasets = [allVerbDatasets.first['filename']];
    }
  }

  Future<void> loadStateAtLogin(String uid) async {
    if (isGuest) return;
    final userID = uid;
    final doc = await FirebaseFirestore.instance.collection('users').doc(userID).get();
    if (doc.exists) {
      final data = doc.data()!;
      unlockedWortschatzDatasets = List<String>.from(data['unlockedDatasets'] ?? [allWortschatzDatasets.first['filename']]);
      unlockedArticleDatasets = List<String>.from(data['unlockedArticleDatasets'] ?? [allArticleDatasets.first['filename']]);
      unlockedVerbDatasets = List<String>.from(data['unlockedVerbDatasets'] ?? [allVerbDatasets.first['filename']]);
      datasetScores = Map<String, double>.from(data['datasetPassPercentages'] ?? {});
      notifyListeners();
    }
  }

  Future<void> _loadState() async {
    if (isGuest) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        unlockedWortschatzDatasets = List<String>.from(data['unlockedDatasets'] ?? [allWortschatzDatasets.first['filename']]);
        unlockedArticleDatasets = List<String>.from(data['unlockedArticleDatasets'] ?? [allArticleDatasets.first['filename']]);
        unlockedVerbDatasets = List<String>.from(data['unlockedVerbDatasets'] ?? [allVerbDatasets.first['filename']]);
        datasetScores = Map<String, double>.from(data['datasetPassPercentages'] ?? {});
        notifyListeners();
      }
    }
  }

  Future<void> _saveState() async {
    if (isGuest) {
      print('DEBUG: DatasetService._saveState called but in guest mode, skipping Firestore write.');
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final dataToSave = {
        'unlockedDatasets': unlockedWortschatzDatasets,
        'unlockedArticleDatasets': unlockedArticleDatasets,
        'unlockedVerbDatasets': unlockedVerbDatasets,
        'datasetPassPercentages': datasetScores,
      };
      print('DEBUG: DatasetService._saveState writing to Firestore for user: ${user.uid}');
      print('DEBUG: Data being written: ${dataToSave}');
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(dataToSave, SetOptions(merge: true));
    } else {
      print('DEBUG: DatasetService._saveState called but no user is logged in.');
    }
  }

  bool isDatasetUnlocked(String dataset, bool isArticle) {
    if (isArticle) {
      return unlockedArticleDatasets.contains(dataset);
    } else if (dataset.startsWith('v')) {
      return unlockedVerbDatasets.contains(dataset);
    } else {
      return unlockedWortschatzDatasets.contains(dataset);
    }
  }

  void unlockDataset(String dataset, bool isArticle) {
    if (isArticle) {
      if (!unlockedArticleDatasets.contains(dataset)) {
        unlockedArticleDatasets.add(dataset);
      }
    } else if (dataset.startsWith('v')) {
      if (!unlockedVerbDatasets.contains(dataset)) {
        unlockedVerbDatasets.add(dataset);
      }
    } else {
      if (!unlockedWortschatzDatasets.contains(dataset)) {
        unlockedWortschatzDatasets.add(dataset);
      }
    }
    notifyListeners();
  }

  void unlockNextDataset(DatasetType type) {
    switch (type) {
      case DatasetType.article:
        final nextDatasetIndex = unlockedArticleDatasets.length;
        if (nextDatasetIndex < allArticleDatasets.length) {
          if (nextDatasetIndex == 0 || (datasetScores[allArticleDatasets[nextDatasetIndex - 1]['filename']] ?? 0) >= 50) {
            unlockedArticleDatasets.add(allArticleDatasets[nextDatasetIndex]['filename']);
            developer.log('Unlocked next article dataset:  [38;5;2m${allArticleDatasets[nextDatasetIndex]['filename']} [0m');
          }
        }
        break;
      case DatasetType.verb:
        final nextVerbDatasetIndex = unlockedVerbDatasets.length;
        if (nextVerbDatasetIndex < allVerbDatasets.length) {
          if (nextVerbDatasetIndex == 0 || (datasetScores[allVerbDatasets[nextVerbDatasetIndex - 1]['filename']] ?? 0) >= 50) {
            unlockedVerbDatasets.add(allVerbDatasets[nextVerbDatasetIndex]['filename']);
            developer.log('Unlocked next verb dataset:  [38;5;2m${allVerbDatasets[nextVerbDatasetIndex]['filename']} [0m');
          }
        }
        break;
      case DatasetType.wortschatz:
      default:
        final nextDatasetIndex = unlockedWortschatzDatasets.length;
        if (nextDatasetIndex < allWortschatzDatasets.length) {
          if (nextDatasetIndex == 0 || (datasetScores[allWortschatzDatasets[nextDatasetIndex - 1]['filename']] ?? 0) >= 50) {
            unlockedWortschatzDatasets.add(allWortschatzDatasets[nextDatasetIndex]['filename']);
            developer.log('Unlocked next wortschatz dataset:  [38;5;2m${allWortschatzDatasets[nextDatasetIndex]['filename']} [0m');
          }
        }
        break;
    }
    notifyListeners();
  }

  void updateDatasetScore(String dataset, double score) {
    final oldScore = datasetScores[dataset];
    print('DEBUG: updateDatasetScore called for dataset: '
        ' [33m$dataset [0m. Old score:  [36m$oldScore [0m, New score:  [32m$score [0m');
    datasetScores[dataset] = score;
    notifyListeners();
  }

  double getDatasetScore(String dataset) {
    return datasetScores[dataset] ?? 0.0;
  }

  void resetAll() {
    unlockedWortschatzDatasets.clear();
    unlockedArticleDatasets.clear();
    unlockedVerbDatasets.clear();
    datasetScores.clear();
    _initializeDefaults();
    notifyListeners();
  }

  Future<List<List<dynamic>>> loadCsv(String path) async {
    final data = await rootBundle.loadString(path);
    List<List<dynamic>> csvTable = const CsvToListConverter().convert(data);
    return csvTable;
  }
}
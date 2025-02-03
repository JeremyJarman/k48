import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

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

Future<void> uploadDatasetsToFirestore() async {
  try {
    for (var dataset in allWortschatzDatasets) {
      final csvData = await loadCsv(dataset['filename']);
      print('Attempting to load ${dataset['filename']}'); // Debug print
      List<List<dynamic>> rows = csvData;

      List<Map<String, String>> wortschatzRows = [];

      for (var row in rows) {
        final type = row[0] as String;
        final prefix = row[1] as String;
        final word = row[2] as String;
        final suffix = row[3] as String;
        final translation = row[4] as String;
        final definition = row[5] as String;
        final example = row[6] as String;

        wortschatzRows.add({
          'type': type,
          'prefix': prefix,
          'word': word,
          'suffix': suffix,
          'translation': translation,
          'definition': definition,
          'example': example,
        });
      }
        await FirebaseFirestore.instance.collection('Wortschatz').doc(dataset['filename']).set({
        'Wortschatz': wortschatzRows,
      });
      print('Uploading dataset: ${dataset['filename']}'); // Debug print
    }

    for (var dataset in allArticleDatasets) {
     final csvData = await loadCsv(dataset['filename']);
      print('Attempting to load ${dataset['filename']}'); // Debug print
      List<List<dynamic>> rows = csvData;

      List<Map<String, String>> articleRows = [];

      for (var row in rows) {
        final index = row[0] as String;
        final article = row[1] as String;
        final noun = row[2] as String;
        final translation = row[3] as String;
      

        articleRows.add({
          'index': index,
          'article': article,
          'noun': noun,
          'translation': translation,
        });
      }
        await FirebaseFirestore.instance.collection('Articles').doc(dataset['filename']).set({
        'Articles': articleRows,
      });
      print('Uploading dataset: ${dataset['filename']}'); // Debug print
    }

    print('Datasets uploaded successfully');
  } catch (e) {
    print('Error uploading datasets to firestore: $e');
  }
}


  Future<void> downloadWortschatzDatasetsFromFirestore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (var dataset in allWortschatzDatasets) {
        final localData = prefs.getString('Wortschatz_${dataset['filename']}');
        if (localData != null) {
          List<Map<String, String>> wortschatzRows = List<Map<String, String>>.from(json.decode(localData));
          print('Loaded dataset from local storage: ${dataset['filename']}'); // Debug print
        } else {
          final doc = await FirebaseFirestore.instance.collection('Wortschatz').doc(dataset['filename']).get();
          if (doc.exists) {
            final data = doc.data();




            if (data != null) {
              List<Map<String, String>> wortschatzRows = List<Map<String, String>>.from(data['Wortschatz']);
              // Store the data locally
              prefs.setString('Wortschatz_${dataset['filename']}', json.encode(wortschatzRows));
              // Process the data as needed
              print('Downloaded dataset: ${dataset['filename']}'); // Debug print
            }
          }
        }
      }
    } catch (e) {
      print('Error downloading Wortschatz datasets: $e');
    }
  }

  Future<void> downloadArticleDatasetsFromFirestore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (var dataset in allArticleDatasets) {
        final localData = prefs.getString('Articles_${dataset['filename']}');
        if (localData != null) {
          List<Map<String, String>> articleRows = List<Map<String, String>>.from(json.decode(localData));
          // Process the data as needed
          print('Loaded dataset from local storage: ${dataset['filename']}'); // Debug print
        } else {
          final doc = await FirebaseFirestore.instance.collection('Articles').doc(dataset['filename']).get();
          if (doc.exists) {
            final data = doc.data();
            if (data != null) {
              List<Map<String, String>> articleRows = List<Map<String, String>>.from(data['Articles']);
              // Store the data locally
              prefs.setString('Articles_${dataset['filename']}', json.encode(articleRows));
              // Process the data as needed
              print('Downloaded dataset: ${dataset['filename']}'); // Debug print
            }
          }
        }
      }
    } catch (e) {
      print('Error downloading Article datasets: $e');
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
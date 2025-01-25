import 'package:shared_preferences/shared_preferences.dart';

class DatasetService {
  static const String _completedDatasetsKey = 'completed_datasets';
  static const String _datasetScoresKey = 'dataset_scores';

  // List all datasets here with their corresponding CSV filenames and titles
  final List<Map<String, String>> allDatasets = [
    {'filename': 'WordLists_01.csv', 'title': 'Menschen'},
    {'filename': 'WordLists_02.csv', 'title': 'Stationen im leben'},
    {'filename': 'WordLists_03.csv', 'title': 'Wohnen'},
    {'filename': 'WordLists_04.csv', 'title': 'Freizeit und Kultur'},
    // Add more datasets as needed
  ];

  Future<List<String>> getUnlockedDatasets() async {
    final prefs = await SharedPreferences.getInstance();
    final completedDatasets = prefs.getStringList(_completedDatasetsKey) ?? [];

    // Unlock the first dataset by default
    if (completedDatasets.isEmpty) {
      return [allDatasets.first['filename']!];
    }

    // Unlock the next dataset if the previous one is completed
    final unlockedDatasets = <String>[];
    for (var dataset in allDatasets) {
      unlockedDatasets.add(dataset['filename']!);
      if (!completedDatasets.contains(dataset['filename'])) {
        break;
      }
    }

    return unlockedDatasets;
  }

  Future<void> markDatasetAsCompleted(String dataset, int score) async {
    final prefs = await SharedPreferences.getInstance();
    final completedDatasets = prefs.getStringList(_completedDatasetsKey) ?? [];
    if (!completedDatasets.contains(dataset)) {
      completedDatasets.add(dataset);
      await prefs.setStringList(_completedDatasetsKey, completedDatasets);
    }

    // Store the score
    final datasetScores = prefs.getStringList(_datasetScoresKey) ?? [];
    final scoreEntry = '$dataset:$score';
    final existingIndex = datasetScores.indexWhere((entry) => entry.startsWith('$dataset:'));
    if (existingIndex != -1) {
      datasetScores[existingIndex] = scoreEntry;
    } else {
      datasetScores.add(scoreEntry);
    }
    await prefs.setStringList(_datasetScoresKey, datasetScores);
  }

  Future<Map<String, int>> getDatasetScores() async {
    final prefs = await SharedPreferences.getInstance();
    final datasetScores = prefs.getStringList(_datasetScoresKey) ?? [];
    final scoresMap = <String, int>{};
    for (var entry in datasetScores) {
      final parts = entry.split(':');
      if (parts.length == 2) {
        scoresMap[parts[0]] = int.parse(parts[1]);
      }
    }
    return scoresMap;
  }

  Future<List<String>> getCompletedDatasets() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_completedDatasetsKey) ?? [];
  }
}
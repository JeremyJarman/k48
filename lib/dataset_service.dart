import 'package:shared_preferences/shared_preferences.dart';
import 'csv_loader.dart';

class DatasetService {
  static const String _completedDatasetsKey = 'completed_datasets';
  static const String _completedArticleDatasetsKey = 'completed_article_datasets';
  static const String _datasetScoresKey = 'dataset_scores';
  static const String _articleDatasetScoresKey = 'article_dataset_scores';

  // List all wortschatz datasets here with their corresponding CSV filenames and titles
  final List<Map<String, String>> allDatasets = [
    {'filename': 'WordLists_01.csv', 'title': 'Menschen'},
    {'filename': 'WordLists_02.csv', 'title': 'Stationen im Leben'},
    {'filename': 'WordLists_03.csv', 'title': 'Wohnen'},
    {'filename': 'WordLists_04.csv', 'title': 'Freizeit und Kultur'},
    // Add more datasets as needed
  ];

  // List all article datasets here with their corresponding CSV filenames and titles
  final List<Map<String, String>> allArticleDatasets = [
    {'filename': 'd1.csv', 'title': 'Top 100'},
    {'filename': 'd2.csv', 'title': '200 - 300'},
    {'filename': 'd3.csv', 'title': '300 - 400'},
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

  Future<List<String>> getUnlockedArticleDatasets() async {
    final prefs = await SharedPreferences.getInstance();
    final completedDatasets = prefs.getStringList(_completedArticleDatasetsKey) ?? [];

    // Unlock the first dataset by default
    if (completedDatasets.isEmpty) {
      return [allArticleDatasets.first['filename']!];
    }

    // Unlock the next dataset if the previous one is completed
    final unlockedDatasets = <String>[];
    for (var dataset in allArticleDatasets) {
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
    final datasetScores = prefs.getStringList(_datasetScoresKey) ?? [];

    if (!completedDatasets.contains(dataset)) {
      completedDatasets.add(dataset);
    }

    // Remove any existing score for this dataset
    datasetScores.removeWhere((element) => element.startsWith('$dataset:'));
    // Add the new score
    datasetScores.add('$dataset:$score');

    await prefs.setStringList(_completedDatasetsKey, completedDatasets);
    await prefs.setStringList(_datasetScoresKey, datasetScores);
  }

  Future<void> markArticleDatasetAsCompleted(String dataset, int score) async {
    final prefs = await SharedPreferences.getInstance();
    final completedDatasets = prefs.getStringList(_completedArticleDatasetsKey) ?? [];
    final datasetScores = prefs.getStringList(_articleDatasetScoresKey) ?? [];

    if (!completedDatasets.contains(dataset)) {
      completedDatasets.add(dataset);
    }

    // Remove any existing score for this dataset
    datasetScores.removeWhere((element) => element.startsWith('$dataset:'));
    // Add the new score
    datasetScores.add('$dataset:$score');

    await prefs.setStringList(_completedArticleDatasetsKey, completedDatasets);
    await prefs.setStringList(_articleDatasetScoresKey, datasetScores);
  }

  Future<Map<String, int>> getDatasetScores() async {
    final prefs = await SharedPreferences.getInstance();
    final datasetScores = prefs.getStringList(_datasetScoresKey) ?? [];
    return Map.fromIterable(
      datasetScores,
      key: (e) => e.split(':')[0],
      value: (e) => int.parse(e.split(':')[1]),
    );
  }

  Future<Map<String, int>> getArticleDatasetScores() async {
    final prefs = await SharedPreferences.getInstance();
    final datasetScores = prefs.getStringList(_articleDatasetScoresKey) ?? [];
    return Map.fromIterable(
      datasetScores,
      key: (e) => e.split(':')[0],
      value: (e) => int.parse(e.split(':')[1]),
    );
  }
}
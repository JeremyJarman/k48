import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dataset_service.dart';
import 'articles_gameplay_screen.dart';

class ArticlesPage extends StatefulWidget {
  @override
  _ArticlesPageState createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {
  late DatasetService _datasetService;
  List<String> _unlockedArticleDatasets = [];
  Map<String, double> _datasetScores = {};

  @override
  void initState() {
    super.initState();
    _datasetService = Provider.of<DatasetService>(context, listen: false);
    _loadUnlockedDatasets();
  }

  Future<void> _loadUnlockedDatasets() async {
    final unlockedArticleDatasets = _datasetService.unlockedArticleDatasets;
    final datasetScores = _datasetService.datasetScores;
    print('Unlocked Articles Datasets: $unlockedArticleDatasets'); // Debugging statement
    print('Dataset Scores: $datasetScores'); // Debugging statement
    Future.microtask(() {
      setState(() {
        _unlockedArticleDatasets = unlockedArticleDatasets;
        _datasetScores = datasetScores;
      });
    });
  }

  void _onDatasetCompleted(String dataset, int score) async {
    _datasetService.updateDatasetScore(dataset, score.toDouble());
    _datasetService.unlockNextDataset(true); // Assuming true for Article datasets
    final unlockedArticleDatasets = _datasetService.unlockedArticleDatasets;
    final datasetScores = _datasetService.datasetScores;
    print('Unlocked Article Datasets after completion: $unlockedArticleDatasets'); // Debugging statement
    print('Article Dataset Scores after completion: $datasetScores'); // Debugging statement
    Future.microtask(() {
      setState(() {
        _unlockedArticleDatasets = unlockedArticleDatasets;
        _datasetScores = datasetScores;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.3),
        title: Text(
          'Articles',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white), // Set back arrow color to white
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/galaxy.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          ListView.builder(
            itemCount: _datasetService.allArticleDatasets.length,
            itemBuilder: (context, index) {
              final dataset = _datasetService.allArticleDatasets[index];
              final isUnlocked = _unlockedArticleDatasets.contains(dataset['filename']);
              final score = _datasetScores[dataset['filename']] ?? 0.0;
              return ListTile(
                title: Text(
                  '${index + 1}. ${dataset['title']} - $score%',
                  style: TextStyle(color: isUnlocked ? Colors.white : Colors.grey),
                ),
                onTap: isUnlocked
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ArticlesGameplayScreen(
                              dataset: dataset['filename']!,
                              title: dataset['title']!,
                              onDatasetCompleted: (score) => _onDatasetCompleted(dataset['filename']!, score),
                            ),
                          ),
                        );
                      }
                    : null,
              );
            },
          ),
        ],
      ),
    );
  }
}
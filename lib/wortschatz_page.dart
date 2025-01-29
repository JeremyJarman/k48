import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dataset_service.dart';
import 'wortschatz_gameplay_screen.dart';
//import 'my_app_state.dart';

class WortschatzPage extends StatefulWidget {
  @override
  _WortschatzPageState createState() => _WortschatzPageState();
}

class _WortschatzPageState extends State<WortschatzPage> {
  late DatasetService _datasetService;
  List<String> _unlockedDatasets = [];
  Map<String, double> _datasetScores = {};

  @override
  void initState() {
    super.initState();
    _datasetService = Provider.of<DatasetService>(context, listen: false);
    _loadUnlockedDatasets();
    _precacheImages();
  }

  Future<void> _loadUnlockedDatasets() async {
    final unlockedDatasets = _datasetService.unlockedWortschatzDatasets;
    final datasetScores = _datasetService.datasetScores;
    print('Unlocked Wortschatz Datasets: $unlockedDatasets'); // Debugging statement
    print('Wortschatz Dataset Scores: $datasetScores'); // Debugging statement
    setState(() {
      _unlockedDatasets = unlockedDatasets;
      _datasetScores = datasetScores;
    });
  }

  Future<void> _precacheImages() async {
    await precacheImage(AssetImage('assets/galaxy.jpg'), context);
  }

  void _onDatasetCompleted(String dataset, int score) async {
    _datasetService.updateDatasetScore(dataset, score.toDouble());
    _datasetService.unlockNextDataset(false); // Assuming false for Wortschatz datasets
    final unlockedDatasets = _datasetService.unlockedWortschatzDatasets;
    final datasetScores = _datasetService.datasetScores;
    print('Unlocked Wortschatz Datasets after completion: $unlockedDatasets'); // Debugging statement
    print('Wortschatz Dataset Scores after completion: $datasetScores'); // Debugging statement
    setState(() {
      _unlockedDatasets = unlockedDatasets;
      _datasetScores = datasetScores;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.3),
        title: Text(
          'Wortschatz',
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
            itemCount: _datasetService.allWortschatzDatasets.length,
            itemBuilder: (context, index) {
              final dataset = _datasetService.allWortschatzDatasets[index];
              final isUnlocked = _unlockedDatasets.contains(dataset['filename']);
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
                            builder: (context) => WortschatzGameplayScreen(
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
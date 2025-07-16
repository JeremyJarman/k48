import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dataset_service.dart';
import 'wortschatz_gameplay_screen.dart';
import 'my_app_state.dart';
import 'dart:developer' as developer; 

class WortschatzPage extends StatefulWidget {
  const WortschatzPage({super.key});

  @override
  WortschatzPageState createState() => WortschatzPageState();
}

class WortschatzPageState extends State<WortschatzPage> {
  late DatasetService _datasetService;
  List<String> _unlockedDatasets = [];
  Map<String, double> _datasetScores = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(const AssetImage('assets/galaxy.jpg'), context);
    });
    // _datasetService = Provider.of<DatasetService>(context, listen: false);
    // _loadUnlockedDatasets();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _datasetService = Provider.of<MyAppState>(context, listen: false).datasetService;
    _loadUnlockedDatasets();
  }

  Future<void> _loadUnlockedDatasets() async {
    final unlockedDatasets = _datasetService.unlockedWortschatzDatasets;
    final datasetScores = _datasetService.datasetScores;
    developer.log('Unlocked Wortschatz Datasets: $unlockedDatasets'); // Debugging statement
    developer.log('Wortschatz Dataset Scores: $datasetScores'); // Debugging statement
    setState(() {
      _unlockedDatasets = unlockedDatasets;
      _datasetScores = datasetScores;
    });
  }

  void _onDatasetCompleted(String dataset, int score) async {
    print('DEBUG: WortschatzPage _onDatasetCompleted: dataset=$dataset, score=$score');
    final unlockedDatasets = _datasetService.unlockedWortschatzDatasets;
    final datasetScores = _datasetService.datasetScores;
    print('DEBUG: WortschatzPage after update: unlockedDatasets=$unlockedDatasets, datasetScores=$datasetScores');
    developer.log('Unlocked Wortschatz Datasets after completion: $unlockedDatasets'); // Debugging statement
    developer.log('Wortschatz Dataset Scores after completion: $datasetScores'); // Debugging statement
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
        iconTheme: IconThemeData(color: Colors.white),
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(height: 50),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(Colors.black.withOpacity(0.3)),
                      showCheckboxColumn: false,
                      columns: const [
                        DataColumn(label: Text('Dataset', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Status', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Percentage', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                      ],
                      rows: List.generate(_datasetService.allWortschatzDatasets.length, (index) {
                        final dataset = _datasetService.allWortschatzDatasets[index];
                        final filename = dataset['filename'];
                        final title = dataset['title'];
                        final isUnlocked = _unlockedDatasets.contains(filename);
                        final score = _datasetScores[filename];
                        String status;
                        if (score == null) {
                          status = 'Not attempted';
                        } else if (score >= 50) {
                          status = 'Passed';
                        } else {
                          status = 'Failed';
                        }
                        return DataRow(
                          cells: [
                            DataCell(Text('${index + 1}. $title', style: TextStyle(color: isUnlocked ? Colors.white : Colors.grey))),
                            DataCell(Text(status, style: TextStyle(color: isUnlocked ? Colors.white : Colors.grey))),
                            DataCell(Text(score == null ? '-' : '${score.toStringAsFixed(0)}%', style: TextStyle(color: isUnlocked ? Colors.white : Colors.grey))),
                          ],
                          onSelectChanged: isUnlocked
                              ? (_) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WortschatzGameplayScreen(
                                        dataset: filename,
                                        title: title,
                                        onDatasetCompleted: (score) => _onDatasetCompleted(filename, score),
                                      ),
                                    ),
                                  );
                                }
                              : null,
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
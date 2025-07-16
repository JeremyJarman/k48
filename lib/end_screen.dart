import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'home_page.dart';
import 'package:provider/provider.dart';
import 'my_app_state.dart';
import 'wortschatz_review.dart';
import 'articles_review.dart';
import 'verbs_review.dart';
import 'dataset_service.dart'; // For DatasetType enum

class EndScreen extends StatefulWidget {
  final bool datasetPassed;
  final int correctAnswers;
  final List<int> uniqueWrongIndices;
  final double percent;
  final int currentElo;
  final List<List<dynamic>> data;
  final DatasetType datasetType;
  final String datasetName;

  const EndScreen({
    super.key,
    required this.datasetPassed,
    required this.correctAnswers,
    required this.uniqueWrongIndices,
    required this.percent,
    required this.currentElo,
    required this.data,
    required this.datasetType,
    required this.datasetName,
  });

  @override
  EndScreenState createState() => EndScreenState();
}

class EndScreenState extends State<EndScreen> {
  late int oldElo;
  late int newElo;
  late int eloChange;
  late Map<String, dynamic> currentRank;
  late Map<String, dynamic> newRank;
  late int levelWithinRank;
  late int eloWithinLevel;
  late String rankBadge;
  late double progressToNextRank;

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<MyAppState>(context, listen: false);
    oldElo = widget.currentElo;
    final percentageScore = widget.percent;
    // Calculate new ELO locally (simulate what updateDatasetPassPercentage would do)
    final Map<String, double> tempScores = Map<String, double>.from(appState.datasetService.datasetScores);
    tempScores[widget.datasetName] = percentageScore;
    double totalElo = 0.0;
    bool all100 = true;
    for (var ds in appState.datasetService.allWortschatzDatasets) {
      final filename = ds['filename'];
      final maxElo = ds['elo'] ?? 0;
      final percent = tempScores[filename] ?? 0.0;
      if (percent < 100) all100 = false;
      totalElo += maxElo * (percent / 100.0);
    }
    for (var ds in appState.datasetService.allArticleDatasets) {
      final filename = ds['filename'];
      final maxElo = ds['elo'] ?? 0;
      final percent = tempScores[filename] ?? 0.0;
      if (percent < 100) all100 = false;
      totalElo += maxElo * (percent / 100.0);
    }
    for (var ds in appState.datasetService.allVerbDatasets) {
      final filename = ds['filename'];
      final maxElo = ds['elo'] ?? 0;
      final percent = tempScores[filename] ?? 0.0;
      if (percent < 100) all100 = false;
      totalElo += maxElo * (percent / 100.0);
    }
    if (!all100 && totalElo >= 2100) {
      totalElo = 2099;
    }
    newElo = totalElo.floor();
    eloChange = newElo - oldElo;
    // Calculate new rank, badge, progress
    currentRank = MyAppState.ranks.firstWhere((rank) => oldElo >= rank['minElo'] && oldElo <= rank['maxElo'], orElse: () => MyAppState.ranks.first);
    newRank = MyAppState.ranks.firstWhere((rank) => newElo >= rank['minElo'] && newElo <= rank['maxElo'], orElse: () => MyAppState.ranks.first);
    levelWithinRank = ((newElo - newRank['minElo']) / 100).floor() + 1;
    eloWithinLevel = newElo % 100;
    rankBadge = '${newRank['name']}$levelWithinRank.svg';
    final nextRank = MyAppState.ranks.firstWhere((rank) => rank['minElo'] > newElo, orElse: () => newRank);
    progressToNextRank = ((newElo - newRank['minElo']) / (nextRank['minElo'] - newRank['minElo']) * 100).clamp(0, 100).toDouble();
    // Save results as soon as EndScreen is reached
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _commitResults(context);
    });
  }

  void _commitResults(BuildContext context) {
    final appState = Provider.of<MyAppState>(context, listen: false);
    // Actually update state and save to Firebase
    print('DEBUG: EndScreen commitResults New Calculated Percentage Score=${widget.percent}');
    appState.updateLocalDatasetScore(widget.datasetName, widget.percent);
    if (widget.datasetPassed) {
      appState.unlockNextDataset(widget.datasetType);
    }
    appState.pushStateToFirebase();
  }

  @override
  Widget build(BuildContext context) {
    // Debug logging
    print('DEBUG: EndScreen oldElo=$oldElo, newElo=$newElo, eloChange=$eloChange, rank=${newRank['name']}, level=$levelWithinRank');

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.3),
        title: Text(
          'End of Quiz',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/stars.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: SvgPicture.asset(
              'assets/GameOverFrame.svg',
              width: MediaQuery.of(context).size.width * 0.6,
              fit: BoxFit.contain,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Text(
                      widget.datasetPassed
                          ? 'Congratulations! You passed the dataset!'
                          : 'The ship was damaged beyond repair.',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: 140,
                    child: SvgPicture.asset(
                      'assets/ranks/$rankBadge',
                      fit: BoxFit.contain,
                    ),
                  ),
                  Text(
                    '${newRank['name']} $levelWithinRank',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '${eloChange > 0 ? '+' : ''}$eloChange',
                    style: TextStyle(
                      fontSize: 15,
                      color: eloChange > 0 ? Colors.green : (eloChange < 0 ? Colors.red : Colors.white),
                    ),
                  ),
                  SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: 15,
                      child: LinearProgressIndicator(
                        value: progressToNextRank / 100,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '$eloWithinLevel/100',
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            switch (widget.datasetType) {
                              case DatasetType.article:
                                return ArticlesReviewPage(
                                  wrongAnswerIndices: widget.uniqueWrongIndices,
                                  data: widget.data,
                                );
                              case DatasetType.verb:
                                return VerbsReviewScreen(
                                  wrongAnswerIndices: widget.uniqueWrongIndices,
                                  data: widget.data,
                                );
                              case DatasetType.wortschatz:
                              default:
                                return WortschatzReviewScreen(
                                  wrongAnswerIndices: widget.uniqueWrongIndices,
                                  data: widget.data,
                                );
                            }
                          },
                        ),
                      );
                    },
                    child: Text('Review Incorrect Answers'),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => MyHomePage()),
                        (route) => false,
                      );
                    },
                    child: Text('Return to Home'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
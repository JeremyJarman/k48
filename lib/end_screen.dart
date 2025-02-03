import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:german_nouns_app/home_page.dart';
import 'package:provider/provider.dart';
import 'my_app_state.dart';
import 'wortschatz_review.dart';
import 'articles_review.dart';

class EndScreen extends StatelessWidget {
  final bool datasetPassed;
  final int correctAnswers;
  final List<int> wrongAnswerIndices;
  final List<List<dynamic>> data;
  final bool isArticleReview;
  final int eloChange;
  final String datasetName; // Add datasetName parameter

  EndScreen({
    required this.datasetPassed,
    required this.correctAnswers,
    required this.wrongAnswerIndices,
    required this.data,
    this.isArticleReview = false, // Default to false for wortschatz review
    required this.eloChange,
    required this.datasetName, // Add datasetName parameter
  });

  @override
  Widget build(BuildContext context) {
    final totalQuestions = data.length;
    final percentageScore = ((correctAnswers / totalQuestions) * 100).round();
    final appState = Provider.of<MyAppState>(context, listen: false);

    // Update ELO and unlocked datasets in Firestore
    appState.updateElo(appState.elo + eloChange);

    if (datasetPassed) {
      // Unlock the next dataset if the current one is passed
      appState.unlockNextDataset(isArticleReview);
    }

    // Update dataset pass percentage
    appState.updateDatasetPassPercentage(datasetName, percentageScore.toDouble());

    final currentRank = MyAppState.ranks.firstWhere((rank) => appState.elo >= rank['minElo'] && appState.elo <= rank['maxElo'], orElse: () => MyAppState.ranks.first);
    final nextRank = MyAppState.ranks.firstWhere((rank) => rank['minElo'] > appState.elo, orElse: () => currentRank);
    final progressToNextRank = ((appState.elo - currentRank['minElo']) / (nextRank['minElo'] - currentRank['minElo']) * 100).clamp(0, 100).toDouble();
    final levelWithinRank = ((appState.elo - currentRank['minElo']) / 100).floor() + 1;
    final eloWithinLevel = appState.elo % 100;
    final rankBadge = appState.getRankBadge();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.3),
        title: Text(
          'End of Quiz',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white), // Set back arrow color to white
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
              width: MediaQuery.of(context).size.width * 0.6, // 60% of the width
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
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5, // 50% of the width
                    child: Text(
                      datasetPassed
                          ? 'Congratulations! You passed the dataset!'
                          : 'The ship was damaged beyond repair.',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SvgPicture.asset(
                    'assets/ranks/$rankBadge',
                    height: 150,
                  ),
                  Text(
                    '${currentRank['name']} $levelWithinRank',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '${eloChange > 0 ? '+' : ''}$eloChange',
                    style: TextStyle(
                      fontSize: 15,
                      color: eloChange > 0 ? Colors.green : Colors.red,
                    ),
                  ),
                  SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.5, // Reduce width
                      height: 15, // Increase height
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
                          builder: (context) => isArticleReview
                              ? ArticlesReviewPage(
                                  
                                  wrongAnswerIndices: wrongAnswerIndices.toSet().toList(), // Remove duplicates
                                  data: data,
                                )
                              : WortschatzReviewScreen(
                                  wrongAnswers: totalQuestions - correctAnswers,
                                  wrongAnswerIndices: wrongAnswerIndices.toSet().toList(), // Remove duplicates
                                  data: data,
                                ),
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
                      ); // Return to home screen
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
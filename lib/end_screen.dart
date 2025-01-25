import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'wortschatz_review.dart';
import 'dataset_service.dart';

class EndScreen extends StatelessWidget {
  final bool datasetPassed;
  final int correctAnswers;
  final List<int> wrongAnswerIndices;
  final List<List<dynamic>> data;
  final String dataset;

  EndScreen({
    required this.datasetPassed,
    required this.correctAnswers,
    required this.wrongAnswerIndices,
    required this.data,
    required this.dataset,
  });

  @override
  Widget build(BuildContext context) {
    final totalQuestions = data.length;
    final percentageScore = ((correctAnswers / totalQuestions) * 100).round();

    if (datasetPassed) {
      DatasetService().markDatasetAsCompleted(dataset, percentageScore);
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/galaxy.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: 1.5, // Adjust the scale factor as needed
                child: SvgPicture.asset(
                  'assets/GameOverFrame.svg',
                  width: 300, // Adjust the width as needed
                  height: 300, // Adjust the height as needed
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 120), // Add some space at the top
                  Text(
                    datasetPassed ? 'Congratulations!' : 'Game Over',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center, // Center the text
                  ),
                  SizedBox(height: 20),
                  Text(
                    datasetPassed ? 'You have completed the dataset.' : 'Your ship is damaged beyond repair!',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                    textAlign: TextAlign.center, // Center the text
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Your Score: $percentageScore%',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                    textAlign: TextAlign.center, // Center the text
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WortschatzReviewScreen(
                            wrongAnswers: totalQuestions - correctAnswers,
                            wrongAnswerIndices: wrongAnswerIndices.toSet().toList(), // Remove duplicates
                            data: data,
                          ),
                        ),
                      );
                    },
                    child: Text('Review Incorrect Answers'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst); // Return to home screen
                    },
                    child: Text('Return to Home'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
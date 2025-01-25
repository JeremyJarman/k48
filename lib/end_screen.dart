import 'package:flutter/material.dart';
import 'wortschatz_review.dart';
import 'articles_review_page.dart';

class EndScreen extends StatelessWidget {
  final bool datasetPassed;
  final int correctAnswers;
  final List<int> wrongAnswerIndices;
  final List<List<dynamic>> data;
  final bool isArticleReview; // Add this parameter to determine the review screen

  EndScreen({
    required this.datasetPassed,
    required this.correctAnswers,
    required this.wrongAnswerIndices,
    required this.data,
    this.isArticleReview = false, // Default to false for wortschatz review
  });

  @override
  Widget build(BuildContext context) {
    final totalQuestions = data.length;
    final percentageScore = ((correctAnswers / totalQuestions) * 100).round();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.3),
        title: Text(
          'End of Quiz',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white), // Set back arrow color to white
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/galaxy.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst); // Return to home screen
                },
                child: Text('Return to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
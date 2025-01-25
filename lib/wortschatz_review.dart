import 'package:flutter/material.dart';

class WortschatzReviewScreen extends StatelessWidget {
  final int wrongAnswers;
  final List<int> wrongAnswerIndices;
  final List<List<dynamic>> data;

  WortschatzReviewScreen({
    required this.wrongAnswers,
    required this.wrongAnswerIndices,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Review Incorrect Answers'),
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.3),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/galaxy.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView.builder(
          itemCount: wrongAnswerIndices.length,
          itemBuilder: (context, index) {
            final wordIndex = wrongAnswerIndices[index];
            final wordData = data[wordIndex];
            final word = wordData[2];
            final correctDefinition = wordData[5];
            final correctTranslation = wordData[4];

            return Card(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              child: ListTile(
                title: Text(
                  word,
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Definition: $correctDefinition',
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      'Translation: $correctTranslation',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
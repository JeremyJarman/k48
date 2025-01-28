import 'package:flutter/material.dart';
import 'dataset_service.dart';
import 'csv_loader.dart';

class ArticlesReviewPage extends StatefulWidget {
  final List<int> wrongAnswerIndices;
  final List<List<dynamic>> data;

  ArticlesReviewPage({
    required this.wrongAnswerIndices,
    required this.data,
  });

  @override
  _ArticlesReviewPageState createState() => _ArticlesReviewPageState();
}

class _ArticlesReviewPageState extends State<ArticlesReviewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.3),
        title: Text(
          'Articles Review',
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
        child: widget.wrongAnswerIndices.isEmpty
            ? Center(child: Text('No incorrect answers to review.', style: TextStyle(color: Colors.white, fontSize: 20)))
            : ListView.builder(
                itemCount: widget.wrongAnswerIndices.length,
                itemBuilder: (context, index) {
                  final wordIndex = widget.wrongAnswerIndices[index];
                  final wordData = widget.data[wordIndex];
                  final noun = wordData[2]; // Assuming the noun is in the first column
                  final article = wordData[1]; // Assuming the article is in the second column

                  return Card(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    child: ListTile(
                      title: Text(
                        '$article $noun',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
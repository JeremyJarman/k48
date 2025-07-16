import 'package:flutter/material.dart';
//import 'dataset_service.dart';
//import 'csv_loader.dart';

class ArticlesReviewPage extends StatefulWidget {
  final List<int> wrongAnswerIndices;
  final List<List<dynamic>> data;

  const ArticlesReviewPage({
    super.key,
    required this.wrongAnswerIndices,
    required this.data,
  });

  @override
  ArticlesReviewPageState createState() => ArticlesReviewPageState();
}

class ArticlesReviewPageState extends State<ArticlesReviewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.3),
        title: Text('Articles Review'),
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
            padding: const EdgeInsets.only(top: 80),
            itemCount: widget.wrongAnswerIndices.length,
            itemBuilder: (context, idx) {
              final i = widget.wrongAnswerIndices[idx];
              final row = widget.data[i];
              final article = row[0].toString();
              final noun = row[1].toString();
              final translation = row[2].toString();
              return Card(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    '$article $noun',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  subtitle: Text(
                    translation,
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
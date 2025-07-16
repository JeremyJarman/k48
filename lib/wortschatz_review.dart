import 'package:flutter/material.dart';

class WortschatzReviewScreen extends StatelessWidget {
  final List<int> wrongAnswerIndices;
  final List<List<dynamic>> data;

  WortschatzReviewScreen({
    required this.wrongAnswerIndices,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.3),
        title: Text('Wortschatz Review',style: TextStyle( color: Colors.white),),
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
          ListView.builder(
            padding: const EdgeInsets.only(top: 80),
            itemCount: wrongAnswerIndices.length,
            itemBuilder: (context, idx) {
              final i = wrongAnswerIndices[idx];
              final row = data[i];
              final wordType = row[0].toString();
              final prefix = row[1].toString();
              final word = row[2].toString();
              final suffix = row[3].toString();
              final translation = row[4].toString();
              final definition = row[5].toString();
              return Card(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wordType,
                        style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.white),
                      ),
                      SizedBox(height: 6),
                      Text(
                        prefix.isNotEmpty
                          ? (suffix.isNotEmpty ? '$prefix $word ($suffix)' : '$prefix $word')
                          : (suffix.isNotEmpty ? '$word ($suffix)' : word),
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Definition: $definition',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Translation: $translation',
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                    ],
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
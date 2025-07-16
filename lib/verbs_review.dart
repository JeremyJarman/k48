import 'package:flutter/material.dart';

class VerbsReviewScreen extends StatelessWidget {
  final List<int> wrongAnswerIndices;
  final List<List<dynamic>> data;

  const VerbsReviewScreen({
    Key? key,
    required this.wrongAnswerIndices,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.3),
        title: Text('Verbs Review',style: TextStyle( color: Colors.white),),
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
              final germanVerb = row[1].toString();
              final englishDefinition = row[2].toString();
              return Card(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    germanVerb,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  subtitle: Text(
                    englishDefinition,
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
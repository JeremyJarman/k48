import 'package:flutter/material.dart';

class ReviewScreen extends StatelessWidget {
  final List<Map<String, String>> failedPairs;

  ReviewScreen({required this.failedPairs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Review Failed Pairs'),
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
            children: [
              SizedBox(height: 20),
              Text(
                'Failed Articles:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center, // Center the text
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: failedPairs.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        '${failedPairs[index]['article']} ${failedPairs[index]['noun']}',
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
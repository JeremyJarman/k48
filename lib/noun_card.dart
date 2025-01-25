import 'package:flutter/material.dart';
import 'dart:math';

class NounCard extends StatelessWidget {
  final String noun;
  final String? selectedArticle;
  final String? adjective;

  NounCard({required this.noun, required this.selectedArticle, required this.adjective});



  String getBestimmtEnding(String article, String caseType) {
    switch (caseType) {
      case 'N':
        if (article == 'der') return 'er';
        if (article == 'die') return 'ie';
        if (article == 'das') return 'as';
        break;
      case 'D':
        if (article == 'der') return 'em';
        if (article == 'die') return 'er';
        if (article == 'das') return 'em';
        break;
      case 'A':
        if (article == 'der') return 'en';
        if (article == 'die') return 'ie';
        if (article == 'das') return 'as';
        break;
    }
    return '';
  }

 String getUnbestimmtEnding(String article, String caseType) {
    switch (caseType) {
      case 'N':
        if (article == 'der') return '';
        if (article == 'die') return 'e';
        if (article == 'das') return '';

        break;
      case 'D':
        if (article == 'der') return 'em';
        if (article == 'die') return 'er';
        if (article == 'das') return 'em';
        break;
      case 'A':
        if (article == 'der') return 'en';
        if (article == 'die') return 'e';
        if (article == 'das') return '';
        break;
    }
    return '';
  }

   String getBestimmtAdjectiveEnding(String article, String caseType) {
    switch (caseType) {
      case 'N':
        if (article == 'der') return 'e';
        if (article == 'die') return 'e';
        if (article == 'das') return 'e';

        break;
      case 'D':
        if (article == 'der') return 'en';
        if (article == 'die') return 'en';
        if (article == 'das') return 'en';
        break;
      case 'A':
        if (article == 'der') return 'en';
        if (article == 'die') return 'e';
        if (article == 'das') return 'e';
        break;
    }
    return '';
  }

   String getUnbestimmtAdjectiveEnding(String article, String caseType) {
    switch (caseType) {
      case 'N':
        if (article == 'der') return 'er';
        if (article == 'die') return 'e';
        if (article == 'das') return 'es';

        break;
      case 'D':
        if (article == 'der') return 'en';
        if (article == 'die') return 'en';
        if (article == 'das') return 'en';
        break;
      case 'A':
        if (article == 'der') return 'en';
        if (article == 'die') return 'e';
        if (article == 'das') return 'es';
        break;
    }
    return '';
  }
   
   String getOhneArticleAdjectiveEnding(String article, String caseType) {
    switch (caseType) {
      case 'N':
        if (article == 'der') return 'er';
        if (article == 'die') return 'e';
        if (article == 'das') return 'es';

        break;
      case 'D':
        if (article == 'der') return 'em';
        if (article == 'die') return 'er';
        if (article == 'das') return 'em';
        break;
      case 'A':
        if (article == 'der') return 'en';
        if (article == 'die') return 'e';
        if (article == 'das') return 'es';
        break;
    }
    return '';
  }


  @override
  Widget build(BuildContext context) {
    final randomAdjective = adjective;
    final nominativeBestimmtEnding = getBestimmtEnding(selectedArticle ?? '', 'N');
    final dativeBestimmtEnding = getBestimmtEnding(selectedArticle ?? '', 'D');
    final accusativeBestimmtEnding = getBestimmtEnding(selectedArticle ?? '', 'A');
    final nominativeUnbestimmtEnding = getUnbestimmtEnding(selectedArticle ?? '', 'N');
    final dativeUnbestimmtEnding = getUnbestimmtEnding(selectedArticle ?? '', 'D');
    final accusativeUnbestimmtEnding = getUnbestimmtEnding(selectedArticle ?? '', 'A');

    final nominativeBestimmtAEnding = getBestimmtAdjectiveEnding(selectedArticle ?? '', 'N');
    final dativeBestimmtAEnding = getBestimmtAdjectiveEnding(selectedArticle ?? '', 'D');
    final accusativeBestimmtAEnding = getBestimmtAdjectiveEnding(selectedArticle ?? '', 'A');
    final nominativeUnbestimmtAEnding = getUnbestimmtAdjectiveEnding(selectedArticle ?? '', 'N');
    final dativeUnbestimmtAEnding = getUnbestimmtAdjectiveEnding(selectedArticle ?? '', 'D');
    final accusativeUnbestimmtAEnding = getUnbestimmtAdjectiveEnding(selectedArticle ?? '', 'A');

    final nominativeOhneAEnding = getOhneArticleAdjectiveEnding(selectedArticle ?? '', 'N');
    final dativeOhneAEnding = getOhneArticleAdjectiveEnding(selectedArticle ?? '', 'D');
    final accusativeOhneAEnding = getOhneArticleAdjectiveEnding(selectedArticle ?? '', 'A');

    return Card(
      color: Theme.of(context).primaryColor.withOpacity(0.3), // Set the background color to be 60% transparent
      child: Container(
        width: 300, // Set a fixed width
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${selectedArticle ?? ''} $noun',
              style: TextStyle(fontSize: 24, color: Colors.white), // Set text color to white for better contrast
            ),
            SizedBox(height: 10),
            Text(
              '(N) d$nominativeBestimmtEnding $randomAdjective$nominativeBestimmtAEnding $noun',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            //Text(
            //  '(N) ein$nominativeUnbestimmtEnding $randomAdjective$nominativeUnbestimmtAEnding $noun',
            //  style: TextStyle(fontSize: 16, color: Colors.white),
            //),
            SizedBox(height: 10),
            Text(
              '(D) mit ein$dativeUnbestimmtEnding $randomAdjective$dativeUnbestimmtAEnding $noun',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            SizedBox(height: 10),
            Text(
              '(A) für d$accusativeBestimmtEnding $randomAdjective$accusativeBestimmtAEnding $noun',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
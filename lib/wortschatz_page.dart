import 'package:flutter/material.dart';
import 'gameplay_screen.dart';

class WortschatzPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.3),
        title: Text(
          'Wortschatz',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white), // Set back arrow color to white
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/galaxy.jpg'), // Use the same background image as the home page
                fit: BoxFit.cover,
              ),
            ),
          ),
          ListView(
            padding: EdgeInsets.only(top: kToolbarHeight + 20), // Add spacing between the top app bar and the first option
            children: [
              ListTile(
                title: Text('01. Menschen', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GameplayScreen(dataset: 'WordLists_01.csv', title: 'Menschen')),
                  );
                },
              ),
              ListTile(
                title: Text('02. Stationen im Leben', style: TextStyle(color: Colors.white)),
                onTap: () {
                  // TODO: Unlock and navigate to this dataset
                },
              ),
              ListTile(
                title: Text('03. Wohnen', style: TextStyle(color: Colors.white)),
                onTap: () {
                  // TODO: Unlock and navigate to this dataset
                },
              ),
              ListTile(
                title: Text('04. Freizeit und Kultur', style: TextStyle(color: Colors.white)),
                onTap: () {
                  // TODO: Unlock and navigate to this dataset
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
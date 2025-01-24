import 'package:flutter/material.dart';
import 'gameplay_screen.dart';

class WortschatzPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wortschatz'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Menschen'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GameplayScreen(dataset: 'WordLists_01.csv', title: 'Menschen')),
              );
            },
          ),
          ListTile(
            title: Text('Stationen im Leben'),
            onTap: () {
              // TODO: Unlock and navigate to this dataset
            },
          ),
          ListTile(
            title: Text('Wohnen'),
            onTap: () {
              // TODO: Unlock and navigate to this dataset
            },
          ),
          ListTile(
            title: Text('Freizeit und Kultur'),
            onTap: () {
              // TODO: Unlock and navigate to this dataset
            },
          ),
        ],
      ),
    );
  }
}
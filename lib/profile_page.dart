import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'my_app_state.dart';
import 'login_page.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String alias = '';
  int elo = 0;
  int furthestDistance = 0;
  int scoreEasy = 0;
  int scoreIntermediate = 0;
  int scoreHardcore = 0;

  @override
  void initState() {
    super.initState();
    loadProfileData();
  }

  Future<void> loadProfileData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          alias = doc.data()?['alias'] ?? '';
          elo = doc.data()?['elo'] ?? 0;
          furthestDistance = doc.data()?['furthestDistance'] ?? 0;
          scoreEasy = doc.data()?['score_easy'] ?? 0;
          scoreIntermediate = doc.data()?['score_intermediate'] ?? 0;
          scoreHardcore = doc.data()?['score_hardcore'] ?? 0;
        });
      }
    }
  }

  String getRankBadge(String rank, String level) {
    return 'assets/ranks/${rank}${level}.svg';
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    String rank = appState.getRank();
    String level = appState.getLevel();
    String tagline = appState.getTagline();
    String rankBadge = getRankBadge(rank, level);

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/stars.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          width: double.infinity, // Set the width to be as wide as the screen
          child: Stack(
            alignment: Alignment.center,
            children: [
              SvgPicture.asset(
                'assets/GameOverFrame.svg',
                width: 600,
                height: 600,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 130),
                  Text(
                    alias,
                    style: TextStyle(fontSize: 34, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SvgPicture.asset(
                    rankBadge,
                    width: 150,
                    height: 150,
                  ),
                  Text(
                    tagline,
                    style: TextStyle(fontSize: 20, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Rank: $rank Level $level' ,
                    style: TextStyle(fontSize: 20, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                 
                  SizedBox(height: 10),
                    Text(
                    'Distances Traveled:',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Easy: $scoreEasy',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Intermediate: $scoreIntermediate',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Hardcore: $scoreHardcore',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                   SizedBox(height: 10),
                  Text(
                    'Elo Rating: $elo',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: Text('Logout'),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
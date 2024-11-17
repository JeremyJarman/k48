import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'login_page.dart';
import 'avatar_edit_page.dart';
import 'package:provider/provider.dart';
import 'my_app_state.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String avatarSeed = 'initial_seed';
  String alias = '';

  @override
  void initState() {
    super.initState();
    loadAvatarSeed();
    loadAlias();
  }

  Future<void> loadAvatarSeed() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          avatarSeed = doc.data()?['avatarSeed'] ?? 'initial_seed';
        });
      }
    }
  }

  Future<void> loadAlias() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          alias = doc.data()?['alias'] ?? '';
        });
      }
    }
  }

  void setRandomAvatar() {
    setState(() {
      avatarSeed = DateTime.now().millisecondsSinceEpoch.toString();
    });
    saveAvatarSeed();
  }

  void updateAvatar(String newSeed) {
    setState(() {
      avatarSeed = newSeed;
    });
    saveAvatarSeed();
  }

  Future<void> saveAvatarSeed() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'avatarSeed': avatarSeed,
      }, SetOptions(merge: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

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
                width: 500,
                height: 500,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 200),
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      RandomAvatar(avatarSeed,trBackground: true, // Generate a random avatar
                        height: 130,
                        width: 130,
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.white),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AvatarEditPage(
                                initialSeed: avatarSeed,
                                onAvatarSelected: updateAvatar,
                                initialAlias: alias, // Pass the initial alias
                              ),
                            ),
                          ).then((_) => loadAlias()); // Reload alias after returning from edit page
                        },
                      ),
                    ],
                  ),
                 
                  SizedBox(height: 10),
                  Text(
                    '$alias the ${appState.getTagline()}',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 130),
                  Text(
                    'Rank:',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    '${appState.getRank()}',
                    style: TextStyle(fontSize: 25, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    '${appState.getLevel()}',
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
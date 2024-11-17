import 'package:flutter/material.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AvatarEditPage extends StatefulWidget {
  final String initialSeed;
  final Function(String) onAvatarSelected;
  final String initialAlias;

  AvatarEditPage({required this.initialSeed, required this.onAvatarSelected, required this.initialAlias});

  @override
  _AvatarEditPageState createState() => _AvatarEditPageState();
}

class _AvatarEditPageState extends State<AvatarEditPage> {
  late String avatarSeed;
  final TextEditingController seedController = TextEditingController();
  final TextEditingController aliasController = TextEditingController();

  @override
  void initState() {
    super.initState();
    avatarSeed = widget.initialSeed;
    seedController.text = avatarSeed;
    aliasController.text = widget.initialAlias;
  }

  void setRandomAvatar() {
    setState(() {
      avatarSeed = DateTime.now().millisecondsSinceEpoch.toString();
      seedController.text = avatarSeed;
    });
  }

  void setAvatarFromSeed() {
    setState(() {
      avatarSeed = seedController.text;
    });
  }

  Future<void> saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'avatarSeed': avatarSeed,
        'alias': aliasController.text,
      }, SetOptions(merge: true));
    }
    widget.onAvatarSelected(avatarSeed);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/stars.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RandomAvatar(avatarSeed, // Generate a random avatar
                  height: 100,
                  width: 100,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: setRandomAvatar,
                  child: Text('Generate Random Avatar'),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: seedController,
                  decoration: InputDecoration(
                    labelText: 'Enter Seed',
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: setAvatarFromSeed,
                  child: Text('Set Avatar from Seed'),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: aliasController,
                  decoration: InputDecoration(
                    labelText: 'Alias',
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: saveProfile,
                  child: Text('Save Profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
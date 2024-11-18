import 'package:flutter/material.dart';
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
  final TextEditingController aliasController = TextEditingController();
  String? _selectedImage;

  @override
  void initState() {
    super.initState();
    avatarSeed = widget.initialSeed;
    aliasController.text = widget.initialAlias;
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && _selectedImage != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'avatarUrl': _selectedImage,
        'alias': aliasController.text,
      }, SetOptions(merge: true));

      widget.onAvatarSelected(_selectedImage!);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> images = [
      'assets/Nexar2.jpg',
      'assets/Aevone.jpg',
       // Add more images as needed
    ];

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
                _selectedImage == null
                    ? Text('No image selected.', style: TextStyle(color: Colors.white))
                    : Image.asset(_selectedImage!, height: 100, width: 100),
                SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  children: images.map((image) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedImage = image;
                        });
                      },
                      child: Image.asset(image, height: 50, width: 50),
                    );
                  }).toList(),
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
                  onPressed: _saveProfile,
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
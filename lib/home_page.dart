import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth_wrapper.dart'; // Import the AuthWrapper
import 'wortschatz_page.dart';
import 'admin_panel.dart';
import 'leaderboard_page.dart';
import 'profile_page.dart';
import 'difficulty_selection.dart';
import 'login_page.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'main.dart';
import 'my_app_state.dart'; // Ensure this import is present

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String description = '';
  String selectedValue = 'Option 1'; // Example dropdown value

  @override
  void initState() {
    super.initState();
    loadDescription();
  }

  Future<void> loadDescription() async {
    final text = await rootBundle.loadString('assets/WelcomeText.txt');
    setState(() {
      description = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    var appState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String result) {
              if (result == 'Profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              } else if (result == 'Admin Panel') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminPanel()),
                );
              } else if (result == 'Leaderboard') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LeaderboardPage()),
                );
              } else if (result == 'Logout') {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Profile',
                child: Text('Profile'),
              ),
              const PopupMenuItem<String>(
                value: 'Admin Panel',
                child: Text('Admin Panel'),
              ),
              const PopupMenuItem<String>(
                value: 'Leaderboard',
                child: Text('Leaderboard'),
              ),
              const PopupMenuItem<String>(
                value: 'Logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/galaxy.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 10,
              left: 10,
              child: Text(
                'Nearest Star: ${appState.getDistanceToNearestStar()} ly',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome to k48!',
                    style: TextStyle(fontSize: 26, color: Colors.white), // Set text color to white for better contrast
                    textAlign: TextAlign.center, // Center the text
                  ),
                  SizedBox(height: 20),
                  Container(
                    height: screenHeight * 0.5, // Limit the height to half the screen height
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        description,
                        style: TextStyle(fontSize: 16, color: Colors.white), // Set text color to white for better contrast
                        textAlign: TextAlign.center, // Center the text
                      ),
                    ),
                  ),
                  DropdownButton<String>(
                    value: selectedValue,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedValue = newValue!;
                      });
                    },
                    items: <String>['Option 1', 'Option 2', 'Option 3', 'Option 4']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DifficultySelection(agent: 'Aevone')),
                      );
                    },
                    child: Text('Solo mission'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => WortschatzPage()),
                      );
                    },
                    child: Text('Wortschatz'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Implement Artikels page
                    },
                    child: Text('Artikels'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'login_page.dart'; // Import the login page
import 'my_app_state.dart'; // Import the MyAppState
import 'auth_wrapper.dart'; // Import the AuthWrapper
import 'difficulty_selection.dart'; // Import the DifficultySelection
import 'admin_panel.dart'; // Import the AdminPanel
import 'package:flutter/services.dart' show rootBundle;

void customPrint(Object? object) => debugPrint(object.toString());

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: GermanNounApp(),
    ),
  );
}

class GermanNounApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'German Noun App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthWrapper(), // Use AuthWrapper to handle authentication
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String description = '';

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

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/galaxy.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome to k48!',
                style: TextStyle(fontSize: 24, color: Colors.white), // Set text color to white for better contrast
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
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DifficultySelection()),
                  );
                },
                child: Text('Solo mission'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AdminPanel()),
                  );
                },
                child: Text('Admin Panel'),
              ),
              SizedBox(height: 20),
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
            ],
          ),
        ),
      ),
    );
  }
}
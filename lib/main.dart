import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'login_page.dart'; // Import the login page
import 'my_app_state.dart'; // Import the MyAppState
import 'german_noun_quiz.dart';
import 'signup_page.dart';
import 'splash_screen.dart';
import 'home_page.dart'; // Import the extracted home page
import 'auth_wrapper.dart'; // Import the auth wrapper

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Ensure this line is present
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MyApp(),
    ),
  );
}

void customPrint(Object? object) => debugPrint(object.toString());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'German Nouns App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthWrapper(), // Use the auth wrapper
    );
  }
}

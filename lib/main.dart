import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'auth_wrapper.dart'; // Import the auth wrapper
import 'dataset_service.dart';
import 'my_app_state.dart'; // Import MyAppState




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Ensure this line is present
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MyAppState()), // Add MyAppState provider
        ChangeNotifierProvider(create: (_) => DatasetService()), // Use Provider instead of ChangeNotifierProvider
      ],
      child: MyApp(),
    ),
  );

 
}

void customPrint(Object? object) => debugPrint(object.toString());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'k48 deployment test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // initialRoute: '/',
      // routes: {
      //   '/': (context) => SplashScreen(),
      //   '/login': (context) => LoginPage(),
      //   '/signup': (context) => SignupPage(),
      //   '/home': (context) => MyHomePage(),
      //   '/wortschatz': (context) => WortschatzPage(),
      //   '/auth': (context) => AuthWrapper(),
      // },
      home: AuthWrapper(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Simulate a splash screen delay
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

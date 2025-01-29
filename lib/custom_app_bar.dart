import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'my_app_state.dart';
//import 'main.dart'; // Import the main file to navigate to the home page
import 'home_page.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return AppBar(
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.3), // Set the app bar to be 40% opaque
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white), // Make the back arrow white
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MyHomePage()),
            (route) => false,
          );
        },
      ),
      title: Center(
        //child: Text(
          //appState.difficulty,
          //style: TextStyle(color: Colors.white, fontSize: 20),
       // ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            //child: Text(
             // 'Best: ${appState.highScore}',
             // style: TextStyle(color: Colors.white, fontSize: 16),
            //),
          ),
        ),
      ],
    );
  }
}
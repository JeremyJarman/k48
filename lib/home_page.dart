import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'articles_page.dart';
import 'package:provider/provider.dart';
//import 'package:firebase_core/firebase_core.dart';
//import 'auth_wrapper.dart'; // Import the AuthWrapper
import 'wortschatz_page.dart';
import 'leaderboard_page.dart';
import 'profile_page.dart';

import 'login_page.dart';
//import 'main.dart';
import 'my_app_state.dart'; // Ensure this import is present
import 'verbs_page.dart';
import 'landing_page.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final PageController _pageController = PageController(viewportFraction: 0.7);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _goToPage(_currentPage + 1);
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _goToPage(_currentPage - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    var appState = context.watch<MyAppState>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.3),
        leading: appState.isGuest
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  appState.resetAll();
                  appState.setGuestMode(false);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LandingPage()),
                    (route) => false,
                  );
                },
              )
            : null,
        title: Text(
          'Home',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String result) {
              if (result == 'Profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              } else if (result == 'Leaderboard') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LeaderboardPage()),
                );
              } else if (result == 'Logout') {
                var appState = Provider.of<MyAppState>(context, listen: false);
                if (appState.isGuest) {
                  appState.resetAll();
                  appState.setGuestMode(false);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                } else {
                  appState.resetAll();
                  FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                }
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Profile',
                child: Text('Profile'),
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
        height: screenHeight,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/galaxy.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: MediaQuery.of(context).padding.top + 80), // Add space below app bar
            Text(
              'Welcome to k48!',
              style: TextStyle(
                fontSize: 28, 
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30),
            Expanded(
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: 3,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return _buildCarouselTile(index);
                    },
                  ),
                  // Left arrow
                  Positioned(
                    left: 20,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: _currentPage > 0
                          ? IconButton(
                              onPressed: _previousPage,
                              icon: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 24,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black.withOpacity(0.3),
                                shape: CircleBorder(),
                                padding: EdgeInsets.all(12),
                              ),
                            )
                          : SizedBox.shrink(),
                    ),
                  ),
                  // Right arrow
                  Positioned(
                    right: 20,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: _currentPage < 2
                          ? IconButton(
                              onPressed: _nextPage,
                              icon: Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 24,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black.withOpacity(0.3),
                                shape: CircleBorder(),
                                padding: EdgeInsets.all(12),
                              ),
                            )
                          : SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Page indicator dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return GestureDetector(
                  onTap: () => _goToPage(index),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index 
                          ? Colors.white 
                          : Colors.white.withOpacity(0.4),
                      border: _currentPage == index
                          ? Border.all(color: Colors.white, width: 2)
                          : null,
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildCarouselTile(int index) {
    final tiles = [
      {
        'title': 'Artikel',
        'subtitle': 'Learn German Articles',
        'icon': Icons.article,
        'color': Colors.blue,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ArticlesPage()),
          );
        },
      },
      {
        'title': 'Wortschatz',
        'subtitle': 'Expand Your Vocabulary',
        'icon': Icons.book,
        'color': Colors.green,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WortschatzPage()),
          );
        },
      },
      {
        'title': 'Verbs',
        'subtitle': 'Master German Verbs',
        'icon': Icons.flash_on,
        'color': Colors.orange,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => VerbsPage()),
          );
        },
      },
    ];

    final tile = tiles[index];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15),
      child: GestureDetector(
        onTap: tile['onTap'] as VoidCallback,
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: Colors.white.withOpacity(0.10), // Add transparency to the card
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  (tile['color'] as Color).withOpacity(0.7),
                  (tile['color'] as Color).withOpacity(0.4),
                ],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    tile['icon'] as IconData,
                    size: 60,
                    color: Colors.white,
                  ),
                  SizedBox(height: 15),
                  Text(
                    tile['title'] as String,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    tile['subtitle'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
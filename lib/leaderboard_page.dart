import 'package:flutter/material.dart';
//import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:flutter_svg/flutter_svg.dart';
//import 'my_app_state.dart';
//import 'profile_page.dart'; // Import ProfilePage for getRankBadge method

class LeaderboardPage extends StatefulWidget {
  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final double _textSize = 18.0; // Hardcoded text size
  final double _textSizeHeading = 14.0;

  String getRankBadge(String rank, String level) {
    return 'assets/ranks/${rank}${level}.svg';
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //var appState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Leaderboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Easy'),
            Tab(text: 'Intermediate'),
            Tab(text: 'Hardcore'),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/stars.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildLeaderboard(context, 'Nouns_easy'),
            _buildLeaderboard(context, 'Nouns_intermediate'),
            _buildLeaderboard(context, 'Nouns_hardcore'),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboard(BuildContext context, String documentId) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('scores').doc(documentId).snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var data = snapshot.data!.data() as Map<String, dynamic>;
        var scores = data.entries.toList();
        scores.sort((a, b) => b.value.compareTo(a.value));

        if (scores.isEmpty) {
          return Center(child: Text('No data available', style: TextStyle(color: Colors.white, fontSize: _textSize)));
        }

        List<TableRow> rows = [
          TableRow(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFD9D9D9)),
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(alignment: Alignment.center, child: Text('RANK', style: TextStyle(color: Colors.white, fontSize: _textSizeHeading))),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(alignment: Alignment.center, child: Text('ALIAS', style: TextStyle(color: Colors.white, fontSize: _textSizeHeading))),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(alignment: Alignment.center, child: Text('ELO', style: TextStyle(color: Colors.white,  fontSize: _textSizeHeading))),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(alignment: Alignment.center, child: Text('DISTANCE', style: TextStyle(color: Colors.white, fontSize: _textSizeHeading))),
              ),
            ],
          ),
        ];

        for (var index = 0; index < scores.length; index++) {
          rows.add(
            TableRow(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFD9D9D9)),
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(color: Colors.white, fontSize: _textSize),
                    ),
                  ),
                ),
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('users').doc(scores[index].key).get(),
                  builder: (context, userSnapshot) {
                    if (!userSnapshot.hasData) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(alignment: Alignment.center, child: Text('Loading...', style: TextStyle(color: Colors.white, fontSize: _textSize))),
                      );
                    }
                    var userData = userSnapshot.data!.data() as Map<String, dynamic>;
                    //var elo = userData['elo'] ?? 0;
                    //var rank = MyAppState().getRankFromElo(elo);
                    //var level = MyAppState().getLevelFromElo(elo);
                    //var rankBadge = getRankBadge(rank, level);

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                          //  SvgPicture.asset(
                              
                           //   width: 30,
                           //   height: 30,
                          //  ),
                            SizedBox(width: 8),
                            Text(
                              userData['alias'] ?? 'Anonymous',
                              style: TextStyle(color: Colors.white, fontSize: _textSize),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('users').doc(scores[index].key).get(),
                  builder: (context, userSnapshot) {
                    if (!userSnapshot.hasData) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(alignment: Alignment.center, child: Text('Loading...', style: TextStyle(color: Colors.white, fontSize: _textSize))),
                      );
                    }
                    var userData = userSnapshot.data!.data() as Map<String, dynamic>;
                    var elo = userData['elo'] ?? 0;
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          '$elo',
                          style: TextStyle(color: Colors.white, fontSize: _textSize),
                        ),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      '${scores[index].value} ly',
                      style: TextStyle(color: Colors.white, fontSize: _textSize),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Table(
            border: TableBorder(
              horizontalInside: BorderSide(color: Color(0xFFD9D9D9)),
            ),
            columnWidths: {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(2),
            },
            children: rows,
          ),
        );
      },
    );
  }
}
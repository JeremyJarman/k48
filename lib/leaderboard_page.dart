import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:random_avatar/random_avatar.dart';

class LeaderboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Leaderboard'),
          bottom: TabBar(
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
            children: [
              LeaderboardTab(difficulty: 'score_easy'),
              LeaderboardTab(difficulty: 'score_intermediate'),
              LeaderboardTab(difficulty: 'score_hardcore'),
            ],
          ),
        ),
      ),
    );
  }
}

class LeaderboardTab extends StatelessWidget {
  final String difficulty;

  LeaderboardTab({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .orderBy(difficulty, descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var users = snapshot.data!.docs;

        if (users.isEmpty) {
          return Center(child: Text('No data available', style: TextStyle(color: Colors.white)));
        }

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            var user = users[index];
            return ListTile(
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${index + 1}',
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                  SizedBox(width: 10),
                RandomAvatar(user['avatarSeed'], height: 40, width: 40),
                ],
              ),
              title: Text(user['alias'], style: TextStyle(color: Colors.white)),
              subtitle: Text('Distance traveled: ${user[difficulty]} ly', style: TextStyle(color: Colors.white)),
            );
          },
        );
      },
    );
  }
}
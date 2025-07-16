import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'my_app_state.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.3),
        title: Text('Leaderboard', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/galaxy.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .orderBy('elo', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error loading leaderboard', style: TextStyle(color: Colors.white)));
              }
              final users = snapshot.data?.docs ?? [];
              if (users.isEmpty) {
                return Center(child: Text('No users found.', style: TextStyle(color: Colors.white)));
              }
              return ListView.builder(
                padding: const EdgeInsets.only(top: 90, bottom: 16),
                itemCount: users.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // Header row
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          SizedBox(width: 32, child: Text('#', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold))),
                          Expanded(flex: 2, child: Text('Alias', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold))),
                          SizedBox(width: 60, child: Text('ELO', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold))),
                          Expanded(child: Text('Rank', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold))),
                        ],
                      ),
                    );
                  }
                  final user = users[index - 1];
                  final elo = (user['elo'] ?? 0) as int;
                  final alias = user['alias'] ?? 'Unknown';
                  final uid = user.id;
                  final isCurrentUser = currentUser != null && currentUser.uid == uid;
                  final rankName = MyAppState().getRank(elo);
                  final levelWithinRank = (() {
                    for (var rank in MyAppState.ranks) {
                      if (elo >= rank['minElo'] && elo <= rank['maxElo']) {
                        int range = rank['maxElo'] - rank['minElo'] + 1;
                        int levelRange = range ~/ 3;
                        if (elo < rank['minElo'] + levelRange) return 1;
                        if (elo < rank['minElo'] + 2 * levelRange) return 2;
                        return 3;
                      }
                    }
                    return 0;
                  })();
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCurrentUser
                          ? Theme.of(context).primaryColor.withOpacity(0.5)
                          : Theme.of(context).primaryColor.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 32,
                            child: Text(
                              '${index}',
                              style: TextStyle(
                                color: isCurrentUser ? Colors.amber : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              alias,
                              style: TextStyle(
                                color: isCurrentUser ? Colors.amber : Colors.white,
                                fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                                fontSize: 18,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(
                            width: 60,
                            child: Text(
                              '$elo',
                              style: TextStyle(
                                color: isCurrentUser ? Colors.amber : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '$rankName $levelWithinRank',
                              style: TextStyle(
                                color: isCurrentUser ? Colors.amber : Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

extension MyAppStateRankBadge on MyAppState {
  // Helper to get badge for any ELO (without mutating state)
  String? getRankBadgeForElo(int elo) {
    for (var rank in MyAppState.ranks) {
      if (elo >= rank['minElo'] && elo <= rank['maxElo']) {
        final levelWithinRank = ((elo - rank['minElo']) / 100).floor() + 1;
        return '${rank['name']}$levelWithinRank.svg';
      }
    }
    return null;
  }
}
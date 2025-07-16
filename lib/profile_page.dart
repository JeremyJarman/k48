import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'my_app_state.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  String alias = '';
  int elo = 0;
  final TextEditingController _aliasController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProfileData();
  }

  Future<void> loadProfileData() async {
    final appState = Provider.of<MyAppState>(context, listen: false);
    setState(() {
      alias = appState.alias;
      elo = appState.elo;
      _aliasController.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context);
    final rankName = MyAppState().getRank(appState.elo);
    final levelWithinRank = (() {
      for (var rank in MyAppState.ranks) {
        if (appState.elo >= rank['minElo'] && appState.elo <= rank['maxElo']) {
          int range = rank['maxElo'] - rank['minElo'] + 1;
          int levelRange = range ~/ 3;
          if (appState.elo < rank['minElo'] + levelRange) return 1;
          if (appState.elo < rank['minElo'] + 2 * levelRange) return 2;
          return 3;
        }
      }
      return 0;
    })();
    final rankBadge = '$rankName$levelWithinRank.svg';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.3),
        title: Text('Profile', style: TextStyle(color: Colors.white)),
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
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Rank badge and name
                  SizedBox(
                    height: 140,
                    child: SvgPicture.asset(
                      'assets/ranks/$rankBadge',
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '$rankName $levelWithinRank',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'ELO: ${appState.elo}',
                    style: TextStyle(fontSize: 20, color: Colors.white70),
                  ),
                  SizedBox(height: 32),
                  // Alias input
                  TextField(
                    controller: _aliasController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: alias,
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white54),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'Enter new alias',
                      hintStyle: TextStyle(color: Colors.white38),
                      fillColor: Colors.white10,
                      filled: true,
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final newAlias = _aliasController.text.trim();
                      if (newAlias.isNotEmpty) {
                        appState.updateAlias(newAlias);
                        setState(() {
                          alias = newAlias;
                          _aliasController.text = '';
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Alias updated!')),
                        );
                      }
                    },
                    child: Text('Update Alias'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
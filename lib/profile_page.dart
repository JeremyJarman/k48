import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'my_app_state.dart';
import 'dataset_service.dart'; // Import the DatasetService
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String alias = '';
  int passedDatasets = 0;
  double averagePassPercentage = 0.0;
  int elo = 0;
  final TextEditingController _aliasController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProfileData();
  }

  Future<void> loadProfileData() async {
    final appState = Provider.of<MyAppState>(context, listen: false);
    final datasetService = appState.datasetService;

    final datasetScores = datasetService.datasetScores;
    //final unlockedWortschatzDatasets = datasetService.unlockedWortschatzDatasets;
    //final unlockedArticleDatasets = datasetService.unlockedArticleDatasets;

    final allScores = datasetScores.values.toList();
    final totalDatasets = allScores.length;
    final passedDatasets = allScores.where((score) => score >= 50).length; // Assuming 50 is the passing score
    final averagePassPercentage = totalDatasets > 0
        ? allScores.reduce((a, b) => a + b) / totalDatasets
        : 0.0;

    setState(() {
      alias = appState.alias;
      elo = appState.elo;
      this.passedDatasets = passedDatasets;
      this.averagePassPercentage = averagePassPercentage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.3),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              // Handle logout logic here
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/stars.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: kToolbarHeight + 20), // Add spacing from the top
                TextField(
                  controller: _aliasController,
                  decoration: InputDecoration(
                    labelText: 'Alias',
                    labelStyle: TextStyle(color: Colors.white),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.save, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          alias = _aliasController.text;
                        });
                        final appState = Provider.of<MyAppState>(context, listen: false);
                        appState.updateAlias(alias);
                      },
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 20),
                Text('Passed Datasets: $passedDatasets', style: TextStyle(color: Colors.white)),
                Text('Average Pass Percentage: ${averagePassPercentage.toStringAsFixed(2)}%', style: TextStyle(color: Colors.white)),
                Text('ELO: $elo', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
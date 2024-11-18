import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'difficulty_selection.dart'; // Import the DifficultySelection

class AgentSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> agents = [
      {
        'name': 'Nexar',
        'image': 'assets/Nexar2.jpg',
        'abilities': 'A natural-born risk-taker, when active Nexar can use his signature ability to survive one failed warp gate attempt without losing all momentum',
        'icon': MdiIcons.shield,
      },
      {
        'name': 'Aevone',
        'image': 'assets/Aevone.jpg',
        'abilities': 'Born into a family of eccentric language enthusiasts, when activated Aevone can use her signature ability to eliminate one incorrect option.',
        'icon': MdiIcons.magnify,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Your Pilot'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/stars.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: PageView.builder(
            itemCount: agents.length,
            itemBuilder: (context, index) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/GameOverFrame.svg',
                    width: 500,
                    height: 500,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: 170),
                      Text(
                        agents[index]['name']!,
                        style: TextStyle(fontSize: 24, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5),
                      Image.asset(agents[index]['image']!, height: 210, width: 210),
                      SizedBox(height: 10),                 
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 95.0),
                        child: Text(
                          agents[index]['abilities']!,
                          style: TextStyle(fontSize: 16, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 15),
                      Icon(
                        agents[index]['icon'],
                        color: Colors.white,
                        size: 40,
                      ),
                      SizedBox(height: 90),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => DifficultySelection(agent: agents[index]['name'])),
                          );
                        },
                        child: Text('Select ${agents[index]['name']}'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
// leaderboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/leaderboard_service.dart';
import 'home_screen.dart'; // Import HomeScreen for navigation

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.red.shade800, Colors.red.shade400],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Top Scores',
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              // Added vertical spacing here:
              const SizedBox(height: 16.0),
              Expanded(
                child: FutureBuilder<List<LeaderboardEntry>>(
                  future: LeaderboardService().getLeaderboard(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                          child:
                              CircularProgressIndicator(color: Colors.white));
                    } else if (snapshot.hasError) {
                      return Center(
                          child: Text('Error: ${snapshot.error}',
                              style: const TextStyle(color: Colors.white)));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                          child: Text('No scores yet',
                              style: TextStyle(color: Colors.white)));
                    } else {
                      return ListView.separated(
                        // Use ListView.separated for dividers
                        itemCount: snapshot.data!.length,
                        separatorBuilder: (context, index) => const Divider(
                            color: Colors.white38), // Subtle divider
                        itemBuilder: (context, index) {
                          final entry = snapshot.data![index];
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text('${index + 1}',
                                  style: const TextStyle(
                                      color: Colors.red)), // Red number color
                              backgroundColor: Colors.white,
                            ),
                            title: Text(entry.name,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            trailing: Text('${entry.score}',
                                style: const TextStyle(color: Colors.white)),
                          ).animate().slideX(
                              begin: index.isEven ? -1 : 1,
                              delay: (index * 100).ms,
                              duration: 600.ms);
                        },
                      );
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ), // Navigate to HomeScreen
                    );
                  },
                  child: const Text('Start New Quiz',
                      style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

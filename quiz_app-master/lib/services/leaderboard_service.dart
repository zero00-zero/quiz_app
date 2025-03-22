import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LeaderboardEntry {
  final String name;
  final int score;

  LeaderboardEntry({required this.name, required this.score});

  Map<String, dynamic> toJson() => {
        'name': name,
        'score': score,
      };

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      name: json['name'],
      score: json['score'],
    );
  }
}

class LeaderboardService {
  static const String _key = 'leaderboard';

  Future<List<LeaderboardEntry>> getLeaderboard() async {
    final prefs = await SharedPreferences.getInstance();
    final String? leaderboardJson = prefs.getString(_key);
    if (leaderboardJson == null) {
      return [];
    }
    final List<dynamic> leaderboardData = jsonDecode(leaderboardJson);
    return leaderboardData
        .map((entry) => LeaderboardEntry.fromJson(entry))
        .toList();
  }

  Future<void> addScore(String name, int score) async {
    final leaderboard = await getLeaderboard();
    leaderboard.add(LeaderboardEntry(name: name, score: score));
    leaderboard.sort((a, b) => b.score.compareTo(a.score));
    if (leaderboard.length > 10) {
      leaderboard.removeRange(10, leaderboard.length);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _key, jsonEncode(leaderboard.map((e) => e.toJson()).toList()));
  }
}

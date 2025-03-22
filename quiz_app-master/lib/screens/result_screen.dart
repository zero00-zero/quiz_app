// result_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/question.dart';
import '../services/leaderboard_service.dart';
import 'leaderboard_screen.dart';
import 'home_screen.dart';

class ResultScreen extends StatefulWidget {
  final int score;
  final int totalQuestions;
  final List<Question> questions;

  const ResultScreen({
    Key? key,
    required this.score,
    required this.totalQuestions,
    required this.questions,
  }) : super(key: key);

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final TextEditingController _nameController = TextEditingController();
  String? _nameError;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submitScore() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _nameError = 'Please enter your name';
      });
      return;
    }
    setState(() {
      _nameError = null;
    });

    await LeaderboardService().addScore(name, widget.score);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => LeaderboardScreen(),
      ),
    );
  }

  void _restartQuiz() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Quiz Completed!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ).animate().fadeIn(duration: 600.ms),
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0, top: 10.0),
                  child: Text(
                    'Your Score: ${widget.score} points',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ).animate().slideY(duration: 600.ms),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 0.0, vertical: 12.0),
                  child: TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Enter your name for leaderboard',
                      labelStyle: const TextStyle(color: Colors.white70),
                      errorText: _nameError,
                      errorStyle: const TextStyle(color: Colors.yellowAccent),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white70),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 0.0, vertical: 12.0),
                  child: ElevatedButton(
                    onPressed: _submitScore,
                    child: const Text('Submit Score to Leaderboard',
                        style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(
                    height:
                        30), // **Increased spacing before "Review of Answers"**
                Divider(
                    color: Colors.white70,
                    height:
                        30), // **Added a Divider line for visual separation**
                const SizedBox(height: 15), // **Spacing after Divider**
                Text(
                  'Your Answer Review', // **CHANGED: More descriptive title**
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Container(
                  constraints: BoxConstraints(maxHeight: 300),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: widget.questions.length,
                    itemBuilder: (context, index) {
                      final question = widget.questions[index];
                      final userAnswerIndex = question.selectedAnswerIndex;
                      final correctAnswerIndex = question.correctIndex;
                      bool isCorrect = userAnswerIndex == correctAnswerIndex;
                      String userAnswer = userAnswerIndex != null
                          ? question.options[userAnswerIndex]
                          : 'Not answered';
                      String correctAnswer =
                          question.options[correctAnswerIndex];

                      return Card(
                        elevation: 2,
                        shadowColor: Colors.black54,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        color: Colors.white.withOpacity(0.95),
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Question ${index + 1}: ${question.text}',
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87),
                              ),
                              const SizedBox(height: 8),
                              Text('Your Answer: $userAnswer',
                                  style: TextStyle(
                                    color: isCorrect
                                        ? Colors.green[800]
                                        : Colors.red[800],
                                    fontWeight: FontWeight.bold,
                                  )),
                              Text('Correct Answer: $correctAnswer',
                                  style: TextStyle(
                                    color: Colors.green[800],
                                    fontWeight: FontWeight.bold,
                                  )),
                              const SizedBox(height: 8),
                              const Text('Explanation:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87)),
                              Text(question.explanation,
                                  style:
                                      const TextStyle(color: Colors.black87)),
                            ],
                          ),
                        ),
                      ).animate().slideX(
                          begin: index.isEven ? -1 : 1,
                          delay: (index * 100).ms,
                          duration: 500.ms);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: ElevatedButton(
                    onPressed: _restartQuiz,
                    child: const Text('Restart Quiz',
                        style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

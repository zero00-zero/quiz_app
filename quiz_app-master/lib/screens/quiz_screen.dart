// quiz_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import '../models/question.dart';
import '../services/question_service.dart';
import '../widgets/question_widget.dart';
import 'result_screen.dart';
import 'package:audioplayers/audioplayers.dart';
import 'home_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuestionService _questionService = QuestionService(
    'fpG9lyWaH5mUAFi0tDLQ8l7XMhMzZr2y', // Replace with your actual API key!
  );

  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  String _loadError = ''; // Added error message state

  // Audio Players
  final AudioPlayer _backgroundMusicPlayer = AudioPlayer();
  final AudioPlayer _correctAnswerPlayer = AudioPlayer();
  final AudioPlayer _incorrectAnswerPlayer = AudioPlayer();

  // Timer and Stopwatch
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  String _elapsedTime = '00';

  Timer? _questionTimer;
  int _questionTimeRemaining = 30;

  @override
  void initState() {
    super.initState();
    _loadAudio();
    _playBackgroundMusic();
    _loadQuestions();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    _stopwatch.reset();
    _questionTimer?.cancel();
    _backgroundMusicPlayer.dispose();
    _correctAnswerPlayer.dispose();
    _incorrectAnswerPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadAudio() async {
    try {
      await _backgroundMusicPlayer.setSource(
        AssetSource('assets/audio/background_music.mp3'),
      );
      await _correctAnswerPlayer.setSource(
        AssetSource('assets/audio/correct_answer.mp3'),
      );
      await _incorrectAnswerPlayer.setSource(
        AssetSource('assets/audio/incorrect_answer.mp3'),
      );
    } catch (e) {
      print('Error loading audio assets: $e');
    }
  }

  void _playBackgroundMusic() async {
    try {
      await _backgroundMusicPlayer.setReleaseMode(ReleaseMode.loop);
      await _backgroundMusicPlayer.play(
        AssetSource('assets/audio/background_music.mp3'),
      );
    } catch (e) {
      print('Error playing background music: $e');
    }
  }

  void _playCorrectAnswerSound() async {
    try {
      await _correctAnswerPlayer.play(
        AssetSource('assets/audio/correct_answer.mp3'),
      );
    } catch (e) {
      print('Error playing correct answer sound: $e');
    }
  }

  void _playIncorrectAnswerSound() async {
    try {
      await _incorrectAnswerPlayer.play(
        AssetSource('assets/audio/incorrect_answer.mp3'),
      );
    } catch (e) {
      print('Error playing incorrect answer sound: $e');
    }
  }

  void _startTimer() {
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_stopwatch.isRunning) {
        setState(() {
          _elapsedTime = (_stopwatch.elapsedMilliseconds / 1000)
              .floor()
              .toString()
              .padLeft(2, '0');
        });
      }
    });
  }

  void _stopTimer() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
      _timer?.cancel();
    }
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true; // Start loading, set loading to true
      _loadError = ''; // Clear any previous error
    });
    try {
      final questions = await _questionService.generateQuestions(10);
      setState(() {
        _questions = questions;
        _isLoading = false;
        if (_questions.isNotEmpty) {
          // Start timer only if questions are loaded
          _startQuestionTimer();
        }
      });
    } catch (e) {
      print('Error loading questions: $e');
      setState(() {
        _isLoading = false;
        _loadError =
            'Failed to load questions. Please check your internet connection and API key.'; // Set error message
      });
    }
  }

  void _startQuestionTimer() {
    _questionTimeRemaining = 30;
    _questionTimer?.cancel();
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_questionTimeRemaining > 0) {
        setState(() {
          _questionTimeRemaining--;
        });
      } else {
        _questionTimer?.cancel();
        _answerQuestion(-1);
      }
    });
    _startStopwatchForQuestion();
  }

  void _startStopwatchForQuestion() {
    _stopwatch.reset();
    _stopwatch.start();
    _startTimer();
  }

  int calculatePoints(int milliseconds) {
    int basePoints = 100;
    int bonusPoints = 0;
    int timeTakenSeconds = (milliseconds / 1000).floor();

    if (timeTakenSeconds <= 5) {
      bonusPoints = 50;
    } else if (timeTakenSeconds <= 10) {
      bonusPoints = 25;
    }
    return basePoints + bonusPoints;
  }

  void _answerQuestion(int selectedIndex) {
    _stopTimer();
    _questionTimer?.cancel();
    int pointsEarned = 0;
    bool answeredByTimeOut = selectedIndex == -1;

    setState(() {
      if (!answeredByTimeOut) {
        _questions[_currentQuestionIndex].selectedAnswerIndex = selectedIndex;

        if (selectedIndex == _questions[_currentQuestionIndex].correctIndex) {
          pointsEarned = calculatePoints(_stopwatch.elapsedMilliseconds);
          _score += pointsEarned;
          _playCorrectAnswerSound();
        } else {
          _playIncorrectAnswerSound();
        }
      } else {
        _playIncorrectAnswerSound();
      }

      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
        _startQuestionTimer();
      } else {
        _backgroundMusicPlayer.stop();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              score: _score,
              totalQuestions: _questions.length,
              questions: _questions,
            ),
          ),
        );
      }
    });
  }

  void _restartQuiz() {
    _stopTimer();
    _questionTimer?.cancel();
    _backgroundMusicPlayer.resume();
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _isLoading = true;
      _questions = [];
      _elapsedTime = '00';
      _questionTimeRemaining = 30;
    });
    _loadQuestions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Philippine Quiz'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                'Time: $_questionTimeRemaining s',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.red.shade900,
              Colors.red.shade700,
              Colors.red.shade500,
              Colors.red.shade400
            ],
            stops: const [0.1, 0.3, 0.7, 0.9],
          ),
        ),
        child: SafeArea(
          top: true,
          bottom: true, // **CHANGED: SafeArea bottom to true**
          child: Padding(
            // **Added Padding to SafeArea's child**
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: _isLoading // Conditional rendering based on loading state
                ? Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : _loadError.isNotEmpty // Check for load error
                    ? Center(
                        child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          _loadError, // Display error message
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.yellowAccent, fontSize: 16),
                        ),
                      ))
                    : _questions
                            .isEmpty // Check if questions list is empty (though it shouldn't be if no error)
                        ? Center(
                            child: Text(
                              'No questions available.',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 10),
                              Expanded(
                                child: QuestionWidget(
                                  question: _questions[_currentQuestionIndex],
                                  questionNumber: _currentQuestionIndex + 1,
                                  totalQuestions: _questions.length,
                                  onAnswer: _answerQuestion,
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms);
  }
}

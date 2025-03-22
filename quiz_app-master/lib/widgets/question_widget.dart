// widgets/question_widget.dart
import 'package:flutter/material.dart';
import '../models/question.dart';
import 'package:flutter_animate/flutter_animate.dart';

class QuestionWidget extends StatelessWidget {
  final Question question;
  final int questionNumber;
  final int totalQuestions;
  final Function(int) onAnswer;

  const QuestionWidget({
    Key? key,
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    required this.onAnswer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black54,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        // **Wrap Column with SingleChildScrollView to enable scrolling**
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(), // Add ClampingScrollPhysics for smoother scrolling
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Question $questionNumber/$totalQuestions',
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
              const SizedBox(height: 15),
              Text(
                question.text,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ).animate().fadeIn(duration: 500.ms),
              const SizedBox(height: 25),
              if (question.options.isNotEmpty)
                Column(
                  children: question.options.asMap().entries.map((entry) {
                    int index = entry.key;
                    String option = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => onAnswer(index),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.red.shade800,
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: BorderSide(color: Colors.red.shade400.withOpacity(0.8), width: 1.5),
                            ),
                            elevation: 4,
                          ),
                          child: Text(
                            option,
                            style: const TextStyle(fontSize: 18, color: Colors.black87),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ).animate().slideX(begin: -1, duration: 400.ms, delay: (index*100).ms);
                  }).toList(),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    'Options are not available for this question.',
                    style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
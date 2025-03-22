// question.dart
class Question {
  final String text;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  int? selectedAnswerIndex;

  Question({
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.selectedAnswerIndex,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    List<dynamic> optionsJson =
        json['options'] ?? []; // Get options, default to empty list if missing
    List<String> optionsList =
        optionsJson.cast<String>().toList(); // Cast and convert to List<String>

    return Question(
      text: json['text'] ??
          'Question text not available', // Provide default text if missing
      options: optionsList, // Use the processed optionsList
      correctIndex: json['correctIndex'] ?? 0, // Default to 0 if missing
      explanation: json['explanation'] ?? 'No explanation provided.',
    );
  }
}

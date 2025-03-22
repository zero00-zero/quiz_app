// question_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question.dart';

class QuestionService {
  final String apiKey;
  final String apiUrl = 'https://api.mistral.ai/v1/chat/completions';

  QuestionService(this.apiKey);

  Future<List<Question>> generateQuestions(int count) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'mistral-tiny',
        
        'messages': [
          {
            'role': 'user',
            'content':
                'Generate $count multiple-choice questions about Philippine history, culture, geography, and current events. For each question, provide 4 options, indicate the correct answer index (0-3), and include a brief explanation of why the correct answer is correct. Format the response as a JSON array of objects, each with "text", "options" (array of 4 strings), "correctIndex" (0-3), and "explanation" (string) properties.'
          }
        ],
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final content = jsonResponse['choices'][0]['message']['content'];
      try {
        final questionsJson = jsonDecode(content);
        return questionsJson
            .map<Question>((q) => Question.fromJson(q))
            .toList();
      } catch (e) {
        print('Error decoding questions JSON: $e');
        print('JSON content: $content');
        throw Exception('Failed to parse questions JSON');
      }
    } else {
      print(
          'Failed to generate questions. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to generate questions');
    }
  }
}

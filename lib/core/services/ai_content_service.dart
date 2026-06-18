import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/lesson_repository.dart';
import 'claude_service.dart';

// ── AiContentService ──────────────────────────────────────────────────────────

class AiContentService {
  AiContentService(this._claude);

  final ClaudeService _claude;

  static const String _systemPrompt = '''
You are an expert ESL teacher creating personalized lessons for Spanish-speaking adults learning English.
Output ONLY a raw JSON object — no markdown, no preamble, no text outside the JSON.

The JSON must match this exact schema:
{
  "id": "placeholder",
  "titleEs": "Título en Español",
  "titleEn": "Title in English",
  "difficulty": "A1" or "A2" or "B1",
  "iconEmoji": "single relevant emoji",
  "targetVocabulary": [
    {
      "wordEn": "English word or phrase",
      "wordEs": "Spanish translation",
      "exampleEn": "Example sentence in English",
      "exampleEs": "Ejemplo en español"
    }
  ],
  "grammarRuleEs": "Explicación de la regla gramatical en español (2-4 párrafos con viñetas)",
  "grammarRuleEn": "Grammar rule explanation in English (1-2 sentences)",
  "grammarExample": ""A short example sentence in quotes"",
  "simulatorPrompt": "Full Claude system prompt for the conversation character. Must instruct the AI to return JSON: {feedbackColor: green|amber|red, aiSpokenReply: ..., isConversationFinished: false/true}",
  "simulatorCharacterEn": "Character name in English",
  "simulatorCharacterRoleEs": "Rol del personaje en español",
  "simulatorOpeningEn": "Opening line from the character in English",
  "simulatorOpeningHintEs": "Pista para el estudiante en español",
  "simulatorExpectedTurns": 6,
  "simulatorTargetGoalEs": "Meta de la conversación en español",
  "quizzes": [
    {
      "question": "Quiz question in Spanish",
      "options": ["Option A", "Option B", "Option C", "Option D"],
      "correctIndex": 0
    }
  ]
}

Rules:
- targetVocabulary: exactly 6 to 8 items
- quizzes: exactly 2 to 3 items
- grammarRuleEs: use bullet points with \\n• notation
- simulatorPrompt: must be detailed and include the JSON return format instruction
- All Spanish text must be in natural, friendly Spanish suitable for adult learners
''';

  Future<PathLesson> generateCustomLesson({
    required String userGoal,
    required String userLevel,
  }) async {
    final topic = _topicDescription(userGoal);
    final userMessage =
        'Create an English lesson for a Spanish-speaking adult student.\n\n'
        'Topic area: $topic\n'
        'CEFR level: $userLevel\n\n'
        'Make the vocabulary and scenario directly relevant to the topic area. '
        'The simulator character should be someone the student would realistically '
        'encounter in that context. Respond with JSON only.';

    final raw = await _claude.complete(
      systemPrompt: _systemPrompt,
      userMessage: userMessage,
      maxTokens: 2500,
    );
    return _parse(raw);
  }

  String _topicDescription(String goal) {
    switch (goal) {
      case 'citizenship':
        return 'US civics, history, and government vocabulary (for naturalization interview preparation)';
      case 'career':
        return 'workplace English and professional communication (job interviews, office interactions, emails)';
      case 'travel':
      case 'general':
      default:
        return 'everyday life situations (shopping, healthcare, public services, transportation)';
    }
  }

  PathLesson _parse(String raw) {
    // Strip markdown fences if present
    var cleaned = raw
        .replaceAll(RegExp(r'```json\s*'), '')
        .replaceAll(RegExp(r'```\s*'), '');

    final start = cleaned.indexOf('{');
    final end = cleaned.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) {
      throw const FormatException('No JSON object found in response');
    }

    final json =
        jsonDecode(cleaned.substring(start, end + 1)) as Map<String, dynamic>;

    // Inject a unique ID so it never collides with static lessons
    json['id'] = 'ai_daily_${DateTime.now().millisecondsSinceEpoch}';

    return PathLesson.fromJson(json);
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final aiContentServiceProvider = Provider<AiContentService>(
  (ref) => AiContentService(ClaudeService()),
);

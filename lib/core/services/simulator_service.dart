import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/scenario_models.dart';
import 'claude_service.dart';

// ── SimulatorResponse ─────────────────────────────────────────────────────────

class SimulatorResponse {
  const SimulatorResponse({
    required this.feedbackColor,
    required this.aiSpokenReply,
    required this.isConversationFinished,
    this.hintEs = '',
  });

  /// One of: 'green' | 'amber' | 'red'
  final String feedbackColor;
  final String aiSpokenReply;
  final bool isConversationFinished;

  /// Spanish hint shown to the student after 3 failed attempts.
  final String hintEs;

  factory SimulatorResponse.fromJson(Map<String, dynamic> json) {
    final color = json['feedback_color'];
    return SimulatorResponse(
      feedbackColor: (color == 'green' || color == 'red') ? color : 'amber',
      aiSpokenReply: (json['ai_spoken_reply'] as String?) ?? '',
      isConversationFinished:
          (json['is_conversation_finished'] as bool?) ?? false,
      hintEs: (json['hint_es'] as String?) ?? '',
    );
  }

  /// Used when JSON parsing fails entirely.
  factory SimulatorResponse.fallback(String raw) => SimulatorResponse(
        feedbackColor: 'amber',
        aiSpokenReply: raw.isNotEmpty ? raw : "I didn't catch that. Could you try again?",
        isConversationFinished: false,
      );
}

// ── SimulatorService ──────────────────────────────────────────────────────────

class SimulatorService {
  SimulatorService(this._claude);

  final ClaudeService _claude;

  static const String _systemPrompt = '''
You are an encouraging, native English-speaking roleplay partner. The user is practicing conversational English. Keep your responses to 1-2 short sentences to mimic a real, fast-paced conversation.

You must return ONLY a valid JSON object with these exact keys. No markdown, no preamble, no text outside the JSON object:
{
  "feedback_color": "green" | "amber" | "red",
  "ai_spoken_reply": "<your next in-character line in English>",
  "is_conversation_finished": true | false,
  "hint_es": "<short Spanish hint of what the student could say, e.g. 'Intenta: I feel pain in my back'>"
}

feedback_color:
  green  = student's English was clear and natural
  amber  = understandable but has noticeable errors
  red    = too unclear to understand; politely ask for clarification in character

hint_es: always provide a short example phrase in Spanish that hints at what the student could say next. Keep it under 15 words.

is_conversation_finished = true only when the scenario goal is fully achieved.
''';

  Future<SimulatorResponse> evaluate({
    required String scenarioContext,
    required String conversationHistory,
    required String userMessage,
  }) async {
    final prompt = '''
SCENARIO:
$scenarioContext

CONVERSATION SO FAR:
$conversationHistory

STUDENT JUST SAID:
"$userMessage"

Respond with JSON only.
''';

    final raw = await _claude.complete(
      systemPrompt: _systemPrompt,
      userMessage: prompt,
      maxTokens: 256,
    );

    return _parse(raw);
  }

  SimulatorResponse _parse(String raw) {
    try {
      final start = raw.indexOf('{');
      final end = raw.lastIndexOf('}');
      if (start == -1 || end == -1 || end <= start) {
        return SimulatorResponse.fallback(raw);
      }
      final json = jsonDecode(raw.substring(start, end + 1)) as Map<String, dynamic>;
      return SimulatorResponse.fromJson(json);
    } catch (_) {
      return SimulatorResponse.fallback(raw);
    }
  }

  // ── Coffee Shop scenario ───────────────────────────────────────────────────

  static const ScenarioData coffeeShopScenario = ScenarioData(
    id: 'coffee_shop_barista',
    titleEs: 'La Cafetería',
    descriptionEs:
        'Pide un doble espresso a un barista especialista y habla sobre tu equipo.',
    iconEmoji: '☕',
    targetPersona: 'adulto',
    characterNameEn: 'Alex',
    characterRoleEs: 'Barista especialista',
    openingLineEn:
        "Welcome! I'm Alex. What can I pull for you today?",
    openingHintEs: 'Saluda y pide lo que quieres tomar.',
    expectedTurns: 6,
    systemPrompt: '''
You are Alex, a knowledgeable specialty-coffee barista at a third-wave café.
You love talking about espresso extraction, grind size, and equipment.
The student's goal: order a double espresso and mention their 54 mm portafilter and Baratza grinder.
Guide the conversation naturally toward that goal in about 6 turns.
Always reply with the required JSON schema.
''',
  );
}

// ── Provider ──────────────────────────────────────────────────────────────────

final simulatorServiceProvider = Provider<SimulatorService>(
  (ref) => SimulatorService(ClaudeService()),
);

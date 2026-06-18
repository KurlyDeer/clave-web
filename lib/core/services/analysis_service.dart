import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/conversation_report.dart';
import '../models/scenario_models.dart';
import 'claude_service.dart';

// ── AnalysisService ───────────────────────────────────────────────────────────

class AnalysisService {
  AnalysisService(this._claude);

  final ClaudeService _claude;

  static const String _systemPrompt = '''
You are an expert ESL grader. Analyze the following conversation transcript between a Spanish-speaking student and an AI character.
Output ONLY a raw JSON object with this exact schema — no markdown, no preamble, no text outside the JSON:
{"grade": "A" or "B" or "C" or "D" or "F", "summary": "2 sentences in Spanish about their performance", "corrections": [{"mistake": "what they said", "correction": "how to say it better", "reason": "short explanation in Spanish"}]}
Maximum 5 corrections. If they did great, corrections can be an empty array.
grade: A = excellent English, B = good with minor errors, C = understandable but needs work, D = struggled significantly, F = could not communicate
''';

  Future<ConversationReport> analyze(List<ScenarioTurn> turns) async {
    try {
      final transcript = _buildTranscript(turns);
      final raw = await _claude.complete(
        systemPrompt: _systemPrompt,
        userMessage: 'Conversation transcript:\n\n$transcript\n\nRespond with JSON only.',
        maxTokens: 400,
      );
      return _parse(raw);
    } catch (_) {
      return ConversationReport.fallback();
    }
  }

  String _buildTranscript(List<ScenarioTurn> turns) {
    final buffer = StringBuffer();
    for (final turn in turns) {
      final label = turn.speaker == TurnSpeaker.ai ? 'AI' : 'Student';
      buffer.writeln('$label: ${turn.textEn}');
    }
    return buffer.toString();
  }

  ConversationReport _parse(String raw) {
    try {
      final start = raw.indexOf('{');
      final end = raw.lastIndexOf('}');
      if (start == -1 || end == -1 || end <= start) {
        return ConversationReport.fallback();
      }
      final json =
          jsonDecode(raw.substring(start, end + 1)) as Map<String, dynamic>;
      return ConversationReport.fromJson(json);
    } catch (_) {
      return ConversationReport.fallback();
    }
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final analysisServiceProvider = Provider<AnalysisService>(
  (ref) => AnalysisService(ClaudeService()),
);

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'claude_service.dart';

// ── TutorService ───────────────────────────────────────────────────────────────

class TutorService {
  TutorService(this._claude);

  final ClaudeService _claude;

  static const String _systemPrompt =
      'You are Mi Compañero, a highly supportive, bilingual English/Spanish '
      'conversation partner. Chat naturally with the user. If they make a major '
      'English mistake, correct it gently in brackets at the end of your response, '
      'but prioritize keeping the conversation flowing naturally. '
      'Keep replies under 3 sentences.';

  /// Sends the full [conversationHistory] to Claude and returns the AI reply.
  Future<String> chat(String conversationHistory) async {
    try {
      return await _claude.complete(
        systemPrompt: _systemPrompt,
        userMessage: conversationHistory,
        maxTokens: 300,
      );
    } catch (e) {
      debugPrint('⚠️ TutorService error: $e');
      rethrow;
    }
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final tutorServiceProvider = Provider<TutorService>(
  (ref) => TutorService(ClaudeService()),
);

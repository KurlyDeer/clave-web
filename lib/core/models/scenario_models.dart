// ── ScenarioData ──────────────────────────────────────────────────────────────

class ScenarioData {
  const ScenarioData({
    required this.id,
    required this.titleEs,
    required this.descriptionEs,
    required this.iconEmoji,
    required this.targetPersona, // 'nino' | 'adulto' | 'abuelo'
    required this.characterNameEn,
    required this.characterRoleEs,
    required this.openingLineEn,
    required this.openingHintEs,
    required this.systemPrompt,
    this.expectedTurns = 6,
    this.sourceLessonId,
    this.targetGoalEs = '',
  });

  final String id;
  final String titleEs;
  final String descriptionEs;
  final String iconEmoji;
  final String targetPersona;
  final String characterNameEn;
  final String characterRoleEs;
  final String openingLineEn;
  final String openingHintEs;
  final String systemPrompt;
  final int expectedTurns;

  /// Set when this scenario was launched from a PathLesson.
  /// On completion, the simulador will mark that lesson as complete.
  final String? sourceLessonId;

  /// Short Spanish description of the conversation goal shown to the user.
  final String targetGoalEs;
}

// ── ScenarioTurn ──────────────────────────────────────────────────────────────

enum TurnSpeaker { ai, user }

class ScenarioTurn {
  const ScenarioTurn({
    required this.speaker,
    required this.textEn,
    this.hintEs = '',
    this.feedbackEs = '',
    this.isAcceptable = true,
    this.feedbackColor = 'green',
  });

  final TurnSpeaker speaker;
  final String textEn;
  final String hintEs;
  final String feedbackEs;
  final bool isAcceptable;
  final String feedbackColor;
}

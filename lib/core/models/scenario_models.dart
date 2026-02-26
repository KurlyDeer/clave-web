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
  });

  final TurnSpeaker speaker;
  final String textEn;
  final String hintEs;
  final String feedbackEs;
  final bool isAcceptable;
}

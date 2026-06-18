// ── CorrectionItem ────────────────────────────────────────────────────────────

class CorrectionItem {
  const CorrectionItem({
    required this.mistake,
    required this.correction,
    required this.reason,
  });

  final String mistake;
  final String correction;
  final String reason;

  factory CorrectionItem.fromJson(Map<String, dynamic> json) => CorrectionItem(
        mistake: (json['mistake'] as String?) ?? '',
        correction: (json['correction'] as String?) ?? '',
        reason: (json['reason'] as String?) ?? '',
      );
}

// ── ConversationReport ────────────────────────────────────────────────────────

class ConversationReport {
  const ConversationReport({
    required this.grade,
    required this.summary,
    required this.corrections,
  });

  /// Letter grade: A, B, C, D, or F
  final String grade;

  /// 2-sentence performance summary in Spanish
  final String summary;

  final List<CorrectionItem> corrections;

  factory ConversationReport.fromJson(Map<String, dynamic> json) {
    final rawGrade = (json['grade'] as String?) ?? 'B';
    final validGrades = {'A', 'B', 'C', 'D', 'F'};
    final grade = validGrades.contains(rawGrade.toUpperCase())
        ? rawGrade.toUpperCase()
        : 'B';

    final rawCorrections = json['corrections'];
    final corrections = rawCorrections is List
        ? rawCorrections
            .whereType<Map<String, dynamic>>()
            .map(CorrectionItem.fromJson)
            .toList()
        : <CorrectionItem>[];

    return ConversationReport(
      grade: grade,
      summary: (json['summary'] as String?) ??
          '¡Completaste la conversación! Sigue practicando.',
      corrections: corrections,
    );
  }

  factory ConversationReport.fallback() => const ConversationReport(
        grade: 'B',
        summary:
            '¡Completaste la conversación! Sigue practicando para mejorar.',
        corrections: [],
      );
}

enum WordStatus { perfect, heavy, missed }

class WordResult {
  const WordResult({required this.word, required this.status});

  final String word;
  final WordStatus status;
}

class VoiceAnalysisResult {
  const VoiceAnalysisResult({
    required this.wordResults,
    required this.coachingTipEs,
    required this.score,
  });

  final List<WordResult> wordResults;
  final String coachingTipEs;
  final int score; // 0–100

  factory VoiceAnalysisResult.fromJson(
    Map<String, dynamic> json,
    List<String> targetWords,
  ) {
    final wordsJson = (json['words'] as List<dynamic>?) ?? [];
    final words = <WordResult>[];

    for (final w in wordsJson) {
      final statusStr = (w['status'] as String?) ?? 'perfect';
      final status = switch (statusStr) {
        'missed' => WordStatus.missed,
        'heavy' => WordStatus.heavy,
        _ => WordStatus.perfect,
      };
      final word = (w['word'] as String?) ?? '';
      if (word.isNotEmpty) words.add(WordResult(word: word, status: status));
    }

    // Pad with missed status if Claude returned fewer words than expected
    if (words.length < targetWords.length) {
      for (int i = words.length; i < targetWords.length; i++) {
        words.add(WordResult(word: targetWords[i], status: WordStatus.missed));
      }
    }

    return VoiceAnalysisResult(
      wordResults: words,
      coachingTipEs: (json['tip_es'] as String?) ?? '',
      score: (json['score'] as num?)?.toInt() ?? 50,
    );
  }

  /// Fallback result when Claude analysis fails.
  factory VoiceAnalysisResult.fallback(List<String> targetWords) {
    return VoiceAnalysisResult(
      wordResults: targetWords
          .map((w) => WordResult(word: w, status: WordStatus.heavy))
          .toList(),
      coachingTipEs: 'Practica esta oración despacio, palabra por palabra.',
      score: 50,
    );
  }
}

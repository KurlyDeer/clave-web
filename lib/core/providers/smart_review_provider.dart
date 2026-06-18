import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/lesson_repository.dart';
import '../providers/shared_preferences_provider.dart';
import '../../l10n/app_strings.dart';

// ── FailedQuizEntry ────────────────────────────────────────────────────────────

class FailedQuizEntry {
  FailedQuizEntry({
    required this.key,
    required this.lessonId,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.failCount,
    required this.addedDate,
  });

  final String key;
  final String lessonId;
  final String question;
  final List<String> options;
  final int correctIndex;
  final int failCount;
  final String addedDate;

  FailedQuizEntry copyWith({int? failCount}) => FailedQuizEntry(
        key: key,
        lessonId: lessonId,
        question: question,
        options: options,
        correctIndex: correctIndex,
        failCount: failCount ?? this.failCount,
        addedDate: addedDate,
      );

  Map<String, dynamic> toJson() => {
        'key': key,
        'lessonId': lessonId,
        'question': question,
        'options': options,
        'correctIndex': correctIndex,
        'failCount': failCount,
        'addedDate': addedDate,
      };

  factory FailedQuizEntry.fromJson(Map<String, dynamic> json) =>
      FailedQuizEntry(
        key: json['key'] as String,
        lessonId: json['lessonId'] as String,
        question: json['question'] as String,
        options: (json['options'] as List<dynamic>).cast<String>(),
        correctIndex: (json['correctIndex'] as num).toInt(),
        failCount: (json['failCount'] as num).toInt(),
        addedDate: json['addedDate'] as String,
      );
}

// ── SmartReviewNotifier ────────────────────────────────────────────────────────

class SmartReviewNotifier
    extends StateNotifier<Map<String, FailedQuizEntry>> {
  SmartReviewNotifier(this._prefs) : super({}) {
    _load();
  }

  static const _prefsKey = 'smart_review_bank';
  final SharedPreferences _prefs;

  void _load() {
    final raw = _prefs.getString(_prefsKey);
    if (raw == null) return;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      state = map.map(
        (k, v) => MapEntry(
          k,
          FailedQuizEntry.fromJson(v as Map<String, dynamic>),
        ),
      );
    } catch (_) {
      state = {};
    }
  }

  void addFailedItem({
    required String lessonId,
    required QuizItem quiz,
  }) {
    final key = '$lessonId::${quiz.question}';
    final existing = state[key];
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final updated = Map<String, FailedQuizEntry>.from(state);
    updated[key] = existing != null
        ? existing.copyWith(failCount: existing.failCount + 1)
        : FailedQuizEntry(
            key: key,
            lessonId: lessonId,
            question: quiz.question,
            options: quiz.options,
            correctIndex: quiz.correctIndex,
            failCount: 1,
            addedDate: today,
          );
    state = updated;
    _persist();
  }

  void removeItem(String key) {
    if (!state.containsKey(key)) return;
    final updated = Map<String, FailedQuizEntry>.from(state)..remove(key);
    state = updated;
    _persist();
  }

  /// Returns up to [maxItems] entries, sorted by highest fail count first,
  /// with shuffling within each fail-count group.
  List<FailedQuizEntry> pickReviewItems({int maxItems = 10}) {
    final grouped = <int, List<FailedQuizEntry>>{};
    for (final e in state.values) {
      grouped.putIfAbsent(e.failCount, () => []).add(e);
    }
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));
    final result = <FailedQuizEntry>[];
    for (final k in sortedKeys) {
      final group = grouped[k]!..shuffle(Random());
      result.addAll(group);
      if (result.length >= maxItems) break;
    }
    return result.take(maxItems).toList();
  }

  void _persist() {
    _prefs.setString(
      _prefsKey,
      jsonEncode(state.map((k, v) => MapEntry(k, v.toJson()))),
    );
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final smartReviewProvider = StateNotifierProvider<SmartReviewNotifier,
    Map<String, FailedQuizEntry>>(
  (ref) => SmartReviewNotifier(ref.watch(sharedPreferencesProvider)),
);

final smartReviewCountProvider = Provider<int>(
  (ref) => ref.watch(smartReviewProvider).length,
);

// ── SmartReviewService ────────────────────────────────────────────────────────

class SmartReviewService {
  SmartReviewService._();

  /// Builds a review-only [PathLesson] from the given bank entries.
  /// Returns both the lesson and the parallel list of bank keys (for removal
  /// when the user answers correctly in review mode).
  static ({PathLesson lesson, List<String> bankKeys}) buildReviewLesson(
    List<FailedQuizEntry> entries,
  ) {
    final quizzes = entries
        .map(
          (e) => QuizItem(
            question: e.question,
            options: e.options,
            correctIndex: e.correctIndex,
          ),
        )
        .toList();
    final bankKeys = entries.map((e) => e.key).toList();

    const lesson = PathLesson(
      id: 'smart_review_session',
      titleEs: AppStrings.smartReviewTitleEs,
      titleEn: AppStrings.smartReviewTitleEn,
      difficulty: 'MIX',
      iconEmoji: '🧠',
      targetVocabulary: [],
      grammarRuleEs: '',
      grammarRuleEn: '',
      grammarExample: '',
      simulatorPrompt: '',
      simulatorCharacterEn: '',
      simulatorCharacterRoleEs: '',
      simulatorOpeningEn: '',
      simulatorOpeningHintEs: '',
      quizzes: [],
    );

    // quizzes can't be const because they're built at runtime, so rebuild
    final runtimeLesson = PathLesson(
      id: lesson.id,
      titleEs: lesson.titleEs,
      titleEn: lesson.titleEn,
      difficulty: lesson.difficulty,
      iconEmoji: lesson.iconEmoji,
      targetVocabulary: const [],
      grammarRuleEs: '',
      grammarRuleEn: '',
      grammarExample: '',
      simulatorPrompt: '',
      simulatorCharacterEn: '',
      simulatorCharacterRoleEs: '',
      simulatorOpeningEn: '',
      simulatorOpeningHintEs: '',
      quizzes: quizzes,
    );

    return (lesson: runtimeLesson, bankKeys: bankKeys);
  }
}

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/vocab_word_model.dart';
import 'persona_provider.dart';
import 'shared_preferences_provider.dart';
import 'gamification_controller.dart';
import 'audio_provider.dart';
import 'vocab_provider.dart';

// ── Date helpers ──────────────────────────────────────────────────────────────

String _today() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-'
      '${now.day.toString().padLeft(2, '0')}';
}

String _tomorrow() {
  final t = DateTime.now().add(const Duration(days: 1));
  return '${t.year}-${t.month.toString().padLeft(2, '0')}-'
      '${t.day.toString().padLeft(2, '0')}';
}

// ── Spaced-repetition schedule ────────────────────────────────────────────────

/// Persists {wordId → reviewDate (YYYY-MM-DD)} to SharedPreferences.
class RepasoScheduleNotifier
    extends StateNotifier<Map<String, String>> {
  RepasoScheduleNotifier(this._prefs) : super(_load(_prefs));

  static const _key = 'repaso_schedule';
  final dynamic _prefs; // SharedPreferences

  static Map<String, String> _load(dynamic prefs) {
    final raw = prefs.getString(_key) as String?;
    if (raw == null) return {};
    try {
      return Map<String, String>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return {};
    }
  }

  void scheduleWord(String wordId, String dateStr) {
    final updated = {...state, wordId: dateStr};
    _prefs.setString(_key, jsonEncode(updated));
    state = updated;
  }

  void removeWord(String wordId) {
    if (!state.containsKey(wordId)) return;
    final updated = Map<String, String>.from(state)..remove(wordId);
    _prefs.setString(_key, jsonEncode(updated));
    state = updated;
  }
}

final repasoScheduleProvider =
    StateNotifierProvider<RepasoScheduleNotifier, Map<String, String>>((ref) {
  return RepasoScheduleNotifier(ref.watch(sharedPreferencesProvider));
});

// ── Due-today derived provider ────────────────────────────────────────────────

/// Returns the VocabWords that are scheduled for review today or earlier.
final repasoDueWordsProvider = Provider<List<VocabWord>>((ref) {
  final schedule = ref.watch(repasoScheduleProvider);
  final allWords = ref.watch(vocabProvider);
  final today = _today();

  final dueIds = schedule.entries
      .where((e) => e.value.compareTo(today) <= 0)
      .map((e) => e.key)
      .toSet();

  return allWords.where((w) => dueIds.contains(w.id)).toList();
});

// ── Session state ─────────────────────────────────────────────────────────────

class RepasoState {
  const RepasoState({
    this.words = const [],
    this.flippedIds = const {},
    this.knownIds = const {},
    this.repeatIds = const {},
    this.isComplete = false,
    this.currentIndex = 0,
  });

  final List<VocabWord> words;
  final Set<String> flippedIds;
  final Set<String> knownIds;
  final Set<String> repeatIds;
  final bool isComplete;
  final int currentIndex;

  /// Whether the current card has been flipped.
  bool get isCurrentFlipped =>
      words.isNotEmpty &&
      currentIndex < words.length &&
      flippedIds.contains(words[currentIndex].id);

  RepasoState copyWith({
    List<VocabWord>? words,
    Set<String>? flippedIds,
    Set<String>? knownIds,
    Set<String>? repeatIds,
    bool? isComplete,
    int? currentIndex,
  }) {
    return RepasoState(
      words: words ?? this.words,
      flippedIds: flippedIds ?? this.flippedIds,
      knownIds: knownIds ?? this.knownIds,
      repeatIds: repeatIds ?? this.repeatIds,
      isComplete: isComplete ?? this.isComplete,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class RepasoNotifier extends StateNotifier<RepasoState> {
  RepasoNotifier(this._ref) : super(const RepasoState()) {
    _buildSession();
  }

  final Ref _ref;

  void _buildSession() {
    final dueWords = _ref.read(repasoDueWordsProvider);
    final allWords = _ref.read(vocabProvider);

    // Due words come first; fill remainder from most-recent vocab (up to 10 total).
    final dueIds = {for (final w in dueWords) w.id};
    final fillCount = (10 - dueWords.length).clamp(0, 10);
    final recentFill = allWords
        .where((w) => !dueIds.contains(w.id))
        .take(fillCount)
        .toList();

    final sessionWords = [...dueWords, ...recentFill];
    state = RepasoState(words: sessionWords);
  }

  /// Flip the current card to reveal Spanish.
  /// Abuelo persona: auto-plays TTS on flip.
  void flipCurrentCard() {
    if (state.words.isEmpty || state.currentIndex >= state.words.length) return;
    final word = state.words[state.currentIndex];
    if (state.flippedIds.contains(word.id)) return;

    state = state.copyWith(flippedIds: {...state.flippedIds, word.id});

    final persona = _ref.read(personaProvider);
    if (persona == Persona.abuelo) {
      _ref.read(audioServiceProvider).speak(word.wordEs);
    }
  }

  /// Mark current word as known and advance to the next card.
  void markKnownAndAdvance() {
    if (state.words.isEmpty || state.currentIndex >= state.words.length) return;
    final word = state.words[state.currentIndex];
    _ref.read(vocabProvider.notifier).markKnown(word.id);
    _ref.read(repasoScheduleProvider.notifier).removeWord(word.id);
    _advance(knownIds: {...state.knownIds, word.id});
  }

  /// Schedule current word for repeat tomorrow and advance to the next card.
  void scheduleRepeatAndAdvance() {
    if (state.words.isEmpty || state.currentIndex >= state.words.length) return;
    final word = state.words[state.currentIndex];
    _ref.read(repasoScheduleProvider.notifier).scheduleWord(word.id, _tomorrow());
    _advance(repeatIds: {...state.repeatIds, word.id});
  }

  void _advance({Set<String>? knownIds, Set<String>? repeatIds}) {
    final known = knownIds ?? state.knownIds;
    final repeats = repeatIds ?? state.repeatIds;
    final nextIndex = state.currentIndex + 1;
    final isComplete = nextIndex >= state.words.length;

    state = state.copyWith(
      knownIds: known,
      repeatIds: repeats,
      currentIndex: nextIndex,
      isComplete: isComplete,
    );

    if (isComplete) {
      _ref.read(gamificationProvider.notifier).addXp(5);
      _ref.read(gamificationProvider.notifier).recordPractice();
    }
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final repasoProvider =
    StateNotifierProvider.autoDispose<RepasoNotifier, RepasoState>((ref) {
  return RepasoNotifier(ref);
});

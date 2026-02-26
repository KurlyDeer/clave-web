import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../models/vocab_word_model.dart';

// ── Box provider (overridden in main.dart) ────────────────────────────────────

final vocabBoxProvider = Provider<Box<VocabWord>>((ref) {
  throw UnimplementedError('vocabBoxProvider must be overridden in main.dart');
});

// ── Notifier ──────────────────────────────────────────────────────────────────

class VocabNotifier extends StateNotifier<List<VocabWord>> {
  VocabNotifier(this._box) : super(_sorted(_box.values.toList()));

  final Box<VocabWord> _box;

  static List<VocabWord> _sorted(List<VocabWord> words) {
    final list = List<VocabWord>.from(words);
    // Unknown words first (study queue first), then known; newest-first within group.
    list.sort((a, b) {
      if (a.isKnown != b.isKnown) return a.isKnown ? 1 : -1;
      return b.createdAt.compareTo(a.createdAt);
    });
    return list;
  }

  /// Adds a word only if it doesn't already exist (deduplicates on normalised English text).
  Future<void> addWord({
    required String wordEn,
    required String wordEs,
    required String source,
  }) async {
    final trimEn = wordEn.trim();
    final trimEs = wordEs.trim();
    if (trimEn.isEmpty || trimEs.isEmpty) return;

    final id = trimEn.toLowerCase();
    if (_box.containsKey(id)) return;

    final word = VocabWord(
      id: id,
      wordEn: trimEn,
      wordEs: trimEs,
      source: source,
      createdAt: DateTime.now().toIso8601String(),
    );
    await _box.put(id, word);
    state = _sorted(_box.values.toList());
  }

  Future<void> markKnown(String id) async {
    final word = _box.get(id);
    if (word == null) return;
    await _box.put(id, word.copyWith(isKnown: true));
    state = _sorted(_box.values.toList());
  }

  Future<void> markRepeat(String id) async {
    final word = _box.get(id);
    if (word == null) return;
    await _box.put(id, word.copyWith(isKnown: false));
    state = _sorted(_box.values.toList());
  }

  /// Resets all words to isKnown = false for a fresh review session.
  Future<void> resetAll() async {
    for (final word in _box.values.toList()) {
      await _box.put(word.id, word.copyWith(isKnown: false));
    }
    state = _sorted(_box.values.toList());
  }

  Future<void> deleteWord(String id) async {
    await _box.delete(id);
    state = _sorted(_box.values.toList());
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final vocabProvider =
    StateNotifierProvider<VocabNotifier, List<VocabWord>>((ref) {
  final box = ref.watch(vocabBoxProvider);
  return VocabNotifier(box);
});

/// Known vs. total word counts.
final vocabStatsProvider = Provider<({int known, int total})>((ref) {
  final words = ref.watch(vocabProvider);
  return (
    known: words.where((w) => w.isKnown).length,
    total: words.length,
  );
});

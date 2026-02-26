import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'shared_preferences_provider.dart';

const _kCommunityKey = 'community_celebrations';

// ── Model ─────────────────────────────────────────────────────────────────────

class CommunityPost {
  const CommunityPost({
    required this.id,
    required this.authorEs,
    required this.winEs,
    required this.emoji,
  });

  final String id;
  final String authorEs;
  final String winEs;
  final String emoji;
}

// ── Hardcoded wins ────────────────────────────────────────────────────────────

const List<CommunityPost> _posts = [
  CommunityPost(
    id: 'w1',
    authorEs: 'Ana de Florida',
    winEs: 'Completó la Lección 5 y pidió su orden en un restaurante ella sola',
    emoji: '🍽️',
  ),
  CommunityPost(
    id: 'w2',
    authorEs: 'Carlos de Texas',
    winEs: 'Habló con su jefe en inglés por primera vez sin ayuda',
    emoji: '💼',
  ),
  CommunityPost(
    id: 'w3',
    authorEs: 'Rosa de California',
    winEs: 'Fue al doctor y habló sin necesitar intérprete',
    emoji: '🏥',
  ),
  CommunityPost(
    id: 'w4',
    authorEs: 'Miguel de Nueva York',
    winEs: 'Lleva 7 días seguidos de práctica diaria',
    emoji: '🔥',
  ),
  CommunityPost(
    id: 'w5',
    authorEs: 'Lucía de Illinois',
    winEs: 'Ayudó a su abuela a entender una receta médica en inglés',
    emoji: '💊',
  ),
  CommunityPost(
    id: 'w6',
    authorEs: 'Jorge de Arizona',
    winEs: 'Subió de nivel Básico a Intermedio esta semana',
    emoji: '📈',
  ),
  CommunityPost(
    id: 'w7',
    authorEs: 'Elena de Georgia',
    winEs: 'Su jefe la felicitó por su mejora en inglés',
    emoji: '⭐',
  ),
  CommunityPost(
    id: 'w8',
    authorEs: 'David de Nevada',
    winEs: 'Escribió su primer párrafo completo en inglés',
    emoji: '📝',
  ),
  CommunityPost(
    id: 'w9',
    authorEs: 'Sofía de Colorado',
    winEs: 'Habló con la maestra de su hijo en la escuela sin ayuda',
    emoji: '🎓',
  ),
  CommunityPost(
    id: 'w10',
    authorEs: 'Ramón de Washington',
    winEs: 'Completó sus primeras 10 lecciones de English Bridge',
    emoji: '🏆',
  ),
];

// ── State ─────────────────────────────────────────────────────────────────────

class CommunityState {
  const CommunityState({
    this.celebrationCounts = const {},
  });

  final Map<String, int> celebrationCounts;

  List<CommunityPost> get posts => _posts;

  int countFor(String id) => celebrationCounts[id] ?? 0;

  CommunityState copyWith({Map<String, int>? celebrationCounts}) {
    return CommunityState(
      celebrationCounts: celebrationCounts ?? this.celebrationCounts,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class CommunityNotifier extends StateNotifier<CommunityState> {
  CommunityNotifier(this._prefs) : super(const CommunityState()) {
    _load();
  }

  final SharedPreferences _prefs;

  void _load() {
    final raw = _prefs.getString(_kCommunityKey);
    if (raw == null) return;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final counts = decoded.map((k, v) => MapEntry(k, v as int));
      state = state.copyWith(celebrationCounts: counts);
    } catch (_) {}
  }

  Future<void> celebrate(String postId) async {
    final updated = Map<String, int>.from(state.celebrationCounts);
    updated[postId] = (updated[postId] ?? 0) + 1;
    state = state.copyWith(celebrationCounts: updated);
    await _prefs.setString(_kCommunityKey, jsonEncode(updated));
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final communityProvider =
    StateNotifierProvider<CommunityNotifier, CommunityState>((ref) {
  return CommunityNotifier(ref.watch(sharedPreferencesProvider));
});

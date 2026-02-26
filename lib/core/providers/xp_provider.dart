import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'shared_preferences_provider.dart';

// ── Level table ───────────────────────────────────────────────────────────────

const _levels = [
  (0, 'Visitante'),
  (50, 'Curioso'),
  (120, 'Explorador'),
  (210, 'Aventurero'),
  (330, 'Estudiante'),
  (500, 'Practicante'),
  (700, 'Conversador'),
  (950, 'Lector Ávido'),
  (1250, 'Narrador'),
  (1600, 'Cronista'),
  (2000, 'Corresponsal'),
  (2450, 'Periodista'),
  (2950, 'Poeta'),
  (3500, 'Novelista'),
  (4100, 'Literato'),
  (4750, 'Ensayista'),
  (5450, 'Autor Joven'),
  (6200, 'Maestro'),
  (7000, 'Académico'),
  (8000, 'Escritor'),
];

// ── State ─────────────────────────────────────────────────────────────────────

class XpState {
  const XpState({
    required this.totalXp,
    required this.level,
    required this.levelTitle,
    required this.xpToNextLevel,
    required this.levelProgress,
  });

  final int totalXp;
  final int level; // 1–20
  final String levelTitle;
  final int xpToNextLevel;
  final double levelProgress; // 0.0–1.0

  factory XpState.fromXp(int xp) {
    int level = 1;
    for (int i = _levels.length - 1; i >= 0; i--) {
      if (xp >= _levels[i].$1) {
        level = i + 1;
        break;
      }
    }

    final int currentThreshold = _levels[level - 1].$1;
    final int nextThreshold =
        level < _levels.length ? _levels[level].$1 : _levels.last.$1;
    final String title = _levels[level - 1].$2;

    final int xpToNext = level < _levels.length ? nextThreshold - xp : 0;
    final double progress = level < _levels.length
        ? (xp - currentThreshold) / (nextThreshold - currentThreshold)
        : 1.0;

    return XpState(
      totalXp: xp,
      level: level,
      levelTitle: title,
      xpToNextLevel: xpToNext.clamp(0, nextThreshold),
      levelProgress: progress.clamp(0.0, 1.0),
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class XpNotifier extends StateNotifier<XpState> {
  XpNotifier(this._prefs)
      : super(XpState.fromXp(_prefs.getInt('user_xp') ?? 0));

  final SharedPreferences _prefs;

  Future<void> addXp(int amount) async {
    final newXp = state.totalXp + amount;
    await _prefs.setInt('user_xp', newXp);
    state = XpState.fromXp(newXp);
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final xpProvider = StateNotifierProvider<XpNotifier, XpState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return XpNotifier(prefs);
});

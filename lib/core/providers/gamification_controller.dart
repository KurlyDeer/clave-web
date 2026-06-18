import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/streak_model.dart';
import '../services/notification_service.dart';
import 'shared_preferences_provider.dart';
import 'streak_provider.dart';

// ── Level table ───────────────────────────────────────────────────────────────
// Mirrors the table in xp_provider.dart to avoid a circular import.

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

class GamificationState {
  const GamificationState({
    required this.totalXp,
    required this.currentLevel,
    required this.levelTitle,
    required this.levelProgress,
    required this.xpToNextLevel,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastPracticeDate,
    required this.lastLoginDate,
    this.dailyXp = 0,
    this.dailyXpDate = '',
  });

  final int totalXp;
  final int currentLevel; // 1–20
  final String levelTitle;
  final double levelProgress; // 0.0–1.0
  final int xpToNextLevel;
  final int currentStreak;
  final int longestStreak;
  final String lastPracticeDate; // YYYY-MM-DD
  final String lastLoginDate;    // YYYY-MM-DD
  final int dailyXp;             // XP earned today
  final String dailyXpDate;      // YYYY-MM-DD — resets when date changes

  /// True when the user hasn't practised in more than 24 h — streak at risk.
  bool get isMissedDay {
    if (lastPracticeDate.isEmpty) return false;
    final last = DateTime.tryParse(lastPracticeDate);
    if (last == null) return false;
    final diff = DateTime.now()
        .difference(DateTime(last.year, last.month, last.day))
        .inDays;
    return diff > 1;
  }

  factory GamificationState.empty() => const GamificationState(
        totalXp: 0,
        currentLevel: 1,
        levelTitle: 'Visitante',
        levelProgress: 0.0,
        xpToNextLevel: 50,
        currentStreak: 0,
        longestStreak: 0,
        lastPracticeDate: '',
        lastLoginDate: '',
        dailyXp: 0,
        dailyXpDate: '',
      );
}

// ── Level helpers ─────────────────────────────────────────────────────────────

GamificationState _fromXp({
  required int xp,
  required int currentStreak,
  required int longestStreak,
  required String lastPracticeDate,
  required String lastLoginDate,
  int dailyXp = 0,
  String dailyXpDate = '',
}) {
  int level = 1;
  for (int i = _levels.length - 1; i >= 0; i--) {
    if (xp >= _levels[i].$1) {
      level = i + 1;
      break;
    }
  }
  final currentThreshold = _levels[level - 1].$1;
  final nextThreshold =
      level < _levels.length ? _levels[level].$1 : _levels.last.$1;
  final title = _levels[level - 1].$2;
  final xpToNext = level < _levels.length ? nextThreshold - xp : 0;
  final progress = level < _levels.length
      ? ((xp - currentThreshold) / (nextThreshold - currentThreshold))
          .clamp(0.0, 1.0)
      : 1.0;

  return GamificationState(
    totalXp: xp,
    currentLevel: level,
    levelTitle: title,
    levelProgress: progress,
    xpToNextLevel: xpToNext.clamp(0, nextThreshold),
    currentStreak: currentStreak,
    longestStreak: longestStreak,
    lastPracticeDate: lastPracticeDate,
    lastLoginDate: lastLoginDate,
    dailyXp: dailyXp,
    dailyXpDate: dailyXpDate,
  );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class GamificationNotifier extends StateNotifier<GamificationState> {
  GamificationNotifier({
    required Box<dynamic> box,
    required SharedPreferences prefs,
    required Box<StreakData> streakBox,
  })  : _box = box,
        _prefs = prefs,
        super(GamificationState.empty()) {
    _init(prefs, streakBox);
  }

  final Box<dynamic> _box;
  final SharedPreferences _prefs;
  static const _key = 'data';

  // ── Initialisation ────────────────────────────────────────────────────────

  void _init(SharedPreferences prefs, Box<StreakData> streakBox) {
    final raw = _box.get(_key) as Map?;
    if (raw == null) {
      // First run with new engine — migrate XP from SharedPreferences
      // and streak from the old Hive StreakData box.
      final xp = prefs.getInt('user_xp') ?? 0;
      final old = streakBox.get(0);
      final gs = _fromXp(
        xp: xp,
        currentStreak: old?.currentStreak ?? 0,
        longestStreak: old?.longestStreak ?? 0,
        lastPracticeDate: old?.lastPracticeDate ?? '',
        lastLoginDate: _today(),
      );
      _save(gs);
      state = gs;
    } else {
      state = _fromMap(raw);
    }
    // Apply login streak check every time the engine is initialised.
    checkAndApplyStreak();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static String _today() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  GamificationState _fromMap(Map raw) => _fromXp(
        xp: (raw['totalXp'] as int?) ?? 0,
        currentStreak: (raw['currentStreak'] as int?) ?? 0,
        longestStreak: (raw['longestStreak'] as int?) ?? 0,
        lastPracticeDate: (raw['lastPracticeDate'] as String?) ?? '',
        lastLoginDate: (raw['lastLoginDate'] as String?) ?? '',
        dailyXp: (raw['dailyXp'] as int?) ?? 0,
        dailyXpDate: (raw['dailyXpDate'] as String?) ?? '',
      );

  void _save(GamificationState gs) {
    _box.put(_key, {
      'totalXp': gs.totalXp,
      'currentStreak': gs.currentStreak,
      'longestStreak': gs.longestStreak,
      'lastPracticeDate': gs.lastPracticeDate,
      'lastLoginDate': gs.lastLoginDate,
      'dailyXp': gs.dailyXp,
      'dailyXpDate': gs.dailyXpDate,
    });
  }

  // ── Public API ────────────────────────────────────────────────────────────

  /// Add XP and recalculate level. Call on every completed activity.
  void addXp(int amount) {
    final today = _today();
    final currentDaily = state.dailyXpDate == today ? state.dailyXp : 0;
    final newDailyXp = currentDaily + amount;
    final newTotalXp = state.totalXp + amount;

    final next = _fromXp(
      xp: newTotalXp,
      currentStreak: state.currentStreak,
      longestStreak: state.longestStreak,
      lastPracticeDate: state.lastPracticeDate,
      lastLoginDate: state.lastLoginDate,
      dailyXp: newDailyXp,
      dailyXpDate: today,
    );
    _save(next);
    state = next;

    _checkDailyGoalMet(newDailyXp);
  }

  void _checkDailyGoalMet(int dailyXp) {
    final goalMinutes = _prefs.getInt('daily_goal_minutes');
    if (goalMinutes == null) return;

    // Only cancel if a reminder is actually configured
    if (_prefs.getInt('reminder_hour') == null) return;

    final threshold = goalMinutes <= 5 ? 5 : goalMinutes <= 15 ? 15 : 30;

    if (dailyXp >= threshold) {
      NotificationService.instance.cancelToday();
    }
  }

  /// Called automatically on engine init (app launch).
  ///
  /// - Yesterday → increment streak.
  /// - More than 1 day ago → reset streak to 0 (broken).
  /// - Today → no-op.
  void checkAndApplyStreak() {
    final today = _today();
    if (state.lastLoginDate == today) return;

    final last = DateTime.tryParse(state.lastLoginDate);
    final diff = last != null
        ? DateTime.now()
            .difference(DateTime(last.year, last.month, last.day))
            .inDays
        : 999;

    final int newStreak;
    if (state.lastLoginDate.isEmpty) {
      newStreak = state.currentStreak == 0 ? 0 : state.currentStreak;
    } else if (diff == 1) {
      newStreak = state.currentStreak + 1;
    } else {
      newStreak = 0; // streak broken
    }

    final newLongest =
        newStreak > state.longestStreak ? newStreak : state.longestStreak;

    final next = _fromXp(
      xp: state.totalXp,
      currentStreak: newStreak,
      longestStreak: newLongest,
      lastPracticeDate: state.lastPracticeDate,
      lastLoginDate: today,
    );
    _save(next);
    state = next;
  }

  /// Clears all persisted gamification data and resets to the empty state.
  void resetAll() {
    _box.delete(_key);
    state = GamificationState.empty();
  }

  /// Call when the user completes any practice activity.
  ///
  /// Increments streak if a new consecutive day; updates [lastPracticeDate].
  void recordPractice() {
    final today = _today();
    if (state.lastPracticeDate == today) return; // already recorded today

    final last = DateTime.tryParse(state.lastPracticeDate);
    final diff = last != null
        ? DateTime.now()
            .difference(DateTime(last.year, last.month, last.day))
            .inDays
        : 999;

    final newStreak = diff == 1 ? state.currentStreak + 1 : 1;
    final newLongest =
        newStreak > state.longestStreak ? newStreak : state.longestStreak;

    final next = _fromXp(
      xp: state.totalXp,
      currentStreak: newStreak,
      longestStreak: newLongest,
      lastPracticeDate: today,
      lastLoginDate: today,
    );
    _save(next);
    state = next;
  }
}

// ── Box provider (overridden in main.dart) ────────────────────────────────────

final gamificationBoxProvider = Provider<Box<dynamic>>((ref) {
  throw UnimplementedError(
    'gamificationBoxProvider must be overridden in main.dart',
  );
});

// ── Provider ──────────────────────────────────────────────────────────────────

final gamificationProvider =
    StateNotifierProvider<GamificationNotifier, GamificationState>((ref) {
  return GamificationNotifier(
    box: ref.watch(gamificationBoxProvider),
    prefs: ref.watch(sharedPreferencesProvider),
    streakBox: ref.watch(streakBoxProvider),
  );
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../models/streak_model.dart';

// ── Box provider (overridden in main.dart) ───────────────────────────────────

final streakBoxProvider = Provider<Box<StreakData>>((ref) {
  throw UnimplementedError('streakBoxProvider must be overridden in main.dart');
});

// ── Notifier ──────────────────────────────────────────────────────────────────

class StreakNotifier extends StateNotifier<StreakData?> {
  StreakNotifier(this._box) : super(_box.get(0));

  final Box<StreakData> _box;

  String _today() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  void recordPractice() {
    final today = _today();
    final current = state;

    if (current == null) {
      // First ever practice
      final data = StreakData(
        lastPracticeDate: today,
        currentStreak: 1,
        longestStreak: 1,
      );
      _box.put(0, data);
      state = data;
      return;
    }

    if (current.lastPracticeDate == today) {
      // Already practiced today — no-op
      return;
    }

    final last = DateTime.tryParse(current.lastPracticeDate);
    final todayDt = DateTime.now();
    final diff = last != null
        ? todayDt
            .difference(DateTime(last.year, last.month, last.day))
            .inDays
        : 999;

    final int newStreak;
    if (diff == 1) {
      newStreak = current.currentStreak + 1;
    } else {
      newStreak = 1;
    }

    final data = StreakData(
      lastPracticeDate: today,
      currentStreak: newStreak,
      longestStreak: newStreak > current.longestStreak
          ? newStreak
          : current.longestStreak,
    );
    _box.put(0, data);
    state = data;
  }

  /// True when the last practice date was more than 1 day ago (streak endangered).
  bool get isMissedDay {
    final current = state;
    if (current == null) return false;
    final last = DateTime.tryParse(current.lastPracticeDate);
    if (last == null) return false;
    final today = DateTime.now();
    final diff =
        today.difference(DateTime(last.year, last.month, last.day)).inDays;
    return diff > 1;
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final streakProvider =
    StateNotifierProvider<StreakNotifier, StreakData?>((ref) {
  final box = ref.watch(streakBoxProvider);
  return StreakNotifier(box);
});

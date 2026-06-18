import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../models/streak_model.dart';
import 'gamification_controller.dart';

// ── Box provider ──────────────────────────────────────────────────────────────
// Kept so GamificationNotifier can read the old Hive box for one-time
// migration on first run with the new engine.

final streakBoxProvider = Provider<Box<StreakData>>((ref) {
  throw UnimplementedError('streakBoxProvider must be overridden in main.dart');
});

// ── Provider (computed from gamificationProvider) ─────────────────────────────
// Returns StreakData? for backwards compatibility with read-only widgets.
// Write access now goes through gamificationProvider.notifier.recordPractice().

final streakProvider = Provider<StreakData?>((ref) {
  final g = ref.watch(gamificationProvider);
  if (g.currentStreak == 0 && g.lastPracticeDate.isEmpty) return null;
  return StreakData(
    currentStreak: g.currentStreak,
    longestStreak: g.longestStreak,
    lastPracticeDate: g.lastPracticeDate,
  );
});

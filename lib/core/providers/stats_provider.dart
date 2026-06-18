import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'shared_preferences_provider.dart';

class UserStats {
  const UserStats({
    this.xp = 0,
    this.streak = 0,
    this.speakingLessonsCompleted = 0,
    this.writingLessonsCompleted = 0,
  });

  final int xp;
  final int streak;
  final int speakingLessonsCompleted;
  final int writingLessonsCompleted;

  UserStats copyWith({
    int? xp,
    int? streak,
    int? speakingLessonsCompleted,
    int? writingLessonsCompleted,
  }) {
    return UserStats(
      xp: xp ?? this.xp,
      streak: streak ?? this.streak,
      speakingLessonsCompleted: speakingLessonsCompleted ?? this.speakingLessonsCompleted,
      writingLessonsCompleted: writingLessonsCompleted ?? this.writingLessonsCompleted,
    );
  }
}

class StatsNotifier extends StateNotifier<UserStats> {
  StatsNotifier(this._prefs) : super(const UserStats()) {
    _load();
  }

  final SharedPreferences _prefs;

  void _load() {
    state = UserStats(
      xp: _prefs.getInt('user_xp') ?? 0,
      streak: _prefs.getInt('user_streak') ?? 0,
      speakingLessonsCompleted: _prefs.getInt('speaking_lessons') ?? 0,
      writingLessonsCompleted: _prefs.getInt('writing_lessons') ?? 0,
    );
  }

  Future<void> addXp(int amount) async {
    final newXp = state.xp + amount;
    await _prefs.setInt('user_xp', newXp);
    state = state.copyWith(xp: newXp);
  }

  Future<void> incrementStreak() async {
    final newStreak = state.streak + 1;
    await _prefs.setInt('user_streak', newStreak);
    state = state.copyWith(streak: newStreak);
  }

  Future<void> addSpeakingLesson() async {
    final count = state.speakingLessonsCompleted + 1;
    await _prefs.setInt('speaking_lessons', count);
    state = state.copyWith(speakingLessonsCompleted: count);
  }

  Future<void> addWritingLesson() async {
    final count = state.writingLessonsCompleted + 1;
    await _prefs.setInt('writing_lessons', count);
    state = state.copyWith(writingLessonsCompleted: count);
  }
}

final statsProvider = StateNotifierProvider<StatsNotifier, UserStats>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return StatsNotifier(prefs);
});

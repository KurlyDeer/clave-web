import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'shared_preferences_provider.dart';

// ── Enum ──────────────────────────────────────────────────────────────────────

enum StudyPlanDuration { quick, standard, deep }

extension StudyPlanDurationX on StudyPlanDuration {
  int get minutes {
    switch (this) {
      case StudyPlanDuration.quick:
        return 5;
      case StudyPlanDuration.standard:
        return 15;
      case StudyPlanDuration.deep:
        return 30;
    }
  }

  String get labelEs {
    switch (this) {
      case StudyPlanDuration.quick:
        return '5 min';
      case StudyPlanDuration.standard:
        return '15 min';
      case StudyPlanDuration.deep:
        return '30+ min';
    }
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class StudyPlanNotifier extends StateNotifier<StudyPlanDuration?> {
  StudyPlanNotifier(this._prefs) : super(_fromPrefs(_prefs));

  final SharedPreferences _prefs;

  static StudyPlanDuration? _fromPrefs(SharedPreferences prefs) {
    final minutes = prefs.getInt('daily_goal_minutes');
    if (minutes == null) return null;
    if (minutes <= 5) return StudyPlanDuration.quick;
    if (minutes <= 15) return StudyPlanDuration.standard;
    return StudyPlanDuration.deep;
  }

  Future<void> setPlan(StudyPlanDuration plan) async {
    await _prefs.setInt('daily_goal_minutes', plan.minutes);
    state = plan;
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final studyPlanProvider =
    StateNotifierProvider<StudyPlanNotifier, StudyPlanDuration?>(
  (ref) => StudyPlanNotifier(ref.watch(sharedPreferencesProvider)),
);

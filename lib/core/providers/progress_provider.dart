import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'shared_preferences_provider.dart';

class ProgressState {
  const ProgressState({this.stageIndex = 0});

  final int stageIndex;

  double get overallProgress => stageIndex / 6.0;

  ProgressState copyWith({int? stageIndex}) {
    return ProgressState(stageIndex: stageIndex ?? this.stageIndex);
  }
}

class ProgressNotifier extends StateNotifier<ProgressState> {
  ProgressNotifier(this._prefs)
      : super(ProgressState(stageIndex: _prefs.getInt('progress_stage') ?? 0));

  final SharedPreferences _prefs;

  void advanceStage() {
    final next = (state.stageIndex + 1).clamp(0, 6);
    _prefs.setInt('progress_stage', next);
    state = state.copyWith(stageIndex: next);
  }

  void setStage(int index) {
    final clamped = index.clamp(0, 6);
    if (clamped == state.stageIndex) return;
    _prefs.setInt('progress_stage', clamped);
    state = state.copyWith(stageIndex: clamped);
  }
}

final progressProvider =
    StateNotifierProvider<ProgressNotifier, ProgressState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ProgressNotifier(prefs);
});

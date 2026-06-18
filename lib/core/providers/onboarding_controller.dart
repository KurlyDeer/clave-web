import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'path_lesson_provider.dart';
import 'persona_provider.dart';
import 'shared_preferences_provider.dart';
import 'user_name_provider.dart';

// ── UserGoal ──────────────────────────────────────────────────────────────────

enum UserGoal { career, travel, citizenship }

// ── State ─────────────────────────────────────────────────────────────────────

class OnboardingState {
  const OnboardingState({
    this.name = '',
    this.persona,
    this.userGoal,
  });

  final String name;
  final Persona? persona;
  final UserGoal? userGoal;

  OnboardingState copyWith({
    String? name,
    Persona? persona,
    UserGoal? userGoal,
  }) {
    return OnboardingState(
      name: name ?? this.name,
      persona: persona ?? this.persona,
      userGoal: userGoal ?? this.userGoal,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier(this._ref) : super(const OnboardingState());

  final Ref _ref;

  void setName(String name) => state = state.copyWith(name: name);
  void setPersona(Persona p) => state = state.copyWith(persona: p);
  void setUserGoal(UserGoal goal) => state = state.copyWith(userGoal: goal);

  /// Persist everything and mark onboarding as complete.
  Future<void> complete() async {
    final prefs = _ref.read(sharedPreferencesProvider);

    // Save name
    if (state.name.isNotEmpty) {
      _ref.read(userNameProvider.notifier).setName(state.name);
    }

    // Default persona to adulto (user can change from Profile later)
    _ref.read(personaProvider.notifier).setPersona(Persona.adulto);

    // Save goal
    if (state.userGoal != null) {
      await prefs.setString('user_goal', state.userGoal!.name);
    }

    // Switch to citizenship track if that was the goal
    if (state.userGoal == UserGoal.citizenship) {
      await _ref
          .read(learningTrackProvider.notifier)
          .setTrack(LearningTrack.citizenship);
    }

    // Mark onboarding complete
    await prefs.setBool('onboarding_complete', true);
  }

  /// Persist persona + name to SharedPreferences (legacy helper).
  void savePersonaAndName() {
    _ref.read(userNameProvider.notifier).setName(state.name);
    _ref.read(personaProvider.notifier).setPersona(state.persona!);
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>(
  (ref) => OnboardingNotifier(ref),
);

/// Reads the persisted user goal from SharedPreferences.
final userGoalProvider = Provider<UserGoal?>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  final raw = prefs.getString('user_goal');
  if (raw == null) return null;
  try {
    return UserGoal.values.byName(raw);
  } catch (_) {
    return null;
  }
});

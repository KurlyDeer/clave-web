import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/shared_preferences_provider.dart';

class SettingsState {
  const SettingsState({
    this.isDarkMode = true,
    this.isAudioEnabled = true,
    this.isPremium = true,
  });
  final bool isDarkMode;
  final bool isAudioEnabled;
  final bool isPremium;
  SettingsState copyWith({bool? isDarkMode, bool? isAudioEnabled, bool? isPremium}) =>
      SettingsState(
        isDarkMode: isDarkMode ?? this.isDarkMode,
        isAudioEnabled: isAudioEnabled ?? this.isAudioEnabled,
        isPremium: isPremium ?? this.isPremium,
      );
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier(this._prefs) : super(const SettingsState()) {
    _load();
  }

  final SharedPreferences _prefs;

  void _load() {
    state = SettingsState(
      isDarkMode: _prefs.getBool('dark_mode') ?? true,
      isAudioEnabled: _prefs.getBool('tts_enabled') ?? true,
      isPremium: true,
    );
  }

  Future<void> setDarkMode(bool v) async {
    await _prefs.setBool('dark_mode', v);
    state = state.copyWith(isDarkMode: v);
  }

  Future<void> setAudioEnabled(bool v) async {
    await _prefs.setBool('tts_enabled', v);
    state = state.copyWith(isAudioEnabled: v);
  }

  Future<void> setPremium(bool v) async {
    await _prefs.setBool('is_premium', v);
    state = state.copyWith(isPremium: v);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsNotifier(prefs);
});

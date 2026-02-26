import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'shared_preferences_provider.dart';

// ── Notifier ──────────────────────────────────────────────────────────────────

class UserNameNotifier extends StateNotifier<String> {
  UserNameNotifier(this._prefs)
      : super(_prefs.getString('user_name') ?? '');

  final SharedPreferences _prefs;

  void setName(String name) {
    _prefs.setString('user_name', name);
    state = name;
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final userNameProvider =
    StateNotifierProvider<UserNameNotifier, String>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return UserNameNotifier(prefs);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'shared_preferences_provider.dart';

enum Persona { nino, adulto, abuelo }

extension PersonaExtension on Persona {
  /// True when the learner is a senior — triggers larger typography.
  bool get isSeniorMode => this == Persona.abuelo;

  String get displayName {
    switch (this) {
      case Persona.nino:
        return 'Niño';
      case Persona.adulto:
        return 'Adulto';
      case Persona.abuelo:
        return 'Abuelo';
    }
  }
}

class PersonaNotifier extends StateNotifier<Persona?> {
  PersonaNotifier(this._prefs, Persona? initial) : super(initial);

  final SharedPreferences _prefs;

  void setPersona(Persona persona) {
    _prefs.setString('persona', persona.name);
    state = persona;
  }
}

Persona? _personaFromPrefs(SharedPreferences prefs) {
  final saved = prefs.getString('persona');
  if (saved == null) return null;
  try {
    return Persona.values.byName(saved);
  } catch (_) {
    return null;
  }
}

final personaProvider =
    StateNotifierProvider<PersonaNotifier, Persona?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return PersonaNotifier(prefs, _personaFromPrefs(prefs));
});

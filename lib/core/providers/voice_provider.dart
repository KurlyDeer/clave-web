import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/audio_service.dart';
import 'shared_preferences_provider.dart';

class VoiceNotifier extends StateNotifier<TtsVoice> {
  VoiceNotifier(SharedPreferences prefs)
      : _prefs = prefs,
        super(
          TtsVoice.values.firstWhere(
            (v) => v.name == prefs.getString('preferred_voice'),
            orElse: () => TtsVoice.alloy,
          ),
        );

  final SharedPreferences _prefs;

  Future<void> setVoice(TtsVoice voice) async {
    state = voice;
    await _prefs.setString('preferred_voice', voice.name);
  }
}

final voiceProvider = StateNotifierProvider<VoiceNotifier, TtsVoice>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return VoiceNotifier(prefs);
});

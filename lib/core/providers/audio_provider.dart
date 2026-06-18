import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/audio_service.dart';
import 'settings_provider.dart';
import 'voice_provider.dart';

// ── Audio service ─────────────────────────────────────────────────────────────

/// Single shared AudioService instance.
/// Voice changes are applied via ref.listen (no rebuild/dispose mid-playback).
final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();

  // Set initial voice from persisted preference.
  service.setVoice(ref.read(voiceProvider));

  // Keep voice in sync without causing a provider rebuild.
  ref.listen<TtsVoice>(voiceProvider, (_, voice) {
    service.setVoice(voice);
  });

  // Keep audio enabled state in sync with settings.
  final settings = ref.read(settingsProvider);
  AudioService.setEnabled(settings.isAudioEnabled);
  ref.listen<SettingsState>(settingsProvider, (_, s) {
    AudioService.setEnabled(s.isAudioEnabled);
  });

  ref.onDispose(service.dispose);
  return service;
});

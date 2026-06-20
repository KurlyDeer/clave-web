import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

import '../config/api_config.dart';
import 'audio_service_native.dart'
    if (dart.library.html) 'audio_service_web.dart' as platform;

enum TtsVoice { alloy, nova }

extension TtsVoiceExt on TtsVoice {
  String get apiName => name; // 'alloy' or 'nova'
  String get displayEs => switch (this) {
        TtsVoice.alloy => 'Profesor',
        TtsVoice.nova => 'Profesora',
      };
}

/// Cloud TTS service using OpenAI audio API with just_audio playback.
/// Caches downloaded mp3 files in the OS temp directory.
/// TTS failures are caught silently so they never block the learning flow.
class AudioService {
  AudioService();

  static bool _enabled = true;

  /// Configures the iOS audio session for speech playback.
  /// Call once at app startup before runApp.
  static Future<void> init() async {
    await platform.initAudioSession();
  }

  /// Deactivates the audio session before STT starts so the mic has priority.
  static Future<void> deactivateForStt() async {
    await platform.deactivateAudioSession();
  }

  /// Re-activates the audio session after STT stops so TTS can play.
  static Future<void> activateForTts() async {
    await platform.activateAudioSession();
  }

  static void setEnabled(bool value) => _enabled = value;

  final AudioPlayer _player = AudioPlayer();
  TtsVoice _voice = TtsVoice.alloy;

  Stream<bool> get isPlayingStream => _player.playingStream;
  Stream<ProcessingState> get processingStateStream =>
      _player.processingStateStream;

  void setVoice(TtsVoice voice) => _voice = voice;

  /// Speaks [text] at [speed]× (default 1.0, slow = 0.7).
  /// Returns after playback finishes (just_audio play() is blocking).
  Future<void> speak(String text, {double speed = 1.0}) async {
    if (!_enabled) return;
    if (text.trim().isEmpty) return;
    try {
      await _player.stop();
      if (kIsWeb) {
        // On web, stream directly from API (no file caching).
        final uri = Uri.parse(ApiConfig.openAiTtsUrl);
        final response = await http
            .post(
              uri,
              headers: {
                'Authorization': 'Bearer ${ApiConfig.openAiApiKey}',
                'Content-Type': 'application/json',
              },
              body: jsonEncode({
                'model': ApiConfig.openAiTtsModel,
                'input': text,
                'voice': _voice.apiName,
              }),
            )
            .timeout(ApiConfig.ttsTimeout);
        if (response.statusCode == 200) {
          // Use a data URI for web playback.
          final b64 = base64Encode(response.bodyBytes);
          await _player.setUrl('data:audio/mpeg;base64,$b64');
        } else {
          throw Exception('TTS API error: ${response.statusCode}');
        }
      } else {
        // Native: cache to file for offline playback.
        final cacheFile = await platform.getCacheFile(text, _voice.apiName);
        if (!await platform.fileExists(cacheFile)) {
          await _downloadTts(text, _voice, cacheFile);
        }
        await _player.setFilePath(cacheFile);
      }
      await _player.setSpeed(speed);
      await _player.play();
    } catch (e) {
      debugPrint('[AudioService] speak error: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}
  }

  void dispose() {
    _player.dispose();
  }

  // ── Download (native only) ────────────────────────────────────────────────

  Future<void> _downloadTts(
    String text,
    TtsVoice voice,
    String targetPath,
  ) async {
    final response = await http
        .post(
          Uri.parse(ApiConfig.openAiTtsUrl),
          headers: {
            'Authorization': 'Bearer ${ApiConfig.openAiApiKey}',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': ApiConfig.openAiTtsModel,
            'input': text,
            'voice': voice.apiName,
          }),
        )
        .timeout(ApiConfig.ttsTimeout);

    if (response.statusCode == 200) {
      await platform.writeBytes(targetPath, response.bodyBytes);
    } else {
      throw Exception('TTS API error: ${response.statusCode}');
    }
  }
}

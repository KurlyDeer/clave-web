import 'dart:convert';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import '../config/api_config.dart';

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
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.speech());
    } catch (e) {
      debugPrint('[AudioService] AudioSession init failed: $e');
    }
  }

  /// Deactivates the audio session before STT starts so the mic has priority.
  static Future<void> deactivateForStt() async {
    try {
      final session = await AudioSession.instance;
      await session.setActive(false);
    } catch (e) {
      debugPrint('[AudioService] deactivateForStt error: $e');
    }
  }

  /// Re-activates the audio session after STT stops so TTS can play.
  static Future<void> activateForTts() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.speech());
      await session.setActive(true);
    } catch (e) {
      debugPrint('[AudioService] activateForTts error: $e');
    }
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
      final cacheFile = await _getCacheFile(text, _voice);
      if (!cacheFile.existsSync()) {
        await _downloadTts(text, _voice, cacheFile);
      }
      await _player.setFilePath(cacheFile.path);
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

  // ── Cache ─────────────────────────────────────────────────────────────────

  Future<File> _getCacheFile(String text, TtsVoice voice) async {
    final dir = await getTemporaryDirectory();
    final key = _cacheKey(text, voice);
    return File('${dir.path}/tts_$key.mp3');
  }

  /// Stable hash from (text, voice) pair used as the cache filename.
  String _cacheKey(String text, TtsVoice voice) {
    final combined = '${voice.apiName}|$text';
    var hash = 5381;
    for (final c in combined.codeUnits) {
      hash = ((hash << 5) + hash + c) & 0x7FFFFFFF;
    }
    return hash.toRadixString(36);
  }

  // ── Download ──────────────────────────────────────────────────────────────

  Future<void> _downloadTts(
    String text,
    TtsVoice voice,
    File target,
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
      await target.writeAsBytes(response.bodyBytes);
    } else {
      throw Exception('TTS API error: ${response.statusCode}');
    }
  }
}

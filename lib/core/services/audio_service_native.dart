// Native (iOS/Android/macOS) implementation of platform-specific audio helpers.
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

Future<void> initAudioSession() async {
  try {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
  } catch (e) {
    debugPrint('[AudioService] AudioSession init failed: $e');
  }
}

Future<void> deactivateAudioSession() async {
  try {
    final session = await AudioSession.instance;
    await session.setActive(false);
  } catch (e) {
    debugPrint('[AudioService] deactivateForStt error: $e');
  }
}

Future<void> activateAudioSession() async {
  try {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    await session.setActive(true);
  } catch (e) {
    debugPrint('[AudioService] activateForTts error: $e');
  }
}

/// Returns the full path to the cached TTS file for [text] + [voiceName].
Future<String> getCacheFile(String text, String voiceName) async {
  final dir = await getTemporaryDirectory();
  final key = _cacheKey(text, voiceName);
  return '${dir.path}/tts_$key.mp3';
}

/// Returns true if the file at [path] exists.
Future<bool> fileExists(String path) async {
  return File(path).existsSync();
}

/// Writes [bytes] to the file at [path].
Future<void> writeBytes(String path, List<int> bytes) async {
  await File(path).writeAsBytes(bytes);
}

/// Stable hash from (text, voice) pair used as the cache filename.
String _cacheKey(String text, String voiceName) {
  final combined = '$voiceName|$text';
  var hash = 5381;
  for (final c in combined.codeUnits) {
    hash = ((hash << 5) + hash + c) & 0x7FFFFFFF;
  }
  return hash.toRadixString(36);
}

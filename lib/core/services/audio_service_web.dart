// Web implementation of platform-specific audio helpers.
// AudioSession and file-system caching are not available on web,
// so these are no-ops. TTS playback on web is handled via data URIs
// directly in AudioService.speak().

Future<void> initAudioSession() async {
  // No-op on web.
}

Future<void> deactivateAudioSession() async {
  // No-op on web.
}

Future<void> activateAudioSession() async {
  // No-op on web.
}

Future<String> getCacheFile(String text, String voiceName) async {
  // Should never be called on web (speak() uses data URIs instead).
  throw UnsupportedError('File caching is not supported on web.');
}

Future<bool> fileExists(String path) async {
  // Should never be called on web.
  return false;
}

Future<void> writeBytes(String path, List<int> bytes) async {
  // Should never be called on web.
  throw UnsupportedError('File writing is not supported on web.');
}

import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  TtsService() {
    _init();
  }

  final FlutterTts _tts = FlutterTts();

  Future<void> _init() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  /// Stops any current speech then speaks [text] in en-US.
  Future<void> speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  /// Stops speech immediately.
  Future<void> stop() async {
    await _tts.stop();
  }

  void dispose() {
    _tts.stop();
  }
}

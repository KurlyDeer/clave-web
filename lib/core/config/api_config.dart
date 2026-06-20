import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API configuration for Claude.
/// TODO: Move API key server-side before release — never ship secrets in client code.
class ApiConfig {
  ApiConfig._();

  // TODO: Move to server-side proxy before release.
  static String get apiKey => dotenv.env['ANTHROPIC_API_KEY'] ?? '';

  static const String model = 'claude-3-5-sonnet-20241022';
  static const String baseUrl = 'https://api.anthropic.com/v1/messages';
  static const String anthropicVersion = '2023-06-01';
  static const Duration timeout = Duration(seconds: 30);

  // ── OpenAI TTS ─────────────────────────────────────────────────────────────
  // TODO: Move to server-side proxy before release.
  static String get openAiApiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  static const String openAiTtsUrl = 'https://api.openai.com/v1/audio/speech';
  static const String openAiTtsModel = 'tts-1';
  static const Duration ttsTimeout = Duration(seconds: 15);

  static String get rcApiKeyIos => dotenv.env['REVENUECAT_IOS_KEY'] ?? '';
  static String get rcApiKeyAndroid => dotenv.env['REVENUECAT_ANDROID_KEY'] ?? '';
}

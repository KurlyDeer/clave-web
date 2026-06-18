/// API configuration for Claude.
/// TODO: Move API key server-side before release — never ship secrets in client code.
class ApiConfig {
  ApiConfig._();

  // TODO: Move to server-side proxy before release.
  static const String apiKey = 'YOUR_API_KEY_HERE';

  static const String model = 'claude-3-5-sonnet-20241022';
  static const String baseUrl = 'https://api.anthropic.com/v1/messages';
  static const String anthropicVersion = '2023-06-01';
  static const Duration timeout = Duration(seconds: 30);

  // ── OpenAI TTS ─────────────────────────────────────────────────────────────
  // TODO: Move to server-side proxy before release.
  static const String openAiApiKey = 'YOUR_OPENAI_API_KEY_HERE';
  static const String openAiTtsUrl = 'https://api.openai.com/v1/audio/speech';
  static const String openAiTtsModel = 'tts-1';
  static const Duration ttsTimeout = Duration(seconds: 15);

  static const String rcApiKeyIos     = 'REVENUECAT_IOS_KEY';
  static const String rcApiKeyAndroid = 'REVENUECAT_ANDROID_KEY';
}

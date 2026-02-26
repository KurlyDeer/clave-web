import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class ClaudeApiException implements Exception {
  ClaudeApiException(this.message);
  final String message;

  @override
  String toString() => 'ClaudeApiException: $message';
}

class ClaudeService {
  /// Sends a request to Claude and returns the first content text block.
  Future<String> complete({
    required String systemPrompt,
    required String userMessage,
    int maxTokens = 1024,
  }) async {
    final uri = Uri.parse(ApiConfig.baseUrl);
    final body = jsonEncode({
      'model': ApiConfig.model,
      'max_tokens': maxTokens,
      'system': systemPrompt,
      'messages': [
        {'role': 'user', 'content': userMessage},
      ],
    });

    late http.Response response;
    try {
      response = await http
          .post(
            uri,
            headers: {
              'x-api-key': ApiConfig.apiKey,
              'anthropic-version': ApiConfig.anthropicVersion,
              'content-type': 'application/json',
            },
            body: body,
          )
          .timeout(ApiConfig.timeout);
    } catch (e) {
      throw ClaudeApiException('Network error: $e');
    }

    if (response.statusCode != 200) {
      throw ClaudeApiException(
        'HTTP ${response.statusCode}: ${response.body}',
      );
    }

    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final content = json['content'] as List<dynamic>;
      final firstBlock = content.first as Map<String, dynamic>;
      return firstBlock['text'] as String;
    } catch (e) {
      throw ClaudeApiException('Parse error: $e');
    }
  }
}

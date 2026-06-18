import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../services/audio_service.dart';
import '../services/claude_service.dart';
import '../services/connectivity_service.dart';
import '../services/tutor_service.dart';
import '../../l10n/app_strings.dart';
import 'connectivity_provider.dart';
import 'persona_provider.dart';

// ── Models ────────────────────────────────────────────────────────────────────

class CompaneroMessage {
  const CompaneroMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
  });

  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;
}

enum CompaneroStatus { idle, recording, loading, error }

class CompaneroState {
  const CompaneroState({
    this.messages = const [],
    this.status = CompaneroStatus.idle,
    this.errorMessage = '',
    this.userTranscription = '',
    this.failedMessageText = '',
  });

  final List<CompaneroMessage> messages;
  final CompaneroStatus status;
  final String errorMessage;

  /// Live STT text shown while the mic is active.
  final String userTranscription;

  /// The last message that failed to send — used by [retryLastMessage].
  final String failedMessageText;

  CompaneroState copyWith({
    List<CompaneroMessage>? messages,
    CompaneroStatus? status,
    String? errorMessage,
    String? userTranscription,
    String? failedMessageText,
  }) {
    return CompaneroState(
      messages: messages ?? this.messages,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      userTranscription: userTranscription ?? this.userTranscription,
      failedMessageText: failedMessageText ?? this.failedMessageText,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class CompaneroNotifier extends StateNotifier<CompaneroState> {
  CompaneroNotifier({
    required this.personaKey,
    required TutorService tutorService,
    required ConnectivityService connectivity,
  })  : _tutorService = tutorService,
        _connectivity = connectivity,
        super(const CompaneroState()) {
    _addGreeting();
  }

  final String personaKey;
  final TutorService _tutorService;
  final ConnectivityService _connectivity;
  final _stt = SpeechToText();
  bool _sttReady = false;

  // ── Greeting ────────────────────────────────────────────────────────────────

  void _addGreeting() {
    const greetings = {
      'nino':
          '¡Hola! Soy Mi Compañero, tu amigo del inglés. 🌟 ¿Qué quieres platicar hoy?',
      'adulto':
          '¡Hola! Soy Mi Compañero, aquí para practicar inglés contigo. 😊 ¿De qué quieres hablar?',
      'abuelo':
          '¡Buenas! Soy Mi Compañero, tu ayudante de inglés. ⭐ ¿Qué quieres practicar hoy?',
    };
    final greeting = greetings[personaKey] ?? greetings['adulto']!;
    state = state.copyWith(messages: [
      CompaneroMessage(
          text: greeting, isUser: false, timestamp: DateTime.now()),
    ]);
  }

  // ── Text message ─────────────────────────────────────────────────────────────

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final userMsg = CompaneroMessage(
        text: trimmed, isUser: true, timestamp: DateTime.now());
    final allMessages = [...state.messages, userMsg];

    state = state.copyWith(
      messages: allMessages,
      status: CompaneroStatus.loading,
      errorMessage: '',
      userTranscription: '',
    );

    final online = await _connectivity.isOnline();
    if (!online) {
      state = state.copyWith(
        messages: [
          ...allMessages,
          CompaneroMessage(
            text: AppStrings.companeroConnectionErrorEs,
            isUser: false,
            timestamp: DateTime.now(),
            isError: true,
          ),
        ],
        status: CompaneroStatus.idle,
        failedMessageText: trimmed,
      );
      return;
    }

    try {
      // Pass the entire conversation history so the AI has full context.
      final historyStr = allMessages
          .map((m) => '${m.isUser ? "User" : "Mi Compañero"}: ${m.text}')
          .join('\n');

      final response = await _tutorService.chat(historyStr);

      final aiMsg = CompaneroMessage(
          text: response.trim(), isUser: false, timestamp: DateTime.now());
      state = state.copyWith(
        messages: [...allMessages, aiMsg],
        status: CompaneroStatus.idle,
      );
    } catch (e) {
      final detail = e is ClaudeApiException ? e.message : e.toString();
      debugPrint('⚠️ CompaneroError: $detail');
      state = state.copyWith(
        messages: [
          ...allMessages,
          CompaneroMessage(
            text: AppStrings.companeroConnectionErrorEs,
            isUser: false,
            timestamp: DateTime.now(),
            isError: true,
          ),
        ],
        status: CompaneroStatus.idle,
        failedMessageText: trimmed,
      );
    }
  }

  /// Removes the last error bubble (and its preceding user message if present),
  /// then re-sends the failed message.
  Future<void> retryLastMessage() async {
    final text = state.failedMessageText;
    if (text.isEmpty) return;

    final msgs = [...state.messages];
    if (msgs.isNotEmpty && msgs.last.isError) msgs.removeLast();
    if (msgs.isNotEmpty && msgs.last.isUser) msgs.removeLast();

    state = state.copyWith(messages: msgs, failedMessageText: '');
    await sendMessage(text);
  }

  // ── Voice input ───────────────────────────────────────────────────────────────

  Future<void> startVoice() async {
    if (!_sttReady) {
      _sttReady = await _stt.initialize(
        onError: (_) {
          state = state.copyWith(
            status: CompaneroStatus.idle,
            errorMessage: AppStrings.sttErrorEs,
          );
        },
        onStatus: (_) {},
      );
    }
    if (!_sttReady) {
      state = state.copyWith(errorMessage: AppStrings.sttMicDeniedEs);
      return;
    }

    state = state.copyWith(
      status: CompaneroStatus.recording,
      userTranscription: '',
      errorMessage: '',
    );

    await AudioService.deactivateForStt();
    await _stt.listen(
      localeId: 'en_US',
      listenFor: const Duration(seconds: 60),
      pauseFor: const Duration(seconds: 4),
      onResult: (result) {
        state = state.copyWith(userTranscription: result.recognizedWords);
      },
    );
  }

  Future<void> stopVoiceAndSend() async {
    await _stt.stop();
    await AudioService.activateForTts();
    final spoken = state.userTranscription.trim();
    if (spoken.isNotEmpty) {
      await sendMessage(spoken);
    } else {
      state = state.copyWith(
          status: CompaneroStatus.idle, userTranscription: '');
    }
  }

  // ── Utilities ─────────────────────────────────────────────────────────────────

  void clearError() {
    state = state.copyWith(status: CompaneroStatus.idle, errorMessage: '');
  }

  @override
  void dispose() {
    _stt.cancel();
    super.dispose();
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final companeroProvider =
    StateNotifierProvider.autoDispose<CompaneroNotifier, CompaneroState>((ref) {
  final persona = ref.watch(personaProvider);
  final personaKey = persona?.name ?? 'adulto';
  return CompaneroNotifier(
    personaKey: personaKey,
    tutorService: ref.read(tutorServiceProvider),
    connectivity: ref.watch(connectivityServiceProvider),
  );
});

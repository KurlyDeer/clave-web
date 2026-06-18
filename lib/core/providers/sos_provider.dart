import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../services/audio_service.dart';
import '../services/claude_service.dart';
import '../services/connectivity_service.dart';
import '../../l10n/app_strings.dart';
import 'audio_provider.dart';
import 'connectivity_provider.dart';
import 'gamification_controller.dart';
import 'vocab_provider.dart';

// ── Data models ──────────────────────────────────────────────────────────────

class TranslationOption {
  const TranslationOption({
    required this.tone,
    required this.toneEs,
    required this.text,
  });

  final String tone;
  final String toneEs;
  final String text;
}

enum SosStatus { idle, recording, loading, success, offlineError, apiError }

class SosState {
  const SosState({
    this.status = SosStatus.idle,
    this.spokenText = '',
    this.options = const [],
    this.errorMessage = '',
    this.selectedToneIndex = 0,
  });

  final SosStatus status;
  final String spokenText;
  final List<TranslationOption> options;
  final String errorMessage;
  final int selectedToneIndex;

  SosState copyWith({
    SosStatus? status,
    String? spokenText,
    List<TranslationOption>? options,
    String? errorMessage,
    int? selectedToneIndex,
  }) {
    return SosState(
      status: status ?? this.status,
      spokenText: spokenText ?? this.spokenText,
      options: options ?? this.options,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedToneIndex: selectedToneIndex ?? this.selectedToneIndex,
    );
  }
}

// ── System prompt ─────────────────────────────────────────────────────────────

const _sosSystemPrompt = '''
You are a real-time bilingual translator. Translate the given Spanish text into natural, native-sounding American English. You must return ONLY a JSON object containing three string variations: formal, friendly, and urgent.

No markdown, no preamble, no text outside the JSON object:
{"formal":"…","friendly":"…","urgent":"…"}

formal   = polished language for doctors, bosses, and authorities
friendly = natural, relaxed language for friends and neighbors
urgent   = maximum 8 words, direct phrasing for emergencies

Regional Spanish knowledge — understand these before translating:
- chamba/jale/laburo = work     - guagua = bus (Caribbean) or baby (Chile/Ecuador)
- pana/cuate/parcero = friend   - chévere/bacano/chido = cool
- plata/lana/billete = money    - ahorita = right now (context-dependent)
''';

// ── Notifier ──────────────────────────────────────────────────────────────────

class SosNotifier extends StateNotifier<SosState> {
  SosNotifier({
    required ConnectivityService connectivity,
    required AudioService tts,
    required Ref ref,
  })  : _connectivity = connectivity,
        _tts = tts,
        _ref = ref,
        super(const SosState());

  final ConnectivityService _connectivity;
  final AudioService _tts;
  final Ref _ref;
  final _claude = ClaudeService();
  final _stt = SpeechToText();

  bool _sttAvailable = false;

  Future<void> _initStt() async {
    if (!_sttAvailable) {
      _sttAvailable = await _stt.initialize(
        onError: (_) {
          state = state.copyWith(
            status: SosStatus.idle,
            errorMessage: AppStrings.sttErrorEs,
          );
        },
        onStatus: (_) {},
      );
    }
  }

  Future<void> startRecording() async {
    await _initStt();
    if (!_sttAvailable) {
      state = state.copyWith(errorMessage: AppStrings.sttMicDeniedEs);
      return;
    }

    state = state.copyWith(
      status: SosStatus.recording,
      spokenText: '',
      options: [],
      errorMessage: '',
    );

    await AudioService.deactivateForStt();
    await _stt.listen(
      localeId: 'es_US',
      listenFor: const Duration(seconds: 60),
      pauseFor: const Duration(seconds: 5),
      onResult: (result) {
        state = state.copyWith(spokenText: result.recognizedWords);
      },
    );
  }

  Future<void> stopRecordingAndTranslate() async {
    await _stt.stop();
    await AudioService.activateForTts();

    final spoken = state.spokenText.trim();
    if (spoken.isEmpty) {
      state = state.copyWith(status: SosStatus.idle);
      return;
    }

    final online = await _connectivity.isOnline();
    if (!online) {
      state = state.copyWith(status: SosStatus.offlineError);
      return;
    }

    state = state.copyWith(status: SosStatus.loading);

    try {
      final raw = await _claude.complete(
        systemPrompt: _sosSystemPrompt,
        userMessage: spoken,
        maxTokens: 512,
      );

      final options = _parseOptions(raw);
      state = state.copyWith(status: SosStatus.success, options: options);
      // Award XP and record streak for a successful translation
      _ref.read(gamificationProvider.notifier).addXp(5);
      _ref.read(gamificationProvider.notifier).recordPractice();
      // Auto-save phrase pair to vocabulary
      final formalEn =
          options.isNotEmpty ? options.first.text.trim() : '';
      if (formalEn.isNotEmpty) {
        await _ref.read(vocabProvider.notifier).addWord(
              wordEn: formalEn,
              wordEs: spoken,
              source: 'sos',
            );
      }
    } catch (_) {
      state = state.copyWith(
        status: SosStatus.apiError,
        errorMessage: 'Error al conectar con el servicio de traducción.',
      );
    }
  }

  void selectTone(int index) {
    state = state.copyWith(selectedToneIndex: index);
  }

  Future<void> translateText(String spanishText) async {
    final trimmed = spanishText.trim();
    if (trimmed.isEmpty) return;

    final online = await _connectivity.isOnline();
    if (!online) {
      state = state.copyWith(
        status: SosStatus.offlineError,
        spokenText: trimmed,
      );
      return;
    }

    state = state.copyWith(
      status: SosStatus.loading,
      spokenText: trimmed,
      options: [],
      errorMessage: '',
    );

    try {
      final raw = await _claude.complete(
        systemPrompt: _sosSystemPrompt,
        userMessage: trimmed,
        maxTokens: 512,
      );

      final options = _parseOptions(raw);
      state = state.copyWith(status: SosStatus.success, options: options);
      _ref.read(gamificationProvider.notifier).addXp(5);
      _ref.read(gamificationProvider.notifier).recordPractice();
      final formalEn = options.isNotEmpty ? options.first.text.trim() : '';
      if (formalEn.isNotEmpty) {
        await _ref.read(vocabProvider.notifier).addWord(
              wordEn: formalEn,
              wordEs: trimmed,
              source: 'sos',
            );
      }
    } catch (_) {
      state = state.copyWith(
        status: SosStatus.apiError,
        errorMessage: 'Error al conectar con el servicio de traducción.',
      );
    }
  }

  Future<void> speakOption(TranslationOption option) async {
    await _tts.speak(option.text);
  }

  void reset() {
    _stt.stop();
    state = const SosState();
  }

  List<TranslationOption> _parseOptions(String raw) {
    try {
      // Extract the JSON object, stripping any preamble/postamble.
      final start = raw.indexOf('{');
      final end = raw.lastIndexOf('}');
      if (start == -1 || end == -1 || end <= start) {
        return [TranslationOption(tone: 'General', toneEs: 'General', text: raw)];
      }
      final json = jsonDecode(raw.substring(start, end + 1)) as Map<String, dynamic>;
      return [
        TranslationOption(
          tone: 'Formal',
          toneEs: 'Formal',
          text: json['formal'] as String? ?? '',
        ),
        TranslationOption(
          tone: 'Amistoso',
          toneEs: 'Amistoso',
          text: json['friendly'] as String? ?? '',
        ),
        TranslationOption(
          tone: 'Urgente',
          toneEs: 'Urgente',
          text: json['urgent'] as String? ?? '',
        ),
      ];
    } catch (_) {
      // Fallback: wrap raw text as single option.
      return [
        TranslationOption(tone: 'General', toneEs: 'General', text: raw),
      ];
    }
  }

  @override
  void dispose() {
    _stt.cancel();
    super.dispose();
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final sosProvider =
    StateNotifierProvider.autoDispose<SosNotifier, SosState>((ref) {
  return SosNotifier(
    connectivity: ref.watch(connectivityServiceProvider),
    tts: ref.read(audioServiceProvider),
    ref: ref,
  );
});

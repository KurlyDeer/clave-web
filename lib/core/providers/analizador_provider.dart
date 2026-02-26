import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../data/analizador_data.dart';
import '../models/voice_analysis_model.dart';
import '../services/claude_service.dart';
import '../services/connectivity_service.dart';
import 'connectivity_provider.dart';
import 'streak_provider.dart';
import 'xp_provider.dart';

// ── Status ────────────────────────────────────────────────────────────────────

enum AnalizadorStatus {
  idle,
  listening,
  analyzing,
  result,
  abueloResult,
  offlineError,
  error,
}

// ── State ─────────────────────────────────────────────────────────────────────

class AnalizadorState {
  const AnalizadorState({
    this.status = AnalizadorStatus.idle,
    this.sentenceIndex = 0,
    this.transcript = '',
    this.analysisResult,
    this.abueloThumbsUp,
    this.errorMessage = '',
  });

  final AnalizadorStatus status;
  final int sentenceIndex;
  final String transcript;
  final VoiceAnalysisResult? analysisResult;
  final bool? abueloThumbsUp; // null = not yet evaluated
  final String errorMessage;

  PracticeSentence get currentSentence =>
      AnalizadorData.sentences[sentenceIndex % AnalizadorData.sentences.length];

  int get totalSentences => AnalizadorData.sentences.length;

  AnalizadorState copyWith({
    AnalizadorStatus? status,
    String? transcript,
    String? errorMessage,
  }) {
    return AnalizadorState(
      status: status ?? this.status,
      sentenceIndex: sentenceIndex,
      transcript: transcript ?? this.transcript,
      analysisResult: analysisResult,
      abueloThumbsUp: abueloThumbsUp,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// ── Claude prompt ─────────────────────────────────────────────────────────────

const _systemPrompt = '''
Eres un coach de pronunciación para hispanohablantes que aprenden inglés.
Se te da la oración objetivo y lo que reconoció el sistema de voz.
Responde SOLO con JSON válido (sin markdown, sin texto extra):
{"words":[{"word":"string","status":"perfect|heavy|missed"}],"tip_es":"Un consejo corto en español.","score":0}

status: perfect=pronunciado claramente, heavy=acento fuerte pero comprensible, missed=incorrecto u omitido.
El consejo (tip_es) debe mencionar el error más importante para hispanohablantes.
Enfócate en: sonido "th", "v"≠"b", vocal corta "i" (ship/sheep), "w", "sh", consonantes finales.
El consejo debe empezar con: 'Para la palabra "X",...'
''';

// ── Notifier ──────────────────────────────────────────────────────────────────

class AnalizadorNotifier extends StateNotifier<AnalizadorState> {
  AnalizadorNotifier({
    required ConnectivityService connectivity,
    required Ref ref,
  })  : _connectivity = connectivity,
        _ref = ref,
        super(const AnalizadorState());

  final ConnectivityService _connectivity;
  final Ref _ref;
  final _claude = ClaudeService();
  final _stt = SpeechToText();
  bool _sttAvailable = false;

  Future<void> _ensureStt() async {
    if (!_sttAvailable) {
      _sttAvailable = await _stt.initialize(
        onError: (_) {},
        onStatus: (_) {},
      );
    }
  }

  /// Starts STT recording; calls [onSoundLevel] on each mic level update
  /// so the screen can animate its waveform without coupling to provider state.
  Future<void> startListening({
    required ValueChanged<double> onSoundLevel,
  }) async {
    await _ensureStt();
    if (!_sttAvailable) return;

    state = AnalizadorState(
      sentenceIndex: state.sentenceIndex,
      status: AnalizadorStatus.listening,
    );

    await _stt.listen(
      localeId: 'en_US',
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 4),
      onResult: (result) =>
          state = state.copyWith(transcript: result.recognizedWords),
      onSoundLevelChange: onSoundLevel,
    );
  }

  /// Stops recording and runs analysis. Passes [isAbuelo] to choose code path.
  Future<void> stopAndAnalyze({required bool isAbuelo}) async {
    await _stt.stop();
    final spoken = state.transcript.trim();

    if (spoken.isEmpty) {
      state = AnalizadorState(sentenceIndex: state.sentenceIndex);
      return;
    }

    if (isAbuelo) {
      _runAbueloAnalysis(spoken);
      return;
    }

    await _runClaudeAnalysis(spoken);
  }

  // ── Abuelo mode: simple word-overlap scoring ─────────────────────────────

  void _runAbueloAnalysis(String spoken) {
    final target = state.currentSentence.en;
    final targetWords = _tokenize(target);
    final spokenWords = _tokenize(spoken);
    final overlap =
        targetWords.where((w) => spokenWords.contains(w)).length;
    final ratio = targetWords.isEmpty ? 0.0 : overlap / targetWords.length;
    final thumbsUp = ratio >= 0.6;

    state = AnalizadorState(
      sentenceIndex: state.sentenceIndex,
      status: AnalizadorStatus.abueloResult,
      transcript: spoken,
      abueloThumbsUp: thumbsUp,
    );

    if (thumbsUp) {
      _ref.read(xpProvider.notifier).addXp(5);
      _ref.read(streakProvider.notifier).recordPractice();
    }
  }

  // ── Claude phonetic analysis ──────────────────────────────────────────────

  Future<void> _runClaudeAnalysis(String spoken) async {
    final online = await _connectivity.isOnline();
    if (!online) {
      state = AnalizadorState(
        sentenceIndex: state.sentenceIndex,
        status: AnalizadorStatus.offlineError,
      );
      return;
    }

    state = state.copyWith(
      status: AnalizadorStatus.analyzing,
      transcript: spoken,
    );

    final target = state.currentSentence.en;

    try {
      final raw = await _claude.complete(
        systemPrompt: _systemPrompt,
        userMessage: 'Objetivo: "$target"\nReconocido: "$spoken"',
        maxTokens: 400,
      );

      final targetWords = _tokenize(target);
      final result = _parseResult(raw, targetWords);

      state = AnalizadorState(
        sentenceIndex: state.sentenceIndex,
        status: AnalizadorStatus.result,
        transcript: spoken,
        analysisResult: result,
      );

      if (result.score >= 60) {
        _ref.read(xpProvider.notifier).addXp(10);
        _ref.read(streakProvider.notifier).recordPractice();
      }
    } catch (_) {
      state = AnalizadorState(
        sentenceIndex: state.sentenceIndex,
        status: AnalizadorStatus.error,
        transcript: spoken,
        errorMessage: 'Error al analizar. Intenta de nuevo.',
      );
    }
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  void nextSentence() {
    final next =
        (state.sentenceIndex + 1) % AnalizadorData.sentences.length;
    state = AnalizadorState(sentenceIndex: next);
  }

  void prevSentence() {
    final prev = (state.sentenceIndex - 1 + AnalizadorData.sentences.length) %
        AnalizadorData.sentences.length;
    state = AnalizadorState(sentenceIndex: prev);
  }

  void reset() {
    _stt.stop();
    state = AnalizadorState(sentenceIndex: state.sentenceIndex);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static List<String> _tokenize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r"[^a-z\s']"), '')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
  }

  VoiceAnalysisResult _parseResult(String raw, List<String> targetWords) {
    try {
      final cleaned = raw
          .replaceAll(RegExp(r'```json\s*'), '')
          .replaceAll(RegExp(r'```\s*'), '')
          .trim();
      final json = jsonDecode(cleaned) as Map<String, dynamic>;
      return VoiceAnalysisResult.fromJson(json, targetWords);
    } catch (_) {
      return VoiceAnalysisResult.fallback(targetWords);
    }
  }

  @override
  void dispose() {
    _stt.stop();
    super.dispose();
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final analizadorProvider =
    StateNotifierProvider.autoDispose<AnalizadorNotifier, AnalizadorState>(
  (ref) => AnalizadorNotifier(
    connectivity: ref.watch(connectivityServiceProvider),
    ref: ref,
  ),
);

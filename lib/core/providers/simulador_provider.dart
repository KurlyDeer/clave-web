import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../models/scenario_models.dart';
import '../services/claude_service.dart';
import '../services/connectivity_service.dart';
import 'connectivity_provider.dart';
import 'streak_provider.dart';
import 'xp_provider.dart';

// ── Status enum ───────────────────────────────────────────────────────────────

enum SimuladorStatus {
  loading,      // initial AI line loading
  aiSpeaking,   // TTS is playing AI line
  waitingForVoice, // ready for user to hold mic
  recording,    // STT active
  analyzing,    // Claude call in progress
  feedback,     // showing result of user turn
  complete,     // scenario finished
}

// ── State ─────────────────────────────────────────────────────────────────────

class SimuladorState {
  const SimuladorState({
    required this.scenario,
    this.status = SimuladorStatus.loading,
    this.turns = const [],
    this.currentAiLineEn = '',
    this.currentHintEs = '',
    this.userTranscription = '',
    this.feedbackEs = '',
    this.isAcceptable = true,
    this.turnCount = 0,
    this.isOfflineError = false,
    this.errorMessage = '',
  });

  final ScenarioData scenario;
  final SimuladorStatus status;
  final List<ScenarioTurn> turns;
  final String currentAiLineEn;
  final String currentHintEs;
  final String userTranscription;
  final String feedbackEs;
  final bool isAcceptable;
  final int turnCount;
  final bool isOfflineError;
  final String errorMessage;

  SimuladorState copyWith({
    SimuladorStatus? status,
    List<ScenarioTurn>? turns,
    String? currentAiLineEn,
    String? currentHintEs,
    String? userTranscription,
    String? feedbackEs,
    bool? isAcceptable,
    int? turnCount,
    bool? isOfflineError,
    String? errorMessage,
  }) {
    return SimuladorState(
      scenario: scenario,
      status: status ?? this.status,
      turns: turns ?? this.turns,
      currentAiLineEn: currentAiLineEn ?? this.currentAiLineEn,
      currentHintEs: currentHintEs ?? this.currentHintEs,
      userTranscription: userTranscription ?? this.userTranscription,
      feedbackEs: feedbackEs ?? this.feedbackEs,
      isAcceptable: isAcceptable ?? this.isAcceptable,
      turnCount: turnCount ?? this.turnCount,
      isOfflineError: isOfflineError ?? this.isOfflineError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// ── Claude response model ─────────────────────────────────────────────────────

class _ClaudeResponse {
  const _ClaudeResponse({
    required this.isAcceptable,
    required this.feedbackEs,
    required this.nextLineEn,
    required this.nextHintEs,
    required this.isComplete,
  });

  final bool isAcceptable;
  final String feedbackEs;
  final String nextLineEn;
  final String nextHintEs;
  final bool isComplete;
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class SimuladorNotifier extends StateNotifier<SimuladorState> {
  SimuladorNotifier({
    required ScenarioData scenario,
    required ConnectivityService connectivity,
    required Ref ref,
  })  : _connectivity = connectivity,
        _ref = ref,
        super(SimuladorState(scenario: scenario));

  final ConnectivityService _connectivity;
  final Ref _ref;
  final _claude = ClaudeService();
  final _stt = SpeechToText();
  bool _sttAvailable = false;

  // ── Startup ──────────────────────────────────────────────────────────────

  /// Called once when the screen loads — sets up the opening AI turn.
  void startScenario() {
    final s = state.scenario;
    final openingTurn = ScenarioTurn(
      speaker: TurnSpeaker.ai,
      textEn: s.openingLineEn,
      hintEs: s.openingHintEs,
    );
    state = state.copyWith(
      status: SimuladorStatus.aiSpeaking,
      turns: [openingTurn],
      currentAiLineEn: s.openingLineEn,
      currentHintEs: s.openingHintEs,
      turnCount: 1,
    );
  }

  /// Called by the screen after TTS finishes speaking an AI line.
  void onAiSpeechComplete() {
    if (state.status == SimuladorStatus.aiSpeaking) {
      state = state.copyWith(status: SimuladorStatus.waitingForVoice);
    }
  }

  // ── Voice recording ───────────────────────────────────────────────────────

  Future<void> startRecording() async {
    if (!_sttAvailable) {
      _sttAvailable = await _stt.initialize(onError: (_) {}, onStatus: (_) {});
    }
    if (!_sttAvailable) return;

    state = state.copyWith(
      status: SimuladorStatus.recording,
      userTranscription: '',
      isOfflineError: false,
      errorMessage: '',
    );

    await _stt.listen(
      localeId: 'en_US',
      listenFor: const Duration(seconds: 60),
      pauseFor: const Duration(seconds: 5),
      onResult: (result) {
        state = state.copyWith(userTranscription: result.recognizedWords);
      },
    );
  }

  Future<void> stopRecordingAndAnalyze() async {
    await _stt.stop();
    final transcribed = state.userTranscription.trim();

    if (transcribed.isEmpty) {
      state = state.copyWith(
        status: SimuladorStatus.feedback,
        feedbackEs: 'No escuché nada. ¡Mantén el micrófono y habla en inglés!',
        isAcceptable: false,
      );
      return;
    }

    final online = await _connectivity.isOnline();
    if (!online) {
      state = state.copyWith(
        status: SimuladorStatus.waitingForVoice,
        isOfflineError: true,
      );
      return;
    }

    state = state.copyWith(status: SimuladorStatus.analyzing);

    try {
      // Build conversation history for Claude context
      final history = _buildHistory();
      final userMessage =
          '$history\n\nUser just said: "$transcribed"\n\nRespond ONLY with JSON.';

      final raw = await _claude.complete(
        systemPrompt: state.scenario.systemPrompt,
        userMessage: userMessage,
        maxTokens: 512,
      );

      final response = _parseResponse(raw);

      // Append user turn to history
      final userTurn = ScenarioTurn(
        speaker: TurnSpeaker.user,
        textEn: transcribed,
        feedbackEs: response.feedbackEs,
        isAcceptable: response.isAcceptable,
      );

      final newTurns = [...state.turns, userTurn];

      if (response.isComplete) {
        // Append final AI goodbye turn then complete
        final finalAiTurn = ScenarioTurn(
          speaker: TurnSpeaker.ai,
          textEn: response.nextLineEn,
          hintEs: '',
        );
        _awardCompletion();
        state = state.copyWith(
          status: SimuladorStatus.complete,
          turns: [...newTurns, finalAiTurn],
          feedbackEs: response.feedbackEs,
          isAcceptable: response.isAcceptable,
          currentAiLineEn: response.nextLineEn,
          currentHintEs: '',
        );
      } else {
        state = state.copyWith(
          status: SimuladorStatus.feedback,
          turns: newTurns,
          feedbackEs: response.feedbackEs,
          isAcceptable: response.isAcceptable,
          currentAiLineEn: response.nextLineEn,
          currentHintEs: response.nextHintEs,
          turnCount: state.turnCount + 1,
        );
      }
    } catch (_) {
      state = state.copyWith(
        status: SimuladorStatus.waitingForVoice,
        isOfflineError: false,
        errorMessage: 'Error al analizar tu respuesta. Intenta de nuevo.',
      );
    }
  }

  // ── After feedback — advance to next AI turn ──────────────────────────────

  /// Called when user taps "Continuar" after feedback or retries after error.
  void advanceToNextAiTurn() {
    if (state.status != SimuladorStatus.feedback) return;

    // Append the pending AI turn to history
    final aiTurn = ScenarioTurn(
      speaker: TurnSpeaker.ai,
      textEn: state.currentAiLineEn,
      hintEs: state.currentHintEs,
    );
    final newTurns = [...state.turns, aiTurn];

    state = state.copyWith(
      status: SimuladorStatus.aiSpeaking,
      turns: newTurns,
      userTranscription: '',
    );
  }

  void retryTurn() {
    state = state.copyWith(
      status: SimuladorStatus.waitingForVoice,
      userTranscription: '',
      errorMessage: '',
      isOfflineError: false,
    );
  }

  // ── Completion ────────────────────────────────────────────────────────────

  void _awardCompletion() {
    _ref.read(xpProvider.notifier).addXp(15);
    _ref.read(streakProvider.notifier).recordPractice();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _buildHistory() {
    final buffer = StringBuffer();
    buffer.writeln('Conversation so far:');
    for (final turn in state.turns) {
      final speaker = turn.speaker == TurnSpeaker.ai
          ? state.scenario.characterNameEn
          : 'Student';
      buffer.writeln('$speaker: ${turn.textEn}');
    }
    return buffer.toString();
  }

  _ClaudeResponse _parseResponse(String raw) {
    try {
      final cleaned = raw
          .replaceAll(RegExp(r'```json\s*'), '')
          .replaceAll(RegExp(r'```\s*'), '')
          .trim();
      final json = jsonDecode(cleaned) as Map<String, dynamic>;
      return _ClaudeResponse(
        isAcceptable: (json['is_acceptable'] as bool?) ?? true,
        feedbackEs: (json['feedback_es'] as String?) ?? '¡Bien hecho!',
        nextLineEn: (json['next_line_en'] as String?) ?? '',
        nextHintEs: (json['next_hint_es'] as String?) ?? '',
        isComplete: (json['is_complete'] as bool?) ?? false,
      );
    } catch (_) {
      return const _ClaudeResponse(
        isAcceptable: true,
        feedbackEs: '¡Buen intento! Sigue practicando.',
        nextLineEn: 'Thank you. Can you tell me more?',
        nextHintEs: 'Intenta responder la pregunta en inglés.',
        isComplete: false,
      );
    }
  }

  @override
  void dispose() {
    _stt.stop();
    super.dispose();
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final simuladorProvider = StateNotifierProvider.autoDispose
    .family<SimuladorNotifier, SimuladorState, ScenarioData>((ref, scenario) {
  return SimuladorNotifier(
    scenario: scenario,
    connectivity: ref.watch(connectivityServiceProvider),
    ref: ref,
  );
});

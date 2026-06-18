import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../models/lesson_models.dart';
import '../models/scenario_models.dart';
import '../services/audio_service.dart';
import '../services/connectivity_service.dart';
import '../services/simulator_service.dart';
import '../../l10n/app_strings.dart';
import 'connectivity_provider.dart';
import 'lesson_progress_provider.dart';

// ── Status enum ───────────────────────────────────────────────────────────────

enum SimuladorStatus {
  loading,         // initial AI line loading
  aiSpeaking,      // TTS is playing AI line
  waitingForVoice, // ready for user to tap mic
  recording,       // STT active
  analyzing,       // service call in progress
  feedback,        // showing result of user turn
  complete,        // scenario finished
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
    this.feedbackColor = 'green',
    this.turnCount = 0,
    this.isOfflineError = false,
    this.errorMessage = '',
    this.sttConfidence = 0.0,
    this.sttLowConfidence = false,
    this.failedAttempts = 0,
  });

  final ScenarioData scenario;
  final SimuladorStatus status;
  final List<ScenarioTurn> turns;
  final String currentAiLineEn;
  final String currentHintEs;
  final String userTranscription;
  final String feedbackEs;
  final String feedbackColor;
  final int turnCount;
  final bool isOfflineError;
  final String errorMessage;
  final double sttConfidence;
  final bool sttLowConfidence;
  final int failedAttempts;

  bool get isAcceptable => feedbackColor != 'red';
  bool get showHint => failedAttempts >= 3;

  SimuladorState copyWith({
    SimuladorStatus? status,
    List<ScenarioTurn>? turns,
    String? currentAiLineEn,
    String? currentHintEs,
    String? userTranscription,
    String? feedbackEs,
    String? feedbackColor,
    int? turnCount,
    bool? isOfflineError,
    String? errorMessage,
    double? sttConfidence,
    bool? sttLowConfidence,
    int? failedAttempts,
  }) {
    return SimuladorState(
      scenario: scenario,
      status: status ?? this.status,
      turns: turns ?? this.turns,
      currentAiLineEn: currentAiLineEn ?? this.currentAiLineEn,
      currentHintEs: currentHintEs ?? this.currentHintEs,
      userTranscription: userTranscription ?? this.userTranscription,
      feedbackEs: feedbackEs ?? this.feedbackEs,
      feedbackColor: feedbackColor ?? this.feedbackColor,
      turnCount: turnCount ?? this.turnCount,
      isOfflineError: isOfflineError ?? this.isOfflineError,
      errorMessage: errorMessage ?? this.errorMessage,
      sttConfidence: sttConfidence ?? this.sttConfidence,
      sttLowConfidence: sttLowConfidence ?? this.sttLowConfidence,
      failedAttempts: failedAttempts ?? this.failedAttempts,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class SimuladorNotifier extends StateNotifier<SimuladorState> {
  SimuladorNotifier({
    required ScenarioData scenario,
    required ConnectivityService connectivity,
    required SimulatorService service,
    required Ref ref,
  })  : _connectivity = connectivity,
        _service = service,
        _ref = ref,
        super(SimuladorState(scenario: scenario));

  final ConnectivityService _connectivity;
  final SimulatorService _service;
  final Ref _ref;
  final _stt = SpeechToText();
  bool _sttAvailable = false;

  // ── Startup ──────────────────────────────────────────────────────────────

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

  void onAiSpeechComplete() {
    if (state.status == SimuladorStatus.aiSpeaking) {
      state = state.copyWith(status: SimuladorStatus.waitingForVoice);
    }
  }

  // ── Voice recording ───────────────────────────────────────────────────────

  Future<void> startRecording() async {
    if (!_sttAvailable) {
      _sttAvailable = await _stt.initialize(
        onError: (_) {
          state = state.copyWith(
            status: SimuladorStatus.waitingForVoice,
            errorMessage: AppStrings.sttErrorEs,
          );
        },
        onStatus: (_) {},
      );
    }
    if (!_sttAvailable) {
      state = state.copyWith(errorMessage: AppStrings.sttMicDeniedEs);
      return;
    }

    state = state.copyWith(
      status: SimuladorStatus.recording,
      userTranscription: '',
      isOfflineError: false,
      errorMessage: '',
      sttConfidence: 0.0,
      sttLowConfidence: false,
    );

    await AudioService.deactivateForStt();
    await _stt.listen(
      localeId: 'en_US',
      listenFor: const Duration(seconds: 60),
      pauseFor: const Duration(seconds: 5),
      onResult: (result) {
        state = state.copyWith(
          userTranscription: result.recognizedWords,
          sttConfidence: result.finalResult
              ? result.confidence
              : state.sttConfidence,
        );
      },
    );
  }

  Future<void> stopRecordingAndAnalyze() async {
    await _stt.stop();
    await AudioService.activateForTts();
    final transcribed = state.userTranscription.trim();

    if (transcribed.isEmpty) {
      state = state.copyWith(
        status: SimuladorStatus.feedback,
        feedbackColor: 'red',
        feedbackEs: 'No escuché nada. ¡Toca el micrófono y habla en inglés!',
      );
      return;
    }

    if (state.sttConfidence > 0 && state.sttConfidence < 0.7) {
      state = state.copyWith(
        status: SimuladorStatus.waitingForVoice,
        sttLowConfidence: true,
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
      final response = await _service.evaluate(
        scenarioContext: state.scenario.systemPrompt,
        conversationHistory: _buildHistory(),
        userMessage: transcribed,
      );

      final userTurn = ScenarioTurn(
        speaker: TurnSpeaker.user,
        textEn: transcribed,
        feedbackColor: response.feedbackColor,
        isAcceptable: response.feedbackColor != 'red',
      );
      final newTurns = [...state.turns, userTurn];

      final newFailed = response.feedbackColor == 'green'
          ? 0
          : state.failedAttempts + 1;

      if (response.isConversationFinished) {
        final finalAiTurn = ScenarioTurn(
          speaker: TurnSpeaker.ai,
          textEn: response.aiSpokenReply,
        );
        _awardCompletion();
        state = state.copyWith(
          status: SimuladorStatus.complete,
          turns: [...newTurns, finalAiTurn],
          feedbackColor: response.feedbackColor,
          currentAiLineEn: response.aiSpokenReply,
          currentHintEs: response.hintEs,
          failedAttempts: 0,
        );
      } else {
        state = state.copyWith(
          status: SimuladorStatus.feedback,
          turns: newTurns,
          feedbackColor: response.feedbackColor,
          currentAiLineEn: response.aiSpokenReply,
          currentHintEs: response.hintEs,
          turnCount: state.turnCount + 1,
          failedAttempts: newFailed,
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

  void advanceToNextAiTurn() {
    if (state.status != SimuladorStatus.feedback) return;

    final aiTurn = ScenarioTurn(
      speaker: TurnSpeaker.ai,
      textEn: state.currentAiLineEn,
      hintEs: state.currentHintEs,
    );
    state = state.copyWith(
      status: SimuladorStatus.aiSpeaking,
      turns: [...state.turns, aiTurn],
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

  /// Skips the current user turn after repeated failures.
  /// Adds a "[Saltado]" user turn and repeats the AI's last line.
  void skipTurn() {
    const userSkipTurn = ScenarioTurn(
      speaker: TurnSpeaker.user,
      textEn: '[Saltado]',
      feedbackColor: 'amber',
    );
    final aiTurn = ScenarioTurn(
      speaker: TurnSpeaker.ai,
      textEn: state.currentAiLineEn,
      hintEs: state.currentHintEs,
    );
    state = state.copyWith(
      status: SimuladorStatus.aiSpeaking,
      turns: [...state.turns, userSkipTurn, aiTurn],
      userTranscription: '',
      failedAttempts: 0,
    );
  }

  // ── Completion ────────────────────────────────────────────────────────────

  void _awardCompletion() {
    // XP + recordPractice moved to ReportCardScreen (awarded on claim tap).

    // If launched from a PathLesson, mark that lesson complete in Hive.
    final lessonId = state.scenario.sourceLessonId;
    if (lessonId != null) {
      final box = _ref.read(lessonProgressBoxProvider);
      box.put(
        lessonId,
        const LessonProgress(completed: true, voiceScore: 0, feedbackEs: ''),
      );
      _ref.invalidate(lessonProgressProvider(lessonId));
      _ref.invalidate(completedLessonIdsProvider);
      _ref.invalidate(completedLessonCountProvider);
    }
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

  @override
  void dispose() {
    _stt.cancel();
    super.dispose();
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final simuladorProvider = StateNotifierProvider.autoDispose
    .family<SimuladorNotifier, SimuladorState, ScenarioData>((ref, scenario) {
  return SimuladorNotifier(
    scenario: scenario,
    connectivity: ref.watch(connectivityServiceProvider),
    service: ref.watch(simulatorServiceProvider),
    ref: ref,
  );
});

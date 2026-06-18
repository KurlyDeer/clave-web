import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../data/curriculum_structure.dart';
import '../models/lesson_models.dart';
import '../services/audio_service.dart';
import '../services/claude_service.dart';
import '../services/connectivity_service.dart';
import '../../l10n/app_strings.dart';
import 'connectivity_provider.dart';
import 'lesson_progress_provider.dart';
import 'persona_provider.dart';
import 'progress_provider.dart';
import 'gamification_controller.dart';

// ── Status enum ───────────────────────────────────────────────────────────────

enum LessonStatus {
  intro,
  slide,
  voiceChallenge,
  voiceRecording,
  voiceLoading,
  result,
  complete,
}

// ── State ─────────────────────────────────────────────────────────────────────

class LessonState {
  const LessonState({
    required this.lesson,
    required this.personaKey,
    this.status = LessonStatus.intro,
    this.slideIndex = 0,
    this.nextUnlocked = true, // intro always unlocked
    this.selectedAnswer,
    this.quizCorrect,
    this.voiceTranscription = '',
    this.voiceScore = 0,
    this.feedbackEs = '',
    this.stageAdvanced = false,
    this.isOfflineError = false,
    this.errorMessage = '',
    this.elapsedSeconds = 0,
    this.sttConfidence = 0.0,
    this.sttLowConfidence = false,
    this.grammarFlipOrder = const [],
    this.grammarFlipCorrect,
    this.libroPromptText = '',
  });

  final LessonData lesson;
  final String personaKey;
  final LessonStatus status;
  final int slideIndex;
  final bool nextUnlocked;
  final int? selectedAnswer;
  final bool? quizCorrect;
  final String voiceTranscription;
  final int voiceScore;
  final String feedbackEs;
  final bool stageAdvanced;
  final bool isOfflineError;
  final String errorMessage;
  final int elapsedSeconds;
  final double sttConfidence;
  final bool sttLowConfidence;
  final List<String> grammarFlipOrder;
  final bool? grammarFlipCorrect;
  final String libroPromptText;

  PersonaContent get content => lesson.forPersona(personaKey);
  List<LessonSlide> get slides => content.slides;
  int get totalSlides => slides.length;

  LessonState copyWith({
    LessonStatus? status,
    int? slideIndex,
    bool? nextUnlocked,
    int? selectedAnswer,
    bool? quizCorrect,
    String? voiceTranscription,
    int? voiceScore,
    String? feedbackEs,
    bool? stageAdvanced,
    bool? isOfflineError,
    String? errorMessage,
    int? elapsedSeconds,
    double? sttConfidence,
    bool? sttLowConfidence,
    List<String>? grammarFlipOrder,
    bool? grammarFlipCorrect,
    String? libroPromptText,
    bool resetGrammarFlip = false,
  }) {
    return LessonState(
      lesson: lesson,
      personaKey: personaKey,
      status: status ?? this.status,
      slideIndex: slideIndex ?? this.slideIndex,
      nextUnlocked: nextUnlocked ?? this.nextUnlocked,
      selectedAnswer: selectedAnswer ?? this.selectedAnswer,
      quizCorrect: quizCorrect ?? this.quizCorrect,
      voiceTranscription: voiceTranscription ?? this.voiceTranscription,
      voiceScore: voiceScore ?? this.voiceScore,
      feedbackEs: feedbackEs ?? this.feedbackEs,
      stageAdvanced: stageAdvanced ?? this.stageAdvanced,
      isOfflineError: isOfflineError ?? this.isOfflineError,
      errorMessage: errorMessage ?? this.errorMessage,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      sttConfidence: sttConfidence ?? this.sttConfidence,
      sttLowConfidence: sttLowConfidence ?? this.sttLowConfidence,
      grammarFlipOrder:
          resetGrammarFlip ? const [] : (grammarFlipOrder ?? this.grammarFlipOrder),
      grammarFlipCorrect:
          resetGrammarFlip ? null : (grammarFlipCorrect ?? this.grammarFlipCorrect),
      libroPromptText: libroPromptText ?? this.libroPromptText,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class LessonNotifier extends StateNotifier<LessonState> {
  LessonNotifier({
    required LessonData lesson,
    required String personaKey,
    required ConnectivityService connectivity,
    required Ref ref,
  })  : _connectivity = connectivity,
        _ref = ref,
        super(LessonState(lesson: lesson, personaKey: personaKey));

  final ConnectivityService _connectivity;
  final Ref _ref;
  final _claude = ClaudeService();
  final _stt = SpeechToText();
  Timer? _unlockTimer;
  bool _sttAvailable = false;
  DateTime? _startedAt;

  // ── Navigation ────────────────────────────────────────────────────────────

  /// Called when user taps "¡Empezar Lección!" on intro card.
  void startLesson() {
    _startedAt = DateTime.now();
    state = state.copyWith(
      status: LessonStatus.slide,
      slideIndex: 0,
      nextUnlocked: false,
    );
    _startUnlockTimerIfNeeded();
  }

  /// Called when user taps "Siguiente →".
  void nextSlide() {
    if (!state.nextUnlocked) return;
    final next = state.slideIndex + 1;
    if (next >= state.totalSlides) {
      // All slides done → voice challenge
      state = state.copyWith(
        status: LessonStatus.voiceChallenge,
        nextUnlocked: true,
        isOfflineError: false,
        errorMessage: '',
      );
    } else {
      state = state.copyWith(
        status: LessonStatus.slide,
        slideIndex: next,
        nextUnlocked: false,
        selectedAnswer: null,
        quizCorrect: null,
        resetGrammarFlip: true,
        libroPromptText: '',
      );
      _startUnlockTimerIfNeeded();
    }
  }

  /// Unlock next immediately (used by 🔊 Repetir for vocab/phrase slides).
  void unlockNext() {
    if (state.status == LessonStatus.slide) {
      final slide = state.slides[state.slideIndex];
      if (slide.type == SlideType.vocab || slide.type == SlideType.phrase) {
        state = state.copyWith(nextUnlocked: true);
      }
    }
  }

  // ── Quiz ──────────────────────────────────────────────────────────────────

  void selectAnswer(int index) {
    if (state.quizCorrect == true) return; // already correct, ignore
    final correct = index == state.slides[state.slideIndex].correctIndex;
    state = state.copyWith(
      selectedAnswer: index,
      quizCorrect: correct,
      nextUnlocked: correct,
    );
  }

  // ── Grammar Flip ──────────────────────────────────────────────────────────

  void setGrammarFlipOrder(List<String> order) {
    state = state.copyWith(grammarFlipOrder: List.unmodifiable(order));
  }

  void checkGrammarFlip() {
    final slide = state.slides[state.slideIndex];
    final target = slide.contentEn
        .toLowerCase()
        .replaceAll(RegExp(r"[^\w\s]"), '')
        .trim();
    final answer = state.grammarFlipOrder
        .join(' ')
        .toLowerCase()
        .replaceAll(RegExp(r"[^\w\s]"), '')
        .trim();
    final correct = target == answer;
    state = state.copyWith(grammarFlipCorrect: correct, nextUnlocked: correct);
  }

  void resetGrammarFlip() {
    state = state.copyWith(resetGrammarFlip: true);
  }

  // ── Libro Prompt ──────────────────────────────────────────────────────────

  void updateLibroText(String text) {
    state = state.copyWith(
      libroPromptText: text,
      nextUnlocked: text.trim().length >= 5,
    );
  }

  // ── Voice Challenge ───────────────────────────────────────────────────────

  Future<void> startRecording() async {
    if (!_sttAvailable) {
      _sttAvailable = await _stt.initialize(
        onError: (_) {
          state = state.copyWith(
            status: LessonStatus.voiceChallenge,
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
      status: LessonStatus.voiceRecording,
      voiceTranscription: '',
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
          voiceTranscription: result.recognizedWords,
          sttConfidence: result.finalResult
              ? result.confidence
              : state.sttConfidence,
        );
      },
    );
  }

  Future<void> stopRecordingAndScore() async {
    await _stt.stop();
    await AudioService.activateForTts();
    final transcribed = state.voiceTranscription.trim();

    if (transcribed.isEmpty) {
      state = state.copyWith(
        status: LessonStatus.result,
        voiceScore: 0,
        feedbackEs: 'No escuché nada. ¡Inténtalo de nuevo!',
      );
      return;
    }

    if (state.sttConfidence > 0 && state.sttConfidence < 0.7) {
      state = state.copyWith(
        status: LessonStatus.voiceChallenge,
        sttLowConfidence: true,
      );
      return;
    }

    final online = await _connectivity.isOnline();
    if (!online) {
      state = state.copyWith(
        status: LessonStatus.voiceChallenge,
        isOfflineError: true,
      );
      return;
    }

    state = state.copyWith(status: LessonStatus.voiceLoading);

    try {
      final expected = state.content.voiceChallengeEn;
      final prompt = '''
Eres un profesor de inglés amable evaluando a un estudiante hispano.
Oración esperada: "$expected"
Lo que el estudiante dijo: "$transcribed"
Considera: Significado (40pts) + Palabras correctas (40pts) + Fluidez (20pts)
Responde SOLO con JSON: {"score": 75, "feedback_es": "¡Muy bien!..."}''';

      final raw = await _claude.complete(
        systemPrompt: '',
        userMessage: prompt,
        maxTokens: 256,
      );

      final parsed = _parseScore(raw);
      state = state.copyWith(
        status: LessonStatus.result,
        voiceScore: parsed.$1,
        feedbackEs: parsed.$2,
      );
    } catch (_) {
      state = state.copyWith(
        status: LessonStatus.voiceChallenge,
        isOfflineError: false,
        errorMessage: 'Error al analizar tu voz. Intenta de nuevo o salta el reto.',
      );
    }
  }

  void skipVoiceChallenge() {
    completeLesson(0, '');
  }

  void retryVoiceChallenge() {
    state = state.copyWith(
      status: LessonStatus.voiceChallenge,
      voiceTranscription: '',
      isOfflineError: false,
      errorMessage: '',
      sttLowConfidence: false,
    );
  }

  // ── Completion ────────────────────────────────────────────────────────────

  void completeLesson(int score, String feedbackEs) {
    // Score 0 means skipped (allowed). Scores 1–69 fail the voice gate.
    if (score > 0 && score < 70) return;

    final elapsed = _startedAt != null
        ? DateTime.now().difference(_startedAt!).inSeconds
        : 0;

    final box = _ref.read(lessonProgressBoxProvider);
    box.put(
      state.lesson.id,
      LessonProgress(
        completed: true,
        voiceScore: score,
        feedbackEs: feedbackEs,
      ),
    );

    _ref.invalidate(completedLessonIdsProvider);
    _ref.invalidate(completedLessonCountProvider);
    // Also invalidate per-lesson provider so list rebuilds.
    _ref.invalidate(lessonProgressProvider(state.lesson.id));

    // Stage = number of tiers with at least one completed non-placeholder lesson
    final completedIds = box.keys
        .where((k) {
          final p = box.get(k);
          return p != null && p.completed;
        })
        .map((k) => k.toString())
        .toSet();
    int tiersDone = 0;
    for (final tier in CurriculumStructure.tiers) {
      final tierLessons = tier.categories
          .expand((c) => c.lessons)
          .where((l) => !l.isPlaceholder)
          .toList();
      if (tierLessons.isNotEmpty &&
          tierLessons.every((l) => completedIds.contains(l.id))) {
        tiersDone++;
      }
    }
    final newStage = tiersDone.clamp(0, 5);
    final currentStage = _ref.read(progressProvider).stageIndex;
    final advanced = newStage > currentStage;

    if (advanced) {
      _ref.read(progressProvider.notifier).setStage(newStage);
    }

    // Award XP and record streak
    _ref.read(gamificationProvider.notifier).addXp(10);
    _ref.read(gamificationProvider.notifier).recordPractice();

    state = state.copyWith(
      status: LessonStatus.complete,
      voiceScore: score,
      feedbackEs: feedbackEs,
      stageAdvanced: advanced,
      elapsedSeconds: elapsed,
    );
  }

  // ── Timer helpers ─────────────────────────────────────────────────────────

  void _startUnlockTimerIfNeeded() {
    _unlockTimer?.cancel();
    if (state.slideIndex >= state.slides.length) return;
    final slide = state.slides[state.slideIndex];
    // grammarFlip and libroPrompt unlock via user interaction, not a timer
    if (slide.type == SlideType.vocab || slide.type == SlideType.phrase) {
      _unlockTimer = Timer(const Duration(seconds: 3), () {
        if (mounted && state.status == LessonStatus.slide) {
          state = state.copyWith(nextUnlocked: true);
        }
      });
    }
  }

  // ── Parsing ───────────────────────────────────────────────────────────────

  (int, String) _parseScore(String raw) {
    try {
      final cleaned = raw
          .replaceAll(RegExp(r'```json\s*'), '')
          .replaceAll(RegExp(r'```\s*'), '')
          .trim();
      final json = jsonDecode(cleaned) as Map<String, dynamic>;
      final score = (json['score'] as num?)?.toInt() ?? 50;
      final feedback = json['feedback_es'] as String? ?? raw;
      return (score.clamp(0, 100), feedback);
    } catch (_) {
      return (50, raw);
    }
  }

  @override
  void dispose() {
    _unlockTimer?.cancel();
    _stt.cancel();
    super.dispose();
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final lessonPlayerProvider = StateNotifierProvider.autoDispose
    .family<LessonNotifier, LessonState, LessonData>((ref, lesson) {
  final persona = ref.watch(personaProvider);
  final personaKey = persona?.name ?? 'adulto'; // nino | adulto | abuelo
  return LessonNotifier(
    lesson: lesson,
    personaKey: personaKey,
    connectivity: ref.watch(connectivityServiceProvider),
    ref: ref,
  );
});

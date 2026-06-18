import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/lesson_models.dart';
import '../../core/providers/lesson_player_provider.dart';
import '../../core/providers/persona_provider.dart';
import '../../core/providers/audio_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_strings.dart';
import '../../shared/widgets/offline_banner.dart';
import 'lesson_summary_screen.dart';
import 'widgets/grammar_flip_card.dart';
import 'widgets/intro_slide_card.dart';
import 'widgets/libro_prompt_card.dart';
import 'widgets/phrase_slide_card.dart';
import 'widgets/quiz_slide_card.dart';
import 'widgets/result_slide_card.dart';
import 'widgets/vocab_slide_card.dart';
import 'widgets/voice_challenge_view.dart';

class LessonPlayerScreen extends ConsumerStatefulWidget {
  const LessonPlayerScreen({super.key, required this.lesson, this.lessonLabel});

  final LessonData lesson;
  final String? lessonLabel;

  @override
  ConsumerState<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends ConsumerState<LessonPlayerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual<LessonState>(
        lessonPlayerProvider(widget.lesson),
        (prev, next) {
          if (prev?.status != LessonStatus.complete &&
              next.status == LessonStatus.complete) {
            if (!context.mounted) return;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (_) => LessonSummaryScreen(
                  lessonId: next.lesson.id,
                  lessonTitle: next.content.titleEs,
                  xpGained: 10,
                  elapsedSeconds: next.elapsedSeconds,
                  wordCount: 4,
                  voiceScore: next.voiceScore,
                  stageAdvanced: next.stageAdvanced,
                  milestoneEs: next.content.milestoneEs,
                ),
              ),
            );
          }
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(lessonPlayerProvider(widget.lesson));
    final notifier = ref.read(lessonPlayerProvider(widget.lesson).notifier);
    final persona = ref.watch(personaProvider);
    final isSenior = persona?.isSeniorMode ?? false;
    final tts = ref.read(audioServiceProvider);

    final isVoiceActive = state.status == LessonStatus.voiceRecording ||
        state.status == LessonStatus.voiceLoading;

    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;
    final btnHeight = isSenior ? 72.0 : 56.0;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.terracotta,
        foregroundColor: Colors.white,
        title: Text(
          widget.lessonLabel != null
              ? '${widget.lessonLabel}  •  ${state.content.titleEs}'
              : 'Lección ${widget.lesson.order}  •  ${state.content.titleEs}',
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: TextStyle(
            fontSize: isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            tts.stop();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          // Progress bar (slide status only)
          if (state.status == LessonStatus.slide) ...[
            LinearProgressIndicator(
              value: (state.slideIndex + 1) / state.totalSlides,
              minHeight: 6,
              backgroundColor: AppColors.unselectedBorder,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.terracotta),
            ),
          ],
          // Main content
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildSlide(state, notifier, isSenior),
            ),
          ),
          // Bottom bar
          if (!isVoiceActive)
            _buildBottomBar(state, notifier, tts, isSenior, bodySize, btnHeight),
        ],
      ),
    );
  }

  Widget _buildSlide(
      LessonState state, LessonNotifier notifier, bool isSenior) {
    switch (state.status) {
      case LessonStatus.intro:
        return IntroSlideCard(
          key: const ValueKey('intro'),
          content: state.content,
          lessonId: state.lesson.id,
          isSenior: isSenior,
        );

      case LessonStatus.slide:
        final slide = state.slides[state.slideIndex];
        switch (slide.type) {
          case SlideType.vocab:
            return VocabSlideCard(
              key: ValueKey('vocab_${state.slideIndex}'),
              slide: slide,
              isSenior: isSenior,
            );
          case SlideType.phrase:
            return PhraseSlideCard(
              key: ValueKey('phrase_${state.slideIndex}'),
              slide: slide,
              isSenior: isSenior,
            );
          case SlideType.quiz:
            return QuizSlideCard(
              key: ValueKey('quiz_${state.slideIndex}'),
              slide: slide,
              selectedAnswer: state.selectedAnswer,
              quizCorrect: state.quizCorrect,
              isSenior: isSenior,
              onSelectAnswer: notifier.selectAnswer,
            );
          case SlideType.grammarFlip:
            return GrammarFlipCard(
              key: ValueKey('grammarFlip_${state.slideIndex}'),
              slide: slide,
              currentOrder: state.grammarFlipOrder,
              flipCorrect: state.grammarFlipCorrect,
              isSenior: isSenior,
              onOrderChanged: notifier.setGrammarFlipOrder,
              onCheck: notifier.checkGrammarFlip,
              onReset: notifier.resetGrammarFlip,
            );
          case SlideType.libroPrompt:
            return LibroPromptCard(
              key: ValueKey('libroPrompt_${state.slideIndex}'),
              slide: slide,
              currentText: state.libroPromptText,
              isSenior: isSenior,
              onTextChanged: notifier.updateLibroText,
            );
        }

      case LessonStatus.voiceChallenge:
      case LessonStatus.voiceRecording:
        return VoiceChallengeView(
          key: const ValueKey('voice'),
          targetSentence: state.content.voiceChallengeEn,
          transcription: state.voiceTranscription,
          isRecording: state.status == LessonStatus.voiceRecording,
          isOfflineError: state.isOfflineError,
          errorMessage: state.errorMessage,
          isSenior: isSenior,
          onLongPressStart: notifier.startRecording,
          onLongPressEnd: notifier.stopRecordingAndScore,
          onSkip: notifier.skipVoiceChallenge,
          sttLowConfidence: state.sttLowConfidence,
        );

      case LessonStatus.voiceLoading:
        final bodySize =
            isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;
        return Center(
          key: const ValueKey('loading'),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.terracotta),
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.retoScoringEs,
                style: TextStyle(
                  fontSize: bodySize,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
        );

      case LessonStatus.result:
        return ResultSlideCard(
          key: const ValueKey('result'),
          score: state.voiceScore,
          feedbackEs: state.feedbackEs,
          isSenior: isSenior,
          onTryAgain: () => ref
              .read(lessonPlayerProvider(widget.lesson).notifier)
              .retryVoiceChallenge(),
        );

      case LessonStatus.complete:
        final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;
        return Center(
          key: const ValueKey('complete'),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              '¡Lección completada! 🎉',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: bodySize + 4,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
              ),
            ),
          ),
        );
    }
  }

  Widget _buildBottomBar(
    LessonState state,
    LessonNotifier notifier,
    dynamic tts,
    bool isSenior,
    double bodySize,
    double btnHeight,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 20 + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          // 🔊 Repetir (visible for vocab/phrase slides and result; hidden for interactive slides)
          if (state.status != LessonStatus.voiceChallenge &&
              state.status != LessonStatus.voiceLoading &&
              state.status != LessonStatus.complete &&
              !(state.status == LessonStatus.slide &&
                  (state.slides[state.slideIndex].type == SlideType.grammarFlip ||
                   state.slides[state.slideIndex].type == SlideType.libroPrompt))) ...[
            SizedBox(
              height: isSenior ? 56.0 : 48.0,
              child: ElevatedButton(
                onPressed: () {
                  final String text;
                  if (state.status == LessonStatus.slide) {
                    text = state.slides[state.slideIndex].contentEn;
                  } else {
                    text = state.content.voiceChallengeEn;
                  }
                  tts.speak(text);
                  notifier.unlockNext();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deepBlue,
                  foregroundColor: AppColors.lightText,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  AppStrings.lessonRepeatAudioEs,
                  style: TextStyle(
                    fontSize: bodySize - 2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          // Primary action button
          _buildPrimaryButton(state, notifier, isSenior, bodySize, btnHeight),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(
    LessonState state,
    LessonNotifier notifier,
    bool isSenior,
    double bodySize,
    double btnHeight,
  ) {
    switch (state.status) {
      case LessonStatus.intro:
        return SizedBox(
          height: btnHeight,
          child: ElevatedButton(
            onPressed: notifier.startLesson,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.terracotta,
              foregroundColor: AppColors.lightText,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
            child: Text(
              AppStrings.lessonIntroStartEs,
              style: TextStyle(
                fontSize: bodySize,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );

      case LessonStatus.slide:
        return SizedBox(
          height: btnHeight,
          child: ElevatedButton(
            onPressed: state.nextUnlocked ? notifier.nextSlide : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.terracotta,
              foregroundColor: AppColors.lightText,
              disabledBackgroundColor:
                  AppColors.unselectedBorder,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
            child: Text(
              AppStrings.lessonNextEs,
              style: TextStyle(
                fontSize: bodySize,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );

      case LessonStatus.voiceChallenge:
      case LessonStatus.voiceRecording:
        return const SizedBox.shrink(); // mic is the CTA

      case LessonStatus.voiceLoading:
        return SizedBox(
          height: btnHeight,
          child: ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.unselectedBorder,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  AppStrings.retoScoringEs,
                  style: TextStyle(
                    fontSize: bodySize - 2,
                    color: AppColors.darkText,
                  ),
                ),
              ],
            ),
          ),
        );

      case LessonStatus.result:
        final canComplete = state.voiceScore >= 70 || state.voiceScore == 0;
        return SizedBox(
          height: btnHeight,
          child: ElevatedButton(
            onPressed: canComplete
                ? () => notifier.completeLesson(state.voiceScore, state.feedbackEs)
                : notifier.retryVoiceChallenge,
            style: ElevatedButton.styleFrom(
              backgroundColor: canComplete ? Colors.green[700] : AppColors.deepBlue,
              foregroundColor: AppColors.lightText,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
            child: Text(
              canComplete ? AppStrings.lessonCompleteActionEs : AppStrings.retoTryAgainEs,
              style: TextStyle(
                fontSize: bodySize,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );

      case LessonStatus.complete:
        return const SizedBox.shrink();
    }
  }
}

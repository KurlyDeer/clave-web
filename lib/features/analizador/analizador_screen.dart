import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/analizador_data.dart';
import '../../core/models/voice_analysis_model.dart';
import '../../core/providers/analizador_provider.dart';
import '../../core/providers/audio_provider.dart';
import '../../core/providers/persona_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/stt_low_confidence_tooltip.dart';
import '../../l10n/app_strings.dart';
import '../simulador/widgets/glass_mic_button.dart';
import 'widgets/abuelo_feedback.dart';
import 'widgets/coaching_tip_card.dart';
import 'widgets/feedback_heatmap.dart';
import 'widgets/live_waveform.dart';

class AnalizadorScreen extends ConsumerStatefulWidget {
  const AnalizadorScreen({super.key});

  @override
  ConsumerState<AnalizadorScreen> createState() => _AnalizadorScreenState();
}

class _AnalizadorScreenState extends ConsumerState<AnalizadorScreen> {
  // Sound levels kept local to allow high-frequency waveform updates without
  // triggering expensive provider rebuilds.
  final List<double> _soundLevels = [];

  Future<void> _speakNormal(String text) async {
    await ref.read(audioServiceProvider).speak(text, speed: 1.0);
  }

  Future<void> _speakSlow(String text) async {
    await ref.read(audioServiceProvider).speak(text, speed: 0.7);
  }

  void _onSoundLevel(double level) {
    if (!mounted) return;
    setState(() {
      _soundLevels.add(level);
      if (_soundLevels.length > 50) _soundLevels.removeAt(0);
    });
  }

  void _clearLevels() => setState(() => _soundLevels.clear());

  void _startRecording() {
    _clearLevels();
    ref
        .read(analizadorProvider.notifier)
        .startListening(onSoundLevel: _onSoundLevel);
  }

  void _stopRecording() {
    final persona = ref.read(personaProvider);
    ref.read(analizadorProvider.notifier).stopAndAnalyze(
          isAbuelo: persona == Persona.abuelo,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(analizadorProvider);
    final persona = ref.watch(personaProvider);
    final isSenior = persona?.isSeniorMode ?? false;

    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;
    final titleSize = isSenior ? AppFontSizes.titleLarge : AppFontSizes.title;
    final buttonHeight = isSenior ? 72.0 : 60.0;

    final sentence = state.currentSentence;
    final isRecording = state.status == AnalizadorStatus.listening;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.glassGradientStart,
              AppColors.glassGradientMid,
              AppColors.glassGradientEnd,
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ── Top bar ────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.glassText,
                      ),
                      onPressed: () {
                        ref.read(audioServiceProvider).stop();
                        Navigator.of(context).pop();
                      },
                    ),
                    Expanded(
                      child: Text(
                        '${AppStrings.analizadorTitleEs}  •  ${AppStrings.analizadorTitleEn}',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: isSenior
                              ? AppFontSizes.subtitleLarge
                              : AppFontSizes.subtitle,
                          fontWeight: FontWeight.w700,
                          color: AppColors.glassText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Scrollable content ─────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Sentence nav ─────────────────────────────────────
                      _SentenceNavRow(
                        current: state.sentenceIndex + 1,
                        total: state.totalSentences,
                        difficulty: sentence.difficulty,
                        isSenior: isSenior,
                        onPrev: () {
                          _clearLevels();
                          ref.read(analizadorProvider.notifier).prevSentence();
                        },
                        onNext: () {
                          _clearLevels();
                          ref.read(analizadorProvider.notifier).nextSentence();
                        },
                      ),
                      const SizedBox(height: 12),

                      // ── Sentence card ────────────────────────────────────
                      _SentenceCard(
                        sentence: sentence,
                        isSenior: isSenior,
                        bodySize: bodySize,
                        titleSize: titleSize,
                        onListen: () => _speakNormal(sentence.en),
                      ),
                      const SizedBox(height: 20),

                      // ── Waveform (idle / listening states only) ──────────
                      if (state.status == AnalizadorStatus.idle ||
                          state.status == AnalizadorStatus.listening) ...[
                        _WaveformSection(
                          isActive: isRecording,
                          levels: _soundLevels,
                          isSenior: isSenior,
                        ),
                      ],

                      // ── Status-driven body ────────────────────────────────
                      _buildBody(
                        state: state,
                        persona: persona,
                        isSenior: isSenior,
                        bodySize: bodySize,
                        buttonHeight: buttonHeight,
                        isRecording: isRecording,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody({
    required AnalizadorState state,
    required Persona? persona,
    required bool isSenior,
    required double bodySize,
    required double buttonHeight,
    required bool isRecording,
  }) {
    switch (state.status) {
      // ── Idle / Listening ─────────────────────────────────────────────────
      case AnalizadorStatus.idle:
      case AnalizadorStatus.listening:
        return _RecordSection(
          isRecording: isRecording,
          transcript: state.transcript,
          isSenior: isSenior,
          bodySize: bodySize,
          onTapMic: isRecording ? _stopRecording : _startRecording,
          sttLowConfidence: state.sttLowConfidence,
        );

      // ── Analyzing ────────────────────────────────────────────────────────
      case AnalizadorStatus.analyzing:
        return _AnalyzingSection(bodySize: bodySize);

      // ── Claude result (heatmap) ──────────────────────────────────────────
      case AnalizadorStatus.result:
        return _ResultSection(
          transcript: state.transcript,
          result: state.analysisResult!,
          isSenior: isSenior,
          bodySize: bodySize,
          buttonHeight: buttonHeight,
          onRetry: () {
            _clearLevels();
            ref.read(analizadorProvider.notifier).reset();
          },
        );

      // ── Abuelo result (thumbs) ───────────────────────────────────────────
      case AnalizadorStatus.abueloResult:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            AbueloFeedback(
              thumbsUp: state.abueloThumbsUp ?? false,
              onListenSlow: () => _speakSlow(state.currentSentence.en),
              onRetry: () {
                _clearLevels();
                ref.read(analizadorProvider.notifier).reset();
              },
            ),
          ],
        );

      // ── Offline error ────────────────────────────────────────────────────
      case AnalizadorStatus.offlineError:
        return _ErrorSection(
          message: AppStrings.analizadorOfflineEs,
          isSenior: isSenior,
          bodySize: bodySize,
          buttonHeight: buttonHeight,
          onRetry: () {
            _clearLevels();
            ref.read(analizadorProvider.notifier).reset();
          },
        );

      // ── General error ────────────────────────────────────────────────────
      case AnalizadorStatus.error:
        return _ErrorSection(
          message: state.errorMessage.isNotEmpty
              ? state.errorMessage
              : AppStrings.analizadorErrorEs,
          isSenior: isSenior,
          bodySize: bodySize,
          buttonHeight: buttonHeight,
          onRetry: () {
            _clearLevels();
            ref.read(analizadorProvider.notifier).reset();
          },
        );
    }
  }
}

// ── Sentence navigation row ────────────────────────────────────────────────────

class _SentenceNavRow extends StatelessWidget {
  const _SentenceNavRow({
    required this.current,
    required this.total,
    required this.difficulty,
    required this.isSenior,
    required this.onPrev,
    required this.onNext,
  });

  final int current;
  final int total;
  final int difficulty;
  final bool isSenior;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  String get _difficultyLabel => switch (difficulty) {
        1 => AppStrings.analizadorDifficulty1Es,
        2 => AppStrings.analizadorDifficulty2Es,
        _ => AppStrings.analizadorDifficulty3Es,
      };

  @override
  Widget build(BuildContext context) {
    final fontSize = isSenior ? AppFontSizes.body : AppFontSizes.body - 2;

    return Row(
      children: [
        IconButton(
          onPressed: onPrev,
          icon: Icon(Icons.chevron_left_rounded, size: 28),
          color: AppColors.glassText,
          tooltip: AppStrings.analizadorPrevSentenceEs,
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                '${AppStrings.analizadorSentenceCountEs} $current '
                '${AppStrings.analizadorOfEs} $total',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize,
                  color: AppColors.glassTextMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _difficultyLabel,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: AppColors.glowTerracotta,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onNext,
          icon: Icon(Icons.chevron_right_rounded, size: 28),
          color: AppColors.glassText,
          tooltip: AppStrings.analizadorNextSentenceEs,
        ),
      ],
    );
  }
}

// ── Target sentence card ───────────────────────────────────────────────────────

class _SentenceCard extends StatelessWidget {
  const _SentenceCard({
    required this.sentence,
    required this.isSenior,
    required this.bodySize,
    required this.titleSize,
    required this.onListen,
  });

  final PracticeSentence sentence;
  final bool isSenior;
  final double bodySize;
  final double titleSize;
  final VoidCallback onListen;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Text(
            AppStrings.analizadorSentenceLabelEs,
            style: TextStyle(
              fontSize: bodySize - 2,
              color: AppColors.glassTextMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          // English sentence — prominent
          Text(
            sentence.en,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w800,
              color: AppColors.glassText,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          // Spanish translation
          Text(
            sentence.es,
            style: TextStyle(
              fontSize: bodySize - 2,
              color: AppColors.glassTextMuted,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
          // Target sound chip + listen button
          Row(
            children: [
              Expanded(
                child: GlassContainer(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  borderRadius: 10,
                  borderColor: AppColors.glowTerracotta.withAlpha(153),
                  child: Text(
                    sentence.targetSoundEs,
                    style: TextStyle(
                      fontSize: bodySize - 3,
                      color: AppColors.glowTerracotta,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onListen,
                child: GlassContainer(
                  padding: const EdgeInsets.all(12),
                  borderRadius: 40,
                  child: Icon(
                    Icons.volume_up_rounded,
                    color: AppColors.glassText,
                    size: isSenior ? 28 : 22,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Waveform section ───────────────────────────────────────────────────────────

class _WaveformSection extends StatelessWidget {
  const _WaveformSection({
    required this.isActive,
    required this.levels,
    required this.isSenior,
  });

  final bool isActive;
  final List<double> levels;
  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    final h = isSenior ? 80.0 : 64.0;
    return SizedBox(
      height: h,
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        borderRadius: 16,
        borderColor:
            isActive ? AppColors.glowTerracotta.withAlpha(128) : AppColors.glassBorder,
        child: LiveWaveform(
          isActive: isActive,
          levels: levels,
          color: isActive ? AppColors.glowTerracotta : AppColors.glassTextMuted,
          height: isSenior ? 72 : 56,
        ),
      ),
    );
  }
}

// ── Record section ─────────────────────────────────────────────────────────────

class _RecordSection extends StatelessWidget {
  const _RecordSection({
    required this.isRecording,
    required this.transcript,
    required this.isSenior,
    required this.bodySize,
    required this.onTapMic,
    this.sttLowConfidence = false,
  });

  final bool isRecording;
  final String transcript;
  final bool isSenior;
  final double bodySize;
  final VoidCallback onTapMic;
  final bool sttLowConfidence;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          isRecording
              ? AppStrings.analizadorListeningEs
              : AppStrings.analizadorHoldToRecordEs,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: bodySize - 1,
            color:
                isRecording ? AppColors.glowTerracotta : AppColors.glassTextMuted,
            fontWeight: isRecording ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: GlassMicButton(
            isRecording: isRecording,
            isAnalyzing: false,
            onTap: onTapMic,
          ),
        ),
        if (!isRecording && sttLowConfidence) ...[
          const SizedBox(height: 16),
          SttLowConfidenceTooltip(fontSize: bodySize - 2),
        ],
        if (isRecording && transcript.isNotEmpty) ...[
          const SizedBox(height: 20),
          GlassContainer(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const Text('🎙', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    transcript,
                    style: TextStyle(
                      fontSize: bodySize - 1,
                      color: AppColors.glassText,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}

// ── Analyzing ──────────────────────────────────────────────────────────────────

class _AnalyzingSection extends StatelessWidget {
  const _AnalyzingSection({required this.bodySize});

  final double bodySize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: GlassContainer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: AppColors.glassText,
              strokeWidth: 4,
            ),
            const SizedBox(height: 20),
            Text(
              AppStrings.analizadorAnalyzingEs,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: bodySize,
                fontWeight: FontWeight.w600,
                color: AppColors.glassText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Result section (heatmap) ───────────────────────────────────────────────────

class _ResultSection extends StatelessWidget {
  const _ResultSection({
    required this.transcript,
    required this.result,
    required this.isSenior,
    required this.bodySize,
    required this.buttonHeight,
    required this.onRetry,
  });

  final String transcript;
  final VoiceAnalysisResult result;
  final bool isSenior;
  final double bodySize;
  final double buttonHeight;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // "You said" transcript
        if (transcript.isNotEmpty) ...[
          GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Text('🎙', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  '${AppStrings.analizadorYouSaidEs} ',
                  style: TextStyle(
                    fontSize: bodySize - 2,
                    color: AppColors.glassTextMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Expanded(
                  child: Text(
                    transcript,
                    style: TextStyle(
                      fontSize: bodySize - 2,
                      color: AppColors.glassText,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Heatmap
        FeedbackHeatmap(
          wordResults: result.wordResults,
          isSenior: isSenior,
        ),
        const SizedBox(height: 20),

        // Coaching tip
        if (result.coachingTipEs.isNotEmpty)
          CoachingTipCard(
            tipEs: result.coachingTipEs,
            score: result.score,
            isSenior: isSenior,
          ),
        const SizedBox(height: 24),

        // XP badge — good score
        if (result.score >= 60)
          Center(
            child: GlassContainer(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              borderRadius: 30,
              borderColor: AppColors.glowTerracotta.withAlpha(153),
              child: Text(
                AppStrings.analizadorXpEarnedEs,
                style: TextStyle(
                  fontSize: bodySize,
                  fontWeight: FontWeight.w800,
                  color: AppColors.glassText,
                ),
              ),
            ),
          ),
        const SizedBox(height: 20),

        // Retry button
        GestureDetector(
          onTap: onRetry,
          child: GlassContainer(
            padding: EdgeInsets.symmetric(
              vertical: isSenior ? 22 : 16,
              horizontal: 24,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.refresh_rounded,
                  color: AppColors.glassText,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  AppStrings.analizadorTryAgainEs,
                  style: TextStyle(
                    fontSize: bodySize,
                    fontWeight: FontWeight.w700,
                    color: AppColors.glassText,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ── Error section ──────────────────────────────────────────────────────────────

class _ErrorSection extends StatelessWidget {
  const _ErrorSection({
    required this.message,
    required this.isSenior,
    required this.bodySize,
    required this.buttonHeight,
    required this.onRetry,
  });

  final String message;
  final bool isSenior;
  final double bodySize;
  final double buttonHeight;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        GlassContainer(
          borderColor: AppColors.glowTerracotta.withAlpha(153),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: bodySize,
              color: AppColors.glassText,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: onRetry,
          child: GlassContainer(
            padding: EdgeInsets.symmetric(
              vertical: isSenior ? 22 : 16,
              horizontal: 24,
            ),
            borderColor: AppColors.glowTerracotta.withAlpha(153),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.refresh_rounded,
                  color: AppColors.glassText,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  AppStrings.analizadorTryAgainEs,
                  style: TextStyle(
                    fontSize: bodySize,
                    fontWeight: FontWeight.w700,
                    color: AppColors.glassText,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

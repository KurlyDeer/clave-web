import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../core/providers/analizador_provider.dart';
import '../../core/providers/persona_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_strings.dart';
import '../sos/widgets/mic_hold_button.dart';
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
  // Sound levels are kept in local state to allow high-frequency waveform
  // updates without triggering expensive provider rebuilds.
  final List<double> _soundLevels = [];

  // Dedicated TTS instance for this screen — allows rate adjustment
  final FlutterTts _tts = FlutterTts();
  static const double _normalRate = 0.45;
  static const double _slowRate = 0.32; // ~0.75× of normal

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(_normalRate);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  // ── TTS helpers ─────────────────────────────────────────────────────────────

  Future<void> _speakNormal(String text) async {
    await _tts.setSpeechRate(_normalRate);
    await _tts.stop();
    await _tts.speak(text);
  }

  /// Speaks at 0.75× speed — designed for Abuelo mode "Escuchar de nuevo".
  Future<void> _speakSlow(String text) async {
    await _tts.setSpeechRate(_slowRate);
    await _tts.stop();
    await _tts.speak(text);
  }

  // ── Sound level handler ──────────────────────────────────────────────────────

  void _onSoundLevel(double level) {
    if (!mounted) return;
    setState(() {
      _soundLevels.add(level);
      if (_soundLevels.length > 50) _soundLevels.removeAt(0);
    });
  }

  void _clearLevels() => setState(() => _soundLevels.clear());

  // ── Recording actions ────────────────────────────────────────────────────────

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
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: const Color(0xFF8E3A59), // deep rose — unique identity
        foregroundColor: Colors.white,
        title: Text(
          '${AppStrings.analizadorTitleEs}  •  ${AppStrings.analizadorTitleEn}',
          style: TextStyle(
            fontSize: isSenior ? AppFontSizes.subtitleLarge : AppFontSizes.body,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _tts.stop();
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up_rounded),
            tooltip: 'Escuchar',
            onPressed: () => _speakNormal(sentence.en),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Sentence navigation ──────────────────────────────────────────
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
            const SizedBox(height: 16),

            // ── Target sentence card ─────────────────────────────────────────
            _SentenceCard(
              sentence: sentence,
              isSenior: isSenior,
              bodySize: bodySize,
              titleSize: titleSize,
              onListen: () => _speakNormal(sentence.en),
            ),
            const SizedBox(height: 24),

            // ── Waveform ─────────────────────────────────────────────────────
            _WaveformSection(
              isActive: isRecording,
              levels: _soundLevels,
              isSenior: isSenior,
            ),

            // ── Body — changes based on status ───────────────────────────────
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
      // ── Idle / Listening ───────────────────────────────────────────────────
      case AnalizadorStatus.idle:
      case AnalizadorStatus.listening:
        return _RecordSection(
          isRecording: isRecording,
          transcript: state.transcript,
          isSenior: isSenior,
          bodySize: bodySize,
          buttonHeight: buttonHeight,
          onStart: _startRecording,
          onStop: _stopRecording,
        );

      // ── Analyzing ──────────────────────────────────────────────────────────
      case AnalizadorStatus.analyzing:
        return _AnalyzingSection(bodySize: bodySize);

      // ── Claude result (heatmap) ────────────────────────────────────────────
      case AnalizadorStatus.result:
        final result = state.analysisResult!;
        return _ResultSection(
          transcript: state.transcript,
          result: result,
          isSenior: isSenior,
          bodySize: bodySize,
          buttonHeight: buttonHeight,
          onRetry: () {
            _clearLevels();
            ref.read(analizadorProvider.notifier).reset();
          },
        );

      // ── Abuelo result (thumbs) ─────────────────────────────────────────────
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

      // ── Errors ─────────────────────────────────────────────────────────────
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
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
          color: AppColors.deepBlue,
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
                  color: AppColors.darkText.withValues(alpha: 0.55),
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
                  color: AppColors.terracotta,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right_rounded, size: 28),
          color: AppColors.deepBlue,
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

  final dynamic sentence; // PracticeSentence
  final bool isSenior;
  final double bodySize;
  final double titleSize;
  final VoidCallback onListen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Text(
            AppStrings.analizadorSentenceLabelEs,
            style: TextStyle(
              fontSize: bodySize - 2,
              color: AppColors.darkText.withValues(alpha: 0.55),
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
              color: AppColors.darkText,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          // Spanish meaning
          Text(
            sentence.es,
            style: TextStyle(
              fontSize: bodySize - 2,
              color: AppColors.darkText.withValues(alpha: 0.55),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
          // Target sound chip + listen button
          Row(
            children: [
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.terracotta.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.terracotta.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    sentence.targetSoundEs,
                    style: TextStyle(
                      fontSize: bodySize - 3,
                      color: AppColors.terracotta,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: onListen,
                borderRadius: BorderRadius.circular(40),
                child: Container(
                  width: isSenior ? 52 : 44,
                  height: isSenior ? 52 : 44,
                  decoration: BoxDecoration(
                    color: AppColors.deepBlue,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.volume_up_rounded,
                    color: Colors.white,
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
    return Container(
      height: isSenior ? 80 : 64,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF8E3A59).withValues(alpha: 0.06)
            : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? const Color(0xFF8E3A59).withValues(alpha: 0.4)
              : AppColors.unselectedBorder,
        ),
      ),
      child: LiveWaveform(
        isActive: isActive,
        levels: levels,
        color: isActive
            ? const Color(0xFF8E3A59)
            : AppColors.deepBlue.withValues(alpha: 0.35),
        height: isSenior ? 72 : 56,
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
    required this.buttonHeight,
    required this.onStart,
    required this.onStop,
  });

  final bool isRecording;
  final String transcript;
  final bool isSenior;
  final double bodySize;
  final double buttonHeight;
  final VoidCallback onStart;
  final VoidCallback onStop;

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
            color: isRecording
                ? const Color(0xFF8E3A59)
                : AppColors.darkText.withValues(alpha: 0.6),
            fontWeight: isRecording ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: MicHoldButton(
            isRecording: isRecording,
            isSenior: isSenior,
            onLongPressStart: onStart,
            onLongPressEnd: onStop,
          ),
        ),
        if (isRecording && transcript.isNotEmpty) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.unselectedBorder),
            ),
            child: Row(
              children: [
                const Text('🎙', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    transcript,
                    style: TextStyle(
                      fontSize: bodySize - 1,
                      color: AppColors.darkText,
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
      child: Column(
        children: [
          const CircularProgressIndicator(
            color: Color(0xFF8E3A59),
            strokeWidth: 4,
          ),
          const SizedBox(height: 20),
          Text(
            AppStrings.analizadorAnalyzingEs,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: bodySize,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
        ],
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
  final dynamic result; // VoiceAnalysisResult
  final bool isSenior;
  final double bodySize;
  final double buttonHeight;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // "You said" row
        if (transcript.isNotEmpty) ...[
          Row(
            children: [
              const Text('🎙', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                '${AppStrings.analizadorYouSaidEs} ',
                style: TextStyle(
                  fontSize: bodySize - 2,
                  color: AppColors.darkText.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Expanded(
                child: Text(
                  transcript,
                  style: TextStyle(
                    fontSize: bodySize - 2,
                    color: AppColors.darkText.withValues(alpha: 0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
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

        // XP badge if good score
        if (result.score >= 60)
          Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.amber[100],
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.amber[400]!, width: 2),
              ),
              child: Text(
                AppStrings.analizadorXpEarnedEs,
                style: TextStyle(
                  fontSize: bodySize,
                  fontWeight: FontWeight.w800,
                  color: Colors.amber[800],
                ),
              ),
            ),
          ),
        const SizedBox(height: 20),

        // Try again button
        SizedBox(
          height: buttonHeight,
          child: ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(
              AppStrings.analizadorTryAgainEs,
              style: TextStyle(
                fontSize: bodySize,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8E3A59),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
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
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red[200]!),
          ),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: bodySize,
              color: Colors.red[800],
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: buttonHeight,
          child: ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.terracotta,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              AppStrings.analizadorTryAgainEs,
              style: TextStyle(
                fontSize: bodySize,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

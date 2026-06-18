import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/scenario_models.dart';
import '../../core/providers/persona_provider.dart';
import '../../core/providers/simulador_provider.dart';
import '../../core/providers/audio_provider.dart';
import '../../core/services/analysis_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/stt_low_confidence_tooltip.dart';
import '../../l10n/app_strings.dart';
import 'report_card_screen.dart';
import 'widgets/glass_ai_bubble.dart';
import 'widgets/glass_mic_button.dart';
import 'widgets/glass_user_bubble.dart';
import 'widgets/scenario_header.dart';

class SimuladorScreen extends ConsumerStatefulWidget {
  const SimuladorScreen({super.key, required this.scenario});

  final ScenarioData scenario;

  @override
  ConsumerState<SimuladorScreen> createState() => _SimuladorScreenState();
}

class _SimuladorScreenState extends ConsumerState<SimuladorScreen> {
  final _scrollController = ScrollController();
  bool _isAnalyzingReport = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(simuladorProvider(widget.scenario).notifier).startScenario();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _generateReport(List<ScenarioTurn> turns) async {
    final capturedTurns = List<ScenarioTurn>.from(turns);
    final title = widget.scenario.titleEs;
    setState(() => _isAnalyzingReport = true);

    final report =
        await ref.read(analysisServiceProvider).analyze(capturedTurns);

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ReportCardScreen(
          report: report,
          scenarioTitleEs: title,
        ),
      ),
    );
  }

  Future<void> _speakAiLine(String text) async {
    final audio = ref.read(audioServiceProvider);
    await audio.speak(text);
    if (mounted) {
      ref
          .read(simuladorProvider(widget.scenario).notifier)
          .onAiSpeechComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final persona = ref.watch(personaProvider);
    final isSenior = persona?.isSeniorMode ?? false;
    final state = ref.watch(simuladorProvider(widget.scenario));
    final notifier = ref.read(simuladorProvider(widget.scenario).notifier);

    ref.listen(simuladorProvider(widget.scenario), (prev, next) {
      if (next.status == SimuladorStatus.aiSpeaking &&
          prev?.status != SimuladorStatus.aiSpeaking) {
        _speakAiLine(next.currentAiLineEn);
      }
      if (next.turns.length != (prev?.turns.length ?? 0)) {
        _scrollToBottom();
      }
      if (next.status == SimuladorStatus.complete &&
          prev?.status != SimuladorStatus.complete) {
        _generateReport(next.turns);
      }
    });

    return PopScope(
      canPop: !_isAnalyzingReport,
      child: Scaffold(
        body: Stack(
          children: [
            Container(
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
                    // ── Top bar ────────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: AppColors.glassText,
                            ),
                            onPressed: _isAnalyzingReport
                                ? null
                                : () => Navigator.of(context).pop(),
                          ),
                          Expanded(
                            child: Text(
                              widget.scenario.titleEs,
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
                    // ── Character header ───────────────────────────────────
                    ScenarioHeader(
                      scenario: widget.scenario,
                      isSenior: isSenior,
                      isDark: true,
                    ),
                    // ── Goal chip ──────────────────────────────────────────
                    if (widget.scenario.targetGoalEs.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: GlassContainer(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${AppStrings.simuladorGoalLabelEs} ',
                                style: TextStyle(
                                  fontSize:
                                      isSenior ? AppFontSizes.body : 14.0,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.glowTerracotta,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  widget.scenario.targetGoalEs,
                                  style: TextStyle(
                                    fontSize:
                                        isSenior ? AppFontSizes.body : 14.0,
                                    color: AppColors.glassText,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // ── Error banners ──────────────────────────────────────
                    if (state.isOfflineError)
                      _GlassBanner(
                        message: AppStrings.simuladorOfflineEs,
                        color: Colors.red[700]!,
                      ),
                    if (state.errorMessage.isNotEmpty)
                      _GlassBanner(
                        message: state.errorMessage,
                        color: Colors.orange[800]!,
                      ),
                    // ── Chat list ──────────────────────────────────────────
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        itemCount: state.turns.length,
                        itemBuilder: (context, index) {
                          final turn = state.turns[index];
                          if (turn.speaker == TurnSpeaker.ai) {
                            return GlassAiBubble(
                              textEn: turn.textEn,
                              hintEs: turn.hintEs,
                              isSenior: isSenior,
                              onReplay: () => ref
                                  .read(audioServiceProvider)
                                  .speak(turn.textEn),
                            );
                          } else {
                            return GlassUserBubble(
                              textEn: turn.textEn,
                              feedbackColor: turn.feedbackColor,
                              isSenior: isSenior,
                            );
                          }
                        },
                      ),
                    ),
                    // ── Bottom action area ─────────────────────────────────
                    _GlassBottomArea(
                      state: state,
                      notifier: notifier,
                      isSenior: isSenior,
                      onReplayCurrentLine: () => ref
                          .read(audioServiceProvider)
                          .speak(state.currentAiLineEn),
                    ),
                  ],
                ),
              ),
            ),
            // ── Analyzing overlay ──────────────────────────────────────────
            if (_isAnalyzingReport)
              Container(
                color: Colors.black54,
                child: Center(
                  child: GlassContainer(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                            color: AppColors.glowTerracotta),
                        const SizedBox(height: 16),
                        Text(
                          AppStrings.reportCardAnalyzingEs,
                          style: TextStyle(
                            fontSize: isSenior
                                ? AppFontSizes.bodyLarge
                                : AppFontSizes.body,
                            color: AppColors.glassText,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom action area ─────────────────────────────────────────────────────────

class _GlassBottomArea extends StatelessWidget {
  const _GlassBottomArea({
    required this.state,
    required this.notifier,
    required this.isSenior,
    required this.onReplayCurrentLine,
  });

  final SimuladorState state;
  final SimuladorNotifier notifier;
  final bool isSenior;
  final VoidCallback onReplayCurrentLine;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final labelSize = isSenior ? AppFontSizes.body : 16.0;

    switch (state.status) {
      case SimuladorStatus.loading:
        return Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(color: AppColors.glassText),
          ),
        );

      case SimuladorStatus.aiSpeaking:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.simuladorAiSpeakingEs,
              style: TextStyle(
                fontSize: labelSize,
                color: AppColors.glassTextMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            const SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                color: AppColors.glowTerracotta,
                strokeWidth: 3,
              ),
            ),
          ],
        );

      case SimuladorStatus.waitingForVoice:
        if (state.showHint && state.currentHintEs.isNotEmpty) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _HintCard(
                  hintText: state.currentHintEs, isSenior: isSenior),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: notifier.skipTurn,
                child: GlassContainer(
                  padding: EdgeInsets.symmetric(
                      vertical: isSenior ? 18 : 14, horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.skip_next_rounded,
                          color: AppColors.glassTextMuted, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        AppStrings.simuladorSkipTurnEs,
                        style: TextStyle(
                          fontSize: isSenior ? AppFontSizes.body : 16,
                          color: AppColors.glassTextMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (state.sttLowConfidence) ...[
              SttLowConfidenceTooltip(fontSize: labelSize - 2),
              const SizedBox(height: 12),
            ],
            Text(
              AppStrings.simuladorTapMicEs,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: labelSize,
                color: AppColors.glassTextMuted,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GlassMicButton(
                  isRecording: false,
                  isAnalyzing: false,
                  onTap: () => notifier.startRecording(),
                ),
                const SizedBox(width: 20),
                _ReplayButton(onTap: onReplayCurrentLine),
              ],
            ),
          ],
        );

      case SimuladorStatus.recording:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (state.userTranscription.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.glassSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Text(
                  state.userTranscription,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: labelSize,
                    color: AppColors.glassText,
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  AppStrings.simuladorListeningEs,
                  style: TextStyle(
                    fontSize: labelSize,
                    color: AppColors.glassTextMuted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            GlassMicButton(
              isRecording: true,
              isAnalyzing: false,
              onTap: () => notifier.stopRecordingAndAnalyze(),
            ),
          ],
        );

      case SimuladorStatus.analyzing:
        return Center(
          child: GlassMicButton(
            isRecording: false,
            isAnalyzing: true,
            onTap: null,
          ),
        );

      case SimuladorStatus.feedback:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (state.showHint && state.currentHintEs.isNotEmpty) ...[
              _HintCard(
                  hintText: state.currentHintEs, isSenior: isSenior),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: notifier.skipTurn,
                child: GlassContainer(
                  padding: EdgeInsets.symmetric(
                      vertical: isSenior ? 16 : 12, horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.skip_next_rounded,
                          color: AppColors.glassTextMuted, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        AppStrings.simuladorSkipTurnEs,
                        style: TextStyle(
                          fontSize: isSenior ? AppFontSizes.body : 15,
                          color: AppColors.glassTextMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            GestureDetector(
              onTap: notifier.advanceToNextAiTurn,
              child: GlassContainer(
                padding: EdgeInsets.symmetric(
                  vertical: isSenior ? 20 : 16,
                  horizontal: 24,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.simuladorContinueEs,
                      style: TextStyle(
                        fontSize: isSenior ? AppFontSizes.body : 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.glassText,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.glassText,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            if (state.feedbackColor == 'red') ...[
              const SizedBox(height: 10),
              TextButton(
                onPressed: notifier.retryTurn,
                child: Text(
                  AppStrings.simuladorRetryEs,
                  style: TextStyle(
                    fontSize: isSenior ? AppFontSizes.body - 2 : 14,
                    color: AppColors.glowTerracotta,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        );

      case SimuladorStatus.complete:
        // Overlay in SimuladorScreen handles analysis + navigation.
        return const SizedBox.shrink();
    }
  }
}

// ── Replay button ─────────────────────────────────────────────────────────────

class _ReplayButton extends StatelessWidget {
  const _ReplayButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.all(14),
        borderRadius: 40,
        child: Icon(
          Icons.volume_up_rounded,
          color: AppColors.glassText,
          size: 28,
        ),
      ),
    );
  }
}

// ── Hint card ─────────────────────────────────────────────────────────────────

class _HintCard extends StatelessWidget {
  const _HintCard({required this.hintText, required this.isSenior});
  final String hintText;
  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Text('💡', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.simuladorHintAfterFailEs,
                  style: TextStyle(
                    fontSize: isSenior ? AppFontSizes.body - 2 : 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.glowTerracotta,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hintText,
                  style: TextStyle(
                    fontSize: isSenior ? AppFontSizes.body : 14,
                    color: AppColors.glassText,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Glass error banner ────────────────────────────────────────────────────────

class _GlassBanner extends StatelessWidget {
  const _GlassBanner({required this.message, required this.color});
  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: color.withAlpha(230),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }
}

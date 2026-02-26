import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/scenario_models.dart';
import '../../core/providers/persona_provider.dart';
import '../../core/providers/simulador_provider.dart';
import '../../core/services/tts_service.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_strings.dart';
import '../sos/widgets/mic_hold_button.dart';
import 'widgets/ai_message_bubble.dart';
import 'widgets/scenario_header.dart';
import 'widgets/user_message_bubble.dart';

class SimuladorScreen extends ConsumerStatefulWidget {
  const SimuladorScreen({super.key, required this.scenario});

  final ScenarioData scenario;

  @override
  ConsumerState<SimuladorScreen> createState() => _SimuladorScreenState();
}

class _SimuladorScreenState extends ConsumerState<SimuladorScreen> {
  final _scrollController = ScrollController();
  final _tts = TtsService();
  bool _ttsPlaying = false;

  @override
  void initState() {
    super.initState();
    // Kick off the opening AI line after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(simuladorProvider(widget.scenario).notifier).startScenario();
    });
  }

  @override
  void dispose() {
    _tts.dispose();
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

  Future<void> _speakAiLine(String text) async {
    if (_ttsPlaying) return;
    setState(() => _ttsPlaying = true);
    await _tts.speak(text);
    setState(() => _ttsPlaying = false);
    // Signal provider that speech is done
    if (mounted) {
      ref.read(simuladorProvider(widget.scenario).notifier).onAiSpeechComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final persona = ref.watch(personaProvider);
    final isSenior = persona?.isSeniorMode ?? false;
    final state = ref.watch(simuladorProvider(widget.scenario));
    final notifier = ref.read(simuladorProvider(widget.scenario).notifier);

    // Trigger TTS when status becomes aiSpeaking
    ref.listen(simuladorProvider(widget.scenario), (prev, next) {
      if (next.status == SimuladorStatus.aiSpeaking &&
          prev?.status != SimuladorStatus.aiSpeaking) {
        _speakAiLine(next.currentAiLineEn);
      }
      // Auto-scroll whenever turns list changes
      if (next.turns.length != (prev?.turns.length ?? 0)) {
        _scrollToBottom();
      }
    });

    final textSize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.terracotta,
        foregroundColor: AppColors.lightText,
        title: Text(
          widget.scenario.titleEs,
          style: TextStyle(
            fontSize: isSenior ? AppFontSizes.subtitleLarge : AppFontSizes.subtitle,
            fontWeight: FontWeight.w700,
            color: AppColors.lightText,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          ScenarioHeader(scenario: widget.scenario, isSenior: isSenior),
          // Offline error banner
          if (state.isOfflineError)
            _OfflineBanner(isSenior: isSenior),
          // General error message
          if (state.errorMessage.isNotEmpty)
            _ErrorBanner(message: state.errorMessage, isSenior: isSenior),
          // Chat area
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: state.turns.length,
              itemBuilder: (context, index) {
                final turn = state.turns[index];
                if (turn.speaker == TurnSpeaker.ai) {
                  return AiMessageBubble(
                    textEn: turn.textEn,
                    hintEs: turn.hintEs,
                    isSenior: isSenior,
                    onReplay: () => _tts.speak(turn.textEn),
                  );
                } else {
                  return UserMessageBubble(
                    textEn: turn.textEn,
                    feedbackEs: turn.feedbackEs,
                    isAcceptable: turn.isAcceptable,
                    isSenior: isSenior,
                  );
                }
              },
            ),
          ),
          // Bottom action area
          _BottomArea(
            state: state,
            notifier: notifier,
            isSenior: isSenior,
            textSize: textSize,
            scenario: widget.scenario,
            onReplayCurrentLine: () => _tts.speak(state.currentAiLineEn),
          ),
        ],
      ),
    );
  }
}

// ── Bottom action area ─────────────────────────────────────────────────────────

class _BottomArea extends StatelessWidget {
  const _BottomArea({
    required this.state,
    required this.notifier,
    required this.isSenior,
    required this.textSize,
    required this.scenario,
    required this.onReplayCurrentLine,
  });

  final SimuladorState state;
  final SimuladorNotifier notifier;
  final bool isSenior;
  final double textSize;
  final ScenarioData scenario;
  final VoidCallback onReplayCurrentLine;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (state.status) {
      case SimuladorStatus.loading:
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          ),
        );

      case SimuladorStatus.aiSpeaking:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Color(0xFF16A085)),
            const SizedBox(height: 8),
            Text(
              AppStrings.simuladorAiSpeakingEs,
              style: TextStyle(fontSize: textSize, color: Colors.grey[600]),
            ),
          ],
        );

      case SimuladorStatus.waitingForVoice:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.simuladorRecordInstructionEs,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: textSize,
                color: Colors.grey[700],
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MicHoldButton(
                  isRecording: false,
                  isSenior: isSenior,
                  onLongPressStart: notifier.startRecording,
                  onLongPressEnd: notifier.stopRecordingAndAnalyze,
                ),
                const SizedBox(width: 20),
                InkWell(
                  onTap: onReplayCurrentLine,
                  borderRadius: BorderRadius.circular(40),
                  child: Container(
                    width: isSenior ? 60 : 50,
                    height: isSenior ? 60 : 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.volume_up_rounded,
                      color: AppColors.deepBlue,
                      size: isSenior ? 30 : 24,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );

      case SimuladorStatus.recording:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              state.userTranscription.isEmpty
                  ? AppStrings.simuladorListeningEs
                  : state.userTranscription,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: textSize,
                color: AppColors.darkText,
                fontStyle: state.userTranscription.isEmpty
                    ? FontStyle.italic
                    : FontStyle.normal,
              ),
            ),
            const SizedBox(height: 16),
            MicHoldButton(
              isRecording: true,
              isSenior: isSenior,
              onLongPressStart: notifier.startRecording,
              onLongPressEnd: notifier.stopRecordingAndAnalyze,
            ),
          ],
        );

      case SimuladorStatus.analyzing:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 8),
            Text(
              AppStrings.simuladorAnalyzingEs,
              style: TextStyle(fontSize: textSize, color: Colors.grey[600]),
            ),
          ],
        );

      case SimuladorStatus.feedback:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Continue button advances to next AI turn
            SizedBox(
              width: double.infinity,
              height: isSenior ? 64 : 56,
              child: ElevatedButton(
                onPressed: notifier.advanceToNextAiTurn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A085),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  AppStrings.simuladorContinueEs,
                  style: TextStyle(
                    fontSize: textSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            if (!state.isAcceptable) ...[
              const SizedBox(height: 10),
              TextButton(
                onPressed: notifier.retryTurn,
                child: Text(
                  AppStrings.simuladorRetryEs,
                  style: TextStyle(
                    fontSize: textSize - 2,
                    color: AppColors.terracotta,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        );

      case SimuladorStatus.complete:
        return _CompletionCard(
          isSenior: isSenior,
          textSize: textSize,
        );
    }
  }
}

// ── Completion card ────────────────────────────────────────────────────────────

class _CompletionCard extends StatelessWidget {
  const _CompletionCard({required this.isSenior, required this.textSize});

  final bool isSenior;
  final double textSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('🎉', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 8),
        Text(
          AppStrings.simuladorCompleteEs,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isSenior ? AppFontSizes.subtitleLarge : AppFontSizes.subtitle,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF16A085),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          AppStrings.simuladorCompleteBodyEs,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: textSize - 2,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          AppStrings.simuladorXpEarnedEs,
          style: TextStyle(
            fontSize: textSize,
            fontWeight: FontWeight.w700,
            color: AppColors.terracotta,
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          height: isSenior ? 64 : 56,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.terracotta,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              AppStrings.simuladorBackToDashboardEs,
              style: TextStyle(
                fontSize: textSize,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Offline banner ─────────────────────────────────────────────────────────────

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.isSenior});
  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.red[700],
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(
        AppStrings.simuladorOfflineEs,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: isSenior ? AppFontSizes.body : 16.0,
        ),
      ),
    );
  }
}

// ── Error banner ───────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.isSenior});
  final String message;
  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.orange[800],
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: isSenior ? AppFontSizes.body : 16.0,
        ),
      ),
    );
  }
}

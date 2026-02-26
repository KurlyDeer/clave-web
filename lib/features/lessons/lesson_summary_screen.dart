import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/persona_provider.dart';
import '../../core/providers/user_name_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_strings.dart';

class LessonSummaryScreen extends ConsumerStatefulWidget {
  const LessonSummaryScreen({
    super.key,
    required this.lessonId,
    required this.lessonTitle,
    required this.xpGained,
    required this.elapsedSeconds,
    required this.wordCount,
    required this.voiceScore,
    required this.stageAdvanced,
    required this.milestoneEs,
  });

  final int lessonId;
  final String lessonTitle;
  final int xpGained;
  final int elapsedSeconds;
  final int wordCount;
  final int voiceScore;
  final bool stageAdvanced;
  final String milestoneEs;

  @override
  ConsumerState<LessonSummaryScreen> createState() =>
      _LessonSummaryScreenState();
}

class _LessonSummaryScreenState extends ConsumerState<LessonSummaryScreen> {
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final persona = ref.read(personaProvider);
      if (persona == Persona.nino || widget.stageAdvanced) {
        _confettiController.play();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m}m ${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final persona = ref.watch(personaProvider);
    final userName = ref.watch(userNameProvider);
    final isSenior = persona?.isSeniorMode ?? false;
    final titleSize = isSenior ? AppFontSizes.titleLarge : AppFontSizes.title;
    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;

    if (widget.stageAdvanced) {
      return _MilestoneFullPage(
        confettiController: _confettiController,
        userName: userName.isNotEmpty
            ? userName
            : (persona?.displayName ?? 'Campeón'),
        milestoneEs: widget.milestoneEs,
        persona: persona,
        isSenior: isSenior,
        onContinue: () =>
            Navigator.of(context).popUntil((route) => route.isFirst == false
                ? route.settings.name == '/lessons' || route.isFirst
                : true),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.terracotta,
        foregroundColor: AppColors.lightText,
        title: Text(
          AppStrings.summaryTitle,
          style: TextStyle(
            fontSize: bodySize,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Persona celebration
                _CelebrationHeader(persona: persona, isSenior: isSenior),
                const SizedBox(height: 28),

                // Lesson title
                Text(
                  widget.lessonTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 28),

                // Stats grid
                _SummaryCard(
                  icon: '⏱',
                  label: AppStrings.summaryTimeLabel,
                  value: _formatTime(widget.elapsedSeconds),
                  isSenior: isSenior,
                ),
                const SizedBox(height: 12),
                _SummaryCard(
                  icon: '📚',
                  label: AppStrings.summaryWordsLabel,
                  value: '${widget.wordCount}',
                  isSenior: isSenior,
                ),
                const SizedBox(height: 12),
                _SummaryCard(
                  icon: '⭐',
                  label: AppStrings.summaryXpLabel,
                  value: '+${widget.xpGained} XP',
                  isSenior: isSenior,
                  highlight: true,
                ),
                const SizedBox(height: 12),
                _SummaryCard(
                  icon: '🎤',
                  label: AppStrings.summaryVoiceLabel,
                  value: '${widget.voiceScore}/100',
                  isSenior: isSenior,
                ),
                const SizedBox(height: 36),

                // Continue button
                SizedBox(
                  height: isSenior ? 72 : 60,
                  child: ElevatedButton(
                    onPressed: () {
                      // Pop back to lesson list
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.terracotta,
                      foregroundColor: AppColors.lightText,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      AppStrings.summaryContinueEs,
                      style: TextStyle(
                        fontSize: bodySize,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          // Confetti for niño
          if (persona == Persona.nino)
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                numberOfParticles: 30,
                maxBlastForce: 20,
                minBlastForce: 5,
                gravity: 0.3,
                colors: const [
                  AppColors.terracotta,
                  AppColors.deepBlue,
                  Colors.amber,
                  Colors.green,
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── Celebration header ─────────────────────────────────────────────────────────

class _CelebrationHeader extends StatelessWidget {
  const _CelebrationHeader({required this.persona, required this.isSenior});

  final Persona? persona;
  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    if (persona == Persona.abuelo) {
      return Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.amber[100],
              shape: BoxShape.circle,
              border: Border.all(color: Colors.amber[400]!, width: 3),
            ),
            child: const Center(
              child: Text('⭐', style: TextStyle(fontSize: 40)),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '¡Excelente trabajo!',
            style: TextStyle(
              fontSize: isSenior ? AppFontSizes.subtitleLarge : AppFontSizes.subtitle,
              fontWeight: FontWeight.w700,
              color: Colors.amber[800],
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Text(
          persona == Persona.nino ? '🎉🌟🎊' : '🎯✅',
          style: const TextStyle(fontSize: 48),
        ),
        const SizedBox(height: 8),
        Text(
          '¡Lección completada!',
          style: TextStyle(
            fontSize: isSenior ? AppFontSizes.subtitleLarge : AppFontSizes.subtitle,
            fontWeight: FontWeight.w700,
            color: AppColors.terracotta,
          ),
        ),
      ],
    );
  }
}

// ── Summary card ──────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.isSenior,
    this.highlight = false,
  });

  final String icon;
  final String label;
  final String value;
  final bool isSenior;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.terracotta.withValues(alpha: 0.08)
            : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlight ? AppColors.terracotta : AppColors.unselectedBorder,
          width: highlight ? 2 : 1,
        ),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: bodySize - 2,
                color: AppColors.darkText.withValues(alpha: 0.7),
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: bodySize,
              fontWeight: FontWeight.w800,
              color: highlight ? AppColors.terracotta : AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Milestone Full Page ────────────────────────────────────────────────────────

class _MilestoneFullPage extends StatelessWidget {
  const _MilestoneFullPage({
    required this.confettiController,
    required this.userName,
    required this.milestoneEs,
    required this.persona,
    required this.isSenior,
    required this.onContinue,
  });

  final ConfettiController confettiController;
  final String userName;
  final String milestoneEs;
  final Persona? persona;
  final bool isSenior;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final titleSize = isSenior ? AppFontSizes.headlineLarge : AppFontSizes.headline;
    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF0), // warm cream
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  Text(
                    AppStrings.milestoneFullPageTitleEs,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: bodySize,
                      color: AppColors.darkText.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w900,
                      color: AppColors.terracotta,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (persona == Persona.abuelo)
                    const Center(
                      child: Text('🏅', style: TextStyle(fontSize: 72)),
                    )
                  else
                    const Center(
                      child: Text('📖✨', style: TextStyle(fontSize: 64)),
                    ),
                  const SizedBox(height: 24),
                  Text(
                    milestoneEs,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isSenior
                          ? AppFontSizes.subtitleLarge
                          : AppFontSizes.subtitle,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppStrings.milestoneFullPageSubtitleEs,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: bodySize - 2,
                      color: AppColors.darkText.withValues(alpha: 0.6),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: isSenior ? 72 : 60,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.terracotta,
                        foregroundColor: AppColors.lightText,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: Text(
                        AppStrings.summaryContinueEs,
                        style: TextStyle(
                          fontSize: bodySize,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 40,
              maxBlastForce: 25,
              minBlastForce: 8,
              gravity: 0.3,
              colors: const [
                AppColors.terracotta,
                AppColors.deepBlue,
                Colors.amber,
                Colors.green,
                Colors.purple,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

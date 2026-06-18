import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/next_step_provider.dart';
import '../../../core/providers/persona_provider.dart';
import '../../../core/providers/study_plan_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../l10n/app_strings.dart';
import '../../libro/book_gallery_screen.dart';
import '../../libro/libro_screen.dart';
import '../../lessons/lesson_player_screen.dart';
import '../../repaso/repaso_screen.dart';

class FocusCardWidget extends ConsumerWidget {
  const FocusCardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final persona = ref.watch(personaProvider);
    final isSenior = persona?.isSeniorMode ?? false;
    final nextStep = ref.watch(nextStepProvider);
    final personaKey = persona?.name ?? 'adulto';

    final titleSize = isSenior ? AppFontSizes.titleLarge : AppFontSizes.title;
    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;

    String cardTitle;
    String cardSubtitle;

    switch (nextStep.type) {
      case NextStepType.vocabReview:
        cardTitle = AppStrings.repasoFocusCardTitleEs;
        cardSubtitle = nextStep.contextMessageEs;
        break;
      case NextStepType.lesson:
        final content = nextStep.lessonData!.forPersona(personaKey);
        final lessonLabel = nextStep.tierTitleEs != null
            ? '${nextStep.tierTitleEs} · ${nextStep.categoryTitleEs ?? ''}'
            : AppStrings.glassNextLessonEs;
        cardTitle = '$lessonLabel: ${content.titleEs}';
        cardSubtitle = content.topicEs;
        break;
      case NextStepType.bookPrompt:
        cardTitle = AppStrings.glassNextBookPromptEs;
        cardSubtitle = nextStep.bookPrompt?.promptEs ?? '';
        break;
      case NextStepType.allDone:
        cardTitle = AppStrings.glassAllLessonsCompleteEs;
        cardSubtitle = '';
        break;
    }

    return GlassContainer(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: label + time badge
          Row(
            children: [
              Text(
                AppStrings.glassNextStepTitleEs,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.glassTextMuted,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              if (nextStep.studyPlan != null)
                _TimeBadge(plan: nextStep.studyPlan!),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            cardTitle,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w700,
              color: AppColors.glassText,
              height: 1.3,
            ),
          ),
          if (cardSubtitle.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              cardSubtitle,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: TextStyle(
                fontSize: bodySize,
                color: AppColors.glassTextMuted,
              ),
            ),
          ],
          // Deep mode: secondary suggestion
          if (nextStep.secondarySuggestion != null) ...[
            const SizedBox(height: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.deepBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.deepBlue.withValues(alpha: 0.25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.tips_and_updates_rounded,
                      size: 14, color: AppColors.deepBlue),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      nextStep.secondarySuggestion!,
                      style: TextStyle(
                        fontSize: bodySize - 2,
                        color: AppColors.deepBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          _GlowingContinueButton(
            isSenior: isSenior,
            onPressed: () => _navigate(context, nextStep),
          ),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, NextStep nextStep) {
    switch (nextStep.type) {
      case NextStepType.vocabReview:
        Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => const RepasoScreen(),
        ));
        break;
      case NextStepType.lesson:
        Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => LessonPlayerScreen(lesson: nextStep.lessonData!),
        ));
        break;
      case NextStepType.bookPrompt:
        Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => LibroScreen(prompt: nextStep.bookPrompt),
        ));
        break;
      case NextStepType.allDone:
        Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => const BookGalleryScreen(),
        ));
        break;
    }
  }
}

// ── Time Badge ────────────────────────────────────────────────────────────────

class _TimeBadge extends StatelessWidget {
  const _TimeBadge({required this.plan});

  final StudyPlanDuration plan;

  Color get _color {
    switch (plan) {
      case StudyPlanDuration.quick:
        return Colors.green[600]!;
      case StudyPlanDuration.standard:
        return AppColors.deepBlue;
      case StudyPlanDuration.deep:
        return AppColors.glowTerracotta;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 12, color: _color),
          const SizedBox(width: 4),
          Text(
            plan.labelEs,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Glowing Continue Button ───────────────────────────────────────────────────

class _GlowingContinueButton extends StatelessWidget {
  const _GlowingContinueButton({
    required this.isSenior,
    required this.onPressed,
  });

  final bool isSenior;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final buttonHeight = isSenior ? 72.0 : 60.0;
    final textSize =
        isSenior ? AppFontSizes.subtitleLarge : AppFontSizes.subtitle;

    return SizedBox(
      height: buttonHeight,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.glowTerracotta.withValues(alpha: 0.4),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.glowTerracotta,
            foregroundColor: AppColors.lightText,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Text(
            AppStrings.glassContinueEs,
            style: TextStyle(
              fontSize: textSize,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

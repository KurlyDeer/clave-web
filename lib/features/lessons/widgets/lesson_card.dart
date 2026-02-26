import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/lesson_models.dart';
import '../../../core/providers/lesson_progress_provider.dart';
import '../../../core/providers/persona_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_strings.dart';
import '../lesson_player_screen.dart';

class LessonCard extends ConsumerWidget {
  const LessonCard({super.key, required this.lesson});

  final LessonData lesson;

  Color get _levelColor {
    switch (lesson.level) {
      case AppStrings.lessonLevelBasico:
        return Colors.green[700]!;
      case AppStrings.lessonLevelIntermedio:
        return Colors.orange[700]!;
      default:
        return Colors.red[700]!;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final persona = ref.watch(personaProvider);
    final isSenior = persona?.isSeniorMode ?? false;
    final personaKey = persona?.name ?? 'adulto';
    final progress = ref.watch(lessonProgressProvider(lesson.id));
    final isCompleted = progress?.completed ?? false;
    final content = lesson.forPersona(personaKey);

    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;
    final buttonHeight = isSenior ? 60.0 : 52.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: number badge + level chip + completed badge
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.terracotta.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '${lesson.id}',
                      style: TextStyle(
                        fontSize: bodySize - 2,
                        fontWeight: FontWeight.w800,
                        color: AppColors.terracotta,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _levelColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    lesson.level,
                    style: TextStyle(
                      fontSize: bodySize - 4,
                      fontWeight: FontWeight.w700,
                      color: _levelColor,
                    ),
                  ),
                ),
                const Spacer(),
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green[300]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded,
                            color: Colors.green[700], size: 14),
                        const SizedBox(width: 4),
                        Text(
                          AppStrings.lessonCompleteLabel,
                          style: TextStyle(
                            fontSize: bodySize - 6,
                            fontWeight: FontWeight.w700,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            // Title
            Text(
              content.titleEs,
              style: TextStyle(
                fontSize: bodySize,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              content.titleEn,
              style: TextStyle(
                fontSize: bodySize - 4,
                color: AppColors.darkText.withValues(alpha: 0.55),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 6),
            // Topic tag
            Text(
              content.topicEs,
              style: TextStyle(
                fontSize: bodySize - 4,
                color: AppColors.deepBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
            // Score if completed
            if (isCompleted && progress != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.mic, size: 14, color: Colors.green[700]),
                  const SizedBox(width: 4),
                  Text(
                    '${AppStrings.retoScoreLabelEs} ${progress.voiceScore}/100',
                    style: TextStyle(
                      fontSize: bodySize - 4,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            // Action button
            SizedBox(
              height: buttonHeight,
              width: double.infinity,
              child: isCompleted
                  ? OutlinedButton(
                      onPressed: () => _openLesson(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: AppColors.deepBlue, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        AppStrings.lessonReviewEs,
                        style: TextStyle(
                          fontSize: bodySize - 2,
                          fontWeight: FontWeight.w700,
                          color: AppColors.deepBlue,
                        ),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () => _openLesson(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.terracotta,
                        foregroundColor: AppColors.lightText,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      child: Text(
                        AppStrings.lessonStartEs,
                        style: TextStyle(
                          fontSize: bodySize - 2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _openLesson(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LessonPlayerScreen(lesson: lesson),
      ),
    );
  }
}

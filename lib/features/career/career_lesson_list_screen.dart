import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/career_curriculum_data.dart';
import '../../core/models/career_model.dart';
import '../../core/models/lesson_models.dart';
import '../../core/providers/lesson_progress_provider.dart';
import '../../core/providers/persona_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_strings.dart';
import '../lessons/lesson_player_screen.dart';

class CareerLessonListScreen extends ConsumerWidget {
  const CareerLessonListScreen({super.key, required this.track});

  final CareerTrack track;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final persona    = ref.watch(personaProvider);
    final isSenior   = persona?.isSeniorMode ?? false;
    final personaKey = persona?.name ?? 'adulto';

    final lessons = CareerCurriculumData.forTrack(track.lessonIds);

    // Count completions within this track.
    int completedCount = 0;
    for (final lesson in lessons) {
      final progress = ref.watch(lessonProgressProvider(lesson.id));
      if (progress?.completed ?? false) completedCount++;
    }

    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.terracotta,
        foregroundColor: Colors.white,
        title: Text(
          '${track.emoji} ${track.titleEs}',
          style: TextStyle(
            fontSize: isSenior ? AppFontSizes.subtitle : AppFontSizes.body,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              itemCount: lessons.length,
              itemBuilder: (context, index) {
                final lesson = lessons[index];
                final label  = '${track.emoji} ${index + 1}/3';
                return _CareerLessonCard(
                  lesson:     lesson,
                  lessonLabel: label,
                  isSenior:   isSenior,
                  personaKey: personaKey,
                );
              },
            ),
          ),
          Container(
            width: double.infinity,
            color: AppColors.deepBlue,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Text(
              '$completedCount ${AppStrings.lessonSlideOfEs} ${lessons.length} ${AppStrings.lessonProgressSummaryEs}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.lightText,
                fontSize: bodySize - 2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CareerLessonCard extends ConsumerWidget {
  const _CareerLessonCard({
    required this.lesson,
    required this.lessonLabel,
    required this.isSenior,
    required this.personaKey,
  });

  final LessonData lesson;
  final String lessonLabel;
  final bool isSenior;
  final String personaKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress    = ref.watch(lessonProgressProvider(lesson.id));
    final isCompleted = progress?.completed ?? false;
    final content     = lesson.forPersona(personaKey);

    final bodySize    = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;
    final buttonHeight= isSenior ? 60.0 : 52.0;

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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.terracotta.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    lesson.level,
                    style: TextStyle(
                      fontSize: bodySize - 4,
                      fontWeight: FontWeight.w700,
                      color: AppColors.terracotta,
                    ),
                  ),
                ),
                const Spacer(),
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
            Text(
              content.topicEs,
              style: TextStyle(
                fontSize: bodySize - 4,
                color: AppColors.deepBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
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
        builder: (_) => LessonPlayerScreen(
          lesson: lesson,
          lessonLabel: lessonLabel,
        ),
      ),
    );
  }
}

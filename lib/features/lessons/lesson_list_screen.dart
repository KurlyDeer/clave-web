import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/curriculum_structure.dart';
import '../../core/providers/lesson_progress_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_strings.dart';
import '../../shared/widgets/offline_banner.dart';
import 'widgets/lesson_card.dart';

class LessonListScreen extends ConsumerWidget {
  const LessonListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedCount = ref.watch(completedLessonCountProvider);
    final totalLessons = CurriculumStructure.allLessons
        .where((l) => !l.isPlaceholder)
        .length;
    final realLessons = CurriculumStructure.allLessons
        .where((l) => !l.isPlaceholder)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.terracotta,
        foregroundColor: Colors.white,
        title: Text(
          '${AppStrings.dashboardLessonsEs}  •  ${AppStrings.dashboardLessonsEn}',
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: const TextStyle(
            fontSize: AppFontSizes.body,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              itemCount: realLessons.length,
              itemBuilder: (context, index) {
                return LessonCard(lesson: realLessons[index]);
              },
            ),
          ),
          // Completion summary footer
          Container(
            width: double.infinity,
            color: AppColors.deepBlue,
            padding: EdgeInsets.fromLTRB(20, 14, 20, 14 + MediaQuery.of(context).padding.bottom),
            child: Text(
              '$completedCount ${AppStrings.lessonSlideOfEs} $totalLessons ${AppStrings.lessonProgressSummaryEs}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.lightText,
                fontSize: AppFontSizes.body,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

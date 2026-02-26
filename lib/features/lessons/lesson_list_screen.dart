import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/curriculum_data.dart';
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

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.terracotta,
        foregroundColor: Colors.white,
        title: Text(
          '${AppStrings.dashboardLessonsEs}  •  ${AppStrings.dashboardLessonsEn}',
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
              itemCount: CurriculumData.all.length,
              itemBuilder: (context, index) {
                return LessonCard(lesson: CurriculumData.all[index]);
              },
            ),
          ),
          // Completion summary footer
          Container(
            width: double.infinity,
            color: AppColors.deepBlue,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Text(
              '$completedCount ${AppStrings.lessonSlideOfEs} 10 ${AppStrings.lessonProgressSummaryEs}',
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

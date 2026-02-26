import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/lesson_progress_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../l10n/app_strings.dart';

class LiquidProgressWidget extends ConsumerWidget {
  const LiquidProgressWidget({super.key});

  static const int _totalLessons = 10;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedCount = ref.watch(completedLessonCountProvider);
    final fillFraction = (completedCount / _totalLessons).clamp(0.0, 1.0);
    final percent = (fillFraction * 100).round();

    return GlassContainer(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                AppStrings.glassProgressTitleEs,
                style: TextStyle(
                  fontSize: AppFontSizes.body,
                  fontWeight: FontWeight.w700,
                  color: AppColors.glassText,
                ),
              ),
              Text(
                '$percent%',
                style: const TextStyle(
                  fontSize: AppFontSizes.body,
                  fontWeight: FontWeight.w700,
                  color: AppColors.glowTerracotta,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Animated liquid fill bar driven by completed lesson count
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 10,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: AppColors.glassHighlight),
                  AnimatedFractionallySizedBox(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.centerLeft,
                    widthFactor: fillFraction,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.glowTerracotta,
                            AppColors.terracotta,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$completedCount / $_totalLessons ${AppStrings.glassProgressLessonsEs}',
            style: const TextStyle(
              fontSize: AppFontSizes.body,
              color: AppColors.glassTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}

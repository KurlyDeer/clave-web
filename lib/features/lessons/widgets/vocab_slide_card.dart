import 'package:flutter/material.dart';

import '../../../core/models/lesson_models.dart';
import '../../../core/theme/app_theme.dart';

class VocabSlideCard extends StatelessWidget {
  const VocabSlideCard({
    super.key,
    required this.slide,
    required this.isSenior,
  });

  final LessonSlide slide;
  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    final headlineSize =
        isSenior ? AppFontSizes.headlineLarge : AppFontSizes.headline;
    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          // Main word card
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  slide.contentEn,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: headlineSize,
                    fontWeight: FontWeight.w800,
                    color: AppColors.terracotta,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 2,
                  width: 60,
                  color: AppColors.unselectedBorder,
                ),
                const SizedBox(height: 12),
                Text(
                  slide.contentEs,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: bodySize + 2,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
              ],
            ),
          ),
          // Example sentence
          if (slide.exampleEn != null || slide.exampleEs != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.deepBlue.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.deepBlue.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (slide.exampleEn != null) ...[
                    Text(
                      slide.exampleEn!,
                      style: TextStyle(
                        fontSize: bodySize,
                        fontWeight: FontWeight.w500,
                        color: AppColors.darkText,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                  ],
                  if (slide.exampleEs != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      slide.exampleEs!,
                      style: TextStyle(
                        fontSize: bodySize - 2,
                        color: AppColors.darkText.withValues(alpha: 0.6),
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

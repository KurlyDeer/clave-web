import 'package:flutter/material.dart';

import '../../../core/models/lesson_models.dart';
import '../../../core/theme/app_theme.dart';

class IntroSlideCard extends StatelessWidget {
  const IntroSlideCard({
    super.key,
    required this.content,
    required this.lessonId,
    required this.isSenior,
  });

  final PersonaContent content;
  final String lessonId;
  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    final titleSize = isSenior ? AppFontSizes.titleLarge : AppFontSizes.title;
    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.terracotta.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                content.topicEs.split(' ').first,
                style: const TextStyle(fontSize: 40),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            content.titleEs,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content.titleEn,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: bodySize,
              color: AppColors.darkText.withValues(alpha: 0.55),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.deepBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              content.topicEs,
              style: TextStyle(
                fontSize: bodySize - 2,
                color: AppColors.deepBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(16),
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
            child: Column(
              children: [
                Text(
                  'Esta lección tiene 4 pasos',
                  style: TextStyle(
                    fontSize: bodySize - 2,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StepChip(emoji: '📝', label: 'Vocab', bodySize: bodySize),
                    _StepChip(emoji: '📝', label: 'Vocab', bodySize: bodySize),
                    _StepChip(emoji: '💬', label: 'Frase', bodySize: bodySize),
                    _StepChip(emoji: '❓', label: 'Quiz', bodySize: bodySize),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _StepChip extends StatelessWidget {
  const _StepChip({
    required this.emoji,
    required this.label,
    required this.bodySize,
  });

  final String emoji;
  final String label;
  final double bodySize;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: bodySize - 4,
            color: AppColors.darkText.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

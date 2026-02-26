import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_strings.dart';

/// Single AI coaching tip shown below the heatmap.
class CoachingTipCard extends StatelessWidget {
  const CoachingTipCard({
    super.key,
    required this.tipEs,
    required this.score,
    required this.isSenior,
  });

  final String tipEs;
  final int score;
  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;
    final smallSize = bodySize - 2;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.deepBlue.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.deepBlue.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                AppStrings.analizadorCoachTipLabelEs,
                style: TextStyle(
                  fontSize: smallSize,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepBlue,
                ),
              ),
              const Spacer(),
              // Score badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _scoreColor(score).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _scoreColor(score).withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  '${AppStrings.analizadorScoreLabelEs} $score',
                  style: TextStyle(
                    fontSize: smallSize - 1,
                    fontWeight: FontWeight.w700,
                    color: _scoreColor(score),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            tipEs,
            style: TextStyle(
              fontSize: bodySize,
              color: AppColors.darkText,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Color _scoreColor(int score) {
    if (score >= 80) return const Color(0xFF27AE60);
    if (score >= 60) return const Color(0xFFF39C12);
    return const Color(0xFFE74C3C);
  }
}

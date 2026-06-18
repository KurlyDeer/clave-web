import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../l10n/app_strings.dart';

/// Single AI coaching tip shown below the heatmap — glass style.
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
    final scoreColor = _scoreGlowColor(score);

    return GlassContainer(
      padding: const EdgeInsets.all(18),
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
                  color: AppColors.glassText,
                ),
              ),
              const Spacer(),
              // Score badge with traffic-light glow
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.glassSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: scoreColor.withAlpha(200)),
                  boxShadow: [
                    BoxShadow(
                      color: scoreColor.withAlpha(100),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Text(
                  '${AppStrings.analizadorScoreLabelEs} $score',
                  style: TextStyle(
                    fontSize: smallSize - 1,
                    fontWeight: FontWeight.w700,
                    color: scoreColor,
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
              color: AppColors.glassText,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Color _scoreGlowColor(int score) {
    if (score >= 80) return const Color(0xFF27AE60); // green
    if (score >= 60) return const Color(0xFFF39C12); // amber
    return const Color(0xFFE74C3C);                  // red
  }
}

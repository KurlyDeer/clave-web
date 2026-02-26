import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_strings.dart';

class ResultSlideCard extends StatelessWidget {
  const ResultSlideCard({
    super.key,
    required this.score,
    required this.feedbackEs,
    required this.isSenior,
    required this.onTryAgain,
  });

  final int score;
  final String feedbackEs;
  final bool isSenior;
  final VoidCallback onTryAgain;

  Color get _scoreColor {
    if (score >= 80) return Colors.green[600]!;
    if (score >= 50) return Colors.orange[700]!;
    return Colors.red[600]!;
  }

  String get _scoreEmoji {
    if (score >= 80) return '🎉';
    if (score >= 50) return '👍';
    return '💪';
  }

  @override
  Widget build(BuildContext context) {
    final titleSize = isSenior ? AppFontSizes.titleLarge : AppFontSizes.title;
    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;
    final retryHeight = isSenior ? 60.0 : 52.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Text(
            '$_scoreEmoji ${AppStrings.retoScoreLabelEs}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: bodySize,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          // Score display
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _scoreColor.withValues(alpha: 0.12),
                border: Border.all(color: _scoreColor, width: 3),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$score',
                      style: TextStyle(
                        fontSize: titleSize + 6,
                        fontWeight: FontWeight.w900,
                        color: _scoreColor,
                      ),
                    ),
                    Text(
                      '/ 100',
                      style: TextStyle(
                        fontSize: bodySize - 4,
                        color: _scoreColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Score bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: score / 100.0,
              minHeight: 14,
              backgroundColor: AppColors.unselectedBorder,
              valueColor: AlwaysStoppedAnimation<Color>(_scoreColor),
            ),
          ),
          // Feedback
          if (feedbackEs.isNotEmpty) ...[
            const SizedBox(height: 20),
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
              child: Text(
                feedbackEs,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: bodySize,
                  color: AppColors.darkText,
                  height: 1.5,
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          // Try again option
          SizedBox(
            height: retryHeight,
            child: OutlinedButton(
              onPressed: onTryAgain,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.deepBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                AppStrings.retoTryAgainEs,
                style: TextStyle(
                  fontSize: bodySize - 2,
                  color: AppColors.deepBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

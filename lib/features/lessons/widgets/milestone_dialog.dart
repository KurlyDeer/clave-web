import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_strings.dart';

class MilestoneDialog extends StatelessWidget {
  const MilestoneDialog({
    super.key,
    required this.stageIndex,
    required this.milestoneEs,
    required this.isSenior,
  });

  final int stageIndex;
  final String milestoneEs;
  final bool isSenior;

  String get _stageName {
    if (stageIndex < AppStrings.roadmapStages.length) {
      return AppStrings.roadmapStages[stageIndex];
    }
    return '📚 ¡Soy Autor!';
  }

  @override
  Widget build(BuildContext context) {
    final titleSize = isSenior ? AppFontSizes.titleLarge : AppFontSizes.title;
    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;
    final buttonHeight = isSenior ? 72.0 : 60.0;

    return Dialog(
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text(
              AppStrings.milestoneTitleEs,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.w800,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 16),
            // Stage chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.terracotta.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.terracotta.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                _stageName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: bodySize - 2,
                  fontWeight: FontWeight.w700,
                  color: AppColors.terracotta,
                ),
              ),
            ),
            if (milestoneEs.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                milestoneEs,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: bodySize,
                  color: AppColors.darkText.withValues(alpha: 0.8),
                  height: 1.5,
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              height: buttonHeight,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.terracotta,
                  foregroundColor: AppColors.lightText,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                ),
                child: Text(
                  AppStrings.milestoneContinueEs,
                  style: TextStyle(
                    fontSize: bodySize,
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
}

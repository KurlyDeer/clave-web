import 'package:flutter/material.dart';

import '../../../core/providers/xp_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_strings.dart';

class XpLevelWidget extends StatelessWidget {
  const XpLevelWidget({
    super.key,
    required this.xpState,
    required this.isSenior,
  });

  final XpState xpState;
  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;

    return Row(
      children: [
        // Level badge circle
        Container(
          width: isSenior ? 52 : 44,
          height: isSenior ? 52 : 44,
          decoration: const BoxDecoration(
            color: AppColors.terracotta,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${xpState.level}',
              style: TextStyle(
                fontSize: bodySize,
                fontWeight: FontWeight.w800,
                color: AppColors.lightText,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                xpState.levelTitle,
                style: TextStyle(
                  fontSize: bodySize - 2,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: xpState.levelProgress,
                  minHeight: 8,
                  backgroundColor: AppColors.unselectedBorder,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.terracotta,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                xpState.level < 20
                    ? '${xpState.xpToNextLevel} XP ${AppStrings.xpToNextLevelLabel}'
                    : '¡Nivel máximo!',
                style: TextStyle(
                  fontSize: bodySize - 4,
                  color: AppColors.darkText.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

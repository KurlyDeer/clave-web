import 'package:flutter/material.dart';

import '../../../core/models/scenario_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_strings.dart';

class ScenarioHeader extends StatelessWidget {
  const ScenarioHeader({
    super.key,
    required this.scenario,
    required this.isSenior,
    this.isDark = false,
  });

  final ScenarioData scenario;
  final bool isSenior;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final nameSize = isSenior ? AppFontSizes.subtitleLarge : AppFontSizes.subtitle;
    final roleSize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.glassSurface : AppColors.cardBackground,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            width: isSenior ? 56 : 48,
            height: isSenior ? 56 : 48,
            decoration: BoxDecoration(
              color: Color(0xFF16A085),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                scenario.iconEmoji,
                style: TextStyle(fontSize: isSenior ? 28 : 24),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scenario.characterNameEn,
                  style: TextStyle(
                    fontSize: nameSize,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.glassText : AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${AppStrings.simuladorCharacterRoleLabel} ${scenario.characterRoleEs}',
                  style: TextStyle(
                    fontSize: roleSize,
                    color: isDark ? AppColors.glassTextMuted : Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

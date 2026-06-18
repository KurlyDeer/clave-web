import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../../l10n/app_strings.dart';
import 'glass_container.dart';

/// Shown when STT confidence is below the 0.7 threshold.
/// Prompts the user to record again without triggering a Claude call.
class SttLowConfidenceTooltip extends StatelessWidget {
  const SttLowConfidenceTooltip({super.key, required this.fontSize});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            Icons.hearing_disabled_rounded,
            color: AppColors.terracotta,
            size: fontSize + 4,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppStrings.sttLowConfidenceEs,
              style: TextStyle(
                fontSize: fontSize,
                color: AppColors.terracotta,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

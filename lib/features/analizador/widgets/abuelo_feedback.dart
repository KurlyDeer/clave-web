import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../l10n/app_strings.dart';

/// Abuelo-mode result: big thumbs emoji inside a glass card + two glass action buttons.
/// Avoids the complex heatmap and shows simple pass/fail feedback.
class AbueloFeedback extends StatelessWidget {
  const AbueloFeedback({
    super.key,
    required this.thumbsUp,
    required this.onListenSlow,
    required this.onRetry,
  });

  final bool thumbsUp;
  final VoidCallback onListenSlow;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final resultColor =
        thumbsUp ? const Color(0xFF27AE60) : const Color(0xFFE74C3C);

    return Column(
      children: [
        // ── Result card ──────────────────────────────────────────────────────
        GlassContainer(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
          borderColor: resultColor.withAlpha(150),
          child: Column(
            children: [
              Text(
                thumbsUp ? '👍' : '👎',
                style: TextStyle(fontSize: 72),
              ),
              const SizedBox(height: 14),
              Text(
                thumbsUp
                    ? AppStrings.analizadorAbueloGoodEs
                    : AppStrings.analizadorAbueloRetryEs,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppFontSizes.subtitleLarge,
                  fontWeight: FontWeight.w800,
                  color: resultColor,
                ),
              ),
              if (thumbsUp) ...[
                const SizedBox(height: 8),
                const Text(
                  AppStrings.analizadorXpEarnedSmallEs,
                  style: TextStyle(
                    fontSize: AppFontSizes.body,
                    fontWeight: FontWeight.w700,
                    color: Colors.amber,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ── Listen at slow speed ─────────────────────────────────────────────
        GestureDetector(
          onTap: onListenSlow,
          child: GlassContainer(
            padding:
                const EdgeInsets.symmetric(vertical: 22, horizontal: 24),
            borderColor: AppColors.glowTerracotta.withAlpha(150),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.volume_up_rounded,
                    color: AppColors.glassText, size: 28),
                SizedBox(width: 12),
                Text(
                  AppStrings.analizadorListenSlowEs,
                  style: TextStyle(
                    fontSize: AppFontSizes.bodyLarge,
                    fontWeight: FontWeight.w700,
                    color: AppColors.glassText,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        // ── Retry ────────────────────────────────────────────────────────────
        GestureDetector(
          onTap: onRetry,
          child: GlassContainer(
            padding:
                const EdgeInsets.symmetric(vertical: 22, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.refresh_rounded,
                    color: AppColors.glassText, size: 28),
                SizedBox(width: 12),
                Text(
                  AppStrings.analizadorTryAgainEs,
                  style: TextStyle(
                    fontSize: AppFontSizes.bodyLarge,
                    fontWeight: FontWeight.w700,
                    color: AppColors.glassText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_strings.dart';

/// Abuelo-mode result: big thumbs emoji + two action buttons.
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
    final bg = thumbsUp
        ? const Color(0xFF27AE60).withValues(alpha: 0.09)
        : const Color(0xFFE74C3C).withValues(alpha: 0.09);
    final border = thumbsUp
        ? const Color(0xFF27AE60).withValues(alpha: 0.35)
        : const Color(0xFFE74C3C).withValues(alpha: 0.35);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: border, width: 2),
          ),
          child: Column(
            children: [
              Text(
                thumbsUp ? '👍' : '👎',
                style: const TextStyle(fontSize: 72),
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
                  color: thumbsUp
                      ? const Color(0xFF27AE60)
                      : const Color(0xFFE74C3C),
                ),
              ),
              if (thumbsUp) ...[
                const SizedBox(height: 8),
                Text(
                  AppStrings.analizadorXpEarnedSmallEs,
                  style: const TextStyle(
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

        // Listen at 0.75x speed
        SizedBox(
          height: 72,
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onListenSlow,
            icon: const Icon(Icons.volume_up_rounded, size: 28),
            label: const Text(
              AppStrings.analizadorListenSlowEs,
              style: TextStyle(
                fontSize: AppFontSizes.bodyLarge,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.deepBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Retry
        SizedBox(
          height: 72,
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 28),
            label: const Text(
              AppStrings.analizadorTryAgainEs,
              style: TextStyle(
                fontSize: AppFontSizes.bodyLarge,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.terracotta,
              side: const BorderSide(color: AppColors.terracotta, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

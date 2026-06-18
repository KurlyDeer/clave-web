import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/gamification_controller.dart';
import '../../../core/providers/streak_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_strings.dart';

class StreakWidget extends ConsumerWidget {
  const StreakWidget({super.key, required this.isSenior});

  final bool isSenior;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(streakProvider);
    final isMissedDay = ref.watch(gamificationProvider).isMissedDay;
    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;

    if (streak == null || streak.currentStreak == 0) {
      return _StreakCard(
        isSenior: isSenior,
        child: Text(
          AppStrings.streakStartTodayEs,
          style: TextStyle(
            fontSize: bodySize - 2,
            color: AppColors.darkText.withValues(alpha: 0.7),
          ),
        ),
      );
    }

    if (isMissedDay) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.amber[50],
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.amber[300]!, width: 1.5),
        ),
        child: Row(
          children: [
            const Text('🔥', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                AppStrings.streakEncouragementEs,
                style: TextStyle(
                  fontSize: bodySize - 2,
                  color: Colors.amber[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return _StreakCard(
      isSenior: isSenior,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Text(
            '${streak.currentStreak}',
            style: TextStyle(
              fontSize: bodySize,
              fontWeight: FontWeight.w800,
              color: AppColors.terracotta,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            AppStrings.streakDaysLabel,
            style: TextStyle(
              fontSize: bodySize - 2,
              color: AppColors.darkText.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.isSenior, required this.child});

  final bool isSenior;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: child,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/gamification_controller.dart';
import '../../../core/providers/streak_provider.dart';
import '../../../core/providers/vocab_provider.dart';
import '../../../core/providers/xp_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../l10n/app_strings.dart';

class StatsTilesWidget extends ConsumerWidget {
  const StatsTilesWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final xp = ref.watch(xpProvider);
    final streak = ref.watch(streakProvider);
    final vocabStats = ref.watch(vocabStatsProvider);
    final gamification = ref.watch(gamificationProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                _StatTile(
                  icon: Icons.bolt,
                  value: '${xp.totalXp}',
                  label: AppStrings.glassStatsXpEs,
                ),
                const SizedBox(height: 12),
                _StatTile(
                  icon: Icons.local_fire_department,
                  value: '${streak?.currentStreak ?? 0}',
                  label: AppStrings.glassStatsStreakEs,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                _StatTile(
                  icon: Icons.translate,
                  value: '${vocabStats.total}',
                  label: AppStrings.glassStatsWordsEs,
                ),
                const SizedBox(height: 12),
                _StatTile(
                  icon: Icons.emoji_events,
                  value: '${xp.level}',
                  label: gamification.levelTitle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Single stat tile ──────────────────────────────────────────────────────────

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.glowTerracotta, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: AppFontSizes.title,
              fontWeight: FontWeight.w800,
              color: AppColors.glassText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.glassTextMuted,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

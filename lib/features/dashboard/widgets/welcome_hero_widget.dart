import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/next_step_provider.dart';
import '../../../core/providers/persona_provider.dart';
import '../../../core/providers/user_name_provider.dart';
import '../../../core/providers/xp_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_container.dart';

class WelcomeHeroWidget extends ConsumerWidget {
  const WelcomeHeroWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final persona = ref.watch(personaProvider);
    final isSenior = persona?.isSeniorMode ?? false;
    final name = ref.watch(userNameProvider);
    final nextStep = ref.watch(nextStepProvider);
    final xp = ref.watch(xpProvider);

    final headlineSize =
        isSenior ? AppFontSizes.headlineLarge : AppFontSizes.headline;
    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;

    final greeting =
        name.trim().isNotEmpty ? '¡Hola, ${name.trim()}!' : '¡Hola!';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting + context subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: TextStyle(
                    fontSize: headlineSize,
                    fontWeight: FontWeight.w800,
                    color: AppColors.glassText,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  nextStep.contextMessageEs,
                  style: TextStyle(
                    fontSize: bodySize,
                    color: AppColors.glassTextMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // XP frosted-glass badge — top right of dashboard
          _XpBadge(totalXp: xp.totalXp, isSenior: isSenior),
        ],
      ),
    );
  }
}

// ── XP Badge ──────────────────────────────────────────────────────────────────

class _XpBadge extends StatelessWidget {
  const _XpBadge({required this.totalXp, required this.isSenior});

  final int totalXp;
  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    final fontSize = isSenior ? 16.0 : 13.0;
    final iconSize = isSenior ? 20.0 : 16.0;

    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt, color: AppColors.glowTerracotta, size: iconSize),
          const SizedBox(width: 4),
          Text(
            '$totalXp XP',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: AppColors.glassText,
            ),
          ),
        ],
      ),
    );
  }
}

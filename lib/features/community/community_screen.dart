import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/community_provider.dart';
import '../../core/providers/persona_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_strings.dart';
import 'widgets/win_card.dart';

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state    = ref.watch(communityProvider);
    final persona  = ref.watch(personaProvider);
    final isSenior = persona?.isSeniorMode ?? false;

    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;

    final headerText = switch (persona) {
      Persona.nino   => AppStrings.communityHeaderNinoEs,
      Persona.abuelo => AppStrings.communityHeaderAbueloEs,
      _              => AppStrings.communityHeaderAdultoEs,
    };

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.terracotta,
        foregroundColor: Colors.white,
        title: Text(
          AppStrings.communityTitleEs,
          style: TextStyle(
            fontSize: isSenior ? AppFontSizes.subtitle : AppFontSizes.body,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          // ── Header ─────────────────────────────────────────
          Text(
            headerText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: bodySize + 2,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // ── Win cards ───────────────────────────────────────
          for (final post in state.posts)
            WinCard(
              post: post,
              celebrationCount: state.countFor(post.id),
              isSenior: isSenior,
              onCelebrate: () =>
                  ref.read(communityProvider.notifier).celebrate(post.id),
            ),

          // ── Footer ──────────────────────────────────────────
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.deepBlue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.deepBlue.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              AppStrings.communityFooterEs,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: bodySize,
                fontWeight: FontWeight.w600,
                color: AppColors.deepBlue,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

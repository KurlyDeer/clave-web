import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_container.dart';
import '../../l10n/app_strings.dart';
import '../persona/persona_screen.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.glassGradientStart,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.glassGradientStart,
              AppColors.glassGradientMid,
              AppColors.glassGradientEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _AppLogo(),
                const SizedBox(height: 32),
                const _WelcomeMessage(),
                const SizedBox(height: 40),
                _StartButton(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PersonaScreen()),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Logo / Header ──────────────────────────────────────────────────────────────

class _AppLogo extends StatelessWidget {
  const _AppLogo();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GlassContainer(
          padding: const EdgeInsets.all(20),
          borderRadius: 22,
          child: Text('🌉', style: TextStyle(fontSize: 48)),
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.appName,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppFontSizes.headline,
            fontWeight: FontWeight.w800,
            color: AppColors.glassText,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          AppStrings.appTaglineEs,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppFontSizes.subtitle,
            color: AppColors.glassText,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          AppStrings.appTaglineEn,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppFontSizes.body,
            color: AppColors.glassTextMuted,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

// ── Welcome Message ────────────────────────────────────────────────────────────

class _WelcomeMessage extends StatelessWidget {
  const _WelcomeMessage();

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      backgroundColor: Color(0xFF2E86C1).withValues(alpha: 0.25),
      borderColor: AppColors.deepBlue.withValues(alpha: 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.welcomeGreeting,
            style: TextStyle(
              fontSize: AppFontSizes.title,
              fontWeight: FontWeight.w800,
              color: AppColors.glassText,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            AppStrings.welcomeBodyEs,
            style: TextStyle(
              fontSize: AppFontSizes.body,
              color: AppColors.glassText,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: AppColors.glassText.withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          Text(
            AppStrings.welcomeBodyEn,
            style: TextStyle(
              fontSize: AppFontSizes.body - 1,
              color: AppColors.glassTextMuted,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Start Button ───────────────────────────────────────────────────────────────

class _StartButton extends StatelessWidget {
  const _StartButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.glowTerracotta.withValues(alpha: 0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: SizedBox(
        height: 60,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.glowTerracotta,
            foregroundColor: AppColors.lightText,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Text(
            '${AppStrings.ctaStartEs}  •  ${AppStrings.ctaStartEn}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppFontSizes.subtitle,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}

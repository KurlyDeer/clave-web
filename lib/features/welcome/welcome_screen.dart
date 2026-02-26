import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_strings.dart';
import '../persona/persona_screen.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
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
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: AppColors.terracotta,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              '🌉',
              style: TextStyle(fontSize: 48),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          AppStrings.appName,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppFontSizes.headline,
            fontWeight: FontWeight.w800,
            color: AppColors.terracotta,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          AppStrings.appTaglineEs,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppFontSizes.subtitle,
            color: AppColors.deepBlue,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          AppStrings.appTaglineEn,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppFontSizes.body,
            color: AppColors.deepBlue.withValues(alpha: 0.65),
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.deepBlue,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.welcomeGreeting,
            style: TextStyle(
              fontSize: AppFontSizes.title,
              fontWeight: FontWeight.w800,
              color: AppColors.lightText,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            AppStrings.welcomeBodyEs,
            style: TextStyle(
              fontSize: AppFontSizes.body,
              color: AppColors.lightText,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: AppColors.lightText.withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          Text(
            AppStrings.welcomeBodyEn,
            style: TextStyle(
              fontSize: AppFontSizes.body - 1,
              color: AppColors.lightText.withValues(alpha: 0.75),
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
    return SizedBox(
      height: 60,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.terracotta,
          foregroundColor: AppColors.lightText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: const Text(
          '${AppStrings.ctaStartEs}  •  ${AppStrings.ctaStartEn}',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppFontSizes.subtitle,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

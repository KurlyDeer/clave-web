import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/persona_provider.dart';
import '../../core/providers/pro_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_strings.dart';
import 'privacy_screen.dart';

class ProUpgradeScreen extends ConsumerWidget {
  const ProUpgradeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state   = ref.watch(proProvider);
    final persona = ref.watch(personaProvider);
    final isSenior = persona?.isSeniorMode ?? false;

    final titleSize  = isSenior ? AppFontSizes.titleLarge   : AppFontSizes.title;
    final bodySize   = isSenior ? AppFontSizes.bodyLarge    : AppFontSizes.body;
    final btnHeight  = isSenior ? 72.0 : 60.0;
    final btnTextSize= isSenior ? AppFontSizes.subtitleLarge : AppFontSizes.subtitle;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.terracotta,
        foregroundColor: Colors.white,
        title: Text(
          AppStrings.proUpgradeTitleEs,
          style: TextStyle(
            fontSize: isSenior ? AppFontSizes.subtitle : AppFontSizes.body,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Hero ──────────────────────────────────────────
                Center(
                  child: Text(
                    '👑',
                    style: TextStyle(fontSize: isSenior ? 80 : 64),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    AppStrings.proUpgradeSubtitleEs,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkText,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // ── Benefits ─────────────────────────────────────
                _BenefitRow(
                  text: AppStrings.proBenefit1Es,
                  isSenior: isSenior,
                  bodySize: bodySize,
                ),
                const SizedBox(height: 12),
                _BenefitRow(
                  text: AppStrings.proBenefit2Es,
                  isSenior: isSenior,
                  bodySize: bodySize,
                ),
                const SizedBox(height: 12),
                _BenefitRow(
                  text: AppStrings.proBenefit3Es,
                  isSenior: isSenior,
                  bodySize: bodySize,
                ),
                const SizedBox(height: 24),

                // ── Abuelo-only amber card ─────────────────────
                if (isSenior) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber[300]!),
                    ),
                    child: Text(
                      AppStrings.proAbueloLifetimeEs,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: bodySize,
                        fontWeight: FontWeight.w700,
                        color: Colors.amber[800],
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // ── Already Pro ───────────────────────────────
                if (state.isPro) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.green[300]!),
                    ),
                    child: Text(
                      AppStrings.proAlreadyProEs,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: bodySize,
                        fontWeight: FontWeight.w700,
                        color: Colors.green[800],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // ── Error banner ──────────────────────────────
                if (state.purchaseError.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Text(
                      state.purchaseError,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: bodySize - 2,
                        color: Colors.red[800],
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Purchase button ───────────────────────────
                if (!state.isPro) ...[
                  SizedBox(
                    height: btnHeight,
                    child: ElevatedButton(
                      onPressed: state.isLoading
                          ? null
                          : () => ref.read(proProvider.notifier).purchasePro(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.terracotta,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: Text(
                        AppStrings.proPurchaseButtonEs,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: btnTextSize,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Restore button ────────────────────────
                  SizedBox(
                    height: btnHeight,
                    child: OutlinedButton(
                      onPressed: state.isLoading
                          ? null
                          : () => ref.read(proProvider.notifier).restorePurchases(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.deepBlue, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        AppStrings.proRestoreButtonEs,
                        style: TextStyle(
                          fontSize: btnTextSize - 2,
                          color: AppColors.deepBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // ── Privacy link ──────────────────────────────
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const PrivacyScreen(),
                      ),
                    ),
                    child: Text(
                      AppStrings.proPrivacyLinkEs,
                      style: TextStyle(
                        fontSize: bodySize - 2,
                        color: AppColors.deepBlue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // ── Loading overlay ───────────────────────────────────
          if (state.isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.text,
    required this.isSenior,
    required this.bodySize,
  });

  final String text;
  final bool isSenior;
  final double bodySize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: bodySize,
          fontWeight: FontWeight.w600,
          color: AppColors.darkText,
        ),
      ),
    );
  }
}

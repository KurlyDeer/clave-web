import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/persona_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_strings.dart';

class PrivacyScreen extends ConsumerWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final persona  = ref.watch(personaProvider);
    final isSenior = persona?.isSeniorMode ?? false;

    final titleSize = isSenior ? AppFontSizes.subtitleLarge : AppFontSizes.subtitle;
    final bodySize  = isSenior ? AppFontSizes.bodyLarge     : AppFontSizes.body;

    const sections = [
      (
        titleEs: AppStrings.privacySection1TitleEs,
        titleEn: AppStrings.privacySection1TitleEn,
        bodyEs:  AppStrings.privacySection1BodyEs,
        bodyEn:  AppStrings.privacySection1BodyEn,
      ),
      (
        titleEs: AppStrings.privacySection2TitleEs,
        titleEn: AppStrings.privacySection2TitleEn,
        bodyEs:  AppStrings.privacySection2BodyEs,
        bodyEn:  AppStrings.privacySection2BodyEn,
      ),
      (
        titleEs: AppStrings.privacySection3TitleEs,
        titleEn: AppStrings.privacySection3TitleEn,
        bodyEs:  AppStrings.privacySection3BodyEs,
        bodyEn:  AppStrings.privacySection3BodyEn,
      ),
      (
        titleEs: AppStrings.privacySection4TitleEs,
        titleEn: AppStrings.privacySection4TitleEn,
        bodyEs:  AppStrings.privacySection4BodyEs,
        bodyEn:  AppStrings.privacySection4BodyEn,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.deepBlue,
        foregroundColor: Colors.white,
        title: Text(
          AppStrings.privacyTitleEs,
          style: TextStyle(
            fontSize: isSenior ? AppFontSizes.subtitle : AppFontSizes.body,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final s in sections) ...[
              _PrivacySection(
                titleEs: s.titleEs,
                titleEn: s.titleEn,
                bodyEs:  s.bodyEs,
                bodyEn:  s.bodyEn,
                titleSize: titleSize,
                bodySize:  bodySize,
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}

class _PrivacySection extends StatelessWidget {
  const _PrivacySection({
    required this.titleEs,
    required this.titleEn,
    required this.bodyEs,
    required this.bodyEn,
    required this.titleSize,
    required this.bodySize,
  });

  final String titleEs;
  final String titleEn;
  final String bodyEs;
  final String bodyEn;
  final double titleSize;
  final double bodySize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titleEs,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            bodyEs,
            style: TextStyle(
              fontSize: bodySize,
              color: AppColors.darkText,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            titleEn,
            style: TextStyle(
              fontSize: titleSize - 2,
              fontWeight: FontWeight.w700,
              color: AppColors.deepBlue,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            bodyEn,
            style: TextStyle(
              fontSize: bodySize - 2,
              color: AppColors.darkText.withValues(alpha: 0.65),
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

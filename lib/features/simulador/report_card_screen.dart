import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/conversation_report.dart';
import '../../core/providers/gamification_controller.dart';
import '../../core/providers/persona_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_container.dart';
import '../../l10n/app_strings.dart';

class ReportCardScreen extends ConsumerWidget {
  const ReportCardScreen({
    super.key,
    required this.report,
    required this.scenarioTitleEs,
  });

  final ConversationReport report;
  final String scenarioTitleEs;

  Color _gradeColor(String grade) {
    switch (grade) {
      case 'A':
        return AppColors.successGreen;
      case 'B':
        return AppColors.deepBlue;
      case 'C':
        return AppColors.warningAmber;
      default:
        return AppColors.errorRed;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final persona = ref.watch(personaProvider);
    final isSenior = persona?.isSeniorMode ?? false;
    final gradeColor = _gradeColor(report.grade);

    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;
    final headlineSize =
        isSenior ? AppFontSizes.headlineLarge : AppFontSizes.headline;
    final buttonHeight = isSenior ? 72.0 : 60.0;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.glassGradientStart,
                AppColors.glassGradientMid,
                AppColors.glassGradientEnd,
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── Scenario title ──────────────────────────────────────
                  Text(
                    scenarioTitleEs,
                    style: TextStyle(
                      fontSize: bodySize,
                      color: AppColors.glassTextMuted,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // ── Grade label ─────────────────────────────────────────
                  Text(
                    AppStrings.reportCardGradeLabelEs,
                    style: TextStyle(
                      fontSize: bodySize,
                      color: AppColors.glassTextMuted,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Grade circle ────────────────────────────────────────
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: gradeColor.withOpacity(0.15),
                      border: Border.all(
                          color: gradeColor.withOpacity(0.8), width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: gradeColor.withOpacity(0.4),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        report.grade,
                        style: TextStyle(
                          fontSize: headlineSize,
                          fontWeight: FontWeight.w900,
                          color: gradeColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Summary card ────────────────────────────────────────
                  GlassContainer(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      report.summary,
                      style: TextStyle(
                        fontSize: bodySize,
                        color: AppColors.glassText,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Corrections ─────────────────────────────────────────
                  if (report.corrections.isEmpty)
                    GlassContainer(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🌟', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              AppStrings.reportCardNoErrorsEs,
                              style: TextStyle(
                                fontSize: bodySize,
                                color: AppColors.successGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: report.corrections
                          .map((c) => _CorrectionCard(
                                item: c,
                                bodySize: bodySize,
                              ))
                          .toList(),
                    ),

                  const SizedBox(height: 32),

                  // ── Claim XP button ─────────────────────────────────────
                  GestureDetector(
                    onTap: () {
                      ref
                          .read(gamificationProvider.notifier)
                          .addXp(50);
                      ref
                          .read(gamificationProvider.notifier)
                          .recordPractice();
                      Navigator.of(context)
                          .popUntil((route) => route.isFirst);
                    },
                    child: Container(
                      width: double.infinity,
                      height: buttonHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: AppColors.glowTerracotta.withOpacity(0.15),
                        border: Border.all(
                          color: AppColors.glowTerracotta.withOpacity(0.8),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.glowTerracotta.withOpacity(0.3),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🏆',
                              style: TextStyle(fontSize: 22)),
                          const SizedBox(width: 10),
                          Text(
                            AppStrings.reportCardClaimXpEs,
                            style: TextStyle(
                              fontSize: isSenior
                                  ? AppFontSizes.bodyLarge
                                  : AppFontSizes.subtitle,
                              fontWeight: FontWeight.w700,
                              color: AppColors.glassText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Correction card ───────────────────────────────────────────────────────────

class _CorrectionCard extends StatelessWidget {
  const _CorrectionCard({required this.item, required this.bodySize});

  final CorrectionItem item;
  final double bodySize;

  @override
  Widget build(BuildContext context) {
    final labelSize = bodySize - 2;

    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Mistake row ───────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${AppStrings.reportCardMistakeLabelEs} ',
                style: TextStyle(
                  fontSize: labelSize,
                  fontWeight: FontWeight.w700,
                  color: AppColors.errorRed,
                ),
              ),
              Expanded(
                child: Text(
                  item.mistake,
                  style: TextStyle(
                    fontSize: labelSize,
                    color: AppColors.errorRed.withOpacity(0.85),
                    decoration: TextDecoration.lineThrough,
                    decorationColor: AppColors.errorRed,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // ── Correction row ─────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${AppStrings.reportCardCorrectionLabelEs} ',
                style: TextStyle(
                  fontSize: labelSize,
                  fontWeight: FontWeight.w700,
                  color: AppColors.successGreen,
                ),
              ),
              Expanded(
                child: Text(
                  item.correction,
                  style: TextStyle(
                    fontSize: labelSize,
                    color: AppColors.successGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (item.reason.isNotEmpty) ...[
            const SizedBox(height: 6),
            // ── Reason ────────────────────────────────────────────────────
            Text(
              item.reason,
              style: TextStyle(
                fontSize: labelSize - 1,
                color: AppColors.glassTextMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

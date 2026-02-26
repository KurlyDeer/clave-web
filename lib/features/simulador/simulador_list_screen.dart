import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/scenario_data.dart';
import '../../core/models/scenario_models.dart';
import '../../core/providers/persona_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_strings.dart';
import 'simulador_screen.dart';

class SimuladorListScreen extends ConsumerWidget {
  const SimuladorListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final persona = ref.watch(personaProvider);
    final isSenior = persona?.isSeniorMode ?? false;
    final personaKey = persona?.name ?? 'adulto';

    // Filter scenarios by current persona
    final scenarios = kScenarios
        .where((s) => s.targetPersona == personaKey)
        .toList();

    final titleSize =
        isSenior ? AppFontSizes.subtitleLarge : AppFontSizes.subtitle;
    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.terracotta,
        foregroundColor: AppColors.lightText,
        title: Text(
          AppStrings.simuladorTitleEs,
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.w700,
            color: AppColors.lightText,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text(
              AppStrings.simuladorPickScenarioEs,
              style: TextStyle(
                fontSize: bodySize,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
          ),
          if (scenarios.isEmpty)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    AppStrings.simuladorEmptyEs,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: bodySize,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: scenarios.length,
                itemBuilder: (context, index) {
                  return _ScenarioCard(
                    scenario: scenarios[index],
                    isSenior: isSenior,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ── Scenario card ──────────────────────────────────────────────────────────────

class _ScenarioCard extends StatelessWidget {
  const _ScenarioCard({
    required this.scenario,
    required this.isSenior,
  });

  final ScenarioData scenario;
  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    final titleSize = isSenior ? AppFontSizes.subtitleLarge : AppFontSizes.subtitle;
    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;
    final smallSize = isSenior ? AppFontSizes.body : 16.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.cardBackground,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => SimuladorScreen(scenario: scenario),
          ),
        ),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emoji circle
              Container(
                width: isSenior ? 64 : 56,
                height: isSenior ? 64 : 56,
                decoration: const BoxDecoration(
                  color: Color(0xFF16A085),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    scenario.iconEmoji,
                    style: TextStyle(fontSize: isSenior ? 30 : 26),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scenario.titleEs,
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      scenario.descriptionEs,
                      style: TextStyle(
                        fontSize: bodySize,
                        color: Colors.grey[700],
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A085).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        scenario.characterRoleEs,
                        style: TextStyle(
                          fontSize: smallSize,
                          color: const Color(0xFF16A085),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

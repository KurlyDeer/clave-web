import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/audio_provider.dart';
import '../../core/providers/persona_provider.dart';
import '../../core/providers/voice_provider.dart';
import '../../core/services/audio_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_container.dart';
import '../../l10n/app_strings.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final persona = ref.watch(personaProvider);
    final isSenior = persona?.isSeniorMode ?? false;
    final selectedVoice = ref.watch(voiceProvider);

    final titleSize = isSenior ? AppFontSizes.subtitleLarge : AppFontSizes.subtitle;
    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;
    final sectionSize = isSenior ? AppFontSizes.body : AppFontSizes.body - 2;

    return Scaffold(
      backgroundColor: AppColors.glassGradientStart,
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
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new,
                          color: AppColors.glassText),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Text(
                      AppStrings.settingsTitleEs,
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w800,
                        color: AppColors.glassText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── Voice section ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.settingsVoiceSectionEs.toUpperCase(),
                      style: TextStyle(
                        fontSize: sectionSize,
                        letterSpacing: 1.6,
                        fontWeight: FontWeight.w700,
                        color: AppColors.glassTextMuted,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GlassContainer(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _VoiceTile(
                            label: AppStrings.settingsVoiceProfesorEs,
                            subtitle: 'Voz alloy',
                            voice: TtsVoice.alloy,
                            isSelected: selectedVoice == TtsVoice.alloy,
                            isSenior: isSenior,
                            bodySize: bodySize,
                            onSelect: () => ref
                                .read(voiceProvider.notifier)
                                .setVoice(TtsVoice.alloy),
                            onPreview: () => ref
                                .read(audioServiceProvider)
                                .speak(AppStrings.settingsPreviewText),
                          ),
                          const SizedBox(height: 12),
                          _VoiceTile(
                            label: AppStrings.settingsVoiceProfesoraEs,
                            subtitle: 'Voz nova',
                            voice: TtsVoice.nova,
                            isSelected: selectedVoice == TtsVoice.nova,
                            isSenior: isSenior,
                            bodySize: bodySize,
                            onSelect: () => ref
                                .read(voiceProvider.notifier)
                                .setVoice(TtsVoice.nova),
                            onPreview: () {
                              // Preview using nova voice explicitly
                              final svc = ref.read(audioServiceProvider);
                              final current = ref.read(voiceProvider);
                              svc.setVoice(TtsVoice.nova);
                              svc
                                  .speak(AppStrings.settingsPreviewText)
                                  .then((_) => svc.setVoice(current));
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Voice Tile ────────────────────────────────────────────────────────────────

class _VoiceTile extends StatelessWidget {
  const _VoiceTile({
    required this.label,
    required this.subtitle,
    required this.voice,
    required this.isSelected,
    required this.isSenior,
    required this.bodySize,
    required this.onSelect,
    required this.onPreview,
  });

  final String label;
  final String subtitle;
  final TtsVoice voice;
  final bool isSelected;
  final bool isSenior;
  final double bodySize;
  final VoidCallback onSelect;
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? AppColors.glowTerracotta
        : AppColors.glassBorder;
    final borderWidth = isSelected ? 2.0 : 1.0;
    final btnHeight = isSenior ? 72.0 : 60.0;

    return GestureDetector(
      onTap: onSelect,
      child: Container(
        height: btnHeight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.glowTerracotta.withValues(alpha: 0.12)
              : AppColors.glassSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        child: Row(
          children: [
            // Radio-style indicator
            Container(
              width: isSenior ? 26 : 22,
              height: isSenior ? 26 : 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.glowTerracotta
                      : AppColors.glassBorder,
                  width: 2,
                ),
                color: isSelected
                    ? AppColors.glowTerracotta
                    : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
            const SizedBox(width: 14),
            // Labels
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: bodySize,
                      fontWeight: FontWeight.w700,
                      color: AppColors.glassText,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: bodySize - 4,
                      color: AppColors.glassTextMuted,
                    ),
                  ),
                ],
              ),
            ),
            // Preview button
            IconButton(
              onPressed: onPreview,
              icon: Icon(
                Icons.play_circle_outline_rounded,
                color: AppColors.glassText,
                size: isSenior ? 32 : 26,
              ),
              tooltip: AppStrings.settingsPreviewEs,
            ),
          ],
        ),
      ),
    );
  }
}

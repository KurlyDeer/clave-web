import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/onboarding_controller.dart';
import '../../core/providers/persona_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_container.dart';
import '../../l10n/app_strings.dart';
import '../placement/placement_screen.dart';

class PersonaScreen extends ConsumerStatefulWidget {
  const PersonaScreen({super.key});

  @override
  ConsumerState<PersonaScreen> createState() => _PersonaScreenState();
}

class _PersonaScreenState extends ConsumerState<PersonaScreen> {
  Persona? _selected;
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (_selected == null) return;
    final notifier = ref.read(onboardingProvider.notifier);
    notifier.setPersona(_selected!);
    notifier.setName(_nameController.text.trim());
    notifier.savePersonaAndName();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const PlacementScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSenior = _selected?.isSeniorMode ?? false;

    return PopScope(
      canPop: false,
      child: Scaffold(
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
                  _buildHeader(isSenior),
                  const SizedBox(height: 28),
                  _buildPersonaCards(isSenior),
                  const SizedBox(height: 32),
                  _buildNameField(isSenior),
                  const SizedBox(height: 24),
                  _buildContinueButton(isSenior),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isSenior) {
    return Column(
      children: [
        Text(
          AppStrings.personaPromptEs,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isSenior ? AppFontSizes.titleLarge : AppFontSizes.title,
            fontWeight: FontWeight.w800,
            color: AppColors.glassText,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          AppStrings.personaSubtitleEs,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isSenior
                ? AppFontSizes.bodyLarge - 2
                : AppFontSizes.body - 2,
            color: AppColors.glassTextMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildPersonaCards(bool isSenior) {
    return Row(
      children: [
        Expanded(
          child: _PersonaCard(
            emoji: AppStrings.personaNinoEmoji,
            label: AppStrings.personaNino,
            sublabel: AppStrings.personaNinoDesc,
            persona: Persona.nino,
            selected: _selected,
            isSenior: isSenior,
            onTap: () => setState(() => _selected = Persona.nino),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PersonaCard(
            emoji: AppStrings.personaAdultoEmoji,
            label: AppStrings.personaAdulto,
            sublabel: AppStrings.personaAdultoDesc,
            persona: Persona.adulto,
            selected: _selected,
            isSenior: isSenior,
            onTap: () => setState(() => _selected = Persona.adulto),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PersonaCard(
            emoji: AppStrings.personaAbueloEmoji,
            label: AppStrings.personaAbuelo,
            sublabel: AppStrings.personaAbueloDesc,
            persona: Persona.abuelo,
            selected: _selected,
            isSenior: isSenior,
            onTap: () => setState(() => _selected = Persona.abuelo),
          ),
        ),
      ],
    );
  }

  Widget _buildNameField(bool isSenior) {
    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.personaNamePromptEs,
          style: TextStyle(
            fontSize: bodySize,
            fontWeight: FontWeight.w600,
            color: AppColors.glassText,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _nameController,
          style: TextStyle(fontSize: bodySize, color: AppColors.glassText),
          decoration: InputDecoration(
            hintText: AppStrings.personaNameHintEs,
            hintStyle: TextStyle(
              fontSize: bodySize,
              color: AppColors.glassTextMuted,
            ),
            filled: true,
            fillColor: AppColors.glassSurface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.glassBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.glassBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppColors.glowTerracotta, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton(bool isSenior) {
    final hasSelection = _selected != null;
    final buttonHeight = isSenior ? 72.0 : 60.0;
    final textSize =
        isSenior ? AppFontSizes.subtitleLarge : AppFontSizes.subtitle;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: hasSelection
            ? [
                BoxShadow(
                  color: AppColors.glowTerracotta.withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: SizedBox(
        height: buttonHeight,
        child: ElevatedButton(
          onPressed: hasSelection ? _onContinue : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.glowTerracotta,
            foregroundColor: AppColors.lightText,
            disabledBackgroundColor:
                AppColors.glowTerracotta.withValues(alpha: 0.35),
            disabledForegroundColor: AppColors.lightText.withValues(alpha: 0.6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Text(
            hasSelection
                ? '${AppStrings.personaContinueEs}  •  ${AppStrings.personaContinueEn}'
                : AppStrings.ctaSelectPersonaFirst,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: textSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Persona Card ───────────────────────────────────────────────────────────────

class _PersonaCard extends StatelessWidget {
  const _PersonaCard({
    required this.emoji,
    required this.label,
    required this.sublabel,
    required this.persona,
    required this.selected,
    required this.isSenior,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final String sublabel;
  final Persona persona;
  final Persona? selected;
  final bool isSenior;
  final VoidCallback onTap;

  bool get _isSelected => selected == persona;

  @override
  Widget build(BuildContext context) {
    final labelSize =
        isSenior ? AppFontSizes.subtitleLarge : AppFontSizes.subtitle;
    final sublabelSize =
        isSenior ? AppFontSizes.bodyLarge - 2 : AppFontSizes.body - 2;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: _isSelected ? 1.06 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        child: Container(
          decoration: _isSelected
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.glowTerracotta.withValues(alpha: 0.4),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                )
              : null,
          child: GlassContainer(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
            borderRadius: 18,
            borderColor:
                _isSelected ? AppColors.glowTerracotta : AppColors.glassBorder,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  emoji,
                  style: TextStyle(fontSize: isSenior ? 40 : 34),
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: labelSize,
                    fontWeight: FontWeight.w700,
                    color: _isSelected
                        ? AppColors.glowTerracotta
                        : AppColors.glassText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  sublabel,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: sublabelSize,
                    color: AppColors.glassTextMuted,
                  ),
                ),
                if (_isSelected) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.glowTerracotta,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: AppColors.lightText,
                      size: 18,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

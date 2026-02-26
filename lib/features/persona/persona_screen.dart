import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/persona_provider.dart';
import '../../core/providers/user_name_provider.dart';
import '../../core/theme/app_theme.dart';
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
    final name = _nameController.text.trim();
    ref.read(userNameProvider.notifier).setName(name);
    ref.read(personaProvider.notifier).setPersona(_selected!);
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
        backgroundColor: AppColors.cream,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildLogo(isSenior),
                const SizedBox(height: 32),
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
    );
  }

  Widget _buildLogo(bool isSenior) {
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
            child: Text('🌉', style: TextStyle(fontSize: 48)),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.appName,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isSenior
                ? AppFontSizes.headlineLarge
                : AppFontSizes.headline,
            fontWeight: FontWeight.w800,
            color: AppColors.terracotta,
            letterSpacing: -0.5,
          ),
        ),
      ],
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
            color: AppColors.darkText,
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
            color: AppColors.darkText.withValues(alpha: 0.6),
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
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _nameController,
          style: TextStyle(fontSize: bodySize),
          decoration: InputDecoration(
            hintText: AppStrings.personaNameHintEs,
            hintStyle: TextStyle(
              fontSize: bodySize,
              color: AppColors.darkText.withValues(alpha: 0.4),
            ),
            filled: true,
            fillColor: AppColors.cardBackground,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.unselectedBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.unselectedBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppColors.terracotta, width: 2),
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

    return SizedBox(
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: hasSelection ? _onContinue : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              hasSelection ? AppColors.terracotta : AppColors.unselectedBorder,
          foregroundColor: AppColors.lightText,
          disabledBackgroundColor: AppColors.unselectedBorder,
          disabledForegroundColor:
              AppColors.lightText.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: hasSelection ? 4 : 0,
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          decoration: BoxDecoration(
            color: _isSelected
                ? AppColors.terracotta.withValues(alpha: 0.08)
                : AppColors.cardBackground,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _isSelected
                  ? AppColors.terracotta
                  : AppColors.unselectedBorder,
              width: _isSelected ? 3 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _isSelected
                    ? AppColors.terracotta.withValues(alpha: 0.18)
                    : AppColors.shadow,
                blurRadius: _isSelected ? 14 : 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
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
                style: TextStyle(
                  fontSize: labelSize,
                  fontWeight: FontWeight.w700,
                  color: _isSelected
                      ? AppColors.terracotta
                      : AppColors.darkText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                sublabel,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: sublabelSize,
                  color: AppColors.darkText.withValues(alpha: 0.55),
                ),
              ),
              if (_isSelected) ...[
                const SizedBox(height: 10),
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: AppColors.terracotta,
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
    );
  }
}

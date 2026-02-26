import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/persona_provider.dart';
import '../../core/providers/placement_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_strings.dart';
import '../analizador/analizador_screen.dart';
import '../lessons/lesson_list_screen.dart';
import '../libro/book_gallery_screen.dart';
import '../simulador/simulador_list_screen.dart';
import '../vocab/vocab_screen.dart';
import '../sos/sos_screen.dart';
import 'widgets/book_map_widget.dart';
import 'widgets/streak_widget.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final persona = ref.watch(personaProvider);
    final placement = ref.watch(placementProvider);
    final isSenior = persona?.isSeniorMode ?? false;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DashboardHeader(
                persona: persona,
                level: placement.resultLevel,
                isSenior: isSenior,
              ),
              const SizedBox(height: 16),
              StreakWidget(isSenior: isSenior),
              const SizedBox(height: 28),
              BookMapWidget(isSenior: isSenior),
              const SizedBox(height: 28),
              _SosButton(isSenior: isSenior),
              const SizedBox(height: 12),
              _SimuladorButton(isSenior: isSenior),
              const SizedBox(height: 12),
              _AnalizadorButton(isSenior: isSenior),
              const SizedBox(height: 12),
              _LibroButton(isSenior: isSenior),
              const SizedBox(height: 12),
              _VocabButton(isSenior: isSenior),
              const SizedBox(height: 12),
              _LessonButton(isSenior: isSenior),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────────

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.persona,
    required this.level,
    required this.isSenior,
  });

  final Persona? persona;
  final PlacementLevel? level;
  final bool isSenior;

  String get _greeting {
    switch (persona) {
      case Persona.nino:
        return AppStrings.dashboardGreetingNinoEs;
      case Persona.abuelo:
        return AppStrings.dashboardGreetingAbueloEs;
      default:
        return AppStrings.dashboardGreetingAdultoEs;
    }
  }

  @override
  Widget build(BuildContext context) {
    final headlineSize =
        isSenior ? AppFontSizes.headlineLarge : AppFontSizes.headline;
    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting,
                style: TextStyle(
                  fontSize: headlineSize,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkText,
                  height: 1.2,
                ),
              ),
              if (level != null) ...[
                const SizedBox(height: 10),
                Chip(
                  backgroundColor: AppColors.deepBlue,
                  label: Text(
                    '${level!.displayEs}  •  ${level!.displayEn}',
                    style: TextStyle(
                      color: AppColors.lightText,
                      fontSize: bodySize - 2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.terracotta,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Text('🌉', style: TextStyle(fontSize: 36)),
          ),
        ),
      ],
    );
  }
}

// ── SOS Button ────────────────────────────────────────────────────────────────

class _SosButton extends StatelessWidget {
  const _SosButton({required this.isSenior});

  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    final buttonHeight = isSenior ? 72.0 : 68.0;
    final textSize =
        isSenior ? AppFontSizes.subtitleLarge : AppFontSizes.subtitle;

    return SizedBox(
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const SosScreen()),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.terracotta,
          foregroundColor: AppColors.lightText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: Text(
          '${AppStrings.dashboardSosEs}  •  ${AppStrings.dashboardSosEn}',
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

// ── Lesson Button ──────────────────────────────────────────────────────────────

class _LessonButton extends StatelessWidget {
  const _LessonButton({required this.isSenior});

  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    final buttonHeight = isSenior ? 72.0 : 68.0;
    final textSize =
        isSenior ? AppFontSizes.subtitleLarge : AppFontSizes.subtitle;

    return SizedBox(
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const LessonListScreen()),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[700],
          foregroundColor: AppColors.lightText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: Text(
          '${AppStrings.dashboardLessonsEs}  •  ${AppStrings.dashboardLessonsEn}',
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

// ── Vocab Button ───────────────────────────────────────────────────────────────

class _VocabButton extends StatelessWidget {
  const _VocabButton({required this.isSenior});

  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    final buttonHeight = isSenior ? 72.0 : 68.0;
    final textSize =
        isSenior ? AppFontSizes.subtitleLarge : AppFontSizes.subtitle;

    return SizedBox(
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const VocabScreen()),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8E44AD), // purple
          foregroundColor: AppColors.lightText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: Text(
          '${AppStrings.dashboardVocabEs}  •  ${AppStrings.dashboardVocabEn}',
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

// ── Simulador Button ───────────────────────────────────────────────────────────

class _SimuladorButton extends StatelessWidget {
  const _SimuladorButton({required this.isSenior});

  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    final buttonHeight = isSenior ? 72.0 : 68.0;
    final textSize =
        isSenior ? AppFontSizes.subtitleLarge : AppFontSizes.subtitle;

    return SizedBox(
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
              builder: (_) => const SimuladorListScreen()),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF16A085), // teal
          foregroundColor: AppColors.lightText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: Text(
          '${AppStrings.dashboardSimuladorEs}  •  ${AppStrings.dashboardSimuladorEn}',
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

// ── Analizador Button ──────────────────────────────────────────────────────────

class _AnalizadorButton extends StatelessWidget {
  const _AnalizadorButton({required this.isSenior});

  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    final buttonHeight = isSenior ? 72.0 : 68.0;
    final textSize =
        isSenior ? AppFontSizes.subtitleLarge : AppFontSizes.subtitle;

    return SizedBox(
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const AnalizadorScreen()),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8E3A59), // deep rose
          foregroundColor: AppColors.lightText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: Text(
          '${AppStrings.dashboardAnalizadorEs}  •  ${AppStrings.dashboardAnalizadorEn}',
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

// ── Libro Button ───────────────────────────────────────────────────────────────

class _LibroButton extends StatelessWidget {
  const _LibroButton({required this.isSenior});

  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    final buttonHeight = isSenior ? 72.0 : 68.0;
    final textSize =
        isSenior ? AppFontSizes.subtitleLarge : AppFontSizes.subtitle;

    return SizedBox(
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const BookGalleryScreen()),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.deepBlue,
          foregroundColor: AppColors.lightText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: Text(
          '${AppStrings.dashboardLibroEs}  •  ${AppStrings.dashboardLibroEn}',
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

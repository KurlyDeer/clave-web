import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/persona_provider.dart';
import '../../core/providers/user_name_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_container.dart';
import '../../l10n/app_strings.dart';

class PublishSuccessScreen extends ConsumerStatefulWidget {
  const PublishSuccessScreen({super.key});

  @override
  ConsumerState<PublishSuccessScreen> createState() =>
      _PublishSuccessScreenState();
}

class _PublishSuccessScreenState extends ConsumerState<PublishSuccessScreen> {
  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
    WidgetsBinding.instance.addPostFrameCallback((_) => _confetti.play());
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final persona = ref.watch(personaProvider);
    final userName = ref.watch(userNameProvider);
    final isSenior = persona?.isSeniorMode ?? false;

    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;
    final titleSize = isSenior ? AppFontSizes.headlineLarge : AppFontSizes.headline;
    final subtitleSize =
        isSenior ? AppFontSizes.subtitleLarge : AppFontSizes.subtitle;

    return Scaffold(
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
        child: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom -
                        64,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Spacer(),
                        if (persona == Persona.abuelo)
                          _AbueloContent(
                            userName: userName.isNotEmpty ? userName : 'Abuelo',
                            isSenior: isSenior,
                            titleSize: titleSize,
                            bodySize: bodySize,
                            subtitleSize: subtitleSize,
                          )
                        else if (persona == Persona.nino)
                          _NinoContent(
                            userName: userName.isNotEmpty ? userName : 'Campeón',
                            isSenior: false,
                            titleSize: titleSize,
                            bodySize: bodySize,
                            subtitleSize: subtitleSize,
                          )
                        else
                          _AdultoContent(
                            userName:
                                userName.isNotEmpty ? userName : 'Estudiante',
                            isSenior: isSenior,
                            titleSize: titleSize,
                            bodySize: bodySize,
                            subtitleSize: subtitleSize,
                          ),
                        const Spacer(),
                        const SizedBox(height: 32),
                        // XP badge
                        Center(
                          child: GlassContainer(
                            borderRadius: 30,
                            borderColor: Colors.amber.withValues(alpha: 0.6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            child: Text(
                              AppStrings.publishXpEarnedEs,
                              style: TextStyle(
                                fontSize: bodySize,
                                fontWeight: FontWeight.w800,
                                color: Colors.amber,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: GlassContainer(
                            backgroundColor:
                                AppColors.glowTerracotta.withValues(alpha: 0.7),
                            borderColor: AppColors.glowTerracotta,
                            padding: EdgeInsets.zero,
                            child: SizedBox(
                              height: isSenior ? 72 : 60,
                              child: Center(
                                child: Text(
                                  AppStrings.publishContinueEs,
                                  style: TextStyle(
                                    fontSize: bodySize,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Confetti
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confetti,
                blastDirectionality: BlastDirectionality.explosive,
                numberOfParticles: 40,
                maxBlastForce: 25,
                minBlastForce: 8,
                gravity: 0.3,
                colors: const [
                  AppColors.glowTerracotta,
                  Color(0xFF5DADE2),
                  Colors.amber,
                  Colors.greenAccent,
                  Colors.purpleAccent,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Abuelo content ─────────────────────────────────────────────────────────────

class _AbueloContent extends StatelessWidget {
  const _AbueloContent({
    required this.userName,
    required this.isSenior,
    required this.titleSize,
    required this.bodySize,
    required this.subtitleSize,
  });

  final String userName;
  final bool isSenior;
  final double titleSize;
  final double bodySize;
  final double subtitleSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('👴📖', style: TextStyle(fontSize: 64)),
        const SizedBox(height: 20),
        Text(
          userName,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.w900,
            color: AppColors.glowTerracotta,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.publishSuccessAbueloEs,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: subtitleSize,
            fontWeight: FontWeight.w700,
            color: AppColors.glassText,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          AppStrings.publishSuccessAbueloSubtitleEs,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: bodySize,
            color: AppColors.glassTextMuted,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

// ── Niño content ───────────────────────────────────────────────────────────────

class _NinoContent extends StatelessWidget {
  const _NinoContent({
    required this.userName,
    required this.isSenior,
    required this.titleSize,
    required this.bodySize,
    required this.subtitleSize,
  });

  final String userName;
  final bool isSenior;
  final double titleSize;
  final double bodySize;
  final double subtitleSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('🦸‍♂️📖', style: TextStyle(fontSize: 64)),
        const SizedBox(height: 20),
        // Certificate card
        GlassContainer(
          borderColor: AppColors.glowTerracotta,
          borderRadius: 20,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                AppStrings.publishSuccessNinoTitleEs,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: subtitleSize,
                  fontWeight: FontWeight.w800,
                  color: AppColors.glowTerracotta,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 2,
                color: AppColors.glowTerracotta.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'se otorga a',
                style: TextStyle(
                  fontSize: bodySize - 2,
                  color: AppColors.glassTextMuted,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                userName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.w900,
                  color: AppColors.glassText,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.publishSuccessNinoEs,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: bodySize,
                  color: AppColors.glassText,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Adulto content ─────────────────────────────────────────────────────────────

class _AdultoContent extends StatelessWidget {
  const _AdultoContent({
    required this.userName,
    required this.isSenior,
    required this.titleSize,
    required this.bodySize,
    required this.subtitleSize,
  });

  final String userName;
  final bool isSenior;
  final double titleSize;
  final double bodySize;
  final double subtitleSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('🎓📖', style: TextStyle(fontSize: 64)),
        const SizedBox(height: 20),
        Text(
          userName,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.w900,
            color: AppColors.glowTerracotta,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.publishSuccessAdultoEs,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: subtitleSize,
            fontWeight: FontWeight.w700,
            color: AppColors.glassText,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          AppStrings.publishSuccessAdultoSubtitleEs,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: bodySize,
            color: AppColors.glassTextMuted,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

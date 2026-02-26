import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/persona_provider.dart';
import '../../core/providers/user_name_provider.dart';
import '../../core/theme/app_theme.dart';
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
      backgroundColor: const Color(0xFFFFFBF0),
      body: Stack(
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
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber[100],
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.amber[400]!,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            AppStrings.publishXpEarnedEs,
                            style: TextStyle(
                              fontSize: bodySize,
                              fontWeight: FontWeight.w800,
                              color: Colors.amber[800],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        height: isSenior ? 72 : 60,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.terracotta,
                            foregroundColor: AppColors.lightText,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                          ),
                          child: Text(
                            AppStrings.publishContinueEs,
                            style: TextStyle(
                              fontSize: bodySize,
                              fontWeight: FontWeight.w700,
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
                AppColors.terracotta,
                AppColors.deepBlue,
                Colors.amber,
                Colors.green,
                Colors.purple,
              ],
            ),
          ),
        ],
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
            color: AppColors.terracotta,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.publishSuccessAbueloEs,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: subtitleSize,
            fontWeight: FontWeight.w700,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          AppStrings.publishSuccessAbueloSubtitleEs,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: bodySize,
            color: AppColors.darkText.withValues(alpha: 0.65),
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
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.terracotta, width: 3),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                AppStrings.publishSuccessNinoTitleEs,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: subtitleSize,
                  fontWeight: FontWeight.w800,
                  color: AppColors.terracotta,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 2,
                color: AppColors.terracotta.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'se otorga a',
                style: TextStyle(
                  fontSize: bodySize - 2,
                  color: AppColors.darkText.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                userName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.w900,
                  color: AppColors.deepBlue,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.publishSuccessNinoEs,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: bodySize,
                  color: AppColors.darkText,
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
            color: AppColors.terracotta,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.publishSuccessAdultoEs,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: subtitleSize,
            fontWeight: FontWeight.w700,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          AppStrings.publishSuccessAdultoSubtitleEs,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: bodySize,
            color: AppColors.darkText.withValues(alpha: 0.65),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

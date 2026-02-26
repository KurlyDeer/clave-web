import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/career_model.dart';
import '../../core/providers/persona_provider.dart';
import '../../core/providers/pro_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_strings.dart';
import '../pro/pro_upgrade_screen.dart';
import 'career_lesson_list_screen.dart';

class CareerTracksScreen extends ConsumerWidget {
  const CareerTracksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proState = ref.watch(proProvider);
    final persona  = ref.watch(personaProvider);
    final isSenior = persona?.isSeniorMode ?? false;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.terracotta,
        foregroundColor: Colors.white,
        title: Text(
          AppStrings.careerTracksTitleEs,
          style: TextStyle(
            fontSize: isSenior ? AppFontSizes.subtitle : AppFontSizes.body,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: proState.isInitialized && !proState.isPro
          ? _ProGateWidget(isSenior: isSenior)
          : _TrackListWidget(isSenior: isSenior),
    );
  }
}

// ── Pro gate ──────────────────────────────────────────────────────────────────

class _ProGateWidget extends StatelessWidget {
  const _ProGateWidget({required this.isSenior});

  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    final bodySize  = isSenior ? AppFontSizes.bodyLarge    : AppFontSizes.body;
    final btnHeight = isSenior ? 72.0 : 60.0;
    final btnSize   = isSenior ? AppFontSizes.subtitleLarge : AppFontSizes.subtitle;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔒', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 20),
          Text(
            AppStrings.careerProGateTitleEs,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: bodySize + 4,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.careerProGateBodyEs,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: bodySize,
              color: AppColors.darkText,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: btnHeight,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ProUpgradeScreen(),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.terracotta,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              child: Text(
                AppStrings.careerProGateCTAEs,
                style: TextStyle(
                  fontSize: btnSize,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Track list ────────────────────────────────────────────────────────────────

class _TrackListWidget extends StatelessWidget {
  const _TrackListWidget({required this.isSenior});

  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      children: [
        for (final track in CareerTrack.values)
          _CareerTrackCard(
            track: track,
            isSenior: isSenior,
          ),
      ],
    );
  }
}

class _CareerTrackCard extends StatelessWidget {
  const _CareerTrackCard({required this.track, required this.isSenior});

  final CareerTrack track;
  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    final titleSize = isSenior ? AppFontSizes.subtitleLarge : AppFontSizes.subtitle;
    final bodySize  = isSenior ? AppFontSizes.bodyLarge     : AppFontSizes.body;
    final btnHeight = isSenior ? 72.0 : 60.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => CareerLessonListScreen(track: track),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Text(
                track.emoji,
                style: TextStyle(fontSize: isSenior ? 48 : 40),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${track.titleEs}  •  ${track.titleEn}',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      track.descriptionEs,
                      style: TextStyle(
                        fontSize: bodySize - 2,
                        color: AppColors.darkText.withValues(alpha: 0.65),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${track.lessonIds.length} lecciones',
                      style: TextStyle(
                        fontSize: bodySize - 2,
                        color: AppColors.terracotta,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: AppColors.deepBlue,
                size: btnHeight * 0.5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

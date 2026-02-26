import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'widgets/camino_preview_widget.dart';
import 'widgets/focus_card_widget.dart';
import 'widgets/liquid_progress_widget.dart';
import 'widgets/stats_tiles_widget.dart';
import 'widgets/welcome_hero_widget.dart';

/// The main "Home" tab — gradient background with glass cards.
class GlassHomeTab extends StatelessWidget {
  const GlassHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
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
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              WelcomeHeroWidget(),
              SizedBox(height: 24),
              FocusCardWidget(),
              SizedBox(height: 16),
              LiquidProgressWidget(),
              SizedBox(height: 16),
              StatsTilesWidget(),
              SizedBox(height: 16),
              CaminoPreviewWidget(),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/milestone_data.dart';
import '../../core/providers/persona_provider.dart';
import '../../core/providers/shared_preferences_provider.dart';
import '../../core/providers/xp_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_container.dart';
import '../../l10n/app_strings.dart';

class CaminoScreen extends ConsumerStatefulWidget {
  const CaminoScreen({super.key});

  @override
  ConsumerState<CaminoScreen> createState() => _CaminoScreenState();
}

class _CaminoScreenState extends ConsumerState<CaminoScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  int _newlyUnlockedIndex = -1;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _glowAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 0.55),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.55, end: 0.0),
        weight: 60,
      ),
    ]).animate(_glowController);

    WidgetsBinding.instance.addPostFrameCallback((_) => _checkGlow());
  }

  void _checkGlow() {
    if (!mounted) return;
    final xp = ref.read(xpProvider).totalXp;
    final unlockedCount =
        kMilestones.where((m) => xp >= m.xpRequired).length;
    final prefs = ref.read(sharedPreferencesProvider);
    final savedCount = prefs.getInt('camino_last_unlocked_count') ?? 0;

    if (unlockedCount > savedCount) {
      prefs.setInt('camino_last_unlocked_count', unlockedCount);
      setState(() => _newlyUnlockedIndex = unlockedCount - 1);
      _glowController.forward();
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final xpState = ref.watch(xpProvider);
    final persona = ref.watch(personaProvider);
    final isSenior = persona?.isSeniorMode ?? false;
    final totalXp = xpState.totalXp;
    final unlocked = kMilestones.map((m) => totalXp >= m.xpRequired).toList();

    return Scaffold(
      backgroundColor: AppColors.glassGradientStart,
      body: Container(
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
          child: Column(
            children: [
              // ── App bar ────────────────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: AppColors.glassText),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      AppStrings.caminoTitleEs,
                      style: TextStyle(
                        color: AppColors.glassText,
                        fontSize: isSenior
                            ? AppFontSizes.titleLarge
                            : AppFontSizes.title,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Scrollable river ───────────────────────────────────
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const double baseNodeSize = 56.0;
                    final double nodeSize = isSenior ? 64.0 : baseNodeSize;
                    final double nodeRadius = nodeSize / 2;
                    const double vertSpacing = 130.0;
                    const double horizontalOffset = 70.0;
                    const double totalHeight =
                        vertSpacing * 9 + 56.0 + 80.0; // ~1270px

                    final double centerX = constraints.maxWidth / 2;

                    final List<Offset> centers =
                        List.generate(kMilestones.length, (i) {
                      final double y = 40 + nodeRadius + i * vertSpacing;
                      final double x = i.isEven
                          ? centerX - horizontalOffset
                          : centerX + horizontalOffset;
                      return Offset(x, y);
                    });

                    return SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: SizedBox(
                        width: constraints.maxWidth,
                        height: totalHeight,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // River path
                            CustomPaint(
                              size: Size(constraints.maxWidth, totalHeight),
                              painter: _RiverPainter(centers: centers),
                            ),

                            // Milestone nodes
                            ...List.generate(kMilestones.length, (i) {
                              final milestone = kMilestones[i];
                              final isUnlocked = unlocked[i];
                              final center = centers[i];
                              final isNewlyUnlocked = i == _newlyUnlockedIndex;

                              return Positioned(
                                left: center.dx - nodeRadius,
                                top: center.dy - nodeRadius,
                                child: _MilestoneNode(
                                  milestone: milestone,
                                  isUnlocked: isUnlocked,
                                  isSenior: isSenior,
                                  nodeSize: nodeSize,
                                  glowAnimation:
                                      isNewlyUnlocked ? _glowAnimation : null,
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── River path painter ─────────────────────────────────────────────────────────

class _RiverPainter extends CustomPainter {
  const _RiverPainter({required this.centers});

  final List<Offset> centers;

  @override
  void paint(Canvas canvas, Size size) {
    if (centers.length < 2) return;

    final paint = Paint()
      ..color = AppColors.glowTerracotta.withValues(alpha:0.4)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(centers[0].dx, centers[0].dy);

    for (int i = 1; i < centers.length; i++) {
      final p1 = centers[i - 1];
      final p2 = centers[i];
      final midY = (p1.dy + p2.dy) / 2;
      path.cubicTo(p1.dx, midY, p2.dx, midY, p2.dx, p2.dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_RiverPainter old) => old.centers != centers;
}

// ── Single milestone node ──────────────────────────────────────────────────────

class _MilestoneNode extends StatelessWidget {
  const _MilestoneNode({
    required this.milestone,
    required this.isUnlocked,
    required this.isSenior,
    required this.nodeSize,
    this.glowAnimation,
  });

  final MilestoneData milestone;
  final bool isUnlocked;
  final bool isSenior;
  final double nodeSize;
  final Animation<double>? glowAnimation;

  void _showPopup(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: GlassContainer(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                milestone.icon,
                color: AppColors.glowTerracotta,
                size: 52,
              ),
              const SizedBox(height: 14),
              Text(
                milestone.titleEs,
                style: TextStyle(
                  color: AppColors.glassText,
                  fontSize: isSenior
                      ? AppFontSizes.titleLarge
                      : AppFontSizes.title,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                milestone.achievementEs,
                style: TextStyle(
                  color: AppColors.glassTextMuted,
                  fontSize:
                      isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.glowTerracotta.withValues(alpha:0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.glowTerracotta, width: 1),
                ),
                child: Text(
                  '${milestone.xpRequired} XP',
                  style: const TextStyle(
                    color: AppColors.glowTerracotta,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.glassSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.glassBorder, width: 1),
                  ),
                  child: Text(
                    AppStrings.caminoUnlockedEs,
                    style: const TextStyle(
                      color: AppColors.glassText,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget circle = GlassContainer(
      padding: EdgeInsets.zero,
      borderRadius: nodeSize / 2,
      backgroundColor: isUnlocked
          ? AppColors.glowTerracotta.withValues(alpha:0.25)
          : AppColors.glassSurface,
      child: SizedBox(
        width: nodeSize,
        height: nodeSize,
        child: Center(
          child: Icon(
            milestone.icon,
            color: isUnlocked
                ? AppColors.glowTerracotta
                : AppColors.glassTextMuted,
            size: nodeSize * 0.46,
          ),
        ),
      ),
    );

    if (!isUnlocked) {
      circle = ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: Opacity(opacity: 0.35, child: circle),
      );
    } else {
      circle = GestureDetector(
        onTap: () => _showPopup(context),
        child: circle,
      );
    }

    if (glowAnimation != null) {
      circle = AnimatedBuilder(
        animation: glowAnimation!,
        builder: (_, child) => Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: glowAnimation!.value,
              child: Container(
                width: nodeSize + 24,
                height: nodeSize + 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.glowTerracotta,
                ),
              ),
            ),
            child!,
          ],
        ),
        child: circle,
      );
    }

    return circle;
  }
}

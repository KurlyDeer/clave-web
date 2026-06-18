import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/lesson_repository.dart';
import '../../core/providers/lesson_progress_provider.dart';
import '../../core/providers/path_lesson_provider.dart';
import '../../core/providers/persona_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_strings.dart';
import '../lessons/lesson_detail_screen.dart';

// ── Node state enum ────────────────────────────────────────────────────────────

enum _NodeState { completed, active, locked }

// ── Screen ────────────────────────────────────────────────────────────────────

class CaminoScreen extends ConsumerStatefulWidget {
  const CaminoScreen({super.key});

  @override
  ConsumerState<CaminoScreen> createState() => _CaminoScreenState();
}

class _CaminoScreenState extends ConsumerState<CaminoScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lessons = ref.watch(pathLessonsProvider);
    final completedIds = ref.watch(completedLessonIdsProvider);
    final persona = ref.watch(personaProvider);
    final isSenior = persona?.isSeniorMode ?? false;

    // Index of the first incomplete lesson (-1 means all done)
    final nextIndex =
        lessons.indexWhere((l) => !completedIds.contains(l.id));

    return Scaffold(
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
          child: Column(
            children: [
              // ── App bar ─────────────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back,
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

              // ── Scrollable river ─────────────────────────────────
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const double baseNodeSize = 56.0;
                    final double nodeSize =
                        isSenior ? 64.0 : baseNodeSize;
                    final double nodeRadius = nodeSize / 2;
                    const double vertSpacing = 130.0;
                    final double horizontalOffset =
                        (constraints.maxWidth * 0.15).clamp(40.0, 100.0);
                    final double totalHeight =
                        vertSpacing * (lessons.length - 1) +
                            nodeSize +
                            80.0;

                    final double centerX = constraints.maxWidth / 2;

                    final List<Offset> centers =
                        List.generate(lessons.length, (i) {
                      final double y =
                          40 + nodeRadius + i * vertSpacing;
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
                              size: Size(constraints.maxWidth,
                                  totalHeight),
                              painter: _RiverPainter(
                                centers: centers,
                                completedIds: completedIds,
                                lessons: lessons,
                                nextIndex: nextIndex,
                              ),
                            ),

                            // Lesson nodes
                            ...List.generate(lessons.length, (i) {
                              final lesson = lessons[i];
                              final center = centers[i];

                              final _NodeState state;
                              if (completedIds.contains(lesson.id)) {
                                state = _NodeState.completed;
                              } else if (i == nextIndex ||
                                  (nextIndex == -1 &&
                                      i == lessons.length - 1)) {
                                state = _NodeState.active;
                              } else {
                                state = _NodeState.locked;
                              }

                              return Positioned(
                                left: center.dx - nodeRadius,
                                top: center.dy - nodeRadius,
                                child: _LessonNode(
                                  lesson: lesson,
                                  state: state,
                                  isSenior: isSenior,
                                  nodeSize: nodeSize,
                                  pulseAnimation: state ==
                                          _NodeState.active
                                      ? _glowAnimation
                                      : null,
                                  onTap: () =>
                                      _onNodeTap(context, lesson, state),
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

  void _onNodeTap(
    BuildContext context,
    PathLesson lesson,
    _NodeState state,
  ) {
    if (state == _NodeState.locked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.caminoLockedSnackbarEs),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => LessonDetailScreen(lesson: lesson),
      ),
    );
  }
}

// ── River path painter ─────────────────────────────────────────────────────────

class _RiverPainter extends CustomPainter {
  const _RiverPainter({
    required this.centers,
    required this.completedIds,
    required this.lessons,
    required this.nextIndex,
  });

  final List<Offset> centers;
  final Set<String> completedIds;
  final List<PathLesson> lessons;
  final int nextIndex;

  @override
  void paint(Canvas canvas, Size size) {
    if (centers.length < 2) return;

    for (int i = 1; i < centers.length; i++) {
      final p1 = centers[i - 1];
      final p2 = centers[i];

      // Determine segment color
      final bool prevCompleted = completedIds.contains(lessons[i - 1].id);
      final bool currCompleted = completedIds.contains(lessons[i].id);
      final Color segmentColor;

      if (prevCompleted && currCompleted) {
        segmentColor = AppColors.successGreen.withValues(alpha: 0.5);
      } else if (prevCompleted && i == nextIndex) {
        segmentColor = AppColors.deepBlue.withValues(alpha: 0.4);
      } else {
        segmentColor =
            AppColors.glassTextMuted.withValues(alpha: 0.25);
      }

      final paint = Paint()
        ..color = segmentColor
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path();
      path.moveTo(p1.dx, p1.dy);
      final midY = (p1.dy + p2.dy) / 2;
      path.cubicTo(p1.dx, midY, p2.dx, midY, p2.dx, p2.dy);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_RiverPainter old) =>
      old.completedIds != completedIds || old.centers != centers;
}

// ── Single lesson node ─────────────────────────────────────────────────────────

class _LessonNode extends StatelessWidget {
  const _LessonNode({
    required this.lesson,
    required this.state,
    required this.isSenior,
    required this.nodeSize,
    required this.onTap,
    this.pulseAnimation,
  });

  final PathLesson lesson;
  final _NodeState state;
  final bool isSenior;
  final double nodeSize;
  final VoidCallback onTap;
  final Animation<double>? pulseAnimation;

  @override
  Widget build(BuildContext context) {
    final bool isLocked = state == _NodeState.locked;
    final bool isCompleted = state == _NodeState.completed;
    final bool isActive = state == _NodeState.active;

    // Node circle color and border
    final Color bgColor = isCompleted
        ? AppColors.successGreen.withValues(alpha: 0.25)
        : isActive
            ? AppColors.deepBlue.withValues(alpha: 0.25)
            : AppColors.glassSurface;

    final Color borderColor = isCompleted
        ? AppColors.successGreen
        : isActive
            ? AppColors.deepBlue
            : AppColors.glassBorder;

    final double borderWidth = isLocked ? 1.0 : 2.0;

    // Label style
    final TextStyle labelStyle = TextStyle(
      color: isLocked ? AppColors.glassTextMuted : AppColors.glassText,
      fontSize: isSenior ? 14.0 : 12.0,
      fontWeight: FontWeight.w600,
    );

    Widget circle = Container(
      width: nodeSize,
      height: nodeSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: isLocked
            ? null
            : [
                BoxShadow(
                  color: borderColor.withValues(alpha: 0.35),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
      ),
      child: Center(
        child: Text(
          lesson.iconEmoji,
          style: TextStyle(fontSize: nodeSize * 0.46),
        ),
      ),
    );

    // Completed: gold checkmark badge in top-right corner
    if (isCompleted) {
      circle = Stack(
        clipBehavior: Clip.none,
        children: [
          circle,
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.premiumGold,
              ),
              child: const Icon(Icons.check, size: 13, color: Colors.white),
            ),
          ),
        ],
      );
    }

    // Locked: lock icon overlay + reduced opacity
    if (isLocked) {
      circle = Opacity(
        opacity: 0.4,
        child: Stack(
          alignment: Alignment.center,
          children: [
            circle,
            Icon(Icons.lock, size: nodeSize * 0.38, color: AppColors.glassTextMuted),
          ],
        ),
      );
    }

    // Active: pulsing glow shadow (ClipOval keeps glow within node bounds)
    if (isActive && pulseAnimation != null) {
      circle = ClipOval(
        child: AnimatedBuilder(
          animation: pulseAnimation!,
          builder: (_, child) => Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: pulseAnimation!.value * 0.45,
                child: Container(
                  width: nodeSize,
                  height: nodeSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.deepBlue,
                  ),
                ),
              ),
              child!,
            ],
          ),
          child: circle,
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          circle,
          const SizedBox(height: 6),
          SizedBox(
            width: nodeSize + 32,
            child: Text(
              lesson.titleEs,
              style: labelStyle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'gamification_controller.dart';

// ── State ─────────────────────────────────────────────────────────────────────
// XpState is kept so all widgets that watch xpProvider continue to compile.
// XpState.fromXp is preserved for any code that constructs it directly.

class XpState {
  const XpState({
    required this.totalXp,
    required this.level,
    required this.levelTitle,
    required this.xpToNextLevel,
    required this.levelProgress,
  });

  final int totalXp;
  final int level; // 1–20
  final String levelTitle;
  final int xpToNextLevel;
  final double levelProgress; // 0.0–1.0
}

// ── Provider (computed from gamificationProvider) ─────────────────────────────

final xpProvider = Provider<XpState>((ref) {
  final g = ref.watch(gamificationProvider);
  return XpState(
    totalXp: g.totalXp,
    level: g.currentLevel,
    levelTitle: g.levelTitle,
    xpToNextLevel: g.xpToNextLevel,
    levelProgress: g.levelProgress,
  );
});

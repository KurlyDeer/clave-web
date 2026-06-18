import 'lesson_models.dart';

// ── TierData ──────────────────────────────────────────────────────────────────

/// Represents one of the 4 curriculum tiers (Fundamentos, Principiante, etc.)
class TierData {
  const TierData({
    required this.id,
    required this.titleEs,
    required this.titleEn,
    required this.order,
    required this.categories,
    this.requiredTierId,
  });

  final String id;
  final String titleEs;
  final String titleEn;
  final int order;
  final List<CategoryData> categories;
  final String? requiredTierId; // null = no gate (always unlocked)
}

// ── CategoryData ──────────────────────────────────────────────────────────────

/// A thematic grouping of lessons within a tier.
class CategoryData {
  const CategoryData({
    required this.id,
    required this.titleEs,
    required this.titleEn,
    required this.order,
    required this.lessons,
  });

  final String id;
  final String titleEs;
  final String titleEn;
  final int order;
  final List<LessonData> lessons;
}

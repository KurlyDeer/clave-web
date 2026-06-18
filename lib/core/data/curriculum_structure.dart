import '../models/curriculum_models.dart';
import '../models/lesson_models.dart';
import 'curriculum_data.dart';
import 'fundamentos_data.dart';

/// Hierarchical curriculum: 4 tiers → categories → lessons.
/// Real lesson content comes from CurriculumData; placeholder lessons have
/// minimal PersonaContent and isPlaceholder = true.
class CurriculumStructure {
  CurriculumStructure._();

  // ── Placeholder factory ───────────────────────────────────────────────────

  static LessonData _ph({
    required String id,
    required String tierId,
    required String categoryId,
    required int order,
    required String level,
    required String titleEs,
    required String titleEn,
  }) {
    const coming = PersonaContent(
      titleEs: 'Próximamente',
      titleEn: 'Coming Soon',
      topicEs: '🔜 En desarrollo',
      milestoneEs: '',
      voiceChallengeEn: '',
      slides: [],
    );
    return LessonData(
      id: id,
      tierId: tierId,
      categoryId: categoryId,
      order: order,
      level: level,
      isPlaceholder: true,
      content: {'nino': coming, 'adulto': coming, 'abuelo': coming},
    );
  }

  // ── Tier definitions ──────────────────────────────────────────────────────

  static final List<TierData> tiers = [
    // ── 0: Fundamentos ────────────────────────────────────────────────────
    TierData(
      id: 'fundamentos',
      titleEs: 'Fundamentos',
      titleEn: 'Foundations',
      order: 0,
      requiredTierId: null,
      categories: [
        CategoryData(
          id: 'alfabeto',
          titleEs: 'El Alfabeto',
          titleEn: 'The Alphabet',
          order: 0,
          lessons: [
            FundamentosData.lesson1,
            _ph(id: 'fundamentos.alfabeto.2', tierId: 'fundamentos', categoryId: 'alfabeto', order: 2, level: 'Básico', titleEs: 'Vocales en Inglés', titleEn: 'English Vowels'),
            _ph(id: 'fundamentos.alfabeto.3', tierId: 'fundamentos', categoryId: 'alfabeto', order: 3, level: 'Básico', titleEs: 'Consonantes Difíciles', titleEn: 'Tricky Consonants'),
          ],
        ),
        CategoryData(
          id: 'pronombres',
          titleEs: 'Pronombres',
          titleEn: 'Pronouns',
          order: 1,
          lessons: [
            FundamentosData.lesson2,
            _ph(id: 'fundamentos.pronombres.2', tierId: 'fundamentos', categoryId: 'pronombres', order: 2, level: 'Básico', titleEs: 'Nosotros, Ellos', titleEn: 'We, They'),
            _ph(id: 'fundamentos.pronombres.3', tierId: 'fundamentos', categoryId: 'pronombres', order: 3, level: 'Básico', titleEs: 'Mi y Tu (My / Your)', titleEn: 'My and Your'),
          ],
        ),
        CategoryData(
          id: 'verboser',
          titleEs: 'El Verbo "To Be"',
          titleEn: 'The Verb "To Be"',
          order: 2,
          lessons: [
            FundamentosData.lesson3,
            _ph(id: 'fundamentos.verboser.2', tierId: 'fundamentos', categoryId: 'verboser', order: 2, level: 'Básico', titleEs: 'Frases con "To Be"', titleEn: 'Sentences with "To Be"'),
            _ph(id: 'fundamentos.verboser.3', tierId: 'fundamentos', categoryId: 'verboser', order: 3, level: 'Básico', titleEs: 'Preguntas con "To Be"', titleEn: 'Questions with "To Be"'),
          ],
        ),
      ],
    ),

    // ── 1: Principiante ────────────────────────────────────────────────────
    TierData(
      id: 'principiante',
      titleEs: 'Principiante',
      titleEn: 'Beginner',
      order: 1,
      requiredTierId: 'fundamentos',
      categories: [
        CategoryData(
          id: 'saludos',
          titleEs: 'Saludos',
          titleEn: 'Greetings',
          order: 0,
          lessons: [CurriculumData.lesson1, CurriculumData.lesson2],
        ),
        CategoryData(
          id: 'familia',
          titleEs: 'La Familia y el Hogar',
          titleEn: 'Family and Home',
          order: 1,
          lessons: [CurriculumData.lesson3, CurriculumData.lesson4],
        ),
        CategoryData(
          id: 'comida',
          titleEs: 'La Comida y el Trabajo',
          titleEn: 'Food and Work',
          order: 2,
          lessons: [CurriculumData.lesson5, CurriculumData.lesson6],
        ),
        CategoryData(
          id: 'numeros',
          titleEs: 'Los Números',
          titleEn: 'Numbers',
          order: 3,
          lessons: [
            _ph(id: 'principiante.numeros.1', tierId: 'principiante', categoryId: 'numeros', order: 1, level: 'Básico', titleEs: 'Números 1–20', titleEn: 'Numbers 1–20'),
            _ph(id: 'principiante.numeros.2', tierId: 'principiante', categoryId: 'numeros', order: 2, level: 'Básico', titleEs: 'Números Grandes', titleEn: 'Big Numbers'),
            _ph(id: 'principiante.numeros.3', tierId: 'principiante', categoryId: 'numeros', order: 3, level: 'Básico', titleEs: 'Dinero y Precios', titleEn: 'Money and Prices'),
          ],
        ),
      ],
    ),

    // ── 2: Intermedio ─────────────────────────────────────────────────────
    TierData(
      id: 'intermedio',
      titleEs: 'Intermedio',
      titleEn: 'Intermediate',
      order: 2,
      requiredTierId: 'principiante',
      categories: [
        CategoryData(
          id: 'trabajo',
          titleEs: 'Emergencias y Preguntas',
          titleEn: 'Emergencies and Questions',
          order: 0,
          lessons: [CurriculumData.lesson7, CurriculumData.lesson8],
        ),
        CategoryData(
          id: 'viajes',
          titleEs: 'Viajes',
          titleEn: 'Travel',
          order: 1,
          lessons: [
            _ph(id: 'intermedio.viajes.1', tierId: 'intermedio', categoryId: 'viajes', order: 1, level: 'Intermedio', titleEs: 'En el Aeropuerto', titleEn: 'At the Airport'),
            _ph(id: 'intermedio.viajes.2', tierId: 'intermedio', categoryId: 'viajes', order: 2, level: 'Intermedio', titleEs: 'Hotel y Hospedaje', titleEn: 'Hotel and Lodging'),
            _ph(id: 'intermedio.viajes.3', tierId: 'intermedio', categoryId: 'viajes', order: 3, level: 'Intermedio', titleEs: 'Transporte Público', titleEn: 'Public Transport'),
          ],
        ),
        CategoryData(
          id: 'salud',
          titleEs: 'Salud',
          titleEn: 'Health',
          order: 2,
          lessons: [
            _ph(id: 'intermedio.salud.1', tierId: 'intermedio', categoryId: 'salud', order: 1, level: 'Intermedio', titleEs: 'En el Doctor', titleEn: 'At the Doctor'),
            _ph(id: 'intermedio.salud.2', tierId: 'intermedio', categoryId: 'salud', order: 2, level: 'Intermedio', titleEs: 'Síntomas y Medicinas', titleEn: 'Symptoms and Medicine'),
            _ph(id: 'intermedio.salud.3', tierId: 'intermedio', categoryId: 'salud', order: 3, level: 'Intermedio', titleEs: 'Emergencias de Salud', titleEn: 'Health Emergencies'),
          ],
        ),
      ],
    ),

    // ── 3: Fluido ─────────────────────────────────────────────────────────
    TierData(
      id: 'fluido',
      titleEs: 'Fluido',
      titleEn: 'Fluent',
      order: 3,
      requiredTierId: 'intermedio',
      categories: [
        CategoryData(
          id: 'conversacion',
          titleEs: 'Dinero y Mi Historia',
          titleEn: 'Money and My Story',
          order: 0,
          lessons: [CurriculumData.lesson9, CurriculumData.lesson10],
        ),
        CategoryData(
          id: 'escritura',
          titleEs: 'Escritura',
          titleEn: 'Writing',
          order: 1,
          lessons: [
            _ph(id: 'fluido.escritura.1', tierId: 'fluido', categoryId: 'escritura', order: 1, level: 'Avanzado', titleEs: 'Cartas Formales', titleEn: 'Formal Letters'),
            _ph(id: 'fluido.escritura.2', tierId: 'fluido', categoryId: 'escritura', order: 2, level: 'Avanzado', titleEs: 'Correos Electrónicos', titleEn: 'Emails'),
            _ph(id: 'fluido.escritura.3', tierId: 'fluido', categoryId: 'escritura', order: 3, level: 'Avanzado', titleEs: 'Cuentos Cortos', titleEn: 'Short Stories'),
          ],
        ),
        CategoryData(
          id: 'cultura',
          titleEs: 'Cultura',
          titleEn: 'Culture',
          order: 2,
          lessons: [
            _ph(id: 'fluido.cultura.1', tierId: 'fluido', categoryId: 'cultura', order: 1, level: 'Avanzado', titleEs: 'Fiestas Americanas', titleEn: 'American Holidays'),
            _ph(id: 'fluido.cultura.2', tierId: 'fluido', categoryId: 'cultura', order: 2, level: 'Avanzado', titleEs: 'Medios de Comunicación', titleEn: 'Media and News'),
            _ph(id: 'fluido.cultura.3', tierId: 'fluido', categoryId: 'cultura', order: 3, level: 'Avanzado', titleEs: 'Modismos Americanos', titleEn: 'American Idioms'),
          ],
        ),
      ],
    ),
  ];

  // ── Static helpers ────────────────────────────────────────────────────────

  static List<LessonData> get allLessons =>
      tiers.expand((t) => t.categories.expand((c) => c.lessons)).toList();

  static LessonData? findLesson(String id) {
    for (final lesson in allLessons) {
      if (lesson.id == id) return lesson;
    }
    return null;
  }

  static List<LessonData> lessonsForTier(String tierId) => tiers
      .firstWhere((t) => t.id == tierId, orElse: () => tiers.first)
      .categories
      .expand((c) => c.lessons)
      .toList();

  /// A tier is unlocked when its prerequisite tier's non-placeholder lessons
  /// are all marked as complete.
  static bool isTierUnlocked(String tierId, Set<String> completedIds) {
    final tier = tiers.firstWhere((t) => t.id == tierId, orElse: () => tiers.first);
    final reqId = tier.requiredTierId;
    if (reqId == null) return true; // fundamentos always unlocked
    final reqTier = tiers.firstWhere((t) => t.id == reqId, orElse: () => tiers.first);
    final required = reqTier.categories
        .expand((c) => c.lessons)
        .where((l) => !l.isPlaceholder)
        .toList();
    return required.every((l) => completedIds.contains(l.id));
  }

  /// Maps old int lesson IDs (1–10) to new String lesson IDs for migration.
  static const Map<int, String> legacyIdMap = {
    1: 'principiante.saludos.1',
    2: 'principiante.saludos.2',
    3: 'principiante.familia.1',
    4: 'principiante.familia.2',
    5: 'principiante.comida.1',
    6: 'principiante.comida.2',
    7: 'intermedio.trabajo.1',
    8: 'intermedio.trabajo.2',
    9: 'fluido.conversacion.1',
    10: 'fluido.conversacion.2',
  };
}

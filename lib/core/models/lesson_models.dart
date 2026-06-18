import 'package:hive/hive.dart';

// ── Slide types ───────────────────────────────────────────────────────────────

enum SlideType { vocab, phrase, quiz, grammarFlip, libroPrompt }

// ── LessonSlide ───────────────────────────────────────────────────────────────

class LessonSlide {
  const LessonSlide({
    required this.type,
    required this.contentEn,
    required this.contentEs,
    this.exampleEn,
    this.exampleEs,
    this.options,
    this.correctIndex,
  });

  final SlideType type;
  final String contentEn;
  final String contentEs;
  final String? exampleEn;
  final String? exampleEs;
  final List<String>? options; // quiz: 4 answer choices; grammarFlip: shuffled words
  final int? correctIndex; // quiz only — 0–3
}

// ── PersonaContent ────────────────────────────────────────────────────────────

class PersonaContent {
  const PersonaContent({
    required this.titleEs,
    required this.titleEn,
    required this.topicEs,
    required this.slides,
    required this.voiceChallengeEn,
    required this.milestoneEs,
  });

  final String titleEs;
  final String titleEn;
  final String topicEs;
  final List<LessonSlide> slides; // always 4: vocab, vocab, phrase, quiz
  final String voiceChallengeEn;
  final String milestoneEs;
}

// ── LessonData ────────────────────────────────────────────────────────────────

class LessonData {
  const LessonData({
    required this.id,
    required this.tierId,
    required this.categoryId,
    required this.order,
    required this.level,
    required this.content,
    this.isPlaceholder = false,
  });

  final String id;        // composite: "tier.category.order", e.g. "principiante.saludos.1"
  final String tierId;    // e.g. "principiante"
  final String categoryId;// e.g. "saludos"
  final int order;        // position within category: 1, 2, 3…
  final String level;     // 'Básico' | 'Intermedio' | 'Avanzado'
  final Map<String, PersonaContent> content; // keys: 'nino', 'adulto', 'abuelo'
  final bool isPlaceholder; // true = "próximamente" lesson with no real content

  PersonaContent forPersona(String key) =>
      content[key] ?? content['adulto']!;
}

// ── LessonProgress (Hive persisted) ──────────────────────────────────────────

class LessonProgress {
  const LessonProgress({
    required this.completed,
    required this.voiceScore,
    required this.feedbackEs,
  });

  final bool completed;
  final int voiceScore; // 0–100
  final String feedbackEs;
}

class LessonProgressAdapter extends TypeAdapter<LessonProgress> {
  @override
  final int typeId = 0;

  @override
  LessonProgress read(BinaryReader r) => LessonProgress(
        completed: r.readBool(),
        voiceScore: r.readInt(),
        feedbackEs: r.readString(),
      );

  @override
  void write(BinaryWriter w, LessonProgress obj) {
    w.writeBool(obj.completed);
    w.writeInt(obj.voiceScore);
    w.writeString(obj.feedbackEs);
  }
}

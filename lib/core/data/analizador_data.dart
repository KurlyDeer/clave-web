/// Practice sentences for the Analizador de Voz.
/// Curated to target the most common pronunciation challenges
/// for Spanish-speaking English learners.
class PracticeSentence {
  const PracticeSentence({
    required this.en,
    required this.es,
    required this.targetSoundEs,
    required this.difficulty, // 1=Básico, 2=Intermedio, 3=Avanzado
  });

  final String en;
  final String es;
  final String targetSoundEs;
  final int difficulty;
}

class AnalizadorData {
  AnalizadorData._();

  static const List<PracticeSentence> sentences = [
    // ── Básico (difficulty 1) ─────────────────────────────────────────────────

    PracticeSentence(
      en: 'Hello, my name is Carlos.',
      es: 'Hola, me llamo Carlos.',
      targetSoundEs: '🔤 Sonidos básicos',
      difficulty: 1,
    ),
    PracticeSentence(
      en: 'Good morning, how are you?',
      es: '¿Buenos días, cómo estás?',
      targetSoundEs: '🔤 Frases de saludo',
      difficulty: 1,
    ),
    PracticeSentence(
      en: 'Please help me, I need water.',
      es: 'Por favor ayúdame, necesito agua.',
      targetSoundEs: '🔤 Palabras básicas',
      difficulty: 1,
    ),

    // ── Intermedio (difficulty 2) ─────────────────────────────────────────────

    PracticeSentence(
      en: 'I think that this is the best thing.',
      es: 'Creo que esto es lo mejor.',
      targetSoundEs: '🦷 Sonido "th" (lengua entre dientes)',
      difficulty: 2,
    ),
    PracticeSentence(
      en: 'The vegetables are very good for you.',
      es: 'Las verduras son muy buenas para ti.',
      targetSoundEs: '🅱️ "V" vs "B" — labios, no dientes',
      difficulty: 2,
    ),
    PracticeSentence(
      en: 'I will sit here and eat this fish.',
      es: 'Me sentaré aquí y comeré este pescado.',
      targetSoundEs: '👅 Vocal corta "i" — ship ≠ sheep',
      difficulty: 2,
    ),
    PracticeSentence(
      en: 'What do you want to watch tonight?',
      es: '¿Qué quieres ver esta noche?',
      targetSoundEs: '💨 Sonido "w" y "wh"',
      difficulty: 2,
    ),

    // ── Avanzado (difficulty 3) ───────────────────────────────────────────────

    PracticeSentence(
      en: 'I need to wash my shirt first.',
      es: 'Necesito lavar mi camisa primero.',
      targetSoundEs: '🌀 "sh", "ir" y consonantes finales',
      difficulty: 3,
    ),
    PracticeSentence(
      en: 'The thirty-three thieves thought they thrilled the throne.',
      es: 'Los treinta y tres ladrones pensaron que emocionaron al trono.',
      targetSoundEs: '🦷 Sonido "th" (combinado con "r")',
      difficulty: 3,
    ),
  ];
}

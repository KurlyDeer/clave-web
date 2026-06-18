import '../models/lesson_models.dart';

/// 3 Fundamentos lessons × 3 personas.
/// Slides per lesson: vocab → vocab → grammarFlip → phrase → libroPrompt.
class FundamentosData {
  FundamentosData._();

  // ── Lesson 1: Saludos Básicos (fundamentos.alfabeto.1) ────────────────────

  static const lesson1 = LessonData(
    id: 'fundamentos.alfabeto.1',
    tierId: 'fundamentos',
    categoryId: 'alfabeto',
    order: 1,
    level: 'Básico',
    content: {
      'nino': PersonaContent(
        titleEs: 'Saludos Básicos',
        titleEn: 'Basic Greetings',
        topicEs: '🏫 Saludos en la Escuela',
        milestoneEs: '¡Aprendiste tus primeros saludos en inglés!',
        voiceChallengeEn: 'Hello, my name is Carlos.',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Hello',
            contentEs: 'Hola',
            exampleEn: 'Hello! I am a new student.',
            exampleEs: '¡Hola! Soy un estudiante nuevo.',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Good morning',
            contentEs: 'Buenos días',
            exampleEn: 'Good morning, teacher! How are you?',
            exampleEs: '¡Buenos días, maestra! ¿Cómo está usted?',
          ),
          LessonSlide(
            type: SlideType.grammarFlip,
            contentEn: 'I am happy',
            contentEs: 'Yo estoy feliz',
            options: ['Happy', 'I', 'Am'],
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'Hello, my name is Carlos.',
            contentEs: 'Hola, me llamo Carlos.',
            exampleEn: 'Hello! My name is Carlos. Nice to meet you!',
            exampleEs: '¡Hola! Me llamo Carlos. ¡Mucho gusto!',
          ),
          LessonSlide(
            type: SlideType.libroPrompt,
            contentEn: 'Hi! My name is ___. Nice to meet you!',
            contentEs: 'Escribe cómo saludarías a un nuevo amigo en inglés.',
          ),
        ],
      ),
      'adulto': PersonaContent(
        titleEs: 'Saludos Básicos',
        titleEn: 'Basic Greetings',
        topicEs: '💼 Saludos en el Trabajo',
        milestoneEs: '¡Ahora puedes saludar con confianza en inglés!',
        voiceChallengeEn: 'Good morning, nice to meet you.',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Hello',
            contentEs: 'Hola',
            exampleEn: 'Hello! I am the new employee.',
            exampleEs: '¡Hola! Soy el nuevo empleado.',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Good morning',
            contentEs: 'Buenos días',
            exampleEn: 'Good morning! Ready to start the day.',
            exampleEs: '¡Buenos días! Listo para empezar el día.',
          ),
          LessonSlide(
            type: SlideType.grammarFlip,
            contentEn: 'I am happy',
            contentEs: 'Yo estoy feliz',
            options: ['Happy', 'I', 'Am'],
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'Good morning, nice to meet you.',
            contentEs: 'Buenos días, mucho gusto.',
            exampleEn: 'Good morning! Nice to meet you. I am María.',
            exampleEs: '¡Buenos días! Mucho gusto. Soy María.',
          ),
          LessonSlide(
            type: SlideType.libroPrompt,
            contentEn: 'Hello! My name is ___. I am happy to be here.',
            contentEs: 'Escribe cómo saludarías a un nuevo colega en inglés.',
          ),
        ],
      ),
      'abuelo': PersonaContent(
        titleEs: 'Saludos Básicos',
        titleEn: 'Basic Greetings',
        topicEs: '🌳 Saludos en la Comunidad',
        milestoneEs: '¡Muy bien! Ya puedes saludar a tus vecinos en inglés.',
        voiceChallengeEn: 'Hello, good morning.',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Hello',
            contentEs: 'Hola',
            exampleEn: 'Hello, neighbor!',
            exampleEs: '¡Hola, vecino!',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Good morning',
            contentEs: 'Buenos días',
            exampleEn: 'Good morning! How are you today?',
            exampleEs: '¡Buenos días! ¿Cómo está hoy?',
          ),
          LessonSlide(
            type: SlideType.grammarFlip,
            contentEn: 'I am happy',
            contentEs: 'Yo estoy feliz',
            options: ['Happy', 'I', 'Am'],
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'Hello, good morning.',
            contentEs: 'Hola, buenos días.',
            exampleEn: 'Hello! Good morning. It is a beautiful day!',
            exampleEs: '¡Hola! Buenos días. ¡Es un día hermoso!',
          ),
          LessonSlide(
            type: SlideType.libroPrompt,
            contentEn: 'Hello! Good morning. How are you?',
            contentEs: 'Escribe un saludo corto en inglés para un vecino.',
          ),
        ],
      ),
    },
  );

  // ── Lesson 2: Los Pronombres (fundamentos.pronombres.1) ───────────────────

  static const lesson2 = LessonData(
    id: 'fundamentos.pronombres.1',
    tierId: 'fundamentos',
    categoryId: 'pronombres',
    order: 1,
    level: 'Básico',
    content: {
      'nino': PersonaContent(
        titleEs: 'Los Pronombres',
        titleEn: 'Pronouns',
        topicEs: '🏫 Yo, Tú, Él, Ella',
        milestoneEs: '¡Ya conoces los pronombres básicos en inglés!',
        voiceChallengeEn: 'He is my brother.',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'I / You',
            contentEs: 'Yo / Tú',
            exampleEn: 'I am a student. You are my friend.',
            exampleEs: 'Yo soy estudiante. Tú eres mi amigo.',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'He / She',
            contentEs: 'Él / Ella',
            exampleEn: 'He is my brother. She is my sister.',
            exampleEs: 'Él es mi hermano. Ella es mi hermana.',
          ),
          LessonSlide(
            type: SlideType.grammarFlip,
            contentEn: 'She is my friend',
            contentEs: 'Ella es mi amiga',
            options: ['Friend', 'She', 'My', 'Is'],
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'He is my brother.',
            contentEs: 'Él es mi hermano.',
            exampleEn: 'He is my brother. He is very funny!',
            exampleEs: 'Él es mi hermano. ¡Es muy chistoso!',
          ),
          LessonSlide(
            type: SlideType.libroPrompt,
            contentEn: 'I am ___. You are ___. She is ___.',
            contentEs: "Escribe tres oraciones usando 'I', 'You' y 'She'.",
          ),
        ],
      ),
      'adulto': PersonaContent(
        titleEs: 'Los Pronombres',
        titleEn: 'Pronouns',
        topicEs: '💼 Yo, Tú, Él, Ella',
        milestoneEs: '¡Excelente! Usas los pronombres como un profesional.',
        voiceChallengeEn: 'He is my colleague.',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'I / You',
            contentEs: 'Yo / Tú',
            exampleEn: 'I am the manager. You are the client.',
            exampleEs: 'Yo soy el gerente. Tú eres el cliente.',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'He / She',
            contentEs: 'Él / Ella',
            exampleEn: 'He is my colleague. She is my supervisor.',
            exampleEs: 'Él es mi colega. Ella es mi supervisora.',
          ),
          LessonSlide(
            type: SlideType.grammarFlip,
            contentEn: 'She is my friend',
            contentEs: 'Ella es mi amiga',
            options: ['Friend', 'She', 'My', 'Is'],
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'He is my colleague.',
            contentEs: 'Él es mi colega.',
            exampleEn: 'He is my colleague. He starts work at 8 AM.',
            exampleEs: 'Él es mi colega. Empieza a trabajar a las 8 AM.',
          ),
          LessonSlide(
            type: SlideType.libroPrompt,
            contentEn: 'I am ___. You are ___. She is ___.',
            contentEs: "Escribe tres oraciones en inglés usando 'I', 'You' y 'She' sobre tu trabajo.",
          ),
        ],
      ),
      'abuelo': PersonaContent(
        titleEs: 'Los Pronombres',
        titleEn: 'Pronouns',
        topicEs: '🌳 Yo, Tú, Él, Ella',
        milestoneEs: '¡Muy bien hecho! Los pronombres son la base del inglés.',
        voiceChallengeEn: 'He is my son.',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'I / You',
            contentEs: 'Yo / Tú',
            exampleEn: 'I am fine. You are kind.',
            exampleEs: 'Yo estoy bien. Tú eres amable.',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'He / She',
            contentEs: 'Él / Ella',
            exampleEn: 'He is my son. She is my daughter.',
            exampleEs: 'Él es mi hijo. Ella es mi hija.',
          ),
          LessonSlide(
            type: SlideType.grammarFlip,
            contentEn: 'She is my friend',
            contentEs: 'Ella es mi amiga',
            options: ['Friend', 'She', 'My', 'Is'],
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'He is my son.',
            contentEs: 'Él es mi hijo.',
            exampleEn: 'He is my son. He is a good person.',
            exampleEs: 'Él es mi hijo. Es una buena persona.',
          ),
          LessonSlide(
            type: SlideType.libroPrompt,
            contentEn: 'I am ___. He is ___. She is ___.',
            contentEs: "Escribe sobre tu familia usando 'I', 'He' y 'She' en inglés.",
          ),
        ],
      ),
    },
  );

  // ── Lesson 3: El Verbo 'To Be' (fundamentos.verboser.1) ──────────────────

  static const lesson3 = LessonData(
    id: 'fundamentos.verboser.1',
    tierId: 'fundamentos',
    categoryId: 'verboser',
    order: 1,
    level: 'Básico',
    content: {
      'nino': PersonaContent(
        titleEs: "El Verbo 'To Be'",
        titleEn: "The Verb 'To Be'",
        topicEs: '🏫 Soy, Eres, Es',
        milestoneEs: "¡Lo lograste! Ya sabes usar el verbo 'to be'.",
        voiceChallengeEn: 'I am a student.',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'I am',
            contentEs: 'Yo soy / Yo estoy',
            exampleEn: 'I am a student. I am happy.',
            exampleEs: 'Yo soy estudiante. Yo estoy feliz.',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'You are / He is',
            contentEs: 'Tú eres / Él es',
            exampleEn: 'You are my friend. He is my teacher.',
            exampleEs: 'Tú eres mi amigo. Él es mi maestro.',
          ),
          LessonSlide(
            type: SlideType.grammarFlip,
            contentEn: 'You are a student',
            contentEs: 'Tú eres un estudiante',
            options: ['Student', 'You', 'A', 'Are'],
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'I am a student.',
            contentEs: 'Yo soy estudiante.',
            exampleEn: 'I am a student. I am 10 years old.',
            exampleEs: 'Yo soy estudiante. Tengo 10 años.',
          ),
          LessonSlide(
            type: SlideType.libroPrompt,
            contentEn: "I am ___. I am ___ years old. I am from ___.",
            contentEs: "Escribe sobre ti usando el verbo 'to be' en inglés.",
          ),
        ],
      ),
      'adulto': PersonaContent(
        titleEs: "El Verbo 'To Be'",
        titleEn: "The Verb 'To Be'",
        topicEs: '💼 Soy, Eres, Es',
        milestoneEs: "¡Perfecto! El verbo 'to be' es la clave del inglés.",
        voiceChallengeEn: 'I am a professional.',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'I am',
            contentEs: 'Yo soy / Yo estoy',
            exampleEn: 'I am a professional. I am ready.',
            exampleEs: 'Yo soy un profesional. Yo estoy listo.',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'You are / He is',
            contentEs: 'Tú eres / Él es',
            exampleEn: 'You are the supervisor. He is my coworker.',
            exampleEs: 'Tú eres el supervisor. Él es mi compañero.',
          ),
          LessonSlide(
            type: SlideType.grammarFlip,
            contentEn: 'You are a student',
            contentEs: 'Tú eres un estudiante',
            options: ['Student', 'You', 'A', 'Are'],
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'I am a professional.',
            contentEs: 'Yo soy un profesional.',
            exampleEn: 'I am a professional. I am very motivated.',
            exampleEs: 'Yo soy un profesional. Estoy muy motivado.',
          ),
          LessonSlide(
            type: SlideType.libroPrompt,
            contentEn: "I am ___. I am from ___. I am a ___.",
            contentEs: "Escribe sobre ti usando el verbo 'to be': tu nombre, origen y profesión.",
          ),
        ],
      ),
      'abuelo': PersonaContent(
        titleEs: "El Verbo 'To Be'",
        titleEn: "The Verb 'To Be'",
        topicEs: '🌳 Soy, Eres, Es',
        milestoneEs: "¡Qué orgullo! Ya usas el verbo 'to be' como un experto.",
        voiceChallengeEn: 'I am well, thank you.',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'I am',
            contentEs: 'Yo soy / Yo estoy',
            exampleEn: 'I am well. I am 70 years old.',
            exampleEs: 'Yo estoy bien. Tengo 70 años.',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'You are / He is',
            contentEs: 'Tú eres / Él es',
            exampleEn: 'You are very kind. He is my doctor.',
            exampleEs: 'Tú eres muy amable. Él es mi médico.',
          ),
          LessonSlide(
            type: SlideType.grammarFlip,
            contentEn: 'You are a student',
            contentEs: 'Tú eres un estudiante',
            options: ['Student', 'You', 'A', 'Are'],
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'I am well, thank you.',
            contentEs: 'Estoy bien, gracias.',
            exampleEn: 'I am well, thank you. I am happy today.',
            exampleEs: 'Estoy bien, gracias. Estoy feliz hoy.',
          ),
          LessonSlide(
            type: SlideType.libroPrompt,
            contentEn: "I am ___. I am from ___. I am happy.",
            contentEs: "Escribe tres oraciones sobre ti usando 'to be' en inglés.",
          ),
        ],
      ),
    },
  );
}

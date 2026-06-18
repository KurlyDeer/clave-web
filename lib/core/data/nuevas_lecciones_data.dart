import '../models/lesson_models.dart';

/// 5 new lessons across Fundamentos and Principiante tiers.
///
/// ── Integration steps (curriculum_structure.dart) ──────────────────────────
///
///  1. fundamentos.alfabeto.2  → replace the _ph() for 'Vocales en Inglés':
///       lessons: [FundamentosData.lesson1, NuevasLeccionesData.lesson1, _ph(...)],
///
///  2. fundamentos.verboser.2  → replace the _ph() for 'Frases con "To Be"':
///       lessons: [FundamentosData.lesson3, NuevasLeccionesData.lesson2, _ph(...)],
///
///  3. principiante.cafeteria, principiante.rutina, principiante.direcciones →
///       add three new CategoryData blocks inside the principiante TierData.
///
class NuevasLeccionesData {
  NuevasLeccionesData._();

  // ── Lesson 1: Saludos Extendidos (fundamentos.alfabeto.2) ─────────────────
  //  Builds on fundamentos.alfabeto.1 (Hello / Good morning) by adding
  //  afternoon/evening greetings and farewells.

  static const lesson1 = LessonData(
    id: 'fundamentos.alfabeto.2',
    tierId: 'fundamentos',
    categoryId: 'alfabeto',
    order: 2,
    level: 'Básico',
    content: {
      'nino': PersonaContent(
        titleEs: 'Saludos Extendidos',
        titleEn: 'Extended Greetings',
        topicEs: '🏫 Buenas Tardes y Adiós',
        milestoneEs: '¡Ahora sabes saludar y despedirte todo el día en inglés!',
        voiceChallengeEn: 'Good afternoon! See you tomorrow.',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Good afternoon',
            contentEs: 'Buenas tardes',
            exampleEn: 'Good afternoon! How was school today?',
            exampleEs: '¡Buenas tardes! ¿Cómo estuvo la escuela hoy?',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Goodbye / See you later',
            contentEs: 'Adiós / Hasta luego',
            exampleEn: 'Goodbye! See you tomorrow at school.',
            exampleEs: '¡Adiós! Hasta mañana en la escuela.',
          ),
          LessonSlide(
            type: SlideType.grammarFlip,
            contentEn: 'See you tomorrow',
            contentEs: 'Hasta mañana',
            options: ['Tomorrow', 'See', 'You'],
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'Good afternoon! See you tomorrow.',
            contentEs: '¡Buenas tardes! Hasta mañana.',
            exampleEn: 'Good afternoon, friend! See you tomorrow at recess.',
            exampleEs: '¡Buenas tardes, amigo! Hasta mañana en el recreo.',
          ),
          LessonSlide(
            type: SlideType.libroPrompt,
            contentEn: 'Good afternoon, ___. See you tomorrow!',
            contentEs: 'Escribe una despedida en inglés para un amigo de la escuela.',
          ),
        ],
      ),
      'adulto': PersonaContent(
        titleEs: 'Saludos Extendidos',
        titleEn: 'Extended Greetings',
        topicEs: '💼 Buenas Tardes y Hasta Mañana',
        milestoneEs: '¡Perfecto! Ya saludas y te despides como un profesional en inglés.',
        voiceChallengeEn: 'Good afternoon, have a nice day.',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Good afternoon',
            contentEs: 'Buenas tardes',
            exampleEn: 'Good afternoon! Is the manager available?',
            exampleEs: '¡Buenas tardes! ¿Está disponible el gerente?',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Goodbye / Have a nice day',
            contentEs: 'Adiós / Que tenga un buen día',
            exampleEn: 'Goodbye! Have a nice day, everyone.',
            exampleEs: '¡Adiós! Que tengan un buen día a todos.',
          ),
          LessonSlide(
            type: SlideType.grammarFlip,
            contentEn: 'See you tomorrow',
            contentEs: 'Hasta mañana',
            options: ['Tomorrow', 'See', 'You'],
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'Good afternoon, have a nice day.',
            contentEs: 'Buenas tardes, que tenga un buen día.',
            exampleEn: 'Good afternoon, sir. Have a nice day. See you next time.',
            exampleEs: 'Buenas tardes, señor. Que tenga un buen día. Hasta la próxima.',
          ),
          LessonSlide(
            type: SlideType.libroPrompt,
            contentEn: 'Good afternoon, ___. Have a nice day!',
            contentEs: 'Escribe cómo te despedirías de un cliente o colega en inglés.',
          ),
        ],
      ),
      'abuelo': PersonaContent(
        titleEs: 'Saludos Extendidos',
        titleEn: 'Extended Greetings',
        topicEs: '🌳 Buenas Tardes y Adiós',
        milestoneEs: '¡Muy bien! Ahora puedes saludar y despedirte en inglés todo el día.',
        voiceChallengeEn: 'Goodbye, see you later.',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Good afternoon',
            contentEs: 'Buenas tardes',
            exampleEn: 'Good afternoon! The park is beautiful today.',
            exampleEs: '¡Buenas tardes! El parque está hermoso hoy.',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Goodbye / See you later',
            contentEs: 'Adiós / Hasta luego',
            exampleEn: 'Goodbye, dear neighbor. See you later!',
            exampleEs: '¡Adiós, querido vecino! Hasta luego.',
          ),
          LessonSlide(
            type: SlideType.grammarFlip,
            contentEn: 'See you tomorrow',
            contentEs: 'Hasta mañana',
            options: ['Tomorrow', 'See', 'You'],
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'Goodbye, see you later.',
            contentEs: 'Adiós, hasta luego.',
            exampleEn: 'Goodbye! It was so good to see you. See you later.',
            exampleEs: '¡Adiós! Fue muy bueno verte. Hasta luego.',
          ),
          LessonSlide(
            type: SlideType.libroPrompt,
            contentEn: 'Goodbye, ___. See you ___!',
            contentEs: 'Escribe una despedida corta en inglés para un vecino o familiar.',
          ),
        ],
      ),
    },
  );

  // ── Lesson 2: El Verbo 'To Be': Nosotros y Ellos (fundamentos.verboser.2) ──
  //  Extends fundamentos.verboser.1 (I am / You are / He is) to cover
  //  "We are / They are" and introduces the question form "Are you...?".

  static const lesson2 = LessonData(
    id: 'fundamentos.verboser.2',
    tierId: 'fundamentos',
    categoryId: 'verboser',
    order: 2,
    level: 'Básico',
    content: {
      'nino': PersonaContent(
        titleEs: "El Verbo 'To Be': Nosotros",
        titleEn: "The Verb 'To Be': We & They",
        topicEs: '🏫 Nosotros Somos, Ellos Son',
        milestoneEs: "¡Increíble! Ya usas 'we are' y 'they are' como un campeón.",
        voiceChallengeEn: 'We are best friends.',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'We are / They are',
            contentEs: 'Nosotros somos / Ellos son',
            exampleEn: 'We are classmates. They are my best friends.',
            exampleEs: 'Nosotros somos compañeros. Ellos son mis mejores amigos.',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Are you...? / Is he...?',
            contentEs: '¿Eres tú...? / ¿Es él...?',
            exampleEn: 'Are you a student? Is he your teacher?',
            exampleEs: '¿Eres tú estudiante? ¿Es él tu maestro?',
          ),
          LessonSlide(
            type: SlideType.grammarFlip,
            contentEn: 'We are a team',
            contentEs: 'Nosotros somos un equipo',
            options: ['Team', 'We', 'Are', 'A'],
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'We are best friends.',
            contentEs: 'Nosotros somos mejores amigos.',
            exampleEn: 'We are best friends. We are always together at school.',
            exampleEs: 'Somos mejores amigos. Siempre estamos juntos en la escuela.',
          ),
          LessonSlide(
            type: SlideType.libroPrompt,
            contentEn: 'We are ___. They are ___.',
            contentEs: "Escribe dos oraciones en inglés usando 'we are' y 'they are' sobre tu clase.",
          ),
        ],
      ),
      'adulto': PersonaContent(
        titleEs: "El Verbo 'To Be': Nosotros",
        titleEn: "The Verb 'To Be': We & They",
        topicEs: '💼 Nosotros Somos, Ellos Son',
        milestoneEs: "¡Excelente! Ahora puedes hablar de grupos usando 'to be'.",
        voiceChallengeEn: 'We are a great team.',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'We are / They are',
            contentEs: 'Nosotros somos / Ellos son',
            exampleEn: 'We are a strong team. They are our best clients.',
            exampleEs: 'Nosotros somos un equipo fuerte. Ellos son nuestros mejores clientes.',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Are you...? / Is she...?',
            contentEs: '¿Eres tú...? / ¿Es ella...?',
            exampleEn: 'Are you the new manager? Is she the lead engineer?',
            exampleEs: '¿Eres tú el nuevo gerente? ¿Es ella la ingeniera principal?',
          ),
          LessonSlide(
            type: SlideType.grammarFlip,
            contentEn: 'We are a team',
            contentEs: 'Nosotros somos un equipo',
            options: ['Team', 'We', 'Are', 'A'],
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'We are a great team.',
            contentEs: 'Nosotros somos un gran equipo.',
            exampleEn: 'We are a great team. Together, we are unstoppable.',
            exampleEs: 'Somos un gran equipo. Juntos, somos imparables.',
          ),
          LessonSlide(
            type: SlideType.libroPrompt,
            contentEn: 'We are ___. They are ___.',
            contentEs: "Escribe sobre tu equipo de trabajo usando 'we are' y 'they are' en inglés.",
          ),
        ],
      ),
      'abuelo': PersonaContent(
        titleEs: "El Verbo 'To Be': Nosotros",
        titleEn: "The Verb 'To Be': We & They",
        topicEs: '🌳 Nosotros Somos, Ellos Son',
        milestoneEs: "¡Qué orgulloso me siento! Ya dominas el verbo 'to be' completo.",
        voiceChallengeEn: 'We are a happy family.',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'We are / They are',
            contentEs: 'Nosotros somos / Ellos son',
            exampleEn: 'We are a family. They are our grandchildren.',
            exampleEs: 'Nosotros somos una familia. Ellos son nuestros nietos.',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Are you...? / Is he...?',
            contentEs: '¿Es usted...? / ¿Es él...?',
            exampleEn: 'Are you the doctor? Is he your son?',
            exampleEs: '¿Es usted el médico? ¿Es él su hijo?',
          ),
          LessonSlide(
            type: SlideType.grammarFlip,
            contentEn: 'We are a team',
            contentEs: 'Nosotros somos un equipo',
            options: ['Team', 'We', 'Are', 'A'],
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'We are a happy family.',
            contentEs: 'Nosotros somos una familia feliz.',
            exampleEn: 'We are a happy family. They are our greatest joy.',
            exampleEs: 'Somos una familia feliz. Ellos son nuestra mayor alegría.',
          ),
          LessonSlide(
            type: SlideType.libroPrompt,
            contentEn: 'We are ___. They are ___.',
            contentEs: "Escribe sobre tu familia usando 'we are' y 'they are' en inglés.",
          ),
        ],
      ),
    },
  );

  // ── Lesson 3: En la Cafetería (principiante.cafeteria.1) ──────────────────
  //  Vocabulary and phrases for ordering coffee, espresso, or other drinks.
  //  The grammar flip uses the exact sentence requested: "I want a dark roast".

  static const lesson3 = LessonData(
    id: 'principiante.cafeteria.1',
    tierId: 'principiante',
    categoryId: 'cafeteria',
    order: 1,
    level: 'Básico',
    content: {
      'nino': PersonaContent(
        titleEs: 'En la Cafetería',
        titleEn: 'At the Café',
        topicEs: '🏫 Pidiendo una Bebida',
        milestoneEs: '¡Ahora puedes pedir tu bebida favorita en inglés!',
        voiceChallengeEn: 'Can I have a hot chocolate, please?',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'I want / Can I have',
            contentEs: 'Quiero / ¿Me puede dar?',
            exampleEn: 'I want a cookie. Can I have a juice, please?',
            exampleEs: 'Quiero una galleta. ¿Me puede dar un jugo, por favor?',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Hot chocolate / With milk',
            contentEs: 'Chocolate caliente / Con leche',
            exampleEn: 'I want a hot chocolate with milk.',
            exampleEs: 'Quiero un chocolate caliente con leche.',
          ),
          LessonSlide(
            type: SlideType.grammarFlip,
            contentEn: 'I want a dark roast',
            contentEs: 'Quiero un café oscuro',
            options: ['A', 'Dark', 'Roast', 'Want', 'I'],
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'Can I have a hot chocolate, please?',
            contentEs: '¿Me puede dar un chocolate caliente, por favor?',
            exampleEn: 'Excuse me! Can I have a hot chocolate, please? Thank you!',
            exampleEs: '¡Disculpe! ¿Me puede dar un chocolate caliente, por favor? ¡Gracias!',
          ),
          LessonSlide(
            type: SlideType.libroPrompt,
            contentEn: 'I want a ___. Can I have ___, please?',
            contentEs: 'Escribe tu orden favorita en una cafetería en inglés.',
          ),
        ],
      ),
      'adulto': PersonaContent(
        titleEs: 'En la Cafetería',
        titleEn: 'At the Café',
        topicEs: '💼 Pidiendo un Café',
        milestoneEs: '¡Excelente! Ya puedes pedir tu café con confianza en inglés.',
        voiceChallengeEn: 'I would like a dark roast coffee, please.',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'I would like / I want',
            contentEs: 'Quisiera / Quiero',
            exampleEn: 'I would like a coffee. I want it to go, please.',
            exampleEs: 'Quisiera un café. Lo quiero para llevar, por favor.',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Dark roast / Espresso / To go',
            contentEs: 'Café oscuro / Espreso / Para llevar',
            exampleEn: 'One espresso and one dark roast to go, please.',
            exampleEs: 'Un espreso y un café oscuro para llevar, por favor.',
          ),
          LessonSlide(
            type: SlideType.grammarFlip,
            contentEn: 'I want a dark roast',
            contentEs: 'Quiero un café oscuro',
            options: ['A', 'Dark', 'Roast', 'Want', 'I'],
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'I would like a dark roast coffee, please.',
            contentEs: 'Quisiera un café oscuro, por favor.',
            exampleEn: 'Good morning! I would like a dark roast coffee, large size, to go please.',
            exampleEs: '¡Buenos días! Quisiera un café oscuro tamaño grande para llevar, por favor.',
          ),
          LessonSlide(
            type: SlideType.libroPrompt,
            contentEn: 'I would like a ___. ___ size, please.',
            contentEs: 'Escribe tu orden de café o bebida favorita en inglés con todos los detalles.',
          ),
        ],
      ),
      'abuelo': PersonaContent(
        titleEs: 'En la Cafetería',
        titleEn: 'At the Café',
        topicEs: '🌳 Pidiendo un Café',
        milestoneEs: '¡Muy bien! Ahora puedes pedir tu café en inglés sin problema.',
        voiceChallengeEn: 'One coffee with milk, please.',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'I want / One please',
            contentEs: 'Quiero / Uno por favor',
            exampleEn: 'I want one coffee, please.',
            exampleEs: 'Quiero un café, por favor.',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Coffee / With milk / With sugar',
            contentEs: 'Café / Con leche / Con azúcar',
            exampleEn: 'One coffee with milk and sugar, please.',
            exampleEs: 'Un café con leche y azúcar, por favor.',
          ),
          LessonSlide(
            type: SlideType.grammarFlip,
            contentEn: 'I want a dark roast',
            contentEs: 'Quiero un café oscuro',
            options: ['A', 'Dark', 'Roast', 'Want', 'I'],
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'One coffee with milk, please.',
            contentEs: 'Un café con leche, por favor.',
            exampleEn: 'Good morning. One coffee with milk, please. How much is it?',
            exampleEs: 'Buenos días. Un café con leche, por favor. ¿Cuánto cuesta?',
          ),
          LessonSlide(
            type: SlideType.libroPrompt,
            contentEn: 'I want a ___. How much is it?',
            contentEs: 'Escribe cómo pedirías tu bebida favorita en inglés.',
          ),
        ],
      ),
    },
  );

  // ── Lesson 4: La Rutina Diaria (principiante.rutina.1) ────────────────────
  //  Morning routine vocabulary: waking up early, exercising, daily habits.
  //  Voice challenge targets the Spanish-speaker challenge of the 'ea' vowel
  //  in "early" and the rolled 'r' in "every".

  static const lesson4 = LessonData(
    id: 'principiante.rutina.1',
    tierId: 'principiante',
    categoryId: 'rutina',
    order: 1,
    level: 'Básico',
    content: {
      'nino': PersonaContent(
        titleEs: 'La Rutina Diaria',
        titleEn: 'My Daily Routine',
        topicEs: '🏫 Mi Mañana Cada Día',
        milestoneEs: '¡Lo lograste! Ya puedes contar tu rutina de mañana en inglés.',
        voiceChallengeEn: 'I wake up at seven every day.',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'I wake up / I get up',
            contentEs: 'Me despierto / Me levanto',
            exampleEn: 'I wake up at 7 AM. Then I get up and brush my teeth.',
            exampleEs: 'Me despierto a las 7 AM. Luego me levanto y me cepillo los dientes.',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'I eat breakfast / I go to school',
            contentEs: 'Desayuno / Voy a la escuela',
            exampleEn: 'I eat breakfast with my family. Then I go to school.',
            exampleEs: 'Desayuno con mi familia. Luego voy a la escuela.',
          ),
          LessonSlide(
            type: SlideType.grammarFlip,
            contentEn: 'I wake up early',
            contentEs: 'Me despierto temprano',
            options: ['Up', 'I', 'Wake', 'Early'],
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'I wake up at seven every day.',
            contentEs: 'Me despierto a las siete todos los días.',
            exampleEn: 'I wake up at seven every day. I eat breakfast and go to school.',
            exampleEs: 'Me despierto a las siete todos los días. Desayuno y voy a la escuela.',
          ),
          LessonSlide(
            type: SlideType.libroPrompt,
            contentEn: 'Every day, I wake up at ___. Then I ___.',
            contentEs: 'Escribe tu rutina de la mañana en inglés paso a paso.',
          ),
        ],
      ),
      'adulto': PersonaContent(
        titleEs: 'La Rutina Diaria',
        titleEn: 'My Daily Routine',
        topicEs: '💼 Mi Rutina de Mañana',
        milestoneEs: '¡Fantástico! Ahora puedes describir tu día en inglés.',
        voiceChallengeEn: 'I wake up early and go to the gym.',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'I wake up early / I get ready',
            contentEs: 'Me despierto temprano / Me preparo',
            exampleEn: 'I wake up early at 5 AM. I get ready for work.',
            exampleEs: 'Me despierto temprano a las 5 AM. Me preparo para el trabajo.',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'I go to the gym / I exercise',
            contentEs: 'Voy al gimnasio / Hago ejercicio',
            exampleEn: 'I go to the gym before work. I exercise for one hour.',
            exampleEs: 'Voy al gimnasio antes del trabajo. Hago ejercicio por una hora.',
          ),
          LessonSlide(
            type: SlideType.grammarFlip,
            contentEn: 'I wake up early',
            contentEs: 'Me despierto temprano',
            options: ['Up', 'I', 'Wake', 'Early'],
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'I wake up early and go to the gym.',
            contentEs: 'Me despierto temprano y voy al gimnasio.',
            exampleEn: 'Every morning I wake up early and go to the gym. Then I go to work.',
            exampleEs: 'Todas las mañanas me despierto temprano y voy al gimnasio. Luego voy al trabajo.',
          ),
          LessonSlide(
            type: SlideType.libroPrompt,
            contentEn: 'Every morning, I wake up at ___. I ___ and then I ___.',
            contentEs: 'Describe tu rutina matutina completa en inglés.',
          ),
        ],
      ),
      'abuelo': PersonaContent(
        titleEs: 'La Rutina Diaria',
        titleEn: 'My Daily Routine',
        topicEs: '🌳 Mi Mañana Tranquila',
        milestoneEs: '¡Qué bien! Ya puedes describir tu mañana en inglés.',
        voiceChallengeEn: 'I wake up early every morning.',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'I wake up / Every morning',
            contentEs: 'Me despierto / Cada mañana',
            exampleEn: 'I wake up every morning at 6 AM.',
            exampleEs: 'Me despierto cada mañana a las 6 AM.',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'I drink coffee / I take a walk',
            contentEs: 'Tomo café / Doy un paseo',
            exampleEn: 'I drink coffee and then I take a walk in the park.',
            exampleEs: 'Tomo café y luego doy un paseo en el parque.',
          ),
          LessonSlide(
            type: SlideType.grammarFlip,
            contentEn: 'I wake up early',
            contentEs: 'Me despierto temprano',
            options: ['Up', 'I', 'Wake', 'Early'],
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'I wake up early every morning.',
            contentEs: 'Me despierto temprano cada mañana.',
            exampleEn: 'I wake up early every morning. I drink my coffee and feel grateful.',
            exampleEs: 'Me despierto temprano cada mañana. Tomo mi café y me siento agradecido.',
          ),
          LessonSlide(
            type: SlideType.libroPrompt,
            contentEn: 'Every morning, I wake up and I ___.',
            contentEs: 'Escribe sobre tu rutina favorita de la mañana en inglés.',
          ),
        ],
      ),
    },
  );

  // ── Lesson 5: Direcciones (principiante.direcciones.1) ────────────────────
  //  Basic navigation: giving and understanding directions.
  //  Voice challenge targets Spanish-speaker difficulty with the English 'r'
  //  in "right", "straight", and the 'gh' cluster in "light" / "right".

  static const lesson5 = LessonData(
    id: 'principiante.direcciones.1',
    tierId: 'principiante',
    categoryId: 'direcciones',
    order: 1,
    level: 'Básico',
    content: {
      'nino': PersonaContent(
        titleEs: 'Direcciones',
        titleEn: 'Directions',
        topicEs: '🏫 ¿Dónde Está la Escuela?',
        milestoneEs: '¡Increíble! Ahora puedes dar y entender direcciones en inglés.',
        voiceChallengeEn: 'Turn left at the corner.',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Turn left / Turn right',
            contentEs: 'Doble a la izquierda / Doble a la derecha',
            exampleEn: 'Turn left at the school. Turn right at the park.',
            exampleEs: 'Doble a la izquierda en la escuela. Doble a la derecha en el parque.',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Go straight / Stop here',
            contentEs: 'Siga recto / Pare aquí',
            exampleEn: 'Go straight for two blocks. Stop here at the corner.',
            exampleEs: 'Siga recto por dos cuadras. Pare aquí en la esquina.',
          ),
          LessonSlide(
            type: SlideType.grammarFlip,
            contentEn: 'Turn right at the light',
            contentEs: 'Doble a la derecha en el semáforo',
            options: ['Right', 'Turn', 'At', 'The', 'Light'],
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'Turn left at the corner.',
            contentEs: 'Doble a la izquierda en la esquina.',
            exampleEn: 'Go straight, then turn left at the corner. The school is there.',
            exampleEs: 'Siga recto, luego doble a la izquierda en la esquina. La escuela está ahí.',
          ),
          LessonSlide(
            type: SlideType.libroPrompt,
            contentEn: 'Go straight. Turn ___. Stop at ___.',
            contentEs: 'Escribe las direcciones para llegar a tu escuela o casa en inglés.',
          ),
        ],
      ),
      'adulto': PersonaContent(
        titleEs: 'Direcciones',
        titleEn: 'Directions',
        topicEs: '💼 Navegando la Ciudad',
        milestoneEs: '¡Excelente! Ya puedes dar y recibir direcciones en inglés.',
        voiceChallengeEn: 'Turn right at the traffic light, please.',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Turn left / Turn right',
            contentEs: 'Doble a la izquierda / Doble a la derecha',
            exampleEn: 'Turn left on Main Street. Turn right at the traffic light.',
            exampleEs: 'Doble a la izquierda en la Calle Principal. Doble a la derecha en el semáforo.',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Go straight / It is on the left',
            contentEs: 'Siga recto / Está a la izquierda',
            exampleEn: 'Go straight for three blocks. The office is on the left.',
            exampleEs: 'Siga recto por tres cuadras. La oficina está a la izquierda.',
          ),
          LessonSlide(
            type: SlideType.grammarFlip,
            contentEn: 'Turn right at the light',
            contentEs: 'Doble a la derecha en el semáforo',
            options: ['Right', 'Turn', 'At', 'The', 'Light'],
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'Turn right at the traffic light, please.',
            contentEs: 'Doble a la derecha en el semáforo, por favor.',
            exampleEn: 'Go straight, then turn right at the traffic light. The building is on your left.',
            exampleEs: 'Siga recto, luego doble a la derecha en el semáforo. El edificio está a su izquierda.',
          ),
          LessonSlide(
            type: SlideType.libroPrompt,
            contentEn: 'Go straight on ___. Turn ___ at ___. The ___ is on your ___.',
            contentEs: 'Escribe las direcciones para llegar a tu trabajo o lugar favorito en inglés.',
          ),
        ],
      ),
      'abuelo': PersonaContent(
        titleEs: 'Direcciones',
        titleEn: 'Directions',
        topicEs: '🌳 Cómo Llegar al Médico',
        milestoneEs: '¡Muy bien hecho! Ahora puedes pedir direcciones en inglés.',
        voiceChallengeEn: 'Please stop here, thank you.',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Turn left / Turn right',
            contentEs: 'Doble a la izquierda / Doble a la derecha',
            exampleEn: 'Turn left at the church. Turn right at the pharmacy.',
            exampleEs: 'Doble a la izquierda en la iglesia. Doble a la derecha en la farmacia.',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Stop here / How far is it?',
            contentEs: 'Pare aquí / ¿A qué distancia está?',
            exampleEn: 'Please stop here. How far is the doctor\'s office?',
            exampleEs: 'Por favor pare aquí. ¿A qué distancia está el consultorio del médico?',
          ),
          LessonSlide(
            type: SlideType.grammarFlip,
            contentEn: 'Turn right at the light',
            contentEs: 'Doble a la derecha en el semáforo',
            options: ['Right', 'Turn', 'At', 'The', 'Light'],
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'Please stop here, thank you.',
            contentEs: 'Por favor pare aquí, gracias.',
            exampleEn: 'Driver, please stop here. The clinic is right there. Thank you very much.',
            exampleEs: 'Conductor, por favor pare aquí. La clínica está justo ahí. Muchas gracias.',
          ),
          LessonSlide(
            type: SlideType.libroPrompt,
            contentEn: 'To get to ___, go straight and turn ___.',
            contentEs: 'Escribe cómo llegar al médico o a la farmacia en inglés.',
          ),
        ],
      ),
    },
  );
}

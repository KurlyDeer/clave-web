import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/scenario_models.dart';

// ── VocabItem ──────────────────────────────────────────────────────────────

class VocabItem {
  const VocabItem({
    required this.wordEn,
    required this.wordEs,
    required this.exampleEn,
    required this.exampleEs,
  });

  final String wordEn;
  final String wordEs;
  final String exampleEn;
  final String exampleEs;

  factory VocabItem.fromJson(Map<String, dynamic> json) => VocabItem(
        wordEn: json['wordEn'] as String,
        wordEs: json['wordEs'] as String,
        exampleEn: json['exampleEn'] as String,
        exampleEs: json['exampleEs'] as String,
      );
}

// ── QuizItem ──────────────────────────────────────────────────────────────

class QuizItem {
  const QuizItem({
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  final String question;
  final List<String> options;
  final int correctIndex;

  factory QuizItem.fromJson(Map<String, dynamic> json) => QuizItem(
        question: json['question'] as String,
        options: (json['options'] as List<dynamic>).cast<String>(),
        correctIndex: (json['correctIndex'] as num).toInt(),
      );
}

// ── PathLesson ────────────────────────────────────────────────────────────

class PathLesson {
  const PathLesson({
    required this.id,
    required this.titleEs,
    required this.titleEn,
    required this.difficulty,
    required this.iconEmoji,
    required this.targetVocabulary,
    required this.grammarRuleEs,
    required this.grammarRuleEn,
    required this.grammarExample,
    required this.simulatorPrompt,
    required this.simulatorCharacterEn,
    required this.simulatorCharacterRoleEs,
    required this.simulatorOpeningEn,
    required this.simulatorOpeningHintEs,
    this.simulatorExpectedTurns = 6,
    this.simulatorTargetGoalEs = '',
    this.quizzes = const [],
  });

  final String id;              // 'path_' prefix prevents collision with tier IDs
  final String titleEs;
  final String titleEn;
  final String difficulty;      // 'A1' | 'A2' | 'B1'
  final String iconEmoji;
  final List<VocabItem> targetVocabulary; // 6–8 items
  final String grammarRuleEs;
  final String grammarRuleEn;
  final String grammarExample;
  final String simulatorPrompt;
  final String simulatorCharacterEn;
  final String simulatorCharacterRoleEs;
  final String simulatorOpeningEn;
  final String simulatorOpeningHintEs;
  final int simulatorExpectedTurns;
  final String simulatorTargetGoalEs;
  final List<QuizItem> quizzes;

  factory PathLesson.fromJson(Map<String, dynamic> json) => PathLesson(
        id: json['id'] as String,
        titleEs: json['titleEs'] as String,
        titleEn: json['titleEn'] as String,
        difficulty: json['difficulty'] as String,
        iconEmoji: json['iconEmoji'] as String,
        targetVocabulary: (json['targetVocabulary'] as List<dynamic>)
            .map((e) => VocabItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        grammarRuleEs: json['grammarRuleEs'] as String,
        grammarRuleEn: json['grammarRuleEn'] as String,
        grammarExample: json['grammarExample'] as String,
        simulatorPrompt: json['simulatorPrompt'] as String,
        simulatorCharacterEn: json['simulatorCharacterEn'] as String,
        simulatorCharacterRoleEs: json['simulatorCharacterRoleEs'] as String,
        simulatorOpeningEn: json['simulatorOpeningEn'] as String,
        simulatorOpeningHintEs: json['simulatorOpeningHintEs'] as String,
        simulatorExpectedTurns:
            (json['simulatorExpectedTurns'] as num?)?.toInt() ?? 6,
        simulatorTargetGoalEs:
            (json['simulatorTargetGoalEs'] as String?) ?? '',
        quizzes: (json['quizzes'] as List<dynamic>? ?? [])
            .map((e) => QuizItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// Converts this lesson into a ScenarioData for the existing SimuladorScreen.
  /// sourceLessonId is set so the simulator can mark this lesson complete on finish.
  ScenarioData toScenarioData() => ScenarioData(
    id: id,
    titleEs: titleEs,
    descriptionEs: titleEn,
    iconEmoji: iconEmoji,
    targetPersona: 'adulto',
    characterNameEn: simulatorCharacterEn,
    characterRoleEs: simulatorCharacterRoleEs,
    openingLineEn: simulatorOpeningEn,
    openingHintEs: simulatorOpeningHintEs,
    systemPrompt: simulatorPrompt,
    expectedTurns: simulatorExpectedTurns,
    sourceLessonId: id,
    targetGoalEs: simulatorTargetGoalEs,
  );
}

// ── LessonRepository ──────────────────────────────────────────────────────

class LessonRepository {
  LessonRepository._();

  /// Parses a JSON string (from an asset file) into a list of PathLessons.
  /// Falls back to the built-in [lessons] list on any parse error.
  static List<PathLesson> parseLessons(String jsonString) {
    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      final list = map['lessons'] as List<dynamic>;
      final result = list
          .map((e) => PathLesson.fromJson(e as Map<String, dynamic>))
          .toList();
      debugPrint('LessonRepository: loaded ${result.length} lessons from JSON');
      return result;
    } catch (e) {
      debugPrint('LessonRepository.parseLessons error: $e — using fallback');
      return lessons;
    }
  }

  // ─── COPY THIS TEMPLATE to add more lessons ───────────────────────────────
  // PathLesson(
  //   id: 'path_xxx_01',       // unique, always prefix with 'path_'
  //   titleEs: 'Título en Español',
  //   titleEn: 'Title in English',
  //   difficulty: 'A1',        // 'A1' | 'A2' | 'B1'
  //   iconEmoji: '🗣️',
  //   targetVocabulary: [
  //     VocabItem(wordEn: 'hello', wordEs: 'hola',
  //               exampleEn: 'Hello! How are you?',
  //               exampleEs: '¡Hola! ¿Cómo estás?'),
  //     // ... 5–7 more
  //   ],
  //   grammarRuleEs: 'Regla gramatical en español...',
  //   grammarRuleEn: 'Grammar rule in English...',
  //   grammarExample: '"I am Maria. She is my friend."',
  //   simulatorPrompt: '''You are a ... (full Claude system prompt returning JSON)''',
  //   simulatorCharacterEn: 'Character Name',
  //   simulatorCharacterRoleEs: 'Rol del personaje',
  //   simulatorOpeningEn: 'Opening line in English...',
  //   simulatorOpeningHintEs: 'Pista de apertura en español...',
  //   simulatorExpectedTurns: 6,
  // ),
  // ─────────────────────────────────────────────────────────────────────────

  static const List<PathLesson> lessons = [
    _presentaciones,
    _enElTrabajo,
    _enElBanco,
    _historiaEEUU,
    _emergencias,
  ];

  // ── Lesson 1: Presentaciones ──────────────────────────────────────────────

  static const _presentaciones = PathLesson(
    id: 'path_introductions_01',
    titleEs: 'Presentaciones',
    titleEn: 'Introductions',
    difficulty: 'A1',
    iconEmoji: '👋',
    targetVocabulary: [
      VocabItem(
        wordEn: 'Hello',
        wordEs: 'Hola',
        exampleEn: 'Hello! My name is Carlos.',
        exampleEs: '¡Hola! Me llamo Carlos.',
      ),
      VocabItem(
        wordEn: 'Name',
        wordEs: 'Nombre',
        exampleEn: 'My name is Maria. What is your name?',
        exampleEs: 'Mi nombre es María. ¿Cuál es tu nombre?',
      ),
      VocabItem(
        wordEn: 'Good morning',
        wordEs: 'Buenos días',
        exampleEn: 'Good morning! How are you today?',
        exampleEs: '¡Buenos días! ¿Cómo estás hoy?',
      ),
      VocabItem(
        wordEn: 'Good afternoon',
        wordEs: 'Buenas tardes',
        exampleEn: 'Good afternoon, nice to see you!',
        exampleEs: 'Buenas tardes, ¡qué gusto verte!',
      ),
      VocabItem(
        wordEn: 'How are you',
        wordEs: '¿Cómo estás?',
        exampleEn: 'Hi! How are you doing?',
        exampleEs: '¡Hola! ¿Cómo estás?',
      ),
      VocabItem(
        wordEn: 'I am fine',
        wordEs: 'Estoy bien',
        exampleEn: 'I am fine, thank you for asking!',
        exampleEs: 'Estoy bien, ¡gracias por preguntar!',
      ),
      VocabItem(
        wordEn: 'Nice to meet you',
        wordEs: 'Mucho gusto',
        exampleEn: 'Nice to meet you! I am from Mexico.',
        exampleEs: 'Mucho gusto. Soy de México.',
      ),
    ],
    grammarRuleEs:
        'Para presentarte en inglés, usa estas frases esenciales:\n\n'
        '• My name is... = Me llamo... / Mi nombre es...\n'
        '• I am from... = Soy de...\n'
        '• I am... years old = Tengo... años\n\n'
        'Recuerda: En inglés siempre se escribe \'I\' (yo) en mayúscula.\n\n'
        'Para preguntar el nombre de alguien:\n'
        '• What is your name? = ¿Cómo te llamas?\n'
        '• Where are you from? = ¿De dónde eres?',
    grammarRuleEn:
        'To introduce yourself in English, use: \'My name is...\' and \'I am from...\'. '
        'Always capitalize \'I\'.',
    grammarExample:
        '"Hello! My name is Carlos. I am from Mexico. Nice to meet you!"',
    simulatorPrompt:
        'You are a friendly neighbor named Linda meeting someone new at an apartment building.\n'
        'The student is a Spanish speaker practicing English introductions.\n\n'
        'RULES:\n'
        '- Be warm and welcoming — short, natural lines (1-2 sentences)\n'
        '- Ask their name, where they are from, and how long they have lived here\n'
        '- Share a little about yourself in return\n'
        '- After 6 exchanges, wrap up the conversation naturally\n'
        '- Return JSON: {"feedbackColor": "green"|"amber"|"red", "aiSpokenReply": "...", "isConversationFinished": false}\n'
        '- "green" if they used correct English introductions; "amber" if understandable but with errors; "red" only if incomprehensible\n'
        '- Set isConversationFinished to true on your natural closing line',
    simulatorCharacterEn: 'Linda',
    simulatorCharacterRoleEs: 'Vecina amigable',
    simulatorOpeningEn:
        'Oh, hello there! Are you the new neighbor? I\'m Linda — so nice to meet you!',
    simulatorOpeningHintEs:
        'Saluda a tu vecina y preséntate en inglés — di tu nombre y de dónde eres.',
    simulatorExpectedTurns: 6,
    simulatorTargetGoalEs: 'Presentarte y saludar a alguien nuevo en inglés',
    quizzes: [
      QuizItem(
        question: '¿Cómo se dice \'Me llamo Ana\' en inglés?',
        options: ['I name is Ana', 'My name is Ana', 'Name me Ana', 'I am name Ana'],
        correctIndex: 1,
      ),
      QuizItem(
        question: '¿Cuál es la traducción de \'Nice to meet you\'?',
        options: ['Hasta luego', 'Buenos días', 'Mucho gusto', 'Estoy bien'],
        correctIndex: 2,
      ),
    ],
  );

  // ── Lesson 2: En el Trabajo ───────────────────────────────────────────────

  static const _enElTrabajo = PathLesson(
    id: 'path_work_01',
    titleEs: 'En el Trabajo',
    titleEn: 'At Work',
    difficulty: 'A1',
    iconEmoji: '💼',
    targetVocabulary: [
      VocabItem(
        wordEn: 'Meeting',
        wordEs: 'Reunión / Junta',
        exampleEn: 'We have a meeting at 9 a.m.',
        exampleEs: 'Tenemos una reunión a las 9 de la mañana.',
      ),
      VocabItem(
        wordEn: 'Boss',
        wordEs: 'Jefe / Jefa',
        exampleEn: 'My boss is very friendly.',
        exampleEs: 'Mi jefe es muy amable.',
      ),
      VocabItem(
        wordEn: 'Schedule',
        wordEs: 'Horario',
        exampleEn: 'What is your work schedule this week?',
        exampleEs: '¿Cuál es tu horario de trabajo esta semana?',
      ),
      VocabItem(
        wordEn: 'Office',
        wordEs: 'Oficina',
        exampleEn: 'Please come to the office by 8 a.m.',
        exampleEs: 'Por favor llega a la oficina a las 8.',
      ),
      VocabItem(
        wordEn: 'Coworker',
        wordEs: 'Compañero de trabajo',
        exampleEn: 'My coworkers are very helpful.',
        exampleEs: 'Mis compañeros de trabajo son muy serviciales.',
      ),
      VocabItem(
        wordEn: 'Email',
        wordEs: 'Correo electrónico',
        exampleEn: 'I will send you an email with the details.',
        exampleEs: 'Te enviaré un correo con los detalles.',
      ),
      VocabItem(
        wordEn: 'On time',
        wordEs: 'A tiempo / Puntual',
        exampleEn: 'It is important to arrive on time.',
        exampleEs: 'Es importante llegar a tiempo.',
      ),
    ],
    grammarRuleEs:
        'En el trabajo, estas frases te ayudarán a comunicarte bien:\n\n'
        '• I need help with... = Necesito ayuda con...\n'
        '• Can you show me...? = ¿Me puede enseñar...?\n'
        '• I don\'t understand = No entiendo\n'
        '• Please repeat that = Por favor repita eso\n\n'
        'Para hablar de obligaciones usa \'I need to\':\n'
        '• I need to finish this = Necesito terminar esto\n'
        '• I need to call my boss = Necesito llamar a mi jefe',
    grammarRuleEn:
        'At work, use \'I need to...\' for obligations and \'Can you...?\' for polite requests.',
    grammarExample:
        '"Excuse me, can you show me how to use this machine? I am new here."',
    simulatorPrompt:
        'You are a helpful supervisor named Tom at a warehouse or factory.\n'
        'The student is a new Spanish-speaking employee on their first day.\n\n'
        'RULES:\n'
        '- Be patient and encouraging — short, clear sentences (1-3 sentences)\n'
        '- Explain the work schedule and what they need to do today\n'
        '- Ask if they understand and if they have any questions\n'
        '- If they make mistakes, gently correct and move on\n'
        '- After 6 exchanges, finish the orientation naturally\n'
        '- Return JSON: {"feedbackColor": "green"|"amber"|"red", "aiSpokenReply": "...", "isConversationFinished": false}\n'
        '- "green" if they communicated work needs clearly; "amber" if understandable but rough; "red" only if incomprehensible\n'
        '- Set isConversationFinished to true when orientation ends',
    simulatorCharacterEn: 'Tom',
    simulatorCharacterRoleEs: 'Supervisor en el trabajo',
    simulatorOpeningEn:
        'Hey, welcome! You must be the new worker. I\'m Tom, your supervisor. Ready to get started?',
    simulatorOpeningHintEs:
        'Saluda a tu supervisor y dile que estás listo para trabajar.',
    simulatorExpectedTurns: 6,
    simulatorTargetGoalEs:
        'Comunicarte con tu supervisor en tu primer día de trabajo',
    quizzes: [
      QuizItem(
        question: '¿Cómo se dice \'jefe\' en inglés?',
        options: ['Worker', 'Boss', 'Schedule', 'Office'],
        correctIndex: 1,
      ),
      QuizItem(
        question: 'Traduce: \'Es importante llegar a tiempo\'',
        options: [
          'It is important to be late',
          'It is important to be on time',
          'It is important to arrive late',
          'It is important to leave on time',
        ],
        correctIndex: 1,
      ),
    ],
  );

  // ── Lesson 3: En el Banco ─────────────────────────────────────────────────

  static const _enElBanco = PathLesson(
    id: 'path_bank_01',
    titleEs: 'En el Banco',
    titleEn: 'At the Bank',
    difficulty: 'A2',
    iconEmoji: '🏦',
    targetVocabulary: [
      VocabItem(
        wordEn: 'Account',
        wordEs: 'Cuenta (bancaria)',
        exampleEn: 'I would like to open a checking account.',
        exampleEs: 'Quisiera abrir una cuenta de cheques.',
      ),
      VocabItem(
        wordEn: 'Deposit',
        wordEs: 'Depósito / Depositar',
        exampleEn: 'I need to make a deposit today.',
        exampleEs: 'Necesito hacer un depósito hoy.',
      ),
      VocabItem(
        wordEn: 'Teller',
        wordEs: 'Cajero del banco',
        exampleEn: 'Please go to teller number three.',
        exampleEs: 'Por favor pase a la ventanilla número tres.',
      ),
      VocabItem(
        wordEn: 'Withdraw',
        wordEs: 'Retirar / Sacar dinero',
        exampleEn: 'I want to withdraw two hundred dollars.',
        exampleEs: 'Quiero retirar doscientos dólares.',
      ),
      VocabItem(
        wordEn: 'Balance',
        wordEs: 'Saldo',
        exampleEn: 'Can you check my account balance, please?',
        exampleEs: '¿Puede revisar mi saldo, por favor?',
      ),
      VocabItem(
        wordEn: 'Check',
        wordEs: 'Cheque',
        exampleEn: 'I would like to cash this check.',
        exampleEs: 'Quisiera cambiar este cheque.',
      ),
      VocabItem(
        wordEn: 'ATM',
        wordEs: 'Cajero automático',
        exampleEn: 'Where is the nearest ATM?',
        exampleEs: '¿Dónde está el cajero automático más cercano?',
      ),
    ],
    grammarRuleEs:
        'En el banco, es importante ser claro y cortés. Usa estas frases:\n\n'
        '• I would like to... = Quisiera / Me gustaría...\n'
        '• I need to... = Necesito...\n'
        '• Can you help me with...? = ¿Me puede ayudar con...?\n\n'
        'Para pedir información:\n'
        '• What do I need for...? = ¿Qué necesito para...?\n'
        '• How long does it take? = ¿Cuánto tiempo tarda?\n'
        '• What are the fees? = ¿Cuáles son las comisiones?',
    grammarRuleEn:
        'At the bank, use \'I would like to...\' for polite requests and '
        '\'Can you help me with...?\' for assistance.',
    grammarExample:
        '"Excuse me, I would like to withdraw some money. Can you help me?"',
    simulatorPrompt:
        'You are a professional bank teller named Jessica at First National Bank.\n'
        'The student is a Spanish speaker who needs help with banking tasks.\n\n'
        'RULES:\n'
        '- Be professional and patient — clear, helpful sentences (1-3 sentences)\n'
        '- Ask how you can help them, then guide them through their request\n'
        '- Ask for ID if needed, explain any steps clearly\n'
        '- Offer to help with anything else before ending\n'
        '- After 6-7 exchanges, close the interaction professionally\n'
        '- Return JSON: {"feedbackColor": "green"|"amber"|"red", "aiSpokenReply": "...", "isConversationFinished": false}\n'
        '- "green" if they communicated their banking needs clearly; "amber" if understandable with some errors; "red" only if incomprehensible\n'
        '- Set isConversationFinished to true when the banking transaction is complete',
    simulatorCharacterEn: 'Jessica',
    simulatorCharacterRoleEs: 'Cajera del banco',
    simulatorOpeningEn:
        'Good morning! Welcome to First National Bank. How can I help you today?',
    simulatorOpeningHintEs:
        'Dile a la cajera lo que necesitas — por ejemplo, hacer un depósito o revisar tu saldo.',
    simulatorExpectedTurns: 6,
    simulatorTargetGoalEs: 'Realizar trámites bancarios básicos en inglés',
    quizzes: [
      QuizItem(
        question: '¿Cómo se dice \'cajero automático\' en inglés?',
        options: ['Teller', 'Balance', 'ATM', 'Deposit'],
        correctIndex: 2,
      ),
      QuizItem(
        question: '¿Cuál es la traducción de \'I would like to withdraw money\'?',
        options: [
          'Me gustaría depositar dinero',
          'Necesito abrir una cuenta',
          'Quisiera retirar dinero',
          'Quiero revisar mi saldo',
        ],
        correctIndex: 2,
      ),
      QuizItem(
        question:
            'Si el cajero te pregunta \'What is your account balance?\', ¿qué te está preguntando?',
        options: [
          '¿Cuál es tu número de cuenta?',
          '¿Cuál es tu saldo?',
          '¿Cuánto vas a depositar?',
          '¿Tienes identificación?',
        ],
        correctIndex: 1,
      ),
    ],
  );

  // ── Lesson 4: Historia de EE.UU. ─────────────────────────────────────────

  static const _historiaEEUU = PathLesson(
    id: 'path_history_01',
    titleEs: 'Historia de EE.UU.',
    titleEn: 'US History',
    difficulty: 'A2',
    iconEmoji: '🇺🇸',
    targetVocabulary: [
      VocabItem(
        wordEn: 'President',
        wordEs: 'Presidente',
        exampleEn: 'The President lives in the White House.',
        exampleEs: 'El Presidente vive en la Casa Blanca.',
      ),
      VocabItem(
        wordEn: 'Freedom',
        wordEs: 'Libertad',
        exampleEn: 'Freedom is a core value in the United States.',
        exampleEs: 'La libertad es un valor fundamental en los Estados Unidos.',
      ),
      VocabItem(
        wordEn: 'Vote',
        wordEs: 'Votar / Voto',
        exampleEn: 'Every citizen has the right to vote.',
        exampleEs: 'Todo ciudadano tiene el derecho de votar.',
      ),
      VocabItem(
        wordEn: 'Constitution',
        wordEs: 'Constitución',
        exampleEn: 'The Constitution protects the rights of all citizens.',
        exampleEs: 'La Constitución protege los derechos de todos los ciudadanos.',
      ),
      VocabItem(
        wordEn: 'Independence',
        wordEs: 'Independencia',
        exampleEn: 'Independence Day is celebrated on July 4th.',
        exampleEs: 'El Día de la Independencia se celebra el 4 de julio.',
      ),
      VocabItem(
        wordEn: 'Rights',
        wordEs: 'Derechos',
        exampleEn: 'All people have basic human rights.',
        exampleEs: 'Todas las personas tienen derechos humanos básicos.',
      ),
      VocabItem(
        wordEn: 'Democracy',
        wordEs: 'Democracia',
        exampleEn: 'The United States is a democracy.',
        exampleEs: 'Los Estados Unidos son una democracia.',
      ),
    ],
    grammarRuleEs:
        'Para hablar de historia, usamos el pasado simple en inglés:\n\n'
        '• The United States declared independence in 1776.\n'
        '  = Los EE.UU. declararon la independencia en 1776.\n\n'
        '• Abraham Lincoln was the 16th president.\n'
        '  = Abraham Lincoln fue el 16° presidente.\n\n'
        'Para hablar de hechos presentes permanentes, usa el presente simple:\n'
        '• The Constitution has 27 amendments.\n'
        '  = La Constitución tiene 27 enmiendas.',
    grammarRuleEn:
        'Use simple past for historical events (\'declared\', \'was\') and '
        'simple present for permanent facts (\'has\', \'is\').',
    grammarExample:
        '"The United States declared independence from Britain in 1776. '
        'George Washington was the first President."',
    simulatorPrompt:
        'You are a friendly civics teacher named Mr. Rivera preparing a student for the US citizenship test.\n'
        'The student is a Spanish speaker learning about American history and civics.\n\n'
        'RULES:\n'
        '- Be encouraging and educational — clear explanations (1-3 sentences)\n'
        '- Ask them questions about US history like a practice civics test\n'
        '- Confirm correct answers warmly; gently correct wrong ones with the right answer\n'
        '- Cover topics like independence, the Constitution, and the President\n'
        '- After 6 exchanges, give them a final encouraging message\n'
        '- Return JSON: {"feedbackColor": "green"|"amber"|"red", "aiSpokenReply": "...", "isConversationFinished": false}\n'
        '- "green" if they answered correctly in English; "amber" if partially correct or with grammar errors; "red" only if incomprehensible\n'
        '- Set isConversationFinished to true after the final encouraging message',
    simulatorCharacterEn: 'Mr. Rivera',
    simulatorCharacterRoleEs: 'Maestro de educación cívica',
    simulatorOpeningEn:
        'Hello! Today we will practice some US history for your citizenship test. '
        'Let\'s start — when did the United States declare independence?',
    simulatorOpeningHintEs:
        'Responde la pregunta del maestro sobre la independencia de EE.UU. — en inglés.',
    simulatorExpectedTurns: 6,
    simulatorTargetGoalEs:
        'Responder preguntas básicas de historia y civismo de EE.UU. en inglés',
    quizzes: [
      QuizItem(
        question: '¿En qué año declaró la independencia los Estados Unidos?',
        options: ['1492', '1776', '1865', '1920'],
        correctIndex: 1,
      ),
      QuizItem(
        question: '¿Cómo se dice \'Constitución\' en inglés?',
        options: ['Freedom', 'Democracy', 'Constitution', 'Rights'],
        correctIndex: 2,
      ),
      QuizItem(
        question: 'Completa: \'Every citizen has the right to ___\'',
        options: ['freedom', 'vote', 'president', 'independence'],
        correctIndex: 1,
      ),
    ],
  );

  // ── Lesson 5: Emergencias ─────────────────────────────────────────────────

  static const _emergencias = PathLesson(
    id: 'path_emergency_01',
    titleEs: 'Emergencias',
    titleEn: 'Emergencies',
    difficulty: 'A1',
    iconEmoji: '🚨',
    targetVocabulary: [
      VocabItem(
        wordEn: 'Help',
        wordEs: 'Ayuda / Auxilio',
        exampleEn: 'Help! I need an ambulance!',
        exampleEs: '¡Auxilio! ¡Necesito una ambulancia!',
      ),
      VocabItem(
        wordEn: 'Hospital',
        wordEs: 'Hospital',
        exampleEn: 'Please take me to the hospital.',
        exampleEs: 'Por favor llévame al hospital.',
      ),
      VocabItem(
        wordEn: 'Police',
        wordEs: 'Policía',
        exampleEn: 'I need to call the police.',
        exampleEs: 'Necesito llamar a la policía.',
      ),
      VocabItem(
        wordEn: 'Ambulance',
        wordEs: 'Ambulancia',
        exampleEn: 'Call an ambulance — it is an emergency!',
        exampleEs: '¡Llama una ambulancia, es una emergencia!',
      ),
      VocabItem(
        wordEn: 'Emergency',
        wordEs: 'Emergencia',
        exampleEn: 'This is an emergency, please hurry!',
        exampleEs: '¡Esto es una emergencia, por favor dese prisa!',
      ),
      VocabItem(
        wordEn: 'Hurt',
        wordEs: 'Herido / Lastimado',
        exampleEn: 'My child is hurt, please help us!',
        exampleEs: 'Mi hijo está herido, ¡por favor ayúdenos!',
      ),
      VocabItem(
        wordEn: 'Call 911',
        wordEs: 'Llamar al 911',
        exampleEn: 'If it is an emergency, call 911 immediately.',
        exampleEs: 'Si es una emergencia, llama al 911 de inmediato.',
      ),
    ],
    grammarRuleEs:
        'En una emergencia, necesitas comunicarte rápido y claro. Memoriza estas frases:\n\n'
        '• Call 911! = ¡Llama al 911!\n'
        '• I need help! = ¡Necesito ayuda!\n'
        '• There is an accident! = ¡Hay un accidente!\n'
        '• Someone is hurt! = ¡Alguien está herido!\n'
        '• I need an ambulance! = ¡Necesito una ambulancia!\n\n'
        'Para describir dónde estás:\n'
        '• I am at... = Estoy en...\n'
        '• The address is... = La dirección es...\n'
        '• Near the... = Cerca del/de la...',
    grammarRuleEn:
        'In an emergency, use short, direct sentences. '
        'Say \'I need...\' and \'Call 911!\' to get help fast.',
    grammarExample:
        '"Help! There is an accident. Someone is hurt. '
        'Please call 911 — we are on Main Street!"',
    simulatorPrompt:
        'You are a calm 911 dispatcher named Officer Davis.\n'
        'The student is a Spanish speaker calling to report an emergency and needs to communicate clearly in English.\n\n'
        'RULES:\n'
        '- Be calm and professional — ask clear, simple questions (1-2 sentences)\n'
        '- Ask what the emergency is, where they are, and if anyone is hurt\n'
        '- Reassure them that help is on the way\n'
        '- Ask for their name and phone number\n'
        '- After 6 exchanges, confirm help is dispatched and close the call\n'
        '- Return JSON: {"feedbackColor": "green"|"amber"|"red", "aiSpokenReply": "...", "isConversationFinished": false}\n'
        '- "green" if they communicated the emergency clearly; "amber" if partially clear with errors; "red" only if incomprehensible\n'
        '- Set isConversationFinished to true after confirming help is on the way',
    simulatorCharacterEn: 'Officer Davis',
    simulatorCharacterRoleEs: 'Operador del 911',
    simulatorOpeningEn: '911, what is your emergency?',
    simulatorOpeningHintEs:
        'Dile al operador cuál es la emergencia — habla claro y rápido en inglés.',
    simulatorExpectedTurns: 6,
    simulatorTargetGoalEs: 'Reportar una emergencia en inglés llamando al 911',
    quizzes: [
      QuizItem(
        question: '¿Cuál es el número de emergencias en EE.UU.?',
        options: ['411', '311', '911', '211'],
        correctIndex: 2,
      ),
      QuizItem(
        question: '¿Cómo se dice \'¡Necesito ayuda!\' en inglés?',
        options: ['I want help', 'I need help', 'Give me help', 'Help me want'],
        correctIndex: 1,
      ),
    ],
  );
}

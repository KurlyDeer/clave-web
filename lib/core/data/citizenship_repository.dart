import 'lesson_repository.dart';

/// Three citizenship-track lessons preparing learners for the USCIS interview.
class CitizenshipRepository {
  CitizenshipRepository._();

  static const List<PathLesson> lessons = [
    _preguntasCivismo,
    _conversacionOficial,
    _enLaCeremonia,
  ];

  // ── Lesson 1: Preguntas de Cívismo ─────────────────────────────────────────

  static const _preguntasCivismo = PathLesson(
    id: 'path_citizenship_civics_01',
    titleEs: 'Preguntas de Cívismo',
    titleEn: 'Civics Questions',
    difficulty: 'A1',
    iconEmoji: '🏛️',
    targetVocabulary: [
      VocabItem(
        wordEn: 'President',
        wordEs: 'Presidente',
        exampleEn: 'Who is the President of the United States?',
        exampleEs: '¿Quién es el Presidente de los Estados Unidos?',
      ),
      VocabItem(
        wordEn: 'Congress',
        wordEs: 'Congreso',
        exampleEn: 'Congress makes the laws.',
        exampleEs: 'El Congreso hace las leyes.',
      ),
      VocabItem(
        wordEn: 'Constitution',
        wordEs: 'Constitución',
        exampleEn: 'The Constitution is the supreme law.',
        exampleEs: 'La Constitución es la ley suprema.',
      ),
      VocabItem(
        wordEn: 'Amendment',
        wordEs: 'Enmienda',
        exampleEn: 'The First Amendment protects free speech.',
        exampleEs: 'La Primera Enmienda protege la libertad de expresión.',
      ),
      VocabItem(
        wordEn: 'Vote',
        wordEs: 'Votar',
        exampleEn: 'Citizens have the right to vote.',
        exampleEs: 'Los ciudadanos tienen el derecho a votar.',
      ),
      VocabItem(
        wordEn: 'Citizen',
        wordEs: 'Ciudadano',
        exampleEn: 'I want to become a citizen.',
        exampleEs: 'Quiero convertirme en ciudadano.',
      ),
      VocabItem(
        wordEn: 'Freedom',
        wordEs: 'Libertad',
        exampleEn: 'Freedom of speech is a right in America.',
        exampleEs: 'La libertad de expresión es un derecho en América.',
      ),
    ],
    grammarRuleEs:
        'El presente simple en inglés se usa para hablar de hechos y verdades permanentes.\n\n'
        '• "The President lives in the White House." = El Presidente vive en la Casa Blanca.\n'
        '• "Congress makes the laws." = El Congreso hace las leyes.\n'
        '• "What does the Constitution do?" = ¿Qué hace la Constitución?\n\n'
        'Para preguntas, usa "do" o "does":\n'
        '• "Do you know the Pledge of Allegiance?" = ¿Conoces el Juramento de Lealtad?',
    grammarRuleEn:
        'Use the present simple to state civic facts during your USCIS interview.',
    grammarExample:
        '"The Constitution is the supreme law of the land. Congress makes the laws."',
    simulatorPrompt: '''You are Officer Rivera, a USCIS immigration officer conducting a civics portion of a naturalization interview.

RULES:
- Ask standard USCIS civics questions one at a time (e.g., "What is the supreme law of the land?", "Who makes the laws?", "What are the first three words of the Constitution?")
- Accept correct or reasonably correct answers
- If wrong, gently correct and move to the next question
- Be professional, calm, and encouraging
- After 6 exchanges, conclude the civics portion positively
- Return JSON: {"feedbackColor": "green"|"amber"|"red", "aiSpokenReply": "...", "isConversationFinished": false}
- "green" if answer is correct; "amber" if partially correct; "red" if clearly incorrect
- Set isConversationFinished to true after wrapping up the civics questions''',
    simulatorCharacterEn: 'Officer Rivera',
    simulatorCharacterRoleEs: 'Oficial de USCIS',
    simulatorOpeningEn:
        'Good morning. I am Officer Rivera. We will now go over some civics questions. Are you ready?',
    simulatorOpeningHintEs:
        'Di que sí y que estás listo — "Yes, I am ready."',
    simulatorExpectedTurns: 6,
    simulatorTargetGoalEs: 'Responder preguntas de cívismo en inglés',
  );

  // ── Lesson 2: Conversación con el Oficial ──────────────────────────────────

  static const _conversacionOficial = PathLesson(
    id: 'path_citizenship_interview_02',
    titleEs: 'Conversación con el Oficial',
    titleEn: 'Conversation with the Officer',
    difficulty: 'A2',
    iconEmoji: '📋',
    targetVocabulary: [
      VocabItem(
        wordEn: 'Interview',
        wordEs: 'Entrevista',
        exampleEn: 'My interview is at 9 a.m.',
        exampleEs: 'Mi entrevista es a las 9 a.m.',
      ),
      VocabItem(
        wordEn: 'Appointment',
        wordEs: 'Cita / Turno',
        exampleEn: 'I have an appointment today.',
        exampleEs: 'Tengo una cita hoy.',
      ),
      VocabItem(
        wordEn: 'Application',
        wordEs: 'Solicitud',
        exampleEn: 'I filled out the application.',
        exampleEs: 'Llené la solicitud.',
      ),
      VocabItem(
        wordEn: 'Oath',
        wordEs: 'Juramento',
        exampleEn: 'I will take the Oath of Allegiance.',
        exampleEs: 'Tomaré el Juramento de Lealtad.',
      ),
      VocabItem(
        wordEn: 'Document',
        wordEs: 'Documento',
        exampleEn: 'Please bring your documents.',
        exampleEs: 'Por favor traiga sus documentos.',
      ),
      VocabItem(
        wordEn: 'Identification',
        wordEs: 'Identificación',
        exampleEn: 'Can I see your identification?',
        exampleEs: '¿Puedo ver su identificación?',
      ),
    ],
    grammarRuleEs:
        'El tiempo pasado simple en inglés se usa para hablar de experiencias previas.\n\n'
        '• "I lived in Mexico for 10 years." = Viví en México por 10 años.\n'
        '• "I worked as a teacher." = Trabajé como maestro.\n'
        '• "Did you ever leave the country?" = ¿Alguna vez salió del país?\n\n'
        'Verbos irregulares comunes:\n'
        '• go → went, come → came, live → lived, work → worked',
    grammarRuleEn:
        'Use the simple past to answer questions about your personal history at the USCIS interview.',
    grammarExample:
        '"I have lived in the United States for five years. I worked in construction."',
    simulatorPrompt: '''You are Officer Chen, a USCIS officer conducting the personal history portion of a naturalization interview.

RULES:
- Ask personal history questions one at a time: Where are you from? How long have you lived here? What do you do for work? Have you ever left the country? Do you support the Constitution?
- Be professional but warm. Use clear, simple English.
- Accept any response that answers the question, even with grammar errors
- After 6-7 exchanges, tell them they passed the interview
- Return JSON: {"feedbackColor": "green"|"amber"|"red", "aiSpokenReply": "...", "isConversationFinished": false}
- "green" if they clearly answered the question; "amber" if understandable but rough; "red" if off-topic
- Set isConversationFinished to true when you conclude the interview''',
    simulatorCharacterEn: 'Officer Chen',
    simulatorCharacterRoleEs: 'Oficial de USCIS',
    simulatorOpeningEn:
        'Good afternoon. Please have a seat. Can I see your green card and ID?',
    simulatorOpeningHintEs:
        'Di "Yes, of course" y muestra tus documentos — di lo que traes.',
    simulatorExpectedTurns: 7,
    simulatorTargetGoalEs: 'Completar la entrevista personal de ciudadanía',
  );

  // ── Lesson 3: En la Ceremonia ──────────────────────────────────────────────

  static const _enLaCeremonia = PathLesson(
    id: 'path_citizenship_ceremony_03',
    titleEs: 'En la Ceremonia',
    titleEn: 'At the Ceremony',
    difficulty: 'A2',
    iconEmoji: '🎉',
    targetVocabulary: [
      VocabItem(
        wordEn: 'Oath',
        wordEs: 'Juramento',
        exampleEn: 'I take this oath freely.',
        exampleEs: 'Tomo este juramento libremente.',
      ),
      VocabItem(
        wordEn: 'Allegiance',
        wordEs: 'Lealtad / Fidelidad',
        exampleEn: 'I pledge allegiance to the flag.',
        exampleEs: 'Juro lealtad a la bandera.',
      ),
      VocabItem(
        wordEn: 'Flag',
        wordEs: 'Bandera',
        exampleEn: 'The American flag has 50 stars.',
        exampleEs: 'La bandera americana tiene 50 estrellas.',
      ),
      VocabItem(
        wordEn: 'Pledge',
        wordEs: 'Promesa / Jurar',
        exampleEn: 'We pledge to defend the Constitution.',
        exampleEs: 'Prometemos defender la Constitución.',
      ),
      VocabItem(
        wordEn: 'Ceremony',
        wordEs: 'Ceremonia',
        exampleEn: 'The ceremony was beautiful.',
        exampleEs: 'La ceremonia fue hermosa.',
      ),
      VocabItem(
        wordEn: 'Congratulations',
        wordEs: 'Felicitaciones',
        exampleEn: 'Congratulations, you are now a citizen!',
        exampleEs: '¡Felicitaciones, ahora eres ciudadano!',
      ),
      VocabItem(
        wordEn: 'Certificate',
        wordEs: 'Certificado',
        exampleEn: 'I received my citizenship certificate.',
        exampleEs: 'Recibí mi certificado de ciudadanía.',
      ),
    ],
    grammarRuleEs:
        'El tiempo futuro en inglés se forma con "will" o "going to".\n\n'
        '• "I will become a citizen today." = Hoy me convertiré en ciudadano.\n'
        '• "I am going to vote in the next election." = Voy a votar en las próximas elecciones.\n'
        '• "Will you celebrate tonight?" = ¿Vas a celebrar esta noche?\n\n'
        '"Will" se usa para decisiones en el momento.\n'
        '"Going to" se usa para planes ya decididos.',
    grammarRuleEn:
        'Use "will" and "going to" to talk about your plans as a new citizen.',
    grammarExample:
        '"I will vote in every election. I am going to learn more English every day."',
    simulatorPrompt: '''You are Maria, a fellow new citizen sitting next to the student at the naturalization ceremony.

RULES:
- Be warm, excited, and celebratory — this is a joyful day!
- Talk about how you both feel, your plans as new citizens, the ceremony, the oath, voting for the first time
- Use simple, conversational English (A2 level)
- Ask the student questions to keep the conversation going
- After 5-6 exchanges, celebrate together as new citizens
- Return JSON: {"feedbackColor": "green"|"amber"|"red", "aiSpokenReply": "...", "isConversationFinished": false}
- "green" if they responded naturally; "amber" if understandable; "red" if incomprehensible
- Set isConversationFinished to true when you celebrate your new citizenship together''',
    simulatorCharacterEn: 'Maria',
    simulatorCharacterRoleEs: 'Nueva ciudadana en la ceremonia',
    simulatorOpeningEn:
        "I can't believe this day is finally here! Are you excited to become a citizen?",
    simulatorOpeningHintEs:
        'Di que sí y cómo te sientes — "Yes! I am so happy and excited!"',
    simulatorExpectedTurns: 6,
    simulatorTargetGoalEs: 'Celebrar la ceremonia de ciudadanía en inglés',
  );
}

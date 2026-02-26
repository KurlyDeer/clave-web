import '../models/lesson_models.dart';
import '../../l10n/app_strings.dart';

// ── Career Curriculum (IDs 101–303, no collision with core 1–10) ──────────────

class CareerCurriculumData {
  CareerCurriculumData._();

  static const List<LessonData> all = [
    _l101, _l102, _l103,
    _l201, _l202, _l203,
    _l301, _l302, _l303,
  ];

  static List<LessonData> forTrack(List<int> ids) =>
      all.where((l) => ids.contains(l.id)).toList();
}

// ── Construcción ──────────────────────────────────────────────────────────────

const _l101 = LessonData(
  id: 101,
  level: AppStrings.lessonLevelEspecializado,
  content: {
    'adulto': PersonaContent(
      titleEs: 'Seguridad en la Obra',
      titleEn: 'Job Site Safety',
      topicEs: 'Vocabulario esencial de seguridad',
      voiceChallengeEn: 'Watch out! Wear your hard hat at all times.',
      milestoneEs: '¡Conoces el vocabulario de seguridad en la obra!',
      slides: [
        LessonSlide(
          type: SlideType.vocab,
          contentEn: 'Hard hat / Safety vest',
          contentEs: 'Casco / Chaleco de seguridad',
          exampleEn: 'Always wear your hard hat on the job site.',
          exampleEs: 'Siempre usa tu casco en la obra.',
        ),
        LessonSlide(
          type: SlideType.vocab,
          contentEn: 'Danger / Warning',
          contentEs: 'Peligro / Advertencia',
          exampleEn: 'There is a danger sign on that area.',
          exampleEs: 'Hay una señal de peligro en esa área.',
        ),
        LessonSlide(
          type: SlideType.phrase,
          contentEn: '"Watch out!"',
          contentEs: '"¡Cuidado!"',
          exampleEn: 'Watch out! There is a wet floor.',
          exampleEs: '¡Cuidado! Hay piso mojado.',
        ),
        LessonSlide(
          type: SlideType.quiz,
          contentEn: 'Which phrase warns coworkers of immediate danger?',
          contentEs: '¿Qué frase advierte a los compañeros de un peligro inmediato?',
          options: [
            '"Watch out!"',
            '"Good morning!"',
            '"See you later!"',
            '"Thank you!"',
          ],
          correctIndex: 0,
        ),
      ],
    ),
    'abuelo': PersonaContent(
      titleEs: 'Seguridad en la Obra',
      titleEn: 'Job Site Safety',
      topicEs: 'Palabras importantes de seguridad',
      voiceChallengeEn: 'Watch out! Wear your hard hat at all times.',
      milestoneEs: '¡Aprendiste las palabras de seguridad más importantes!',
      slides: [
        LessonSlide(
          type: SlideType.vocab,
          contentEn: 'Hard hat / Safety vest',
          contentEs: 'Casco / Chaleco de seguridad',
          exampleEn: 'Put on your hard hat before entering the site.',
          exampleEs: 'Ponte el casco antes de entrar a la obra.',
        ),
        LessonSlide(
          type: SlideType.vocab,
          contentEn: 'Danger / Warning',
          contentEs: 'Peligro / Advertencia',
          exampleEn: 'The warning sign means be careful.',
          exampleEs: 'La señal de advertencia significa ten cuidado.',
        ),
        LessonSlide(
          type: SlideType.phrase,
          contentEn: '"Watch out!"',
          contentEs: '"¡Cuidado!"',
          exampleEn: 'Watch out! The ladder is not stable.',
          exampleEs: '¡Cuidado! La escalera no está estable.',
        ),
        LessonSlide(
          type: SlideType.quiz,
          contentEn: 'What do you say to warn someone of danger?',
          contentEs: '¿Qué dices para advertir a alguien de un peligro?',
          options: [
            '"Watch out!"',
            '"Good job!"',
            '"Let\'s go!"',
            '"I am done."',
          ],
          correctIndex: 0,
        ),
      ],
    ),
  },
);

const _l102 = LessonData(
  id: 102,
  level: AppStrings.lessonLevelEspecializado,
  content: {
    'adulto': PersonaContent(
      titleEs: 'Herramientas y Materiales',
      titleEn: 'Tools and Materials',
      topicEs: 'Vocabulario de herramientas de construcción',
      voiceChallengeEn: 'I need a drill and some screws for this wall.',
      milestoneEs: '¡Ya puedes pedir herramientas en inglés!',
      slides: [
        LessonSlide(
          type: SlideType.vocab,
          contentEn: 'Drill / Screwdriver',
          contentEs: 'Taladro / Desarmador',
          exampleEn: 'Can you pass me the drill? I need to make a hole.',
          exampleEs: '¿Me puedes pasar el taladro? Necesito hacer un hoyo.',
        ),
        LessonSlide(
          type: SlideType.vocab,
          contentEn: 'Lumber / Concrete',
          contentEs: 'Madera / Concreto',
          exampleEn: 'We need more lumber for the frame.',
          exampleEs: 'Necesitamos más madera para el armazón.',
        ),
        LessonSlide(
          type: SlideType.phrase,
          contentEn: '"Can you pass me the…?"',
          contentEs: '"¿Me puedes pasar el…?"',
          exampleEn: 'Can you pass me the hammer? It is on the table.',
          exampleEs: '¿Me puedes pasar el martillo? Está en la mesa.',
        ),
        LessonSlide(
          type: SlideType.quiz,
          contentEn: 'Which tool makes holes in walls?',
          contentEs: '¿Qué herramienta hace hoyos en las paredes?',
          options: [
            'Drill',
            'Lumber',
            'Concrete',
            'Safety vest',
          ],
          correctIndex: 0,
        ),
      ],
    ),
    'abuelo': PersonaContent(
      titleEs: 'Herramientas y Materiales',
      titleEn: 'Tools and Materials',
      topicEs: 'Herramientas básicas de trabajo',
      voiceChallengeEn: 'I need a drill and some screws for this wall.',
      milestoneEs: '¡Ahora puedes pedir herramientas con confianza!',
      slides: [
        LessonSlide(
          type: SlideType.vocab,
          contentEn: 'Drill / Screwdriver',
          contentEs: 'Taladro / Desarmador',
          exampleEn: 'The drill is a powerful tool for making holes.',
          exampleEs: 'El taladro es una herramienta potente para hacer hoyos.',
        ),
        LessonSlide(
          type: SlideType.vocab,
          contentEn: 'Lumber / Concrete',
          contentEs: 'Madera / Concreto',
          exampleEn: 'We use concrete for strong foundations.',
          exampleEs: 'Usamos concreto para bases fuertes.',
        ),
        LessonSlide(
          type: SlideType.phrase,
          contentEn: '"Can you pass me the…?"',
          contentEs: '"¿Me puedes pasar el…?"',
          exampleEn: 'Can you pass me the screwdriver, please?',
          exampleEs: '¿Me puedes pasar el desarmador, por favor?',
        ),
        LessonSlide(
          type: SlideType.quiz,
          contentEn: 'Which tool is used to make holes?',
          contentEs: '¿Qué herramienta se usa para hacer hoyos?',
          options: [
            'Drill',
            'Screwdriver',
            'Lumber',
            'Hard hat',
          ],
          correctIndex: 0,
        ),
      ],
    ),
  },
);

const _l103 = LessonData(
  id: 103,
  level: AppStrings.lessonLevelEspecializado,
  content: {
    'adulto': PersonaContent(
      titleEs: 'Hablar con el Supervisor',
      titleEn: 'Talking to Your Supervisor',
      topicEs: 'Comunicación profesional en el trabajo',
      voiceChallengeEn: 'Excuse me, I need to report a safety issue.',
      milestoneEs: '¡Puedes comunicarte profesionalmente con tu supervisor!',
      slides: [
        LessonSlide(
          type: SlideType.vocab,
          contentEn: 'Supervisor / Foreman',
          contentEs: 'Supervisor / Capataz',
          exampleEn: 'The supervisor checks the work every morning.',
          exampleEs: 'El supervisor revisa el trabajo cada mañana.',
        ),
        LessonSlide(
          type: SlideType.vocab,
          contentEn: 'Report / Overtime',
          contentEs: 'Reportar / Tiempo extra',
          exampleEn: 'I need to report a broken tool to the foreman.',
          exampleEs: 'Necesito reportar una herramienta rota al capataz.',
        ),
        LessonSlide(
          type: SlideType.phrase,
          contentEn: '"I would like to report…"',
          contentEs: '"Quisiera reportar…"',
          exampleEn: 'I would like to report a safety concern on level two.',
          exampleEs: 'Quisiera reportar un problema de seguridad en el nivel dos.',
        ),
        LessonSlide(
          type: SlideType.quiz,
          contentEn: 'What is the most professional way to raise a concern with your boss?',
          contentEs: '¿Cuál es la forma más profesional de hablar con tu jefe sobre un problema?',
          options: [
            '"I would like to report…"',
            '"Hey! There is a problem!"',
            '"Fix this now!"',
            '"Whatever."',
          ],
          correctIndex: 0,
        ),
      ],
    ),
    'abuelo': PersonaContent(
      titleEs: 'Hablar con el Supervisor',
      titleEn: 'Talking to Your Supervisor',
      topicEs: 'Cómo hablar con tu jefe en inglés',
      voiceChallengeEn: 'Excuse me, I need to report a safety issue.',
      milestoneEs: '¡Ahora sabes cómo hablar con tu jefe de forma respetuosa!',
      slides: [
        LessonSlide(
          type: SlideType.vocab,
          contentEn: 'Supervisor / Foreman',
          contentEs: 'Supervisor / Capataz',
          exampleEn: 'Always speak respectfully to your supervisor.',
          exampleEs: 'Siempre habla con respeto a tu supervisor.',
        ),
        LessonSlide(
          type: SlideType.vocab,
          contentEn: 'Report / Overtime',
          contentEs: 'Reportar / Tiempo extra',
          exampleEn: 'Report any danger to the foreman right away.',
          exampleEs: 'Reporta cualquier peligro al capataz de inmediato.',
        ),
        LessonSlide(
          type: SlideType.phrase,
          contentEn: '"I would like to report…"',
          contentEs: '"Quisiera reportar…"',
          exampleEn: 'I would like to report a problem with the equipment.',
          exampleEs: 'Quisiera reportar un problema con el equipo.',
        ),
        LessonSlide(
          type: SlideType.quiz,
          contentEn: 'How do you politely raise an issue with your supervisor?',
          contentEs: '¿Cómo le dices respetuosamente un problema a tu supervisor?',
          options: [
            '"I would like to report…"',
            '"You need to fix this!"',
            '"I quit!"',
            '"Never mind."',
          ],
          correctIndex: 0,
        ),
      ],
    ),
  },
);

// ── Salud ─────────────────────────────────────────────────────────────────────

const _l201 = LessonData(
  id: 201,
  level: AppStrings.lessonLevelEspecializado,
  content: {
    'adulto': PersonaContent(
      titleEs: 'En la Clínica',
      titleEn: 'At the Clinic',
      topicEs: 'Vocabulario para la sala de espera y recepción',
      voiceChallengeEn: 'I have an appointment at two o\'clock with Doctor Smith.',
      milestoneEs: '¡Puedes comunicarte en la clínica en inglés!',
      slides: [
        LessonSlide(
          type: SlideType.vocab,
          contentEn: 'Appointment / Waiting room',
          contentEs: 'Cita / Sala de espera',
          exampleEn: 'I have an appointment at two o\'clock.',
          exampleEs: 'Tengo una cita a las dos.',
        ),
        LessonSlide(
          type: SlideType.vocab,
          contentEn: 'Insurance / Co-pay',
          contentEs: 'Seguro médico / Copago',
          exampleEn: 'Do you accept my insurance?',
          exampleEs: '¿Aceptan mi seguro médico?',
        ),
        LessonSlide(
          type: SlideType.phrase,
          contentEn: '"I need to check in."',
          contentEs: '"Necesito registrarme."',
          exampleEn: 'Hi, I need to check in. My name is Maria Garcia.',
          exampleEs: 'Hola, necesito registrarme. Me llamo María García.',
        ),
        LessonSlide(
          type: SlideType.quiz,
          contentEn: 'What do you say when you arrive at the doctor\'s office?',
          contentEs: '¿Qué dices cuando llegas al consultorio del médico?',
          options: [
            '"I need to check in."',
            '"I am leaving."',
            '"Goodbye!"',
            '"I am the doctor."',
          ],
          correctIndex: 0,
        ),
      ],
    ),
    'abuelo': PersonaContent(
      titleEs: 'En la Clínica',
      titleEn: 'At the Clinic',
      topicEs: 'Palabras útiles para ir al doctor',
      voiceChallengeEn: 'I have an appointment at two o\'clock with Doctor Smith.',
      milestoneEs: '¡Ahora puedes ir al doctor con más confianza!',
      slides: [
        LessonSlide(
          type: SlideType.vocab,
          contentEn: 'Appointment / Waiting room',
          contentEs: 'Cita / Sala de espera',
          exampleEn: 'Please wait in the waiting room.',
          exampleEs: 'Por favor espere en la sala de espera.',
        ),
        LessonSlide(
          type: SlideType.vocab,
          contentEn: 'Insurance / Co-pay',
          contentEs: 'Seguro médico / Copago',
          exampleEn: 'The co-pay is twenty dollars.',
          exampleEs: 'El copago es veinte dólares.',
        ),
        LessonSlide(
          type: SlideType.phrase,
          contentEn: '"I need to check in."',
          contentEs: '"Necesito registrarme."',
          exampleEn: 'Good morning. I need to check in for my appointment.',
          exampleEs: 'Buenos días. Necesito registrarme para mi cita.',
        ),
        LessonSlide(
          type: SlideType.quiz,
          contentEn: 'What do you say when you arrive at the clinic?',
          contentEs: '¿Qué dices cuando llegas a la clínica?',
          options: [
            '"I need to check in."',
            '"I want to leave."',
            '"Where is the park?"',
            '"I am fine."',
          ],
          correctIndex: 0,
        ),
      ],
    ),
  },
);

const _l202 = LessonData(
  id: 202,
  level: AppStrings.lessonLevelEspecializado,
  content: {
    'adulto': PersonaContent(
      titleEs: 'Describir Síntomas',
      titleEn: 'Describing Symptoms',
      topicEs: 'Cómo explicar tus síntomas al doctor',
      voiceChallengeEn:
          'I hurt my back lifting boxes at work. I need to see a doctor.',
      milestoneEs: '¡Puedes describir tus síntomas en inglés!',
      slides: [
        LessonSlide(
          type: SlideType.vocab,
          contentEn: 'Pain / Swelling',
          contentEs: 'Dolor / Inflamación',
          exampleEn: 'I feel pain in my right shoulder.',
          exampleEs: 'Siento dolor en mi hombro derecho.',
        ),
        LessonSlide(
          type: SlideType.vocab,
          contentEn: 'Injured / Workers\' comp',
          contentEs: 'Lesionado / Compensación laboral',
          exampleEn: 'I was injured at work and need workers\' comp.',
          exampleEs: 'Me lesioné en el trabajo y necesito compensación laboral.',
        ),
        LessonSlide(
          type: SlideType.phrase,
          contentEn: '"The pain started when I…"',
          contentEs: '"El dolor empezó cuando yo…"',
          exampleEn: 'The pain started when I lifted a heavy box.',
          exampleEs: 'El dolor empezó cuando levanté una caja pesada.',
        ),
        LessonSlide(
          type: SlideType.quiz,
          contentEn: 'How do you describe back pain from work to the doctor?',
          contentEs: '¿Cómo describes el dolor de espalda del trabajo al doctor?',
          options: [
            '"I hurt my back lifting boxes at work."',
            '"I feel great today."',
            '"The weather is nice."',
            '"I need some coffee."',
          ],
          correctIndex: 0,
        ),
      ],
    ),
    'abuelo': PersonaContent(
      titleEs: 'Describir Síntomas',
      titleEn: 'Describing Symptoms',
      topicEs: 'Cómo decirle al doctor cómo te sientes',
      voiceChallengeEn:
          'I hurt my back lifting boxes at work. I need to see a doctor.',
      milestoneEs: '¡Ahora puedes decirle al doctor cómo te sientes!',
      slides: [
        LessonSlide(
          type: SlideType.vocab,
          contentEn: 'Pain / Swelling',
          contentEs: 'Dolor / Inflamación',
          exampleEn: 'I have pain in my knee.',
          exampleEs: 'Tengo dolor en la rodilla.',
        ),
        LessonSlide(
          type: SlideType.vocab,
          contentEn: 'Injured / Senior discount',
          contentEs: 'Injuriado / Descuento para mayores',
          exampleEn: 'Ask about the senior discount for your visit.',
          exampleEs: 'Pregunta por el descuento para mayores en tu visita.',
        ),
        LessonSlide(
          type: SlideType.phrase,
          contentEn: '"The pain started when I…"',
          contentEs: '"El dolor empezó cuando yo…"',
          exampleEn: 'The pain started when I stood up this morning.',
          exampleEs: 'El dolor empezó cuando me levanté esta mañana.',
        ),
        LessonSlide(
          type: SlideType.quiz,
          contentEn: 'What is the best way to tell the doctor about your pain?',
          contentEs: '¿Cuál es la mejor forma de decirle al doctor sobre tu dolor?',
          options: [
            '"The pain started when I lifted boxes."',
            '"I am very happy today."',
            '"It is a sunny day."',
            '"I like soup."',
          ],
          correctIndex: 0,
        ),
      ],
    ),
  },
);

const _l203 = LessonData(
  id: 203,
  level: AppStrings.lessonLevelEspecializado,
  content: {
    'adulto': PersonaContent(
      titleEs: 'Cuidado de Pacientes',
      titleEn: 'Patient Care',
      topicEs: 'Inglés para trabajar cuidando personas',
      voiceChallengeEn:
          'Good morning. I am here to check on you and take your temperature.',
      milestoneEs: '¡Sabes el inglés básico para cuidar pacientes!',
      slides: [
        LessonSlide(
          type: SlideType.vocab,
          contentEn: 'Patient / Nurse',
          contentEs: 'Paciente / Enfermera',
          exampleEn: 'The nurse checks on the patient every hour.',
          exampleEs: 'La enfermera revisa al paciente cada hora.',
        ),
        LessonSlide(
          type: SlideType.vocab,
          contentEn: 'Temperature / Blood pressure',
          contentEs: 'Temperatura / Presión arterial',
          exampleEn: 'Your temperature is normal at ninety-eight point six.',
          exampleEs: 'Tu temperatura está normal a noventa y ocho punto seis.',
        ),
        LessonSlide(
          type: SlideType.phrase,
          contentEn: '"How are you feeling today?"',
          contentEs: '"¿Cómo se siente hoy?"',
          exampleEn: 'Good morning, Mr. Jones. How are you feeling today?',
          exampleEs: 'Buenos días, Sr. Jones. ¿Cómo se siente hoy?',
        ),
        LessonSlide(
          type: SlideType.quiz,
          contentEn: 'What do you ask to check on a patient\'s condition?',
          contentEs: '¿Qué preguntas para saber cómo está el paciente?',
          options: [
            '"How are you feeling today?"',
            '"What is the weather like?"',
            '"Are you hungry for pizza?"',
            '"Do you like movies?"',
          ],
          correctIndex: 0,
        ),
      ],
    ),
    'abuelo': PersonaContent(
      titleEs: 'Cuidado de Pacientes',
      titleEn: 'Patient Care',
      topicEs: 'Palabras amables para cuidar a otros',
      voiceChallengeEn:
          'Good morning. I am here to check on you and take your temperature.',
      milestoneEs: '¡Tienes las palabras para cuidar a otros con amor!',
      slides: [
        LessonSlide(
          type: SlideType.vocab,
          contentEn: 'Patient / Nurse',
          contentEs: 'Paciente / Enfermera',
          exampleEn: 'Be kind and gentle with every patient.',
          exampleEs: 'Sé amable y cuidadoso con cada paciente.',
        ),
        LessonSlide(
          type: SlideType.vocab,
          contentEn: 'Temperature / Blood pressure',
          contentEs: 'Temperatura / Presión arterial',
          exampleEn: 'Let me take your blood pressure now.',
          exampleEs: 'Déjame tomar tu presión arterial ahora.',
        ),
        LessonSlide(
          type: SlideType.phrase,
          contentEn: '"How are you feeling today?"',
          contentEs: '"¿Cómo se siente hoy?"',
          exampleEn: 'Hello! How are you feeling today? I am here to help.',
          exampleEs: '¡Hola! ¿Cómo se siente hoy? Estoy aquí para ayudar.',
        ),
        LessonSlide(
          type: SlideType.quiz,
          contentEn: 'Which question shows you care about the patient?',
          contentEs: '¿Qué pregunta muestra que te importa el paciente?',
          options: [
            '"How are you feeling today?"',
            '"Are you done yet?"',
            '"Can you hurry up?"',
            '"I am busy."',
          ],
          correctIndex: 0,
        ),
      ],
    ),
  },
);

// ── Tecnología ────────────────────────────────────────────────────────────────

const _l301 = LessonData(
  id: 301,
  level: AppStrings.lessonLevelEspecializado,
  content: {
    'adulto': PersonaContent(
      titleEs: 'En la Oficina',
      titleEn: 'In the Office',
      topicEs: 'Vocabulario profesional de oficina',
      voiceChallengeEn: 'I have a meeting at ten. Can you book the conference room?',
      milestoneEs: '¡Hablas con confianza en la oficina en inglés!',
      slides: [
        LessonSlide(
          type: SlideType.vocab,
          contentEn: 'Meeting / Conference room',
          contentEs: 'Reunión / Sala de conferencias',
          exampleEn: 'The meeting is in the conference room at ten.',
          exampleEs: 'La reunión es en la sala de conferencias a las diez.',
        ),
        LessonSlide(
          type: SlideType.vocab,
          contentEn: 'Deadline / Project',
          contentEs: 'Fecha límite / Proyecto',
          exampleEn: 'The deadline for this project is Friday.',
          exampleEs: 'La fecha límite de este proyecto es el viernes.',
        ),
        LessonSlide(
          type: SlideType.phrase,
          contentEn: '"Can you send me the file?"',
          contentEs: '"¿Puedes mandarme el archivo?"',
          exampleEn: 'Can you send me the file before noon?',
          exampleEs: '¿Puedes mandarme el archivo antes del mediodía?',
        ),
        LessonSlide(
          type: SlideType.quiz,
          contentEn: 'How do you ask a coworker to share a document?',
          contentEs: '¿Cómo le pides a un compañero que te mande un documento?',
          options: [
            '"Can you send me the file?"',
            '"Go away, please."',
            '"I do not need help."',
            '"See you tomorrow."',
          ],
          correctIndex: 0,
        ),
      ],
    ),
    'abuelo': PersonaContent(
      titleEs: 'En la Oficina',
      titleEn: 'In the Office',
      topicEs: 'Palabras útiles para la computadora y la oficina',
      voiceChallengeEn: 'I have a meeting at ten. Can you book the conference room?',
      milestoneEs: '¡Ahora puedes pedir ayuda en la oficina en inglés!',
      slides: [
        LessonSlide(
          type: SlideType.vocab,
          contentEn: 'Meeting / Conference room',
          contentEs: 'Reunión / Sala de conferencias',
          exampleEn: 'We have a meeting this afternoon in the big room.',
          exampleEs: 'Tenemos una reunión esta tarde en el salón grande.',
        ),
        LessonSlide(
          type: SlideType.vocab,
          contentEn: 'Deadline / Project',
          contentEs: 'Fecha límite / Proyecto',
          exampleEn: 'Ask your boss about the deadline for the project.',
          exampleEs: 'Pregúntale a tu jefe cuál es la fecha límite del proyecto.',
        ),
        LessonSlide(
          type: SlideType.phrase,
          contentEn: '"Can you help me with the computer?"',
          contentEs: '"¿Me puedes ayudar con la computadora?"',
          exampleEn: 'Excuse me, can you help me with the computer?',
          exampleEs: 'Disculpa, ¿me puedes ayudar con la computadora?',
        ),
        LessonSlide(
          type: SlideType.quiz,
          contentEn: 'How do you ask for help with technology at work?',
          contentEs: '¿Cómo pides ayuda con la tecnología en el trabajo?',
          options: [
            '"Can you help me with the computer?"',
            '"I know everything."',
            '"Leave me alone."',
            '"This is too hard."',
          ],
          correctIndex: 0,
        ),
      ],
    ),
  },
);

const _l302 = LessonData(
  id: 302,
  level: AppStrings.lessonLevelEspecializado,
  content: {
    'adulto': PersonaContent(
      titleEs: 'Soporte Técnico',
      titleEn: 'Technical Support',
      topicEs: 'Inglés para problemas de computadora',
      voiceChallengeEn: 'My computer is not working. Can you help me restart it?',
      milestoneEs: '¡Puedes pedir ayuda técnica en inglés!',
      slides: [
        LessonSlide(
          type: SlideType.vocab,
          contentEn: 'Password / Log in',
          contentEs: 'Contraseña / Iniciar sesión',
          exampleEn: 'I forgot my password and cannot log in.',
          exampleEs: 'Olvidé mi contraseña y no puedo iniciar sesión.',
        ),
        LessonSlide(
          type: SlideType.vocab,
          contentEn: 'Restart / Update',
          contentEs: 'Reiniciar / Actualizar',
          exampleEn: 'Try to restart the computer to fix the issue.',
          exampleEs: 'Intenta reiniciar la computadora para solucionar el problema.',
        ),
        LessonSlide(
          type: SlideType.phrase,
          contentEn: '"It is not working."',
          contentEs: '"No está funcionando."',
          exampleEn: 'My printer is not working. Can you check it?',
          exampleEs: 'Mi impresora no está funcionando. ¿Puedes revisarla?',
        ),
        LessonSlide(
          type: SlideType.quiz,
          contentEn: 'What is the first step when your computer has a problem?',
          contentEs: '¿Cuál es el primer paso cuando tu computadora tiene un problema?',
          options: [
            'Restart',
            'Buy a new one',
            'Throw it away',
            'Ignore it',
          ],
          correctIndex: 0,
        ),
      ],
    ),
    'abuelo': PersonaContent(
      titleEs: 'Soporte Técnico',
      titleEn: 'Technical Support',
      topicEs: 'Pedir ayuda con la computadora',
      voiceChallengeEn: 'My computer is not working. Can you help me restart it?',
      milestoneEs: '¡Ahora puedes pedir ayuda con tu computadora!',
      slides: [
        LessonSlide(
          type: SlideType.vocab,
          contentEn: 'Password / Log in',
          contentEs: 'Contraseña / Iniciar sesión',
          exampleEn: 'Ask IT to reset your password.',
          exampleEs: 'Pídele a IT que restablezca tu contraseña.',
        ),
        LessonSlide(
          type: SlideType.vocab,
          contentEn: 'Restart / Update',
          contentEs: 'Reiniciar / Actualizar',
          exampleEn: 'Restarting usually fixes small computer problems.',
          exampleEs: 'Reiniciar generalmente soluciona pequeños problemas de computadora.',
        ),
        LessonSlide(
          type: SlideType.phrase,
          contentEn: '"It is not working."',
          contentEs: '"No está funcionando."',
          exampleEn: 'My screen is not working. I need help.',
          exampleEs: 'Mi pantalla no está funcionando. Necesito ayuda.',
        ),
        LessonSlide(
          type: SlideType.quiz,
          contentEn: 'What do you try first when the computer has problems?',
          contentEs: '¿Qué intentas primero cuando la computadora tiene problemas?',
          options: [
            'Restart it',
            'Throw it away',
            'Go home',
            'Call the police',
          ],
          correctIndex: 0,
        ),
      ],
    ),
  },
);

const _l303 = LessonData(
  id: 303,
  level: AppStrings.lessonLevelEspecializado,
  content: {
    'adulto': PersonaContent(
      titleEs: 'Reuniones Virtuales',
      titleEn: 'Virtual Meetings',
      topicEs: 'Inglés para videollamadas de trabajo',
      voiceChallengeEn: 'I think my microphone is muted. Can you hear me now?',
      milestoneEs: '¡Participas con confianza en reuniones virtuales en inglés!',
      slides: [
        LessonSlide(
          type: SlideType.vocab,
          contentEn: 'Muted / Camera',
          contentEs: 'Silenciado / Cámara',
          exampleEn: 'You are on mute. Please unmute your microphone.',
          exampleEs: 'Estás silenciado. Por favor desactiva el silencio del micrófono.',
        ),
        LessonSlide(
          type: SlideType.vocab,
          contentEn: 'Screen share / Chat',
          contentEs: 'Compartir pantalla / Chat',
          exampleEn: 'Can you start the screen share so we can see?',
          exampleEs: '¿Puedes comenzar a compartir pantalla para que veamos?',
        ),
        LessonSlide(
          type: SlideType.phrase,
          contentEn: '"Can you hear me?"',
          contentEs: '"¿Me pueden escuchar?"',
          exampleEn: 'Hello everyone. Can you hear me? Let\'s begin.',
          exampleEs: 'Hola a todos. ¿Me pueden escuchar? Empecemos.',
        ),
        LessonSlide(
          type: SlideType.quiz,
          contentEn: 'What do you say when you think you are muted?',
          contentEs: '¿Qué dices cuando crees que estás silenciado?',
          options: [
            '"Can you hear me? I think I am muted."',
            '"I quit this meeting."',
            '"The weather is nice."',
            '"I am going to lunch."',
          ],
          correctIndex: 0,
        ),
      ],
    ),
    'abuelo': PersonaContent(
      titleEs: 'Reuniones Virtuales',
      titleEn: 'Virtual Meetings',
      topicEs: 'Cómo participar en videollamadas',
      voiceChallengeEn: 'I think my microphone is muted. Can you hear me now?',
      milestoneEs: '¡Ya puedes unirte a reuniones virtuales con confianza!',
      slides: [
        LessonSlide(
          type: SlideType.vocab,
          contentEn: 'Muted / Camera',
          contentEs: 'Silenciado / Cámara',
          exampleEn: 'Turn on your camera so everyone can see you.',
          exampleEs: 'Enciende tu cámara para que todos te puedan ver.',
        ),
        LessonSlide(
          type: SlideType.vocab,
          contentEn: 'Screen share / Chat',
          contentEs: 'Compartir pantalla / Chat',
          exampleEn: 'You can type questions in the chat box.',
          exampleEs: 'Puedes escribir preguntas en el cuadro de chat.',
        ),
        LessonSlide(
          type: SlideType.phrase,
          contentEn: '"Can you hear me?"',
          contentEs: '"¿Me pueden escuchar?"',
          exampleEn: 'Good morning! Can you hear me? My camera is on.',
          exampleEs: '¡Buenos días! ¿Me pueden escuchar? Mi cámara está encendida.',
        ),
        LessonSlide(
          type: SlideType.quiz,
          contentEn: 'How do you check if people can hear you in a video call?',
          contentEs: '¿Cómo verificas si la gente te puede escuchar en la videollamada?',
          options: [
            '"Can you hear me?"',
            '"I am leaving."',
            '"No more meetings."',
            '"I need a nap."',
          ],
          correctIndex: 0,
        ),
      ],
    ),
  },
);

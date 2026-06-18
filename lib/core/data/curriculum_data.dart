import '../models/lesson_models.dart';

/// 10 lessons × 3 personas (nino, adulto, abuelo).
/// Levels: 1–4 = Básico, 5–8 = Intermedio, 9–10 = Avanzado.
/// Each lesson has 4 slides: vocab, vocab, phrase, quiz.
class CurriculumData {
  CurriculumData._();

  static const List<LessonData> all = [
    lesson1,
    lesson2,
    lesson3,
    lesson4,
    lesson5,
    lesson6,
    lesson7,
    lesson8,
    lesson9,
    lesson10,
  ];

  // ── Lesson 1: Saludos ─────────────────────────────────────────────────────

  static const lesson1 = LessonData(
    id: 'principiante.saludos.1',
    tierId: 'principiante',
    categoryId: 'saludos',
    order: 1,
    level: 'Básico',
    content: {
      'nino': PersonaContent(
        titleEs: 'Saludos en la Escuela',
        titleEn: 'School Greetings',
        topicEs: '🏫 La Escuela',
        milestoneEs: '',
        voiceChallengeEn: 'Hello teacher, good morning!',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Hello',
            contentEs: 'Hola',
            exampleEn: 'Hello, my name is María.',
            exampleEs: 'Hola, me llamo María.',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Good morning',
            contentEs: 'Buenos días',
            exampleEn: 'Good morning, teacher!',
            exampleEs: '¡Buenos días, maestra!',
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'Nice to meet you',
            contentEs: 'Mucho gusto',
            exampleEn: 'Nice to meet you, I am a new student.',
            exampleEs: 'Mucho gusto, soy un estudiante nuevo.',
          ),
          LessonSlide(
            type: SlideType.quiz,
            contentEn: 'How do you say "Buenos días" in English?',
            contentEs: '¿Cómo se dice "Buenos días" en inglés?',
            options: ['Good night', 'Good morning', 'Good afternoon', 'Goodbye'],
            correctIndex: 1,
          ),
        ],
      ),
      'adulto': PersonaContent(
        titleEs: 'Presentaciones en el Trabajo',
        titleEn: 'Work Introductions',
        topicEs: '💼 El Trabajo',
        milestoneEs: '',
        voiceChallengeEn: 'Good morning, my name is Carlos.',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Good morning',
            contentEs: 'Buenos días',
            exampleEn: 'Good morning, I am the new employee.',
            exampleEs: 'Buenos días, soy el empleado nuevo.',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'My name is',
            contentEs: 'Mi nombre es',
            exampleEn: 'My name is Carlos. Nice to meet you.',
            exampleEs: 'Mi nombre es Carlos. Mucho gusto.',
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'Nice to meet you',
            contentEs: 'Mucho gusto en conocerlo',
            exampleEn: 'Nice to meet you, sir. I look forward to working here.',
            exampleEs: 'Mucho gusto, señor. Estoy emocionado de trabajar aquí.',
          ),
          LessonSlide(
            type: SlideType.quiz,
            contentEn: 'Which phrase is used to introduce yourself?',
            contentEs: '¿Qué frase usas para presentarte?',
            options: ['See you later', 'My name is', 'Thank you', 'Excuse me'],
            correctIndex: 1,
          ),
        ],
      ),
      'abuelo': PersonaContent(
        titleEs: 'Saludos al Doctor',
        titleEn: 'Doctor Greetings',
        topicEs: '🏥 La Salud',
        milestoneEs: '',
        voiceChallengeEn: 'Hello doctor, I feel sick today.',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Hello',
            contentEs: 'Hola',
            exampleEn: 'Hello, doctor. I have an appointment.',
            exampleEs: 'Hola, doctor. Tengo una cita.',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'I feel',
            contentEs: 'Me siento',
            exampleEn: 'I feel sick today.',
            exampleEs: 'Me siento enfermo hoy.',
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'I need help',
            contentEs: 'Necesito ayuda',
            exampleEn: 'I need help. I have pain here.',
            exampleEs: 'Necesito ayuda. Tengo dolor aquí.',
          ),
          LessonSlide(
            type: SlideType.quiz,
            contentEn: 'How do you say "Me siento mal" in English?',
            contentEs: '¿Cómo se dice "Me siento mal" en inglés?',
            options: ['I feel fine', 'I feel sick', 'I feel happy', 'I feel tired'],
            correctIndex: 1,
          ),
        ],
      ),
    },
  );

  // ── Lesson 2: Números ─────────────────────────────────────────────────────

  static const lesson2 = LessonData(
    id: 'principiante.saludos.2',
    tierId: 'principiante',
    categoryId: 'saludos',
    order: 2,
    level: 'Básico',
    content: {
      'nino': PersonaContent(
        titleEs: 'Contar en Clase',
        titleEn: 'Counting in Class',
        topicEs: '🔢 Los Números',
        milestoneEs: '¡Has escrito el primer párrafo de tu libro!',
        voiceChallengeEn: 'One, two, three, four, five.',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'One, two, three',
            contentEs: 'Uno, dos, tres',
            exampleEn: 'I have one, two, three pencils.',
            exampleEs: 'Tengo uno, dos, tres lápices.',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Four, five, ten',
            contentEs: 'Cuatro, cinco, diez',
            exampleEn: 'I got ten points on the test!',
            exampleEs: '¡Saqué diez puntos en el examen!',
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'How many?',
            contentEs: '¿Cuántos?',
            exampleEn: 'How many students are in the class?',
            exampleEs: '¿Cuántos estudiantes hay en la clase?',
          ),
          LessonSlide(
            type: SlideType.quiz,
            contentEn: 'What number comes after "four"?',
            contentEs: '¿Qué número va después de "four"?',
            options: ['Three', 'Six', 'Five', 'Seven'],
            correctIndex: 2,
          ),
        ],
      ),
      'adulto': PersonaContent(
        titleEs: 'Cantidades y Precios',
        titleEn: 'Money Amounts & Prices',
        topicEs: '💰 Las Finanzas',
        milestoneEs: '¡Has escrito el primer párrafo de tu libro!',
        voiceChallengeEn: 'The total is twenty-five dollars.',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Dollar / Dollars',
            contentEs: 'Dólar / Dólares',
            exampleEn: 'It costs ten dollars.',
            exampleEs: 'Cuesta diez dólares.',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'How much?',
            contentEs: '¿Cuánto cuesta?',
            exampleEn: 'How much does this cost?',
            exampleEs: '¿Cuánto cuesta esto?',
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'The total is',
            contentEs: 'El total es',
            exampleEn: 'The total is twenty-five dollars and fifty cents.',
            exampleEs: 'El total es veinticinco dólares y cincuenta centavos.',
          ),
          LessonSlide(
            type: SlideType.quiz,
            contentEn: 'How do you ask for the price in English?',
            contentEs: '¿Cómo preguntas el precio en inglés?',
            options: ['What time?', 'How much?', 'Where is?', 'Who is?'],
            correctIndex: 1,
          ),
        ],
      ),
      'abuelo': PersonaContent(
        titleEs: 'La Edad y Medicamentos',
        titleEn: 'Age & Medication Doses',
        topicEs: '💊 La Salud',
        milestoneEs: '¡Has escrito el primer párrafo de tu libro!',
        voiceChallengeEn: 'I am seventy years old.',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'I am … years old',
            contentEs: 'Tengo … años',
            exampleEn: 'I am seventy years old.',
            exampleEs: 'Tengo setenta años.',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Twice a day',
            contentEs: 'Dos veces al día',
            exampleEn: 'Take this pill twice a day.',
            exampleEs: 'Tome esta pastilla dos veces al día.',
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'Once in the morning',
            contentEs: 'Una vez en la mañana',
            exampleEn: 'Take this medicine once in the morning.',
            exampleEs: 'Tome esta medicina una vez en la mañana.',
          ),
          LessonSlide(
            type: SlideType.quiz,
            contentEn: 'What does "twice a day" mean?',
            contentEs: '¿Qué significa "twice a day"?',
            options: ['Una vez al día', 'Tres veces al día', 'Dos veces al día', 'Cada hora'],
            correctIndex: 2,
          ),
        ],
      ),
    },
  );

  // ── Lesson 3: Colores ─────────────────────────────────────────────────────

  static const lesson3 = LessonData(
    id: 'principiante.familia.1',
    tierId: 'principiante',
    categoryId: 'familia',
    order: 1,
    level: 'Básico',
    content: {
      'nino': PersonaContent(
        titleEs: 'Colores de Juguetes',
        titleEn: 'Toy & Backpack Colors',
        topicEs: '🎨 Los Colores',
        milestoneEs: '',
        voiceChallengeEn: 'My backpack is red and blue.',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Red / Blue',
            contentEs: 'Rojo / Azul',
            exampleEn: 'My backpack is red.',
            exampleEs: 'Mi mochila es roja.',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Yellow / Green',
            contentEs: 'Amarillo / Verde',
            exampleEn: 'I have a yellow pencil and a green eraser.',
            exampleEs: 'Tengo un lápiz amarillo y un borrador verde.',
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'What color is it?',
            contentEs: '¿De qué color es?',
            exampleEn: 'What color is your toy car?',
            exampleEs: '¿De qué color es tu carrito?',
          ),
          LessonSlide(
            type: SlideType.quiz,
            contentEn: 'How do you say "azul" in English?',
            contentEs: '¿Cómo se dice "azul" en inglés?',
            options: ['Green', 'Red', 'Blue', 'Yellow'],
            correctIndex: 2,
          ),
        ],
      ),
      'adulto': PersonaContent(
        titleEs: 'Colores en la Construcción',
        titleEn: 'Construction Material Colors',
        topicEs: '🏗️ El Trabajo',
        milestoneEs: '',
        voiceChallengeEn: 'The red cable is dangerous. Be careful.',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Red / Yellow',
            contentEs: 'Rojo / Amarillo',
            exampleEn: 'The red wire means danger. The yellow one is a warning.',
            exampleEs: 'El cable rojo significa peligro. El amarillo es advertencia.',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Green / Orange',
            contentEs: 'Verde / Naranja',
            exampleEn: 'Green means go. Orange cones mark the work zone.',
            exampleEs: 'Verde significa avanzar. Los conos naranja marcan la zona de trabajo.',
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'Be careful, it is',
            contentEs: 'Ten cuidado, está',
            exampleEn: 'Be careful, it is the red zone.',
            exampleEs: 'Ten cuidado, está en la zona roja.',
          ),
          LessonSlide(
            type: SlideType.quiz,
            contentEn: 'What color means danger at a work site?',
            contentEs: '¿Qué color significa peligro en una obra?',
            options: ['Blue', 'Green', 'White', 'Red'],
            correctIndex: 3,
          ),
        ],
      ),
      'abuelo': PersonaContent(
        titleEs: 'Describir Síntomas con Colores',
        titleEn: 'Describing Symptoms by Color',
        topicEs: '🏥 La Salud',
        milestoneEs: '',
        voiceChallengeEn: 'My skin looks yellow. I need to see a doctor.',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Yellow / Pale',
            contentEs: 'Amarillo / Pálido',
            exampleEn: 'My skin looks yellow. I feel weak.',
            exampleEs: 'Mi piel se ve amarilla. Me siento débil.',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Red / Swollen',
            contentEs: 'Rojo / Inflamado',
            exampleEn: 'My knee is red and swollen.',
            exampleEs: 'Mi rodilla está roja e inflamada.',
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'It looks',
            contentEs: 'Se ve',
            exampleEn: 'It looks red and painful here.',
            exampleEs: 'Se ve rojo y doloroso aquí.',
          ),
          LessonSlide(
            type: SlideType.quiz,
            contentEn: 'How do you say "pálido" in English?',
            contentEs: '¿Cómo se dice "pálido" en inglés?',
            options: ['Red', 'Dark', 'Pale', 'Swollen'],
            correctIndex: 2,
          ),
        ],
      ),
    },
  );

  // ── Lesson 4: En Casa ─────────────────────────────────────────────────────

  static const lesson4 = LessonData(
    id: 'principiante.familia.2',
    tierId: 'principiante',
    categoryId: 'familia',
    order: 2,
    level: 'Básico',
    content: {
      'nino': PersonaContent(
        titleEs: 'Los Cuartos de la Casa',
        titleEn: 'Rooms of the House',
        topicEs: '🏠 En Casa',
        milestoneEs: '¡El primer capítulo de tu historia toma forma!',
        voiceChallengeEn: 'I sleep in my bedroom.',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Bedroom / Bathroom',
            contentEs: 'Habitación / Baño',
            exampleEn: 'I sleep in my bedroom.',
            exampleEs: 'Duermo en mi habitación.',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Kitchen / Living room',
            contentEs: 'Cocina / Sala',
            exampleEn: 'We eat in the kitchen and watch TV in the living room.',
            exampleEs: 'Comemos en la cocina y vemos la tele en la sala.',
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'Where is the…?',
            contentEs: '¿Dónde está el/la…?',
            exampleEn: 'Where is the bathroom? It is down the hall.',
            exampleEs: '¿Dónde está el baño? Está al fondo del pasillo.',
          ),
          LessonSlide(
            type: SlideType.quiz,
            contentEn: 'Where do you sleep?',
            contentEs: '¿Dónde duermes?',
            options: ['Kitchen', 'Living room', 'Bedroom', 'Garage'],
            correctIndex: 2,
          ),
        ],
      ),
      'adulto': PersonaContent(
        titleEs: 'Tu Dirección y Domicilio',
        titleEn: 'Home Address & Directions',
        topicEs: '🏠 En Casa',
        milestoneEs: '¡El primer capítulo de tu historia toma forma!',
        voiceChallengeEn: 'I live at one twenty-five Main Street.',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Street / Avenue',
            contentEs: 'Calle / Avenida',
            exampleEn: 'I live on Main Street.',
            exampleEs: 'Vivo en la Calle Principal.',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Apartment / Building',
            contentEs: 'Apartamento / Edificio',
            exampleEn: 'I live in apartment 3B of this building.',
            exampleEs: 'Vivo en el apartamento 3B de este edificio.',
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'My address is',
            contentEs: 'Mi dirección es',
            exampleEn: 'My address is 125 Main Street, Apartment 3.',
            exampleEs: 'Mi dirección es 125 Calle Principal, Apartamento 3.',
          ),
          LessonSlide(
            type: SlideType.quiz,
            contentEn: 'What does "address" mean?',
            contentEs: '¿Qué significa "address"?',
            options: ['Teléfono', 'Nombre', 'Dirección', 'Trabajo'],
            correctIndex: 2,
          ),
        ],
      ),
      'abuelo': PersonaContent(
        titleEs: 'Seguridad en el Hogar',
        titleEn: 'Home Safety Phrases',
        topicEs: '🏠 En Casa',
        milestoneEs: '¡El primer capítulo de tu historia toma forma!',
        voiceChallengeEn: 'Call nine one one. There is an emergency.',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Emergency / Help',
            contentEs: 'Emergencia / Ayuda',
            exampleEn: 'This is an emergency. I need help!',
            exampleEs: 'Esto es una emergencia. ¡Necesito ayuda!',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Lock / Open',
            contentEs: 'Cerrar / Abrir',
            exampleEn: 'Lock the door before you sleep.',
            exampleEs: 'Cierra la puerta antes de dormir.',
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'Call nine one one',
            contentEs: 'Llama al nueve uno uno',
            exampleEn: 'Call nine one one if there is an emergency.',
            exampleEs: 'Llama al 911 si hay una emergencia.',
          ),
          LessonSlide(
            type: SlideType.quiz,
            contentEn: 'What number do you call in an emergency?',
            contentEs: '¿A qué número llamas en una emergencia?',
            options: ['Four one one', 'Two one one', 'Nine one one', 'Five one one'],
            correctIndex: 2,
          ),
        ],
      ),
    },
  );

  // ── Lesson 5: Comida ──────────────────────────────────────────────────────

  static const lesson5 = LessonData(
    id: 'principiante.comida.1',
    tierId: 'principiante',
    categoryId: 'comida',
    order: 1,
    level: 'Intermedio',
    content: {
      'nino': PersonaContent(
        titleEs: 'El Almuerzo Escolar',
        titleEn: 'School Lunch Ordering',
        topicEs: '🍔 La Comida',
        milestoneEs: '',
        voiceChallengeEn: 'Can I have a sandwich and apple juice, please?',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Sandwich / Juice',
            contentEs: 'Sándwich / Jugo',
            exampleEn: 'I want a sandwich and an apple juice.',
            exampleEs: 'Quiero un sándwich y un jugo de manzana.',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Pizza / Milk',
            contentEs: 'Pizza / Leche',
            exampleEn: 'Today we have pizza and cold milk.',
            exampleEs: 'Hoy hay pizza y leche fría.',
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'Can I have…, please?',
            contentEs: '¿Me puede dar…, por favor?',
            exampleEn: 'Can I have a sandwich and milk, please?',
            exampleEs: '¿Me puede dar un sándwich y leche, por favor?',
          ),
          LessonSlide(
            type: SlideType.quiz,
            contentEn: 'How do you politely ask for food?',
            contentEs: '¿Cómo pides comida de manera educada?',
            options: [
              'Give me food now',
              'I want food',
              'Can I have some food, please?',
              'Food, food!'
            ],
            correctIndex: 2,
          ),
        ],
      ),
      'adulto': PersonaContent(
        titleEs: 'Ordenar en un Restaurante',
        titleEn: 'Restaurant Ordering',
        topicEs: '🍽️ La Comida',
        milestoneEs: '',
        voiceChallengeEn: 'I would like the chicken with rice, please.',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Menu / Order',
            contentEs: 'Menú / Ordenar',
            exampleEn: 'Can I see the menu, please?',
            exampleEs: '¿Me puede traer el menú, por favor?',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Chicken / Beef',
            contentEs: 'Pollo / Res',
            exampleEn: 'I will have the chicken, not the beef.',
            exampleEs: 'Voy a pedir el pollo, no la res.',
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'I would like',
            contentEs: 'Quisiera / Me gustaría',
            exampleEn: 'I would like the chicken with rice and beans.',
            exampleEs: 'Quisiera el pollo con arroz y frijoles.',
          ),
          LessonSlide(
            type: SlideType.quiz,
            contentEn: 'Which is the most polite way to order?',
            contentEs: '¿Cuál es la forma más educada de ordenar?',
            options: [
              'Bring me chicken',
              'I would like the chicken, please',
              'Chicken now',
              'Give chicken'
            ],
            correctIndex: 1,
          ),
        ],
      ),
      'abuelo': PersonaContent(
        titleEs: 'Restricciones Alimentarias',
        titleEn: 'Dietary Restrictions',
        topicEs: '🥗 La Salud',
        milestoneEs: '',
        voiceChallengeEn: 'I have diabetes. I cannot eat sugar.',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Diabetes / Allergy',
            contentEs: 'Diabetes / Alergia',
            exampleEn: 'I have diabetes and a nut allergy.',
            exampleEs: 'Tengo diabetes y alergia a las nueces.',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Sugar / Salt',
            contentEs: 'Azúcar / Sal',
            exampleEn: 'No sugar for me. My doctor says to avoid it.',
            exampleEs: 'Sin azúcar para mí. El doctor dice que la evite.',
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'I cannot eat',
            contentEs: 'No puedo comer',
            exampleEn: 'I cannot eat salt. I have high blood pressure.',
            exampleEs: 'No puedo comer sal. Tengo la presión alta.',
          ),
          LessonSlide(
            type: SlideType.quiz,
            contentEn: 'How do you say "No puedo comer azúcar"?',
            contentEs: '¿Cómo se dice "No puedo comer azúcar"?',
            options: [
              'I love sugar',
              'I can eat sugar',
              'I cannot eat sugar',
              'More sugar please'
            ],
            correctIndex: 2,
          ),
        ],
      ),
    },
  );

  // ── Lesson 6: Trabajo ─────────────────────────────────────────────────────

  static const lesson6 = LessonData(
    id: 'principiante.comida.2',
    tierId: 'principiante',
    categoryId: 'comida',
    order: 2,
    level: 'Intermedio',
    content: {
      'nino': PersonaContent(
        titleEs: 'Mi Trabajo del Futuro',
        titleEn: 'Future Jobs',
        topicEs: '🌟 Los Sueños',
        milestoneEs: '¡Tu libro ya tiene tres capítulos — ¡eres un autor!',
        voiceChallengeEn: 'I want to be a doctor when I grow up.',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Doctor / Teacher',
            contentEs: 'Doctor / Maestra',
            exampleEn: 'I want to be a doctor. My mom is a teacher.',
            exampleEs: 'Quiero ser doctor. Mi mamá es maestra.',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Engineer / Artist',
            contentEs: 'Ingeniero / Artista',
            exampleEn: 'He wants to be an engineer. She wants to be an artist.',
            exampleEs: 'Él quiere ser ingeniero. Ella quiere ser artista.',
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'I want to be a',
            contentEs: 'Quiero ser',
            exampleEn: 'I want to be a pilot when I grow up.',
            exampleEs: 'Quiero ser piloto cuando crezca.',
          ),
          LessonSlide(
            type: SlideType.quiz,
            contentEn: 'How do you say "Quiero ser enfermera"?',
            contentEs: '¿Cómo se dice "Quiero ser enfermera"?',
            options: [
              'I am a nurse',
              'She is a nurse',
              'I want to be a nurse',
              'Be a nurse'
            ],
            correctIndex: 2,
          ),
        ],
      ),
      'adulto': PersonaContent(
        titleEs: 'Entrevista de Trabajo',
        titleEn: 'Job Interview Phrases',
        topicEs: '💼 El Trabajo',
        milestoneEs: '¡Tu libro ya tiene tres capítulos — ¡eres un autor!',
        voiceChallengeEn: 'I am a hard worker and I learn quickly.',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Experience / Skills',
            contentEs: 'Experiencia / Habilidades',
            exampleEn: 'I have five years of experience and strong skills.',
            exampleEs: 'Tengo cinco años de experiencia y buenas habilidades.',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Interview / Hired',
            contentEs: 'Entrevista / Contratado',
            exampleEn: 'My job interview is tomorrow. I hope to get hired.',
            exampleEs: 'Mi entrevista es mañana. Espero que me contraten.',
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'I am a hard worker',
            contentEs: 'Soy muy trabajador(a)',
            exampleEn: 'I am a hard worker and I always arrive on time.',
            exampleEs: 'Soy muy trabajador y siempre llego a tiempo.',
          ),
          LessonSlide(
            type: SlideType.quiz,
            contentEn: 'What do you say to describe yourself positively?',
            contentEs: '¿Qué dices para describir tus cualidades?',
            options: [
              'I am always late',
              'I do not like to work',
              'I am a hard worker',
              'I forget everything'
            ],
            correctIndex: 2,
          ),
        ],
      ),
      'abuelo': PersonaContent(
        titleEs: 'Beneficios y Derechos',
        titleEn: 'Senior Benefits & Rights',
        topicEs: '⭐ Los Derechos',
        milestoneEs: '¡Tu libro ya tiene tres capítulos — ¡eres un autor!',
        voiceChallengeEn: 'I would like information about my benefits.',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Benefits / Rights',
            contentEs: 'Beneficios / Derechos',
            exampleEn: 'I want to know my rights and benefits.',
            exampleEs: 'Quiero saber mis derechos y beneficios.',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Medicare / Social Security',
            contentEs: 'Medicare / Seguro Social',
            exampleEn: 'I receive Medicare and Social Security.',
            exampleEs: 'Recibo Medicare y Seguro Social.',
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'I need information about',
            contentEs: 'Necesito información sobre',
            exampleEn: 'I need information about my Medicare benefits.',
            exampleEs: 'Necesito información sobre mis beneficios de Medicare.',
          ),
          LessonSlide(
            type: SlideType.quiz,
            contentEn: 'What is "Medicare"?',
            contentEs: '¿Qué es "Medicare"?',
            options: [
              'Un tipo de comida',
              'Un programa de salud para mayores',
              'Un banco americano',
              'Un seguro de auto'
            ],
            correctIndex: 1,
          ),
        ],
      ),
    },
  );

  // ── Lesson 7: Emergencias ─────────────────────────────────────────────────

  static const lesson7 = LessonData(
    id: 'intermedio.trabajo.1',
    tierId: 'intermedio',
    categoryId: 'trabajo',
    order: 1,
    level: 'Intermedio',
    content: {
      'nino': PersonaContent(
        titleEs: 'Emergencias en la Escuela',
        titleEn: 'School Emergency',
        topicEs: '🚨 Emergencias',
        milestoneEs: '',
        voiceChallengeEn: 'Help! There is a fire. Everyone go outside!',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Fire / Danger',
            contentEs: 'Fuego / Peligro',
            exampleEn: 'Fire! Get out of the building now!',
            exampleEs: '¡Fuego! ¡Sal del edificio ahora!',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Help / Run',
            contentEs: 'Ayuda / Corre',
            exampleEn: 'Help! I fell and I cannot move!',
            exampleEs: '¡Ayuda! Me caí y no me puedo mover.',
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'Go to the exit',
            contentEs: 'Ve a la salida',
            exampleEn: 'In an emergency, go to the nearest exit.',
            exampleEs: 'En una emergencia, ve a la salida más cercana.',
          ),
          LessonSlide(
            type: SlideType.quiz,
            contentEn: 'What do you shout when there is a fire?',
            contentEs: '¿Qué gritas cuando hay un incendio?',
            options: ['Quiet!', 'Fire! Get out!', 'Wait here', 'No problem'],
            correctIndex: 1,
          ),
        ],
      ),
      'adulto': PersonaContent(
        titleEs: 'Accidente de Trabajo',
        titleEn: 'Workplace Accident / 911',
        topicEs: '🚨 Emergencias',
        milestoneEs: '',
        voiceChallengeEn: 'There was an accident. Send an ambulance please.',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Accident / Injured',
            contentEs: 'Accidente / Herido',
            exampleEn: 'There was an accident. A coworker is injured.',
            exampleEs: 'Hubo un accidente. Un compañero está herido.',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Ambulance / Police',
            contentEs: 'Ambulancia / Policía',
            exampleEn: 'Call an ambulance! Call the police!',
            exampleEs: '¡Llama una ambulancia! ¡Llama a la policía!',
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'We need an ambulance at',
            contentEs: 'Necesitamos una ambulancia en',
            exampleEn: 'We need an ambulance at the Main Street warehouse.',
            exampleEs: 'Necesitamos una ambulancia en el almacén de Main Street.',
          ),
          LessonSlide(
            type: SlideType.quiz,
            contentEn: 'What do you call when someone is badly hurt?',
            contentEs: '¿A qué llamas cuando alguien está muy herido?',
            options: ['A taxi', 'Your boss', 'An ambulance', 'A friend'],
            correctIndex: 2,
          ),
        ],
      ),
      'abuelo': PersonaContent(
        titleEs: 'Emergencia Médica',
        titleEn: 'Medical Emergency / Ambulance',
        topicEs: '🚑 La Salud',
        milestoneEs: '',
        voiceChallengeEn: 'I am having chest pain. Please call an ambulance.',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Chest pain / Heart attack',
            contentEs: 'Dolor de pecho / Ataque al corazón',
            exampleEn: 'I have chest pain. I think it is a heart attack.',
            exampleEs: 'Tengo dolor de pecho. Creo que es un ataque al corazón.',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Ambulance / Hospital',
            contentEs: 'Ambulancia / Hospital',
            exampleEn: 'I need an ambulance. Take me to the hospital.',
            exampleEs: 'Necesito una ambulancia. Llévame al hospital.',
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'I cannot breathe',
            contentEs: 'No puedo respirar',
            exampleEn: 'I cannot breathe. Please call 911 right now.',
            exampleEs: 'No puedo respirar. Por favor llama al 911 ahora mismo.',
          ),
          LessonSlide(
            type: SlideType.quiz,
            contentEn: 'What does "I cannot breathe" mean?',
            contentEs: '¿Qué significa "I cannot breathe"?',
            options: [
              'No puedo caminar',
              'No puedo ver',
              'No puedo escuchar',
              'No puedo respirar'
            ],
            correctIndex: 3,
          ),
        ],
      ),
    },
  );

  // ── Lesson 8: Preguntas ───────────────────────────────────────────────────

  static const lesson8 = LessonData(
    id: 'intermedio.trabajo.2',
    tierId: 'intermedio',
    categoryId: 'trabajo',
    order: 2,
    level: 'Intermedio',
    content: {
      'nino': PersonaContent(
        titleEs: 'Pedir Ayuda al Maestro',
        titleEn: 'Asking Teacher for Help',
        topicEs: '🙋 Las Preguntas',
        milestoneEs: '¡Cuatro capítulos escritos — casi llegas!',
        voiceChallengeEn: 'Excuse me teacher, can you help me please?',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Excuse me / Sorry',
            contentEs: 'Con permiso / Perdón',
            exampleEn: 'Excuse me, teacher. I have a question.',
            exampleEs: 'Con permiso, maestra. Tengo una pregunta.',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'I do not understand',
            contentEs: 'No entiendo',
            exampleEn: 'I do not understand this problem. Can you explain?',
            exampleEs: 'No entiendo este problema. ¿Puede explicar?',
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'Can you help me, please?',
            contentEs: '¿Me puede ayudar, por favor?',
            exampleEn: 'Can you help me with this math problem, please?',
            exampleEs: '¿Me puede ayudar con este problema de matemáticas?',
          ),
          LessonSlide(
            type: SlideType.quiz,
            contentEn: 'How do you politely get someone\'s attention?',
            contentEs: '¿Cómo llamas la atención de alguien educadamente?',
            options: ['Hey you!', 'Excuse me', 'Look here!', 'Listen now!'],
            correctIndex: 1,
          ),
        ],
      ),
      'adulto': PersonaContent(
        titleEs: 'Preguntas al Gerente',
        titleEn: 'Work Questions for Manager',
        topicEs: '💼 El Trabajo',
        milestoneEs: '¡Cuatro capítulos escritos — casi llegas!',
        voiceChallengeEn: 'Excuse me, can I ask you a quick question?',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Schedule / Hours',
            contentEs: 'Horario / Horas',
            exampleEn: 'Can you tell me my work schedule for next week?',
            exampleEs: '¿Puede decirme mi horario para la próxima semana?',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Manager / Supervisor',
            contentEs: 'Gerente / Supervisor',
            exampleEn: 'I need to speak with the manager about my hours.',
            exampleEs: 'Necesito hablar con el gerente sobre mis horas.',
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'May I ask you something?',
            contentEs: '¿Le puedo preguntar algo?',
            exampleEn: 'May I ask you something about the new policy?',
            exampleEs: '¿Le puedo preguntar algo sobre la nueva política?',
          ),
          LessonSlide(
            type: SlideType.quiz,
            contentEn: 'Which is the most professional way to ask a question?',
            contentEs: '¿Cuál es la forma más profesional de hacer una pregunta?',
            options: [
              'Hey, answer me!',
              'May I ask you something?',
              'Tell me right now',
              'Question time!'
            ],
            correctIndex: 1,
          ),
        ],
      ),
      'abuelo': PersonaContent(
        titleEs: 'Preguntas al Doctor sobre Medicamentos',
        titleEn: 'Doctor Questions about Medication',
        topicEs: '💊 La Salud',
        milestoneEs: '¡Cuatro capítulos escritos — casi llegas!',
        voiceChallengeEn: 'What are the side effects of this medicine?',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Side effects / Dosage',
            contentEs: 'Efectos secundarios / Dosis',
            exampleEn: 'What are the side effects of this medication?',
            exampleEs: '¿Cuáles son los efectos secundarios de este medicamento?',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Prescription / Pharmacy',
            contentEs: 'Receta / Farmacia',
            exampleEn: 'Do I need a prescription to get this at the pharmacy?',
            exampleEs: '¿Necesito una receta para comprarlo en la farmacia?',
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'How often should I take it?',
            contentEs: '¿Con qué frecuencia debo tomarlo?',
            exampleEn: 'How often should I take this medicine, doctor?',
            exampleEs: '¿Con qué frecuencia debo tomar este medicamento, doctor?',
          ),
          LessonSlide(
            type: SlideType.quiz,
            contentEn: 'How do you ask about taking medicine?',
            contentEs: '¿Cómo preguntas sobre cómo tomar un medicamento?',
            options: [
              'I like this medicine',
              'How often should I take it?',
              'Medicine is good',
              'Take more medicine'
            ],
            correctIndex: 1,
          ),
        ],
      ),
    },
  );

  // ── Lesson 9: Dinero ──────────────────────────────────────────────────────

  static const lesson9 = LessonData(
    id: 'fluido.conversacion.1',
    tierId: 'fluido',
    categoryId: 'conversacion',
    order: 1,
    level: 'Avanzado',
    content: {
      'nino': PersonaContent(
        titleEs: 'Ahorrar para un Juguete',
        titleEn: 'Saving for a Toy',
        topicEs: '🐷 El Ahorro',
        milestoneEs: '',
        voiceChallengeEn: 'I save my money every week to buy a toy.',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Save / Spend',
            contentEs: 'Ahorrar / Gastar',
            exampleEn: 'I save my allowance every week.',
            exampleEs: 'Ahorro mi mesada cada semana.',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Piggy bank / Money',
            contentEs: 'Alcancía / Dinero',
            exampleEn: 'I put my money in my piggy bank.',
            exampleEs: 'Pongo mi dinero en mi alcancía.',
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'I am saving money for',
            contentEs: 'Estoy ahorrando dinero para',
            exampleEn: 'I am saving money for a new toy.',
            exampleEs: 'Estoy ahorrando dinero para un juguete nuevo.',
          ),
          LessonSlide(
            type: SlideType.quiz,
            contentEn: 'What does "to save money" mean?',
            contentEs: '¿Qué significa "to save money"?',
            options: ['Gastar dinero', 'Perder dinero', 'Ahorrar dinero', 'Pedir dinero'],
            correctIndex: 2,
          ),
        ],
      ),
      'adulto': PersonaContent(
        titleEs: 'Abrir una Cuenta Bancaria',
        titleEn: 'Opening a Bank Account',
        topicEs: '🏦 Las Finanzas',
        milestoneEs: '',
        voiceChallengeEn: 'I would like to open a savings account.',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Bank account / Savings',
            contentEs: 'Cuenta bancaria / Ahorros',
            exampleEn: 'I want to open a bank account to save money.',
            exampleEs: 'Quiero abrir una cuenta bancaria para ahorrar.',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Deposit / Withdraw',
            contentEs: 'Depositar / Retirar',
            exampleEn: 'I will deposit my paycheck every Friday.',
            exampleEs: 'Depositaré mi cheque cada viernes.',
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'I would like to open an account',
            contentEs: 'Quisiera abrir una cuenta',
            exampleEn: 'I would like to open a checking account, please.',
            exampleEs: 'Quisiera abrir una cuenta corriente, por favor.',
          ),
          LessonSlide(
            type: SlideType.quiz,
            contentEn: 'What does "deposit" mean?',
            contentEs: '¿Qué significa "deposit"?',
            options: ['Retirar dinero', 'Cerrar cuenta', 'Depositar dinero', 'Pedir préstamo'],
            correctIndex: 2,
          ),
        ],
      ),
      'abuelo': PersonaContent(
        titleEs: 'Seguro Social y Beneficios',
        titleEn: 'Social Security / Benefits',
        topicEs: '⭐ Los Derechos',
        milestoneEs: '',
        voiceChallengeEn: 'When will I receive my Social Security check?',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Social Security / Pension',
            contentEs: 'Seguro Social / Pensión',
            exampleEn: 'I receive Social Security and a small pension.',
            exampleEs: 'Recibo el Seguro Social y una pequeña pensión.',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Check / Direct deposit',
            contentEs: 'Cheque / Depósito directo',
            exampleEn: 'My check comes by direct deposit every month.',
            exampleEs: 'Mi cheque llega por depósito directo cada mes.',
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'When will I receive my payment?',
            contentEs: '¿Cuándo recibiré mi pago?',
            exampleEn: 'When will I receive my Social Security payment?',
            exampleEs: '¿Cuándo recibiré mi pago del Seguro Social?',
          ),
          LessonSlide(
            type: SlideType.quiz,
            contentEn: 'What is a "direct deposit"?',
            contentEs: '¿Qué es un "direct deposit"?',
            options: [
              'Un cheque en papel',
              'Dinero enviado directamente a tu banco',
              'Una tarjeta de crédito',
              'Un cajero automático'
            ],
            correctIndex: 1,
          ),
        ],
      ),
    },
  );

  // ── Lesson 10: Mi Historia ────────────────────────────────────────────────

  static const lesson10 = LessonData(
    id: 'fluido.conversacion.2',
    tierId: 'fluido',
    categoryId: 'conversacion',
    order: 2,
    level: 'Avanzado',
    content: {
      'nino': PersonaContent(
        titleEs: 'El Viaje de mi Familia',
        titleEn: 'My Family\'s Journey',
        topicEs: '❤️ Mi Historia',
        milestoneEs: '¡Felicidades! ¡Tu libro está completo! 📚',
        voiceChallengeEn: 'My family came to America to build a better life.',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Family / Journey',
            contentEs: 'Familia / Viaje',
            exampleEn: 'My family made a long journey to get here.',
            exampleEs: 'Mi familia hizo un largo viaje para llegar aquí.',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Dream / Hope',
            contentEs: 'Sueño / Esperanza',
            exampleEn: 'We have a dream and hope for a better future.',
            exampleEs: 'Tenemos un sueño y esperanza por un mejor futuro.',
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'My family came here to',
            contentEs: 'Mi familia vino aquí para',
            exampleEn: 'My family came here to give us a better life.',
            exampleEs: 'Mi familia vino aquí para darnos una vida mejor.',
          ),
          LessonSlide(
            type: SlideType.quiz,
            contentEn: 'What does "dream" mean?',
            contentEs: '¿Qué significa "dream"?',
            options: ['Viaje', 'Trabajo', 'Sueño', 'Dinero'],
            correctIndex: 2,
          ),
        ],
      ),
      'adulto': PersonaContent(
        titleEs: 'Mi Historia en el Currículo',
        titleEn: 'Resume Story / New Life',
        topicEs: '📄 Mi Historia',
        milestoneEs: '¡Felicidades! ¡Tu libro está completo! 📚',
        voiceChallengeEn: 'I came to this country to build a new life for my family.',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Immigrant / Opportunity',
            contentEs: 'Inmigrante / Oportunidad',
            exampleEn: 'As an immigrant, I found great opportunity here.',
            exampleEs: 'Como inmigrante, encontré grandes oportunidades aquí.',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Contribute / Community',
            contentEs: 'Contribuir / Comunidad',
            exampleEn: 'I want to contribute to my community.',
            exampleEs: 'Quiero contribuir a mi comunidad.',
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'I came to this country to',
            contentEs: 'Vine a este país para',
            exampleEn: 'I came to this country to work hard and help my family.',
            exampleEs: 'Vine a este país para trabajar duro y ayudar a mi familia.',
          ),
          LessonSlide(
            type: SlideType.quiz,
            contentEn: 'What does "contribute" mean?',
            contentEs: '¿Qué significa "contribute"?',
            options: ['Tomar', 'Contribuir / aportar', 'Ignorar', 'Destruir'],
            correctIndex: 1,
          ),
        ],
      ),
      'abuelo': PersonaContent(
        titleEs: 'El Legado Familiar',
        titleEn: 'Family Legacy for Grandchildren',
        topicEs: '👨‍👩‍👧‍👦 La Familia',
        milestoneEs: '¡Felicidades! ¡Tu libro está completo! 📚',
        voiceChallengeEn: 'I am proud of my family and our story.',
        slides: [
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Legacy / Pride',
            contentEs: 'Legado / Orgullo',
            exampleEn: 'I leave a legacy of hard work and pride.',
            exampleEs: 'Dejo un legado de trabajo duro y orgullo.',
          ),
          LessonSlide(
            type: SlideType.vocab,
            contentEn: 'Grandchildren / Future',
            contentEs: 'Nietos / Futuro',
            exampleEn: 'My grandchildren are my future and my joy.',
            exampleEs: 'Mis nietos son mi futuro y mi alegría.',
          ),
          LessonSlide(
            type: SlideType.phrase,
            contentEn: 'I am proud of my family',
            contentEs: 'Estoy orgulloso(a) de mi familia',
            exampleEn: 'I am proud of my family and everything we achieved.',
            exampleEs: 'Estoy orgulloso de mi familia y todo lo que logramos.',
          ),
          LessonSlide(
            type: SlideType.quiz,
            contentEn: 'What does "legacy" mean?',
            contentEs: '¿Qué significa "legacy"?',
            options: ['Dinero', 'Trabajo', 'Legado / lo que dejas', 'Viaje'],
            correctIndex: 2,
          ),
        ],
      ),
    },
  );
}

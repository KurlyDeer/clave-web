import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'persona_provider.dart';
import 'shared_preferences_provider.dart';

// ── Models ─────────────────────────────────────────────────────────────────────

class PlacementQuestion {
  const PlacementQuestion({
    required this.questionEs,
    required this.options,
    required this.correctIndex,
    required this.contextLabel,
  });

  final String questionEs;
  final List<String> options;
  final int correctIndex;
  final String contextLabel;
}

class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.isFromApp,
    this.showOptions = false,
    this.contextLabel,
  });

  final String text;
  final bool isFromApp;
  final bool showOptions;
  final String? contextLabel;
}

enum PlacementLevel { beginner, intermediate, advanced }

extension PlacementLevelExtension on PlacementLevel {
  String get displayEs {
    switch (this) {
      case PlacementLevel.beginner:
        return 'Principiante';
      case PlacementLevel.intermediate:
        return 'Intermedio';
      case PlacementLevel.advanced:
        return 'Avanzado';
    }
  }

  String get displayEn {
    switch (this) {
      case PlacementLevel.beginner:
        return 'Beginner';
      case PlacementLevel.intermediate:
        return 'Intermediate';
      case PlacementLevel.advanced:
        return 'Advanced';
    }
  }
}

class PlacementState {
  const PlacementState({
    this.messages = const [],
    this.currentQuestionIndex = 0,
    this.selectedAnswers = const [-1, -1, -1],
    this.isWaiting = false,
    this.isComplete = false,
    this.resultLevel,
  });

  final List<ChatMessage> messages;
  final int currentQuestionIndex;
  final List<int> selectedAnswers;
  final bool isWaiting;
  final bool isComplete;
  final PlacementLevel? resultLevel;

  PlacementState copyWith({
    List<ChatMessage>? messages,
    int? currentQuestionIndex,
    List<int>? selectedAnswers,
    bool? isWaiting,
    bool? isComplete,
    PlacementLevel? resultLevel,
  }) {
    return PlacementState(
      messages: messages ?? this.messages,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      isWaiting: isWaiting ?? this.isWaiting,
      isComplete: isComplete ?? this.isComplete,
      resultLevel: resultLevel ?? this.resultLevel,
    );
  }
}

// ── Questions ──────────────────────────────────────────────────────────────────

const _questions = [
  PlacementQuestion(
    questionEs: '¿Cómo se dice "Hola" en inglés?',
    options: ['Hello', 'Goodbye', 'Thank you', 'Please'],
    correctIndex: 0,
    contextLabel: 'Principiante',
  ),
  PlacementQuestion(
    questionEs: '¿Cómo preguntarías por el baño en inglés?',
    options: [
      'Where is the bathroom?',
      'What time is it?',
      'How much does it cost?',
      'Can I have the menu?',
    ],
    correctIndex: 0,
    contextLabel: 'Intermedio',
  ),
  PlacementQuestion(
    questionEs: '¿Qué significa la palabra "Knowledge"?',
    options: ['Conocimiento', 'Habilidad', 'Sabiduría', 'Experiencia'],
    correctIndex: 0,
    contextLabel: 'Avanzado',
  ),
];

// ── Notifier ───────────────────────────────────────────────────────────────────

class PlacementNotifier extends StateNotifier<PlacementState> {
  PlacementNotifier(this._prefs, this._persona) : super(const PlacementState()) {
    _init();
  }

  final SharedPreferences _prefs;
  final Persona? _persona;

  Future<void> _init() async {
    final alreadyDone = _prefs.getBool('placement_complete') ?? false;
    if (alreadyDone) {
      final levelName = _prefs.getString('placement_level');
      PlacementLevel? level;
      if (levelName != null) {
        try {
          level = PlacementLevel.values.byName(levelName);
        } catch (_) {}
      }
      if (!mounted) return;
      state = state.copyWith(isComplete: true, resultLevel: level);
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    final intro = _introMessage(_persona);
    state = state.copyWith(
      messages: [ChatMessage(text: intro, isFromApp: true)],
      isWaiting: true,
    );

    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    _appendQuestion(0);
  }

  void _appendQuestion(int index) {
    final q = _questions[index];
    final messages = [
      ...state.messages,
      ChatMessage(
        text: q.questionEs,
        isFromApp: true,
        showOptions: true,
        contextLabel: q.contextLabel,
      ),
    ];
    state = state.copyWith(
      messages: messages,
      currentQuestionIndex: index,
      isWaiting: false,
    );
  }

  Future<void> selectAnswer(int answerIndex) async {
    final qIndex = state.currentQuestionIndex;
    final q = _questions[qIndex];

    final userText = q.options[answerIndex];
    final isCorrect = answerIndex == q.correctIndex;
    final feedback = isCorrect
        ? '¡Correcto! 🎉 "${q.options[q.correctIndex]}" es la respuesta.'
        : '¡Casi! La respuesta correcta es "${q.options[q.correctIndex]}". ¡Sigue intentando!';

    final newAnswers = List<int>.from(state.selectedAnswers)..[qIndex] = answerIndex;
    final messagesWithUser = [
      ...state.messages.map((m) => m.showOptions
          ? ChatMessage(text: m.text, isFromApp: m.isFromApp, contextLabel: m.contextLabel)
          : m),
      ChatMessage(text: userText, isFromApp: false),
    ];

    state = state.copyWith(
      messages: messagesWithUser,
      selectedAnswers: newAnswers,
      isWaiting: true,
    );

    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    final messagesWithFeedback = [
      ...state.messages,
      ChatMessage(text: feedback, isFromApp: true),
    ];
    state = state.copyWith(messages: messagesWithFeedback, isWaiting: true);

    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    final nextIndex = qIndex + 1;
    if (nextIndex < _questions.length) {
      _appendQuestion(nextIndex);
    } else {
      _complete(newAnswers);
    }
  }

  void _complete(List<int> answers) {
    final correctCount = answers
        .asMap()
        .entries
        .where((e) => e.value == _questions[e.key].correctIndex)
        .length;

    final PlacementLevel level;
    if (correctCount == 3) {
      level = PlacementLevel.advanced;
    } else if (correctCount == 2) {
      level = PlacementLevel.intermediate;
    } else {
      level = PlacementLevel.beginner;
    }

    _prefs.setBool('placement_complete', true);
    _prefs.setString('placement_level', level.name);

    final completionMsg =
        '¡Excelente! 🌟 Tu nivel es: ${level.displayEs} / ${level.displayEn}';
    state = state.copyWith(
      messages: [
        ...state.messages,
        ChatMessage(text: completionMsg, isFromApp: true),
      ],
      isWaiting: false,
      isComplete: true,
      resultLevel: level,
    );
  }

  static String _introMessage(Persona? persona) {
    switch (persona) {
      case Persona.nino:
        return '¡Hola pequeño explorador! 🌟 Vamos a jugar con las palabras en inglés. ¡3 preguntas fáciles!';
      case Persona.abuelo:
        return '¡Bienvenido! ⭐ Hagamos una pequeña evaluación juntos. Tomemos el tiempo que necesitemos.';
      default:
        return '¡Hola! 👋 Vamos a conocer tu nivel de inglés con 3 preguntas sencillas. ¡Sin presión!';
    }
  }
}

// ── Provider ───────────────────────────────────────────────────────────────────

final placementProvider =
    StateNotifierProvider<PlacementNotifier, PlacementState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final persona = ref.watch(personaProvider);
  return PlacementNotifier(prefs, persona);
});

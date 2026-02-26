class WritingPrompt {
  const WritingPrompt({required this.promptEs, required this.promptEn});

  final String promptEs;
  final String promptEn;
}

class WritingPromptsData {
  WritingPromptsData._();

  static const List<WritingPrompt> all = [
    WritingPrompt(
      promptEs: 'Escribe sobre tu primer día en este país.',
      promptEn: 'Write about your first day in this country.',
    ),
    WritingPrompt(
      promptEs: 'Describe tu comida favorita y por qué la amas.',
      promptEn: 'Describe your favorite food and why you love it.',
    ),
    WritingPrompt(
      promptEs: 'Escribe una carta a tu familia en tu país de origen.',
      promptEn: 'Write a letter to your family in your home country.',
    ),
    WritingPrompt(
      promptEs: 'Describe el lugar más bonito que hayas visitado.',
      promptEn: 'Describe the most beautiful place you have visited.',
    ),
    WritingPrompt(
      promptEs: 'Escribe sobre una persona que te ha inspirado.',
      promptEn: 'Write about a person who has inspired you.',
    ),
    WritingPrompt(
      promptEs: '¿Cuál es tu sueño más grande para tu vida aquí?',
      promptEn: 'What is your biggest dream for your life here?',
    ),
    WritingPrompt(
      promptEs: 'Describe una tradición especial de tu familia.',
      promptEn: 'Describe a special tradition from your family.',
    ),
    WritingPrompt(
      promptEs: 'Escribe sobre el trabajo que quieres tener.',
      promptEn: 'Write about the job you want to have.',
    ),
    WritingPrompt(
      promptEs: '¿Qué extrañas más de tu país de origen?',
      promptEn: 'What do you miss most from your home country?',
    ),
    WritingPrompt(
      promptEs: 'Describe un día perfecto desde que llegaste aquí.',
      promptEn: 'Describe a perfect day since you arrived here.',
    ),
    WritingPrompt(
      promptEs: 'Escribe sobre algo nuevo que aprendiste en inglés esta semana.',
      promptEn: 'Write about something new you learned in English this week.',
    ),
    WritingPrompt(
      promptEs: 'Describe a tu mejor amigo o alguien importante para ti.',
      promptEn: 'Describe your best friend or someone important to you.',
    ),
    WritingPrompt(
      promptEs: 'Escribe sobre tus metas para los próximos 5 años.',
      promptEn: 'Write about your goals for the next 5 years.',
    ),
    WritingPrompt(
      promptEs: 'Describe una situación en la que el inglés te ayudó.',
      promptEn: 'Describe a situation where English helped you.',
    ),
    WritingPrompt(
      promptEs: '¿Qué consejo le darías a alguien que acaba de llegar a este país?',
      promptEn: 'What advice would you give to someone who just arrived in this country?',
    ),
  ];

  /// Returns the prompt for the given page count (sequential cycling).
  static WritingPrompt forPageCount(int pageCount) =>
      all[pageCount % all.length];
}

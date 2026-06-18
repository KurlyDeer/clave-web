/// Centralized string constants for English Bridge.
/// Primary language: Spanish. English subtitles shown for immersion.
/// All copy lives here — never hardcode UI text in widgets.
class AppStrings {
  AppStrings._();

  // ── App Identity ──────────────────────────────────────────────
  static const String appName = 'English Bridge';
  static const String appTaglineEs = 'Tu puente hacia el inglés';
  static const String appTaglineEn = 'Your bridge to English';

  // ── Welcome Screen ────────────────────────────────────────────
  static const String welcomeGreeting = '¡Bienvenido a English Bridge!';

  static const String welcomeBodyEs =
      'Esta aplicación fue creada especialmente para ti.\n\n'
      'Sin importar tu edad, te guiaremos paso a paso desde '
      'las primeras palabras en inglés hasta que puedas '
      'escribir tu propio libro. Todo en español primero, '
      'para que nunca te sientas perdido.';

  static const String welcomeBodyEn =
      'This app was made just for you.\n\n'
      'No matter your age, we will guide you step by step '
      'from your very first English words to writing your own book. '
      'We start in Spanish so you always feel at home.';

  // ── Persona Selection (Welcome + Persona Screen) ──────────────
  static const String personaPromptEs = '¿Quién eres tú?';
  static const String personaPromptEn = 'Who are you?';
  static const String personaSubtitleEs =
      'Escoge tu perfil para personalizar la experiencia';

  static const String personaNino = 'Niño';
  static const String personaNinoDesc = 'Hasta 12 años';
  static const String personaNinoEmoji = '🌱';

  static const String personaAdulto = 'Adulto';
  static const String personaAdultoDesc = '13 – 64 años';
  static const String personaAdultoEmoji = '🎯';

  static const String personaAbuelo = 'Abuelo';
  static const String personaAbueloDesc = '65 años o más';
  static const String personaAbueloEmoji = '⭐';

  static const String personaContinueEs = 'Continuar';
  static const String personaContinueEn = 'Continue';

  // ── CTA Button ────────────────────────────────────────────────
  static const String ctaStartEs = '¡Vamos a Empezar!';
  static const String ctaStartEn = "Let's Begin!";
  static const String ctaSelectPersonaFirst = 'Primero elige tu perfil arriba';

  // ── Placement Screen ──────────────────────────────────────────
  static const String placementTitle = 'Evaluación de Nivel';
  static const String placementQuestionOf = 'Pregunta';
  static const String placementQuestionOfTotal = 'de 3';
  static const String placementGoToDashboardEs = '¡Ir a mi Panel!';
  static const String placementGoToDashboardEn = "Let's Go!";

  // ── Dashboard Screen ──────────────────────────────────────────
  static const String dashboardRoadmapTitle = '📚 Camino a ser Autor';
  static const String dashboardProgressLabel = '% completado';
  static const String dashboardSosEs = '🆘 S.O.S. Traducir';
  static const String dashboardSosEn = 'Translate Now';
  static const String dashboardSosComingSoonEs = 'Próximamente';
  static const String dashboardSosComingSoonEn = 'Coming Soon';

  static const String dashboardGreetingNinoEs = '¡Hola, explorador! 🌱';
  static const String dashboardGreetingAdultoEs = '¡Bienvenido de vuelta! 🎯';
  static const String dashboardGreetingAbueloEs = '¡Buenas, campeón! ⭐';

  // ── Dashboard (new) ───────────────────────────────────────────
  static const String dashboardLibroEs = '📝 Mi Libro';
  static const String dashboardLibroEn = 'My Book';

  // ── SOS Screen ────────────────────────────────────────────────
  static const String sosTitleEs = '🆘 S.O.S. Traducir';
  static const String sosTitleEn = 'Translate Now';
  static const String sosInstructionEs =
      'Mantén presionado el micrófono y habla en español';
  static const String sosInstructionEn = 'Hold the mic and speak in Spanish';
  static const String sosListeningEs = 'Escuchando…';
  static const String sosTranslatingEs = 'Traduciendo…';
  static const String sosYouSaidEs = 'Dijiste:';
  static const String sosToneFormalEs = 'Formal';
  static const String sosToneFriendlyEs = 'Amistoso';
  static const String sosToneUrgentEs = 'Urgente';
  static const String sosPlayEs = '🔊 Escuchar';
  static const String sosCopyEs = '📋 Copiar';
  static const String sosCopiedEs = '¡Copiado! / Copied';
  static const String sosTryAgainEs = 'Intentar de nuevo';
  static const String sosNewTranslationEs = '🔄 Nueva Traducción';
  static const String sosOfflineEs =
      'Sin conexión — no se puede traducir ahora.\nConéctate a internet e intenta de nuevo.';
  static const String sosApiErrorEs =
      'Hubo un problema con la traducción.\nPor favor intenta de nuevo.';
  static const String sosInputPlaceholderEs = '¿Qué necesitas decir?';
  static const String sosSaveToBookEs = '📖 Guardar en mi Libro';
  static const String sosSavedToBookEs = '¡Guardado en tu Libro! 📖';
  static const String sosTranslateButtonEs = 'Traducir';
  static const String sosOrSpeakEs = 'o mantén el micrófono';

  // ── Libro Screen ──────────────────────────────────────────────
  static const String libroTitleEs = '📝 Mi Libro';
  static const String libroTitleEn = 'My Book';
  static const String libroHintEs =
      'Escribe en inglés aquí…\nWrite in English here…';
  static const String libroRevisarEs = 'Revisar Mi Escritura';
  static const String libroRevisarEn = 'Review My Writing';
  static const String libroReviewingEs = 'Revisando…';
  static const String libroEditarEs = '✏️ Editar de nuevo';
  static const String libroCopyAllEs = '📋 Copiar texto';
  static const String libroErrorTitleEs = 'Error';
  static const String libroIncorrectEs = 'Incorrecto:';
  static const String libroCorrectEs = 'Correcto:';
  static const String libroCloseEs = 'Cerrar';
  static const String libroNoErrorsEs =
      '¡Excelente! No se encontraron errores.';
  static const String libroOfflineEs =
      'Sin conexión — no se puede revisar ahora.\nConéctate a internet e intenta de nuevo.';
  static const String libroApiErrorEs =
      'Hubo un problema al revisar tu texto.\nPor favor intenta de nuevo.';
  static const String libroErrorCountEs = 'errores encontrados';
  static const String libroFeedbackTitleEs = 'Comentarios';

  // ── Shared ────────────────────────────────────────────────────
  static const String offlineBannerEs =
      'Sin conexión — las traducciones no están disponibles';

  // ── Roadmap Stages ────────────────────────────────────────────
  static const List<String> roadmapStages = [
    '🌱 Primeras Palabras',
    '💬 Frases del Día',
    '📖 Leer con Fluidez',
    '✍️ Escribir Oraciones',
    '📝 Mi Primer Ensayo',
    '📚 ¡Soy Autor!',
  ];

  // ── Dashboard (Lessons) ───────────────────────────────────────
  static const String dashboardLessonsEs = '📚 Mis Lecciones';
  static const String dashboardLessonsEn = 'My Lessons';
  static const String lessonProgressSummaryEs = 'lecciones completadas';

  // ── Lesson list / card ────────────────────────────────────────
  static const String lessonCompleteLabel = '✓ Completada';
  static const String lessonLevelBasico = 'Básico';
  static const String lessonLevelIntermedio = 'Intermedio';
  static const String lessonLevelAvanzado = 'Avanzado';
  static const String lessonStartEs = 'Empezar';
  static const String lessonReviewEs = 'Repasar';

  // ── Lesson player ─────────────────────────────────────────────
  static const String lessonIntroStartEs = '¡Empezar Lección!';
  static const String lessonStepEs       = 'Paso';
  static const String lessonHookLabelEs  = 'SITUACIÓN DE HOY';
  static const String lessonRepeatAudioEs = '🔊 Repetir';
  static const String lessonNextEs = 'Siguiente →';
  static const String lessonSlideOfEs = 'de';
  static const String lessonQuizCorrectEs = '¡Correcto! 🎉';
  static const String lessonQuizWrongEs = 'Incorrecto — intenta de nuevo';
  static const String lessonCompleteActionEs = 'Completar Lección ✓';

  // ── STT feedback ──────────────────────────────────────────────
  static const String sttLowConfidenceEs =
      'No te escuché bien. ¡Inténtalo de nuevo!';

  // ── Reto de Voz ───────────────────────────────────────────────
  static const String retoTitleEs = '🎤 Reto de Voz';
  static const String retoInstructionEs = 'Di esta oración en inglés:';
  static const String retoListeningEs = 'Escuchando…';
  static const String retoScoringEs = 'Analizando tu pronunciación…';
  static const String retoScoreLabelEs = 'Tu puntuación:';
  static const String retoTryAgainEs = 'Intentar de nuevo';
  static const String retoSkipEs = 'Saltar Reto (sin puntos)';

  // ── Milestone dialog ──────────────────────────────────────────
  static const String milestoneTitleEs = '¡Capítulo desbloqueado! 📖';
  static const String milestoneContinueEs = '¡Continuar!';

  // ── Lesson errors ─────────────────────────────────────────────
  static const String lessonOfflineEs =
      'Sin conexión — no se puede analizar ahora.\n'
      'Puedes saltar el reto para completar la lección.';
  static const String lessonApiErrorEs =
      'Error al analizar tu voz. Intenta de nuevo o salta el reto.';

  // ── Streak ────────────────────────────────────────────────────
  static const String streakDaysLabel = 'días seguidos';
  static const String streakEncouragementEs =
      '¡No te rindas! Mañana empezamos de nuevo.';
  static const String streakStartTodayEs = '¡Empieza tu racha hoy!';

  // ── XP / Level ────────────────────────────────────────────────
  static const String xpGainedLabel = 'XP Ganado';
  static const String levelLabel = 'Nivel';
  static const String xpToNextLevelLabel = 'para el siguiente nivel';

  // ── Lesson Summary ─────────────────────────────────────────────
  static const String summaryTitle = '¡Lección Completada!';
  static const String summaryTimeLabel = 'Tiempo';
  static const String summaryWordsLabel = 'Palabras Nuevas';
  static const String summaryXpLabel = 'XP Ganado';
  static const String summaryVoiceLabel = 'Puntuación de Voz';
  static const String summaryContinueEs = '¡Continuar!';

  // ── Book Map ───────────────────────────────────────────────────
  static const String bookMapTitleEs = '📖 Mi Camino como Autor';
  static const String bookMapCurrentChapterEs = 'Leyendo…';
  static const String bookMapLockedEs = 'Bloqueado';

  // ── Milestone Full Page ────────────────────────────────────────
  static const String milestoneFullPageTitleEs =
      '¡Nuevo capítulo desbloqueado!';
  static const String milestoneFullPageSubtitleEs =
      '¡Sigue así y llegarás a ser autor!';

  // ── Notifications ──────────────────────────────────────────────
  static const String notifTitleEs = '¡English Bridge!';
  static const String notifBodyNinoEs =
      '¡Hora de practicar! 🌟 Tus amigos ya están aprendiendo inglés.';
  static const String notifBodyAdultoEs =
      '5 minutos de inglés hoy para un mejor trabajo mañana.';
  static const String notifBodyAbueloEs =
      'Es hora de tu práctica diaria para hablar con tus nietos.';

  // ── Name input (Persona Screen) ────────────────────────────────
  static const String personaNamePromptEs = '¿Cómo te llamas?';
  static const String personaNameHintEs = 'Tu nombre (opcional)';

  // ── Pro / Paywall ─────────────────────────────────────────────
  static const String proUpgradeTitleEs    = '🔓 English Bridge Pro';
  static const String proUpgradeSubtitleEs = 'Desbloquea todo tu potencial';
  static const String proBenefit1Es        = '✅ Traducciones SOS ilimitadas';
  static const String proBenefit2Es        = '✅ Revisiones de escritura ilimitadas';
  static const String proBenefit3Es        = '✅ Lecciones de inglés para el trabajo';
  static const String proPurchaseButtonEs  = '¡Obtener English Bridge Pro!';
  static const String proRestoreButtonEs   = 'Restaurar compra anterior';
  static const String proAlreadyProEs      = '¡Ya eres Pro! 🎉';
  static const String proAbueloLifetimeEs  =
      'Un solo pago de por vida.\nSin cobros mensuales. Nunca. Para siempre.';
  static const String proPrivacyLinkEs     = 'Ver Política de Privacidad';
  static const String proLoadingEs         = 'Procesando…';
  static const String proErrorGenericEs    = 'Error al procesar el pago. Inténtalo de nuevo.';
  static const String proRestoreErrorEs    = 'No se pudieron restaurar las compras.';

  // ── Usage limits ──────────────────────────────────────────────
  static const String sosLimitReachedEs   =
      'Usaste tus 3 traducciones gratuitas de hoy.\n¡Actualiza a Pro para traducciones ilimitadas!';
  static const String libroLimitReachedEs =
      'Usaste tus 3 revisiones gratuitas de hoy.\n¡Actualiza a Pro para revisiones ilimitadas!';
  static const String sosRemainingEs      = 'traducciones disponibles hoy';
  static const String libroRemainingEs    = 'revisiones disponibles hoy';
  static const String upgradeToProEs      = 'Ver English Bridge Pro';

  // ── Community ─────────────────────────────────────────────────
  static const String communityTitleEs        = '🌟 Comunidad de Autores';
  static const String communityTitleEn        = 'Author Community';
  static const String communityHeaderNinoEs   = '¡Mira lo que lograron tus compañeros!';
  static const String communityHeaderAdultoEs = 'La comunidad English Bridge celebra tus logros';
  static const String communityHeaderAbueloEs = 'Nuestros estudiantes comparten sus victorias';
  static const String communityFooterEs       = '¡Tu logro también puede inspirar a otros!';

  // ── Career Tracks ─────────────────────────────────────────────
  static const String careerTracksTitleEs  = '💼 Inglés para el Trabajo';
  static const String careerTracksTitleEn  = 'English for Work';
  static const String careerProGateTitleEs = '🔒 Función Pro';
  static const String careerProGateBodyEs  =
      'Las lecciones de carrera son una función exclusiva de English Bridge Pro.';
  static const String careerProGateCTAEs   = 'Ver planes Pro';
  static const String lessonLevelEspecializado = 'Especializado';

  // ── Dashboard new buttons ─────────────────────────────────────
  static const String dashboardCareerEs    = '💼 Inglés para el Trabajo';
  static const String dashboardCareerEn    = 'English for Work';
  static const String dashboardCommunityEs = '🌟 Comunidad';
  static const String dashboardCommunityEn = 'Community';

  // ── Mi Vocabulario ─────────────────────────────────────────────
  static const String vocabTitleEs = '🔤 Mi Vocabulario';
  static const String vocabTitleEn = 'My Vocabulary';
  static const String dashboardVocabEs = '🔤 Repasar mis palabras';
  static const String dashboardVocabEn = 'Review My Words';
  static const String vocabKnowItEs = '✓ Lo sé';
  static const String vocabRepeatEs = '🔁 Repetir';
  static const String vocabTapToFlipEs = 'Toca para ver la traducción';
  static const String vocabFrontLabelEs = 'INGLÉS';
  static const String vocabBackLabelEs = 'ESPAÑOL';
  static const String vocabSpeakEs = '🔊 Escuchar';
  static const String vocabWordsToStudyEs = 'por estudiar';
  static const String vocabWordsKnownOfEs = 'aprendidas';
  static const String vocabEmptyStateEs =
      '¡Tu vocabulario está vacío!\n\n'
      'Usa el Traductor S.O.S. o escribe en Mi Libro para '
      'agregar palabras automáticamente.';
  static const String vocabCelebrationTitleEs = '¡Lo lograste! 🎉';
  static const String vocabCelebrationBodyEs =
      '¡Conoces todas tus palabras!\nSigue usando la app para agregar más.';
  static const String vocabReviewAllEs = '🔄 Repasar todas de nuevo';
  static const String vocabSourceSosEs = 'S.O.S.';
  static const String vocabSourceLibroEs = 'Mi Libro';
  static const String vocabOfEs = 'de';

  // ── Mi Primer Libro (Book Gallery + Editor) ───────────────────
  static const String libroGalleryTitleEs = '📖 Mi Primer Libro';
  static const String libroGalleryTitleEn = 'My First Book';
  static const String libroInspirationLabel = '✨ Inspiración';
  static const String libroNewPageEs = 'Nueva Página';
  static const String libroNewPageEn = 'New Page';
  static const String libroSavePageEs = 'Guardar Página';
  static const String libroSavePageEn = 'Save Page';
  static const String libroRevisarPaginaEs = 'Revisar Mi Página';
  static const String libroPageSavedEs = '¡Página guardada! 📖';
  static const String libroEmptyStateEs =
      '¡Tu libro está esperando!\nEscribe tu primera página y empieza tu historia.';
  static const String libroEmptyStateCTAEs = '✏️ Escribir Mi Primera Página';
  static const String libroPagesCountEs = 'páginas escritas';
  static const String libroDeleteConfirmTitleEs = '¿Borrar esta página?';
  static const String libroDeleteConfirmBodyEs =
      'Esta acción no se puede deshacer.';
  static const String libroDeleteConfirmYesEs = 'Borrar';
  static const String libroDeleteConfirmNoEs = 'Cancelar';
  static const String libroRevisadaBadgeEs = '✓ Revisada';
  static const String libroEditPageEs = 'Editar página';
  static const String libroGlassSubtitleEs = 'Has escrito';
  static const String libroGlassEmptyEs =
      'Tu libro está en blanco.\n¡Completa tu primera lección para empezar a escribir!';
  static const String libroGlassGoToLessonEs = 'Ir a mi primera lección';
  static const String libroGlassPlayEs = 'Escuchar';

  // ── Simulador de Vida Real ────────────────────────────────────
  static const String simuladorTitleEs = '🎭 Simulador de Vida Real';
  static const String simuladorTitleEn = 'Real-Life Simulator';
  static const String dashboardSimuladorEs = '🎭 Practicar en la Vida Real';
  static const String dashboardSimuladorEn = 'Real-Life Practice';
  static const String simuladorPickScenarioEs = 'Elige una situación para practicar:';
  static const String simuladorCharacterRoleLabel = 'Habla con:';
  static const String simuladorHintLabelEs = '💡 Pista';
  static const String simuladorRecordInstructionEs =
      'Mantén presionado el micrófono y responde en inglés';
  static const String simuladorRecordInstructionEn = 'Hold mic and speak in English';
  static const String simuladorListeningEs = 'Escuchando…';
  static const String simuladorAnalyzingEs = 'Analizando tu respuesta…';
  static const String simuladorCorrectEs = '¡Muy bien! ✓';
  static const String simuladorIncorrectEs = 'Intenta de nuevo';
  static const String simuladorContinueEs = 'Continuar →';
  static const String simuladorRetryEs = 'Intentar de nuevo';
  static const String simuladorCompleteEs = '¡Conversación Completada! 🎉';
  static const String simuladorCompleteBodyEs =
      '¡Excelente trabajo practicando inglés en situaciones reales!';
  static const String simuladorXpEarnedEs = '+15 XP ganados';
  static const String simuladorBackToDashboardEs = 'Volver al inicio';
  static const String simuladorOfflineEs =
      'Sin conexión — no se puede continuar ahora.\nConéctate a internet e intenta de nuevo.';
  static const String simuladorEmptyEs =
      'No hay escenarios disponibles para tu perfil.';
  static const String simuladorYouSaidEs = 'Dijiste:';
  static const String simuladorAiSpeakingEs = 'Escucha al personaje…';
  static const String simuladorTapToReplayEs = '🔊 Repetir';
  static const String simuladorFinishXpEs = 'Terminar y Ganar +15 XP';
  static const String simuladorTapMicEs = 'Toca el micrófono y responde en inglés';

  // ── Publicar mi Libro ─────────────────────────────────────────
  static const String publishTitleEs = '📚 Publicar mi Libro';
  static const String publishTitleEn = 'Publish My Book';
  static const String publishBookTitleDefaultEs = 'Mi Primer Libro en Inglés';
  static const String publishAutorLabelEs = 'Autor';
  static const String publishPagesCountEs = 'páginas';
  static const String publishChaptersCountEs = 'capítulos';
  static const String publishPreviewEs = '👁 Vista Previa';
  static const String publishDownloadEs = '⬇️ Descargar mi Libro';
  static const String publishShareEs = '📤 Compartir con la Familia';
  static const String publishGeneratingEs = 'Generando tu libro…';
  static const String publishSuccessAbueloEs =
      '¡Felicidades! Has creado un legado para tus nietos.';
  static const String publishSuccessAbueloSubtitleEs =
      'Tu historia en inglés preserva el amor de tu familia para siempre.';
  static const String publishSuccessNinoTitleEs =
      'Certificado de Superhéroe del Inglés';
  static const String publishSuccessNinoEs =
      '¡Eres un campeón! Escribiste tu propio libro en inglés.';
  static const String publishSuccessAdultoEs =
      '¡Felicidades! Has publicado tu primer libro en inglés.';
  static const String publishSuccessAdultoSubtitleEs =
      'Tu dedicación y esfuerzo te han llevado a este gran logro.';
  static const String publishContinueEs = 'Volver al Inicio';
  static const String publishSealText = 'Language Journey';
  static const String publishChapterLabelEs = 'Capítulo';
  static const String publishBookTitleLabelEs = 'Título del libro';
  static const String publishXpEarnedEs = '+20 XP ganados';
  static const String publishStatsCardTitleEs = 'Tu libro está listo';

  // ── Analizador de Voz ─────────────────────────────────────────
  static const String analizadorTitleEs = '🎤 Analizador de Voz';
  static const String analizadorTitleEn = 'Voice Analyzer';
  static const String dashboardAnalizadorEs = '🎤 Practicar Pronunciación';
  static const String dashboardAnalizadorEn = 'Practice Pronunciation';
  static const String analizadorSentenceLabelEs = 'Di esta oración en inglés:';
  static const String analizadorSentenceLabelEn = 'Say this sentence in English:';
  static const String analizadorTargetSoundEs = 'Sonido objetivo:';
  static const String analizadorHoldToRecordEs =
      'Mantén presionado el micrófono y habla';
  static const String analizadorHoldToRecordEn = 'Hold mic and speak';
  static const String analizadorListeningEs = 'Escuchando…';
  static const String analizadorAnalyzingEs = 'Analizando pronunciación…';
  static const String analizadorYouSaidEs = 'Dijiste:';
  static const String analizadorScoreLabelEs = 'Puntuación:';
  static const String analizadorTryAgainEs = '🔄 Intentar de nuevo';
  static const String analizadorNextSentenceEs = 'Siguiente →';
  static const String analizadorPrevSentenceEs = '← Anterior';
  static const String analizadorCoachTipLabelEs = '💡 Consejo de pronunciación:';
  static const String analizadorOfflineEs =
      'Sin conexión — no se puede analizar ahora.\nConéctate e intenta de nuevo.';
  static const String analizadorErrorEs =
      'Error al analizar tu pronunciación. Intenta de nuevo.';
  static const String analizadorPerfectLegendEs = 'Perfecto';
  static const String analizadorHeavyLegendEs = 'Con acento';
  static const String analizadorMissedLegendEs = 'No reconocido';
  static const String analizadorListenSlowEs = '🔊 Escuchar de nuevo (lento)';
  static const String analizadorAbueloGoodEs = '¡Muy bien!';
  static const String analizadorAbueloRetryEs = '¡Intenta otra vez!';
  static const String analizadorXpEarnedEs = '+10 XP ganados 🌟';
  static const String analizadorXpEarnedSmallEs = '+5 XP ganados 🌟';
  static const String analizadorSentenceCountEs = 'Oración';
  static const String analizadorOfEs = 'de';
  static const String analizadorDifficulty1Es = '🟢 Básico';
  static const String analizadorDifficulty2Es = '🟡 Intermedio';
  static const String analizadorDifficulty3Es = '🔴 Avanzado';

  // ── Glass Dashboard ───────────────────────────────────────────
  static const String glassNextStepTitleEs      = 'TU PRÓXIMO PASO';
  static const String glassNextStepTitleEn      = 'YOUR NEXT STEP';
  static const String glassContinueEs           = 'Continuar';
  static const String glassContinueEn           = 'Continue';
  static const String glassNextLessonEs         = 'Lección';
  static const String glassNextBookPromptEs     = 'Escribe tu próxima página';
  static const String glassAllLessonsCompleteEs = '¡Felicidades! Has completado todas las lecciones.';
  static const String glassStatsXpEs            = 'XP Total';
  static const String glassStatsStreakEs         = 'Racha';
  static const String glassStatsWordsEs         = 'Palabras';
  static const String glassStatsLevelEs         = 'Nivel';
  static const String glassProgressTitleEs      = 'Camino a tu Libro';
  static const String glassProgressLessonsEs    = 'lecciones completadas';

  // ── Repaso Inteligente ────────────────────────────────────────
  static const String repasoTitleEs          = '🧠 Repaso Inteligente';
  static const String repasoTitleEn          = 'Smart Review';
  static const String dashboardRepasoEs      = '🧠 Repaso Inteligente';
  static const String repasoFocusCardTitleEs = '¡Palabras para repasar! 🧠';
  static const String repasoCardFrontLabelEs = 'ESPAÑOL';
  static const String repasoCardBackLabelEs  = 'INGLÉS';
  static const String repasoLoSabeEs         = '✓ Lo sé';
  static const String repasoRepasarEs        = '🔁 Repasar';
  static const String repasoScheduledEs      = '¡Hasta mañana!';
  static const String repasoLearnedEs        = '¡Aprendida! ✓';
  static const String repasoCompleteTitleEs  = '¡Sesión Completada! 🎉';
  static const String repasoCompleteBodyEs   = 'Repasaste todas tus palabras de hoy.';
  static const String repasoXpEarnedEs       = '+5 XP ganados 🌟';
  static const String repasoEmptyEs          =
      '¡No tienes palabras para repasar!\n\n'
      'Usa el S.O.S. o Mi Libro para agregar palabras automáticamente.';
  static const String repasoWordsOfEs        = 'de';
  static const String repasoTapToRevealEs    = 'Toca para revelar';
  static const String repasoKnownCountEs     = 'aprendidas';
  static const String repasoBackToDashEs     = 'Volver al Inicio';

  // ── Camino al Libro ───────────────────────────────────────────
  static const String caminoTitleEs            = '🗺 Camino al Libro';
  static const String caminoLockedEs           = 'Bloqueado';
  static const String caminoUnlockedEs         = '¡Entendido!';
  static const String caminoPreviewLabelEs     = 'TU PROGRESO';
  static const String caminoViewEs             = 'Ver Camino →';
  static const String caminoLockedSnackbarEs   = 'Completa la lección anterior primero';
  static const String caminoCompletedBadgeEs   = 'Completada ✓';
  static const String caminoNextLessonEs       = 'Siguiente lección';
  static const String caminoAllCompleteEs      = '¡Todas las lecciones completadas!';
  static const String caminoProgressEs         = 'lecciones completadas';

  // ── Grammar Flip (Screen 3) ───────────────────────────────────
  static const String lessonGrammarTitleEs         = 'Construye la Frase';
  static const String lessonGrammarSpanishLabelEs  = 'EN ESPAÑOL';
  static const String lessonGrammarAnswerHintEs    = 'Toca una palabra para agregarla aquí';
  static const String lessonGrammarCheckEs         = 'Comprobar';
  static const String lessonGrammarCorrectFeedbackEs = '¡Correcto! ✓';
  static const String lessonGrammarWrongHintEs     =
      '💡 En inglés, el adjetivo va antes del sustantivo.';
  static const String lessonGrammarNextEs          = 'Siguiente →';

  // ── Voice Challenge (Screen 4) ────────────────────────────────
  static const String lessonVoiceHoldMicEs   = 'Toca el micrófono y habla';
  static const String lessonVoiceTapRepeatEs = '🎤 Toca para repetir';
  static const String lessonVoiceLevelLabelEs = 'NIVEL DE VOZ';
  static const String lessonVoiceTerminarEs  = 'Terminar';

  // ── El Borrador (Screen 5) ─────────────────────────────────────────────────
  static const String lessonDraftInstructionEs = 'Escribe esta frase para tu libro:';
  static const String lessonDraftTargetEs      = 'Yo quiero un aumento.';
  static const String lessonDraftHintEs        = 'Escribe en inglés...';
  static const String lessonDraftSaveEs        = 'Guardar en mi Libro';
  static const String lessonDraftSavedEs       = '¡Capítulo guardado!';
  static const String lessonDraftHomeEs        = 'Volver al Inicio';

  // ── Bottom Navigation ─────────────────────────────────────────
  static const String navHomeEs       = 'Inicio';
  static const String navLibraryEs    = 'Biblioteca';
  static const String navSosEs        = 'S.O.S.';
  static const String navCompaneroEs  = 'Mi Compañero';

  // ── Mi Compañero ──────────────────────────────────────────────
  static const String companeroTitleEs    = 'Mi Compañero';
  static const String companeroSubtitleEs = 'Tu tutor de inglés personal';
  static const String companeroInputHintEs = '¿Qué quieres preguntar?';
  static const String companeroErrorEs    = 'Error al conectar. Intenta de nuevo.';
  static const String companeroConnectionErrorEs = 'Error de conexión. Toca para reintentar.';
  static const String companeroRetryEs    = '↻ Reintentar';

  // ── Tier Map ──────────────────────────────────────────────────
  static const String tierMapTitleEs   = '🗺️ Mis Lecciones';
  static const String tierLockedEs     = 'Completa primero:';
  static const String tierComingSoonEs = 'Próximamente';

  // ── Tier Names ────────────────────────────────────────────────
  static const String tierFundamentosEs  = 'Fundamentos';
  static const String tierPrincipianteEs = 'Principiante';
  static const String tierIntermedioEs   = 'Intermedio';
  static const String tierFluidoEs       = 'Fluido';

  // ── FTUE Onboarding ───────────────────────────────────────────
  static const String ftueWelcomeTitleEs      = 'Bienvenido a tu nuevo tutor de inglés';
  static const String ftueWelcomeSubtitleEs   = 'Aprende inglés a tu ritmo, con lecciones diseñadas para tu vida real.';
  static const String ftueNameTitleEs         = '¿Cómo te llamas?';
  static const String ftueNameHintEs          = 'Tu nombre';
  static const String ftueGoalTitleEs         = '¿Cuál es tu meta principal?';
  static const String ftueGoalSubtitleEs      = 'Personalizaremos tu camino de aprendizaje.';
  static const String ftueGoalCareerEs        = 'Avanzar en mi Carrera';
  static const String ftueGoalCareerDescEs    = 'Inglés para el trabajo y oportunidades profesionales';
  static const String ftueGoalTravelEs        = 'Viajar con Confianza';
  static const String ftueGoalTravelDescEs    = 'Inglés para viajes y comunicación básica';
  static const String ftueGoalCitizenshipEs   = 'Ciudadanía de EE.UU.';
  static const String ftueGoalCitizenshipDescEs = 'Prepárate para tu examen de naturalización';
  static const String ftueStartEs             = 'Comenzar mi viaje';
  static const String ftueNextEs              = 'Siguiente';

  // ── Onboarding ────────────────────────────────────────────────
  static const String onboardingTitleEs     = '¿Cuánto tiempo tienes hoy?';
  static const String onboardingSubtitleEs  = 'Crea tu plan de estudio personalizado.';
  static const String onboardingGoal5TitleEs  = '5 Minutos';
  static const String onboardingGoal5DescEs   = 'Repaso rápido y vocabulario';
  static const String onboardingGoal15TitleEs = '15 Minutos';
  static const String onboardingGoal15DescEs  = 'Lección completa y pronunciación';
  static const String onboardingGoal30TitleEs = '30+ Minutos';
  static const String onboardingGoal30DescEs  = 'Inmersión total y escritura';
  static const String onboardingCtaEs       = 'Comenzar mi viaje';

  // ── Study Plan ────────────────────────────────────────────────
  static const String studyPlanTitleEs        = '¿Cuánto tiempo tienes?';
  static const String studyPlanQuestionEs     =
      'Escoge cuánto tiempo puedes dedicar al inglés cada día.\n'
      'Ajustaremos tu camino de aprendizaje para ti.';
  static const String studyPlanQuickTitleEs   = '5 Minutos al Día';
  static const String studyPlanQuickDescEs    =
      'Ideal si tienes poco tiempo. Una práctica rápida y efectiva.';
  static const String studyPlanStandardTitleEs = '15 Minutos al Día';
  static const String studyPlanStandardDescEs  =
      'El plan más popular. Avanza rápido sin agotarte.';
  static const String studyPlanDeepTitleEs    = '30+ Minutos al Día';
  static const String studyPlanDeepDescEs     =
      'Para quienes quieren aprender rápido. ¡Máximo progreso!';

  // ── Library Tab ───────────────────────────────────────────────
  static const String libraryTitleEs        = '📚 Biblioteca';
  static const String librarySectionBookEs  = 'Mi Libro';
  static const String librarySectionVocabEs = 'Mi Vocabulario';
  static const String librarySectionToolsEs = 'Herramientas de Práctica';

  // ── Settings ──────────────────────────────────────────────────
  static const String settingsTitleEs        = 'Ajustes';
  static const String settingsVoiceSectionEs = 'Voz del Profesor';
  static const String settingsVoiceProfesorEs   = 'Profesor';
  static const String settingsVoiceProfesoraEs  = 'Profesora';
  static const String settingsPreviewEs      = 'Escuchar ejemplo';
  static const String settingsPreviewText    = 'Hello! Welcome to English Bridge.';

  // ── Mi Perfil ─────────────────────────────────────────────────
  static const String profileTitleEs             = 'Mi Perfil';
  static const String profileTitleEn             = 'My Profile';
  static const String profilePersonaSectionEs    = 'MI PERFIL';
  static const String profileGoalSectionEs       = 'MI META DIARIA';
  static const String profileDangerSectionEs     = 'ZONA DE REINICIO';
  static const String profileResetButtonEs       = 'Borrar Todo y Empezar de Nuevo';
  static const String profileResetConfirmTitleEs = '¿Estás seguro?';
  static const String profileResetConfirmBodyEs  =
      'Esto borrará todo tu progreso, vocabulario, libro y configuración. '
      'Esta acción no se puede deshacer.';
  static const String profileResetConfirmYesEs   = 'Sí, borrar todo';
  static const String profileResetConfirmNoEs    = 'Cancelar';

  // ── Recordatorio ──────────────────────────────────────────────
  static const String profileReminderSectionEs = 'RECORDATORIO DE ESTUDIO';
  static const String profileReminderLabelEs   = 'Hora del recordatorio';
  static const String profileReminderOffEs     = 'Sin recordatorio';
  static const String profileReminderSetEs     = 'Cada día a las';
  static const String profileReminderRemoveEs  = 'Desactivar recordatorio';

  // ── Learning Path ─────────────────────────────────────────────
  static const String pathTitleEs             = 'Tu Camino de Aprendizaje';
  static const String pathTitleEn             = 'Your Learning Path';
  static const String pathEmptyStateEs        = '¡Pronto habrá más lecciones!';
  static const String pathCompletedOfEs       = 'de';

  // ── Lesson Detail Screen ───────────────────────────────────────
  static const String lessonDetailVocabTitleEs    = '📚 Vocabulario';
  static const String lessonDetailGrammarTitleEs  = '✏️ Regla Gramatical';
  static const String lessonDetailPracticeEs      = 'Practicar en el Simulador';
  static const String lessonDetailPracticeEn      = 'Practice in the Simulator';
  static const String lessonDetailVocabTapTtsEs   = 'Toca para escuchar';
  static const String lessonDetailExampleLabelEs  = 'Ejemplo:';
  static const String lessonDetailRepracticeEs    = 'Practicar de Nuevo';

  // ── Profile Settings (Sound + Dark Mode) ─────────────────────────────────
  static const String profileSettingsSectionEs     = 'SONIDO Y PRONUNCIACION';
  static const String profileTtsToggleTitleEs      = 'Pronunciación con Audio';
  static const String profileTtsToggleDescEs       = 'Escucha las palabras al estudiar vocabulario';
  static const String profileDarkModeToggleTitleEs = 'Modo Oscuro';
  static const String profileDarkModeToggleDescEs  = 'Tema oscuro activo — modo claro próximamente';

  // ── Lesson Detail PageView ────────────────────────────────────────────────
  static const String lessonDetailIntroTitleEs = 'Objetivo de la Lección';
  static const String lessonDetailIntroBodyEs  = 'En esta lección practicarás:';
  static const String lessonDetailReadyEs      = '¿Listo para practicar?';
  static const String lessonDetailQuizTitleEs  = '🧠 Cuestionario';
  static const String lessonDetailQuizNextEs   = 'Siguiente pregunta';
  static const String lessonDetailQuizFinishEs = 'Ver resultado';
  static const String lessonDetailQuizResultEs = 'Tu resultado:';
  static const String lessonDetailQuizContinueEs = 'Continuar →';

  // ── Simulator Guardrails ──────────────────────────────────────────────────
  static const String simuladorGoalLabelEs     = '🎯 Tu meta:';
  static const String simuladorHintAfterFailEs = '💡 Intenta decir algo como:';
  static const String simuladorSkipTurnEs      = 'Saltar este turno';

  // ── Report Card Screen ────────────────────────────────────────
  static const String reportCardAnalyzingEs      = 'Analizando tu pronunciación y gramática...';
  static const String reportCardGradeLabelEs     = 'Tu Calificación';
  static const String reportCardClaimXpEs        = 'Reclamar 50 XP y Continuar';
  static const String reportCardNoErrorsEs       = '¡Perfecto! Sin errores detectados.';
  static const String reportCardMistakeLabelEs   = 'Dijiste:';
  static const String reportCardCorrectionLabelEs = 'Mejor:';

  // ── Learning Tracks ───────────────────────────────────────────────────────
  static const String trackGeneralEs         = 'Inglés General';
  static const String trackCitizenshipEs     = 'Ciudadanía';
  static const String citizenshipTrackDescEs = 'Prepárate para el examen de ciudadanía americana';

  // ── Premium / Citizenship Paywall ─────────────────────────────────────────
  static const String premiumTitleEs    = 'Desbloquea la Preparación para la Ciudadanía';
  static const String premiumSubtitleEs =
      'Prepárate para tu entrevista de naturalización con práctica guiada por IA';
  static const String premiumBullet1Es  = 'Simulador de Oficial de USCIS';
  static const String premiumBullet2Es  = 'Práctica del Formulario N-400';
  static const String premiumBullet3Es  = 'Preguntas de Historia y Cívica';
  static const String premiumUpgradeEs  = 'Desbloquear Ciudadanía';
  static const String premiumBadgeEs    = 'PRO';
  static const String premiumRestoreEs  = '¿Ya compraste? Restaurar';

  // ── Privacy ───────────────────────────────────────────────────
  static const String privacyTitleEs = '🔏 Política de Privacidad';
  static const String privacySection1TitleEs = 'Recolección de Información';
  static const String privacySection1TitleEn = 'Information We Collect';
  static const String privacySection1BodyEs  =
      'Recopilamos únicamente la información que tú '
      'proporcionas, como tus preferencias de aprendizaje y el progreso de tus lecciones. '
      'No recopilamos datos de identificación personal sin tu permiso.';
  static const String privacySection1BodyEn  =
      'We only collect information you provide, '
      'such as your learning preferences and lesson progress. We do not collect personal '
      'identification data without your permission.';
  static const String privacySection2TitleEs = 'Uso de tu Información';
  static const String privacySection2TitleEn = 'How We Use Your Information';
  static const String privacySection2BodyEs  =
      'Tu información se usa exclusivamente para '
      'personalizar tu experiencia. No vendemos ni compartimos tus datos con terceros para publicidad.';
  static const String privacySection2BodyEn  =
      'Your information is used exclusively to '
      'personalize your experience. We do not sell or share your data with third parties for advertising.';
  static const String privacySection3TitleEs = 'Compras';
  static const String privacySection3TitleEn = 'Purchases';
  static const String privacySection3BodyEs  =
      'Las compras se procesan de forma segura a través '
      'de RevenueCat y la tienda de tu dispositivo (App Store o Google Play). '
      'English Bridge nunca almacena los datos de tu tarjeta de crédito.';
  static const String privacySection3BodyEn  =
      'Purchases are securely processed through RevenueCat '
      "and your device's app store. English Bridge never stores your credit card information.";
  static const String privacySection4TitleEs = 'Contacto';
  static const String privacySection4TitleEn = 'Contact Us';
  static const String privacySection4BodyEs  =
      'Preguntas sobre privacidad: privacidad@englishbridge.app';
  static const String privacySection4BodyEn  =
      'Privacy questions: privacy@englishbridge.app';

  // ── STT errors ────────────────────────────────────────────────
  static const String sttMicDeniedEs =
      'Permiso de micrófono denegado. Actívalo en Ajustes de tu dispositivo.';
  static const String sttErrorEs = 'Error de micrófono. Intenta de nuevo.';

  // ── AI Daily Lesson ───────────────────────────────────────────
  static const String aiDailyLessonTitleEs    = 'Tu Lección Diaria Personalizada';
  static const String aiDailyLessonSubtitleEs = 'Una lección nueva creada solo para ti';
  static const String aiDailyLessonLoadingEs  = 'Generando tu lección de hoy...';
  static const String aiDailyLessonErrorEs    = 'No pudimos generar tu lección. Intenta de nuevo.';

  // ── Smart Review (Quiz Bank) ───────────────────────────────────
  static const String smartReviewTitleEs        = 'Practicar Debilidades';
  static const String smartReviewTitleEn        = 'Smart Review';
  static const String smartReviewCardSubtitleEs = ' preguntas pendientes';
  static const String smartReviewCompleteTitleEs = '¡Repaso Completado!';
  static const String smartReviewCompleteBodyEs  =
      'Las respuestas correctas fueron eliminadas.';
  static const String smartReviewBackEs          = 'Volver al inicio';
}

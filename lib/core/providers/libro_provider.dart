import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/claude_service.dart';
import '../services/connectivity_service.dart';
import 'connectivity_provider.dart';
import 'vocab_provider.dart';

// ── Data models ──────────────────────────────────────────────────────────────

class GrammarError {
  const GrammarError({
    required this.original,
    required this.corrected,
    required this.explanationEs,
    required this.startIndex,
    required this.endIndex,
  });

  final String original;
  final String corrected;
  final String explanationEs;
  final int startIndex;
  final int endIndex;
}

enum LibroStatus {
  editing,
  reviewing,
  reviewed,
  noErrors,
  offlineError,
  apiError,
}

class LibroState {
  const LibroState({
    this.status = LibroStatus.editing,
    this.draftText = '',
    this.errors = const [],
    this.overallFeedbackEs = '',
    this.errorMessage = '',
  });

  final LibroStatus status;
  final String draftText;
  final List<GrammarError> errors;
  final String overallFeedbackEs;
  final String errorMessage;

  LibroState copyWith({
    LibroStatus? status,
    String? draftText,
    List<GrammarError>? errors,
    String? overallFeedbackEs,
    String? errorMessage,
  }) {
    return LibroState(
      status: status ?? this.status,
      draftText: draftText ?? this.draftText,
      errors: errors ?? this.errors,
      overallFeedbackEs: overallFeedbackEs ?? this.overallFeedbackEs,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// ── System prompt ─────────────────────────────────────────────────────────────

const _libroSystemPrompt = '''
Eres un profesor de inglés amable. Revisa el texto del estudiante.
Responde SOLO con JSON válido, sin markdown:
{
  "has_errors": true,
  "corrections": [
    {"original":"texto EXACTO del original","corrected":"texto correcto",
     "explanation_es":"Regla en español, máx 2 oraciones amables."}
  ],
  "overall_feedback_es": "Comentario alentador en español."
}
Si no hay errores: {"has_errors":false,"corrections":[],"overall_feedback_es":"¡Excelente!"}
CRÍTICO: "original" debe coincidir EXACTAMENTE con el texto del estudiante.
''';

// ── Notifier ──────────────────────────────────────────────────────────────────

class LibroNotifier extends StateNotifier<LibroState> {
  LibroNotifier({required ConnectivityService connectivity, required Ref ref})
      : _connectivity = connectivity,
        _ref = ref,
        super(const LibroState());

  final ConnectivityService _connectivity;
  final Ref _ref;
  final _claude = ClaudeService();

  void updateDraft(String text) {
    state = state.copyWith(
      status: LibroStatus.editing,
      draftText: text,
      errors: [],
      overallFeedbackEs: '',
      errorMessage: '',
    );
  }

  Future<void> review() async {
    final text = state.draftText.trim();
    if (text.isEmpty) return;

    final online = await _connectivity.isOnline();
    if (!online) {
      state = state.copyWith(status: LibroStatus.offlineError);
      return;
    }

    state = state.copyWith(status: LibroStatus.reviewing);

    try {
      final raw = await _claude.complete(
        systemPrompt: _libroSystemPrompt,
        userMessage: text,
        maxTokens: 1024,
      );

      final result = _parseResult(raw, text);
      state = result;
      // Auto-save each correction pair to the vocabulary word bank.
      for (final err in result.errors) {
        if (err.corrected.isNotEmpty && err.explanationEs.isNotEmpty) {
          await _ref.read(vocabProvider.notifier).addWord(
                wordEn: err.corrected,
                wordEs: err.explanationEs,
                source: 'libro',
              );
        }
      }
    } catch (_) {
      state = state.copyWith(
        status: LibroStatus.apiError,
        errorMessage: 'Error al conectar con el servicio de revisión.',
      );
    }
  }

  void loadDraft(String text) {
    state = state.copyWith(
      status: LibroStatus.editing,
      draftText: text,
      errors: [],
      overallFeedbackEs: '',
      errorMessage: '',
    );
  }

  void resetToEditing() {
    state = state.copyWith(
      status: LibroStatus.editing,
      errors: [],
      overallFeedbackEs: '',
      errorMessage: '',
    );
  }

  LibroState _parseResult(String raw, String draftText) {
    try {
      final cleaned = raw
          .replaceAll(RegExp(r'```json\s*'), '')
          .replaceAll(RegExp(r'```\s*'), '')
          .trim();
      final json = jsonDecode(cleaned) as Map<String, dynamic>;
      final hasErrors = json['has_errors'] as bool? ?? false;
      final feedbackEs = json['overall_feedback_es'] as String? ?? '';

      if (!hasErrors) {
        return state.copyWith(
          status: LibroStatus.noErrors,
          errors: [],
          overallFeedbackEs: feedbackEs,
          draftText: draftText,
        );
      }

      final corrections = json['corrections'] as List<dynamic>? ?? [];
      final errors = <GrammarError>[];

      for (final c in corrections) {
        final map = c as Map<String, dynamic>;
        final original = map['original'] as String? ?? '';
        final corrected = map['corrected'] as String? ?? '';
        final explanationEs = map['explanation_es'] as String? ?? '';

        // Hallucination guard: skip if original not found in draftText.
        final idx = draftText.indexOf(original);
        if (idx == -1 || original.isEmpty) continue;

        errors.add(GrammarError(
          original: original,
          corrected: corrected,
          explanationEs: explanationEs,
          startIndex: idx,
          endIndex: idx + original.length,
        ));
      }

      // Sort by startIndex for span building.
      errors.sort((a, b) => a.startIndex.compareTo(b.startIndex));

      return state.copyWith(
        status: LibroStatus.reviewed,
        errors: errors,
        overallFeedbackEs: feedbackEs,
        draftText: draftText,
      );
    } catch (_) {
      return state.copyWith(
        status: LibroStatus.apiError,
        errorMessage: 'No se pudo procesar la respuesta del servidor.',
      );
    }
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final libroProvider =
    StateNotifierProvider.autoDispose<LibroNotifier, LibroState>((ref) {
  return LibroNotifier(
    connectivity: ref.watch(connectivityServiceProvider),
    ref: ref,
  );
});

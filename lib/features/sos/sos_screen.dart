import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/book_page_model.dart';
import '../../core/providers/book_pages_provider.dart';
import '../../core/providers/persona_provider.dart';
import '../../core/providers/sos_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_container.dart';
import '../../l10n/app_strings.dart';
import 'widgets/mic_hold_button.dart';

class SosScreen extends ConsumerStatefulWidget {
  const SosScreen({super.key});

  @override
  ConsumerState<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends ConsumerState<SosScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _textController;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseOpacity;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _pulseOpacity = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual<SosState>(sosProvider, (prev, next) {
        if (next.status == SosStatus.loading) {
          _pulseController.repeat(reverse: true);
        } else {
          _pulseController.stop();
          _pulseController.animateTo(0);
        }

        if (next.status == SosStatus.success && next.options.isNotEmpty) {
          final persona = ref.read(personaProvider);
          if (persona == Persona.abuelo) {
            final idx = next.selectedToneIndex.clamp(0, next.options.length - 1);
            Future.delayed(const Duration(milliseconds: 600), () {
              if (mounted) {
                ref.read(sosProvider.notifier).speakOption(next.options[idx]);
              }
            });
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sosProvider);
    final persona = ref.watch(personaProvider);
    final isSenior = persona?.isSeniorMode ?? false;
    final notifier = ref.read(sosProvider.notifier);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.glassGradientStart,
            AppColors.glassGradientMid,
            AppColors.glassGradientEnd,
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _GlassHeader(isSenior: isSenior),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Input field — hidden on success
                    if (state.status != SosStatus.success) ...[
                      _BilingualInputField(
                        controller: _textController,
                        isSenior: isSenior,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Tone selector — always visible
                    _ToneSelectorRow(
                      selectedIndex: state.selectedToneIndex,
                      isSenior: isSenior,
                      onSelect: notifier.selectTone,
                    ),
                    const SizedBox(height: 20),

                    // Translate + mic — only when idle or recording
                    if (state.status == SosStatus.idle ||
                        state.status == SosStatus.recording)
                      _TranslateSection(
                        state: state,
                        notifier: notifier,
                        controller: _textController,
                        isSenior: isSenior,
                      ),

                    // Liquid loading animation
                    if (state.status == SosStatus.loading) ...[
                      const SizedBox(height: 24),
                      _LiquidLoadingAnimation(
                        pulseOpacity: _pulseOpacity,
                        isSenior: isSenior,
                      ),
                    ],

                    // Glass result card
                    if (state.status == SosStatus.success)
                      _GlassResultCard(
                        state: state,
                        notifier: notifier,
                        isSenior: isSenior,
                      ),

                    // Error states
                    if (state.status == SosStatus.offlineError ||
                        state.status == SosStatus.apiError) ...[
                      const SizedBox(height: 24),
                      _GlassErrorCard(
                        message: state.status == SosStatus.offlineError
                            ? AppStrings.sosOfflineEs
                            : (state.errorMessage.isNotEmpty
                                ? state.errorMessage
                                : AppStrings.sosApiErrorEs),
                        isSenior: isSenior,
                      ),
                      const SizedBox(height: 16),
                      _GlassResetButton(
                        label: AppStrings.sosTryAgainEs,
                        onPressed: () {
                          notifier.reset();
                          _textController.clear();
                        },
                        isSenior: isSenior,
                      ),
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Glass Header ──────────────────────────────────────────────────────────────

class _GlassHeader extends StatelessWidget {
  const _GlassHeader({required this.isSenior});

  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    final titleSize =
        isSenior ? AppFontSizes.subtitleLarge : AppFontSizes.subtitle;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.glassText,
            ),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
          Expanded(
            child: Text(
              '${AppStrings.sosTitleEs}  •  ${AppStrings.sosTitleEn}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.w700,
                color: AppColors.glassText,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

// ── Bilingual Input Field ─────────────────────────────────────────────────────

class _BilingualInputField extends StatelessWidget {
  const _BilingualInputField({
    required this.controller,
    required this.isSenior,
  });

  final TextEditingController controller;
  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;

    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        style: TextStyle(
          color: AppColors.glassText,
          fontSize: bodySize,
          height: 1.5,
        ),
        maxLines: 4,
        minLines: 2,
        textCapitalization: TextCapitalization.sentences,
        cursorColor: AppColors.glowTerracotta,
        decoration: InputDecoration(
          hintText: AppStrings.sosInputPlaceholderEs,
          hintStyle: TextStyle(
            color: AppColors.glassTextMuted,
            fontSize: bodySize,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}

// ── Tone Selector Row ─────────────────────────────────────────────────────────

class _ToneSelectorRow extends StatelessWidget {
  const _ToneSelectorRow({
    required this.selectedIndex,
    required this.isSenior,
    required this.onSelect,
  });

  final int selectedIndex;
  final bool isSenior;
  final void Function(int) onSelect;

  static const _toneIcons = [
    Icons.business_center,
    Icons.sentiment_satisfied_alt,
    Icons.flash_on,
  ];

  static const _toneLabels = [
    AppStrings.sosToneFormalEs,
    AppStrings.sosToneFriendlyEs,
    AppStrings.sosToneUrgentEs,
  ];

  @override
  Widget build(BuildContext context) {
    final iconSize = isSenior ? 28.0 : 22.0;
    final labelSize = isSenior ? AppFontSizes.body : 14.0;

    return Row(
      children: List.generate(_toneIcons.length, (i) {
        final isSelected = i == selectedIndex;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(i),
            child: GlassContainer(
              margin: EdgeInsets.only(
                left: i == 0 ? 0 : 5,
                right: i == _toneIcons.length - 1 ? 0 : 5,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              borderColor: isSelected
                  ? AppColors.glowTerracotta
                  : AppColors.glassBorder,
              backgroundColor: isSelected
                  ? Color.fromRGBO(230, 126, 34, 0.15)
                  : AppColors.glassSurface,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _toneIcons[i],
                    color: isSelected
                        ? AppColors.glowTerracotta
                        : AppColors.glassText,
                    size: iconSize,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _toneLabels[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.glowTerracotta
                          : AppColors.glassText,
                      fontSize: labelSize,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ── Translate Section (button + mic) ─────────────────────────────────────────

class _TranslateSection extends StatelessWidget {
  const _TranslateSection({
    required this.state,
    required this.notifier,
    required this.controller,
    required this.isSenior,
  });

  final SosState state;
  final SosNotifier notifier;
  final TextEditingController controller;
  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    final isRecording = state.status == SosStatus.recording;
    final height = isSenior ? 72.0 : 60.0;
    final textSize =
        isSenior ? AppFontSizes.subtitleLarge : AppFontSizes.subtitle;
    final smallSize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: height,
          child: ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                notifier.translateText(text);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.glowTerracotta,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
            child: Text(
              AppStrings.sosTranslateButtonEs,
              style: TextStyle(
                fontSize: textSize,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Mic section
        Text(
          AppStrings.sosOrSpeakEs,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.glassTextMuted,
            fontSize: smallSize,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: MicHoldButton(
            isRecording: isRecording,
            isSenior: isSenior,
            onLongPressStart: notifier.startRecording,
            onLongPressEnd: notifier.stopRecordingAndTranslate,
          ),
        ),

        // Live STT feedback while recording
        if (isRecording && state.spokenText.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            state.spokenText,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.glassText,
              fontSize: smallSize,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
        ],
        if (isRecording) ...[
          const SizedBox(height: 8),
          Text(
            AppStrings.sosListeningEs,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.glowTerracotta,
              fontSize: smallSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

// ── Liquid Loading Animation ──────────────────────────────────────────────────

class _LiquidLoadingAnimation extends StatelessWidget {
  const _LiquidLoadingAnimation({
    required this.pulseOpacity,
    required this.isSenior,
  });

  final Animation<double> pulseOpacity;
  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;

    return Column(
      children: [
        AnimatedBuilder(
          animation: pulseOpacity,
          builder: (_, child) => Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.glowTerracotta
                  .withValues(alpha: pulseOpacity.value * 0.35),
              boxShadow: [
                BoxShadow(
                  color: AppColors.glowTerracotta
                      .withValues(alpha: pulseOpacity.value),
                  blurRadius: 30,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: const Icon(
              Icons.translate,
              color: Colors.white,
              size: 36,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.sosTranslatingEs,
          style: TextStyle(
            color: AppColors.glassText,
            fontSize: bodySize,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ── Glass Result Card ─────────────────────────────────────────────────────────

class _GlassResultCard extends ConsumerWidget {
  const _GlassResultCard({
    required this.state,
    required this.notifier,
    required this.isSenior,
  });

  final SosState state;
  final SosNotifier notifier;
  final bool isSenior;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.options.isEmpty) return const SizedBox.shrink();

    final idx = state.selectedToneIndex.clamp(0, state.options.length - 1);
    final option = state.options[idx];
    final titleSize = isSenior ? AppFontSizes.titleLarge : AppFontSizes.title;
    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;
    final buttonHeight = isSenior ? 72.0 : 60.0;
    final resetSize =
        isSenior ? AppFontSizes.subtitleLarge : AppFontSizes.subtitle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // "You said" subtitle
              if (state.spokenText.isNotEmpty) ...[
                Text(
                  '${AppStrings.sosYouSaidEs} ${state.spokenText}',
                  style: TextStyle(
                    color: AppColors.glassTextMuted,
                    fontSize: bodySize - 2,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Translation text
              Text(
                option.text,
                style: TextStyle(
                  color: AppColors.glassText,
                  fontSize: titleSize,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 20),

              // Action buttons
              Row(
                children: [
                  _ActionButton(
                    icon: Icons.volume_up,
                    label: AppStrings.sosPlayEs,
                    isSenior: isSenior,
                    onPressed: () => notifier.speakOption(option),
                  ),
                  const SizedBox(width: 8),
                  _ActionButton(
                    icon: Icons.copy,
                    label: AppStrings.sosCopyEs,
                    isSenior: isSenior,
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: option.text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppStrings.sosCopiedEs),
                          backgroundColor: AppColors.glowTerracotta,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  _ActionButton(
                    icon: Icons.bookmark_add,
                    label: AppStrings.sosSaveToBookEs,
                    isSenior: isSenior,
                    onPressed: () {
                      final now = DateTime.now().toIso8601String();
                      final page = BookPage(
                        id: 'sos_$now',
                        promptEs: state.spokenText,
                        promptEn: 'SOS Translation',
                        text: option.text,
                        createdAt: now,
                        updatedAt: now,
                        isReviewed: false,
                      );
                      ref.read(bookPagesProvider.notifier).savePage(page);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppStrings.sosSavedToBookEs),
                          backgroundColor: AppColors.deepBlue,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Nueva Traducción reset button
        SizedBox(
          height: buttonHeight,
          child: ElevatedButton(
            onPressed: () => notifier.reset(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.glassSurface,
              foregroundColor: AppColors.glassText,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.glassBorder),
              ),
              elevation: 0,
            ),
            child: Text(
              AppStrings.sosNewTranslationEs,
              style: TextStyle(
                fontSize: resetSize,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Action Button ─────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.isSenior,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool isSenior;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final iconSize = isSenior ? 24.0 : 20.0;
    final fontSize = isSenior ? 13.0 : 11.0;

    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: AppColors.glassHighlight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.glassBorder,
              width: 0.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.glassText, size: iconSize),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.glassText,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Glass Error Card ──────────────────────────────────────────────────────────

class _GlassErrorCard extends StatelessWidget {
  const _GlassErrorCard({required this.message, required this.isSenior});

  final String message;
  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;

    return GlassContainer(
      borderColor: Colors.red.withValues(alpha: 0.5),
      backgroundColor: Colors.red.withValues(alpha: 0.1),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.red[200],
          fontSize: bodySize,
          height: 1.5,
        ),
      ),
    );
  }
}

// ── Glass Reset Button ────────────────────────────────────────────────────────

class _GlassResetButton extends StatelessWidget {
  const _GlassResetButton({
    required this.label,
    required this.onPressed,
    required this.isSenior,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    final height = isSenior ? 72.0 : 60.0;
    final textSize =
        isSenior ? AppFontSizes.subtitleLarge : AppFontSizes.subtitle;

    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.glowTerracotta,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 3,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: textSize,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

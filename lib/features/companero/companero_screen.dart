import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/audio_provider.dart';
import '../../core/providers/companero_provider.dart';
import '../../core/providers/persona_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_container.dart';
import '../../l10n/app_strings.dart';
import '../simulador/widgets/glass_mic_button.dart';

/// Mi Compañero — persistent AI chat companion tab.
class CompaneroScreen extends ConsumerStatefulWidget {
  const CompaneroScreen({super.key});

  @override
  ConsumerState<CompaneroScreen> createState() => _CompaneroScreenState();
}

class _CompaneroScreenState extends ConsumerState<CompaneroScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendText() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    await ref.read(companeroProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final persona = ref.watch(personaProvider);
    final isSenior = persona?.isSeniorMode ?? false;
    final chatState = ref.watch(companeroProvider);
    final notifier = ref.read(companeroProvider.notifier);

    // Auto-scroll whenever the message list grows or the AI starts responding.
    ref.listen<CompaneroState>(companeroProvider, (prev, next) {
      if ((prev?.messages.length ?? 0) != next.messages.length) {
        _scrollToBottom();
      }
    });

    final bodySize = isSenior ? AppFontSizes.bodyLarge : AppFontSizes.body;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
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
            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  const Text('🤖', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.companeroTitleEs,
                        style: TextStyle(
                          fontSize: isSenior
                              ? AppFontSizes.titleLarge
                              : AppFontSizes.title,
                          fontWeight: FontWeight.w800,
                          color: AppColors.glassText,
                        ),
                      ),
                      Text(
                        AppStrings.companeroSubtitleEs,
                        style: TextStyle(
                          fontSize: bodySize - 2,
                          color: AppColors.glassTextMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Message list ──────────────────────────────────────────────
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: chatState.messages.length +
                    (chatState.status == CompaneroStatus.loading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == chatState.messages.length) {
                    return const _TypingBubble();
                  }
                  final msg = chatState.messages[index];
                  if (msg.isError) {
                    return _ErrorBubble(
                      text: msg.text,
                      bodySize: bodySize,
                      onRetry: () =>
                          ref.read(companeroProvider.notifier).retryLastMessage(),
                    );
                  }
                  return msg.isUser
                      ? _UserBubble(text: msg.text, bodySize: bodySize)
                      : _AiBubble(
                          text: msg.text,
                          bodySize: bodySize,
                          onReplay: () =>
                              ref.read(audioServiceProvider).speak(msg.text),
                        );
                },
              ),
            ),

            // ── Input / Voice area ────────────────────────────────────────
            _buildInputSection(chatState, notifier, isSenior, bodySize),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection(
    CompaneroState chatState,
    CompaneroNotifier notifier,
    bool isSenior,
    double bodySize,
  ) {
    // ── Recording panel ──────────────────────────────────────────────────────
    if (chatState.status == CompaneroStatus.recording) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.glassSurface,
          border: Border(
              top: BorderSide(color: AppColors.glassBorder, width: 1.0)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Live transcription preview
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 44),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.glassHighlight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.glowTerracotta.withValues(alpha: 0.5)),
              ),
              child: Text(
                chatState.userTranscription.isNotEmpty
                    ? chatState.userTranscription
                    : 'Escuchando…',
                style: TextStyle(
                  fontSize: bodySize,
                  color: chatState.userTranscription.isNotEmpty
                      ? AppColors.glassText
                      : AppColors.glassTextMuted,
                  fontStyle: chatState.userTranscription.isEmpty
                      ? FontStyle.italic
                      : FontStyle.normal,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Tap mic again to stop and send
            GlassMicButton(
              isRecording: true,
              isAnalyzing: false,
              onTap: notifier.stopVoiceAndSend,
            ),
            const SizedBox(height: 8),
            Text(
              'Toca para enviar',
              style: TextStyle(
                fontSize: bodySize - 4,
                color: AppColors.glassTextMuted,
              ),
            ),
          ],
        ),
      );
    }

    // ── Text input bar (idle / loading / error) ───────────────────────────────
    final isLoading = chatState.status == CompaneroStatus.loading;
    final inputHeight = isSenior ? 64.0 : 52.0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassSurface,
        border:
            Border(top: BorderSide(color: AppColors.glassBorder, width: 1.0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Text field
          Expanded(
            child: SizedBox(
              height: inputHeight,
              child: TextField(
                controller: _controller,
                style: TextStyle(
                    fontSize: bodySize, color: AppColors.glassText),
                decoration: InputDecoration(
                  hintText: AppStrings.companeroInputHintEs,
                  hintStyle: TextStyle(
                      fontSize: bodySize - 2,
                      color: AppColors.glassTextMuted),
                  filled: true,
                  fillColor: AppColors.glassHighlight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendText(),
                enabled: !isLoading,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Mic button — tap to start voice recording
          _MicIconButton(
            size: inputHeight,
            onTap: isLoading ? null : ref.read(companeroProvider.notifier).startVoice,
          ),
          const SizedBox(width: 8),

          // Send button
          GestureDetector(
            onTap: isLoading ? null : _sendText,
            child: Container(
              width: inputHeight,
              height: inputHeight,
              decoration: BoxDecoration(
                color: isLoading
                    ? AppColors.glassTextMuted
                    : AppColors.glowTerracotta,
                borderRadius: BorderRadius.circular(16),
                boxShadow: !isLoading
                    ? [
                        BoxShadow(
                          color:
                              AppColors.glowTerracotta.withValues(alpha: 0.4),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: isLoading
                  ? const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      ),
                    )
                  : const Icon(Icons.send_rounded,
                      color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Small mic icon button (in text bar) ───────────────────────────────────────

class _MicIconButton extends StatelessWidget {
  const _MicIconButton({required this.size, required this.onTap});

  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.glassHighlight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: onTap != null
                ? AppColors.glowTerracotta.withValues(alpha: 0.6)
                : AppColors.glassBorder,
          ),
        ),
        child: Icon(
          Icons.mic_rounded,
          color: onTap != null
              ? AppColors.glowTerracotta
              : AppColors.glassTextMuted,
          size: 22,
        ),
      ),
    );
  }
}

// ── Bubbles ───────────────────────────────────────────────────────────────────

class _ErrorBubble extends StatelessWidget {
  const _ErrorBubble({
    required this.text,
    required this.bodySize,
    required this.onRetry,
  });

  final String text;
  final double bodySize;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.12),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          ),
          border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: bodySize,
                color: Colors.red[300],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                constraints: const BoxConstraints(minHeight: 48),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: Colors.red.withValues(alpha: 0.5)),
                ),
                child: Text(
                  AppStrings.companeroRetryEs,
                  style: TextStyle(
                    fontSize: bodySize - 2,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiBubble extends StatelessWidget {
  const _AiBubble({
    required this.text,
    required this.bodySize,
    required this.onReplay,
  });

  final String text;
  final double bodySize;
  final VoidCallback onReplay;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        margin: const EdgeInsets.only(bottom: 12),
        child: GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: TextStyle(
                    fontSize: bodySize,
                    color: AppColors.glassText,
                    height: 1.5),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: onReplay,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.replay_rounded,
                        size: 15, color: AppColors.glowTerracotta),
                    const SizedBox(width: 4),
                    Text(
                      'Escuchar',
                      style: TextStyle(
                        fontSize: bodySize - 4,
                        color: AppColors.glowTerracotta,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.text, required this.bodySize});

  final String text;
  final double bodySize;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        margin: const EdgeInsets.only(bottom: 12),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.glowTerracotta,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(4),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.glowTerracotta.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
              fontSize: bodySize, color: Colors.white, height: 1.5),
        ),
      ),
    );
  }
}

// ── Typing indicator ──────────────────────────────────────────────────────────

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: GlassContainer(
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Dot(delay: 0),
              const SizedBox(width: 6),
              _Dot(delay: 200),
              const SizedBox(width: 6),
              _Dot(delay: 400),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  const _Dot({required this.delay});

  final int delay;

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: AppColors.glassTextMuted,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

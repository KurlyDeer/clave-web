import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// A hold-to-record circle button with a pulsing scale animation while recording.
class MicHoldButton extends StatefulWidget {
  const MicHoldButton({
    super.key,
    required this.isRecording,
    required this.isSenior,
    required this.onLongPressStart,
    required this.onLongPressEnd,
  });

  final bool isRecording;
  final bool isSenior;
  final VoidCallback onLongPressStart;
  final VoidCallback onLongPressEnd;

  @override
  State<MicHoldButton> createState() => _MicHoldButtonState();
}

class _MicHoldButtonState extends State<MicHoldButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(MicHoldButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !oldWidget.isRecording) {
      _controller.repeat(reverse: true);
    } else if (!widget.isRecording && oldWidget.isRecording) {
      _controller.stop();
      _controller.animateTo(0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.isSenior ? 120.0 : 100.0;
    final color =
        widget.isRecording ? AppColors.terracotta : AppColors.deepBlue;
    final icon = widget.isRecording ? Icons.mic : Icons.mic_none;

    return GestureDetector(
      onLongPressStart: (_) => widget.onLongPressStart(),
      onLongPressEnd: (_) => widget.onLongPressEnd(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 20,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: size * 0.45,
          ),
        ),
      ),
    );
  }
}

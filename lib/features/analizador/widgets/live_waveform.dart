import 'dart:math';

import 'package:flutter/material.dart';

/// Animated waveform driven by real-time STT sound levels.
///
/// [levels] — list of recent dB values from speech_to_text's
/// onSoundLevelChange (-10.0 to 0.0 range). When empty or [isActive]
/// is false, shows a gentle idle breathing animation.
class LiveWaveform extends StatefulWidget {
  const LiveWaveform({
    super.key,
    required this.isActive,
    required this.levels,
    required this.color,
    this.height = 64,
  });

  final bool isActive;
  final List<double> levels;
  final Color color;
  final double height;

  @override
  State<LiveWaveform> createState() => _LiveWaveformState();
}

class _LiveWaveformState extends State<LiveWaveform>
    with SingleTickerProviderStateMixin {
  late final AnimationController _idle;

  @override
  void initState() {
    super.initState();
    _idle = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _idle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _idle,
        builder: (context, _) => CustomPaint(
          size: Size(double.infinity, widget.height),
          painter: _WaveformPainter(
            levels: widget.levels,
            idlePhase: _idle.value,
            isActive: widget.isActive,
            color: widget.color,
          ),
        ),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  _WaveformPainter({
    required this.levels,
    required this.idlePhase,
    required this.isActive,
    required this.color,
  });

  final List<double> levels;
  final double idlePhase;
  final bool isActive;
  final Color color;

  static const _barCount = 40;

  @override
  void paint(Canvas canvas, Size size) {
    final spacing = size.width / _barCount;
    final barWidth = spacing * 0.55;
    final midY = size.height / 2;
    final maxBarHalf = size.height / 2 * 0.9;

    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = barWidth;

    for (int i = 0; i < _barCount; i++) {
      final x = spacing * i + spacing / 2;
      double barHalf;

      if (isActive && levels.isNotEmpty) {
        // Map bar index to level history
        final li =
            ((i / _barCount) * levels.length).floor().clamp(0, levels.length - 1);
        final level = levels[li]; // -10..0
        final normalised = ((level + 10) / 10).clamp(0.0, 1.0);
        // Add slight per-bar variation for a natural look
        final jitter = 0.85 + 0.15 * sin(i * 1.3 + idlePhase * pi);
        barHalf = (0.04 + normalised * 0.96) * maxBarHalf * jitter;
      } else {
        // Idle gentle sine-wave animation
        final phase = idlePhase * 2 * pi + i * 0.45;
        barHalf = (0.05 + 0.08 * (0.5 + 0.5 * sin(phase))) * maxBarHalf;
      }

      canvas.drawLine(
        Offset(x, midY - barHalf),
        Offset(x, midY + barHalf),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter old) => true;
}

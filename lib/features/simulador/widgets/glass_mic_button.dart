import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_container.dart';

/// Tap-toggle mic button with pulse animation when recording,
/// and a frosted glass spinner when analyzing.
class GlassMicButton extends StatefulWidget {
  const GlassMicButton({
    super.key,
    required this.isRecording,
    required this.isAnalyzing,
    required this.onTap,
  });

  final bool isRecording;
  final bool isAnalyzing;
  final VoidCallback? onTap;

  @override
  State<GlassMicButton> createState() => _GlassMicButtonState();
}

class _GlassMicButtonState extends State<GlassMicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
    if (widget.isRecording) _pulse.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(GlassMicButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !oldWidget.isRecording) {
      _pulse.repeat(reverse: true);
    } else if (!widget.isRecording && oldWidget.isRecording) {
      _pulse.stop();
      _pulse.reset();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isAnalyzing) {
      return GlassContainer(
        padding: const EdgeInsets.all(20),
        borderRadius: 40,
        child: SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            color: AppColors.glassText,
            strokeWidth: 3,
          ),
        ),
      );
    }

    return ScaleTransition(
      scale: _scale,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, child) {
          final glowAlpha = widget.isRecording
              ? ((_pulse.value * 0.6 + 0.2) * 255).round()
              : 77; // 0.3 * 255
          return GestureDetector(
            onTap: widget.onTap,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isRecording
                    ? AppColors.glowTerracotta
                    : AppColors.glowTerracotta.withAlpha(217),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.glowTerracotta.withAlpha(glowAlpha),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: child,
            ),
          );
        },
        child: Icon(
          widget.isRecording ? Icons.stop_rounded : Icons.mic_rounded,
          color: Colors.white,
          size: 36,
        ),
      ),
    );
  }
}

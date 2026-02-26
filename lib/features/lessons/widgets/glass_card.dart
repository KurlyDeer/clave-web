import 'dart:ui';

import 'package:flutter/material.dart';

/// Glassmorphic card for the Lesson screens.
///
/// Wraps [child] with a [BackdropFilter] blur (default σ = 15),
/// a 15 % white surface and a 35 % white border — tuned for the
/// deep blue-to-purple lesson background.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.margin,
    this.borderRadius = 24.0,
    this.blurSigma = 15.0,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: const Color(0x26FFFFFF), // 15 % white
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: const Color(0x59FFFFFF), // 35 % white
                width: 1.2,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Reusable glassmorphic container with blur + semi-transparent surface.
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.borderRadius = 16.0, // Matches Tailwind rounded-2xl
    this.blurSigma = 12.0, // Matches backdrop-blur-sm roughly
    this.backgroundColor,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blurSigma;
  final Color? backgroundColor;
  final Color? borderColor;

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
              color: backgroundColor ?? AppColors.glassSurface,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                  color: borderColor ?? AppColors.glassBorder, width: 1.0),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

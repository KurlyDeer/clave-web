import 'package:flutter/material.dart';

/// Defines the standard responsive breakpoints for the application.
class ResponsiveBreakpoints {
  /// Width threshold where we transition from a mobile bottom bar to a desktop sidebar.
  static const double desktop = 900.0;

  /// Width threshold where tablet behavior (e.g. slight padding changes) might occur.
  static const double tablet = 600.0;

  /// Maximum content width for core pages (e.g. Lesson screens).
  static const double maxContentWidth = 800.0;

  /// Maximum content width for ultra-focused pages (e.g. Login screen).
  static const double maxNarrowContentWidth = 450.0;
}

/// A utility widget that ensures its child does not exceed a maximum width,
/// keeping it centered on wide displays.
class ResponsiveConstrainer extends StatelessWidget {
  const ResponsiveConstrainer({
    super.key,
    required this.child,
    this.maxWidth = ResponsiveBreakpoints.maxContentWidth,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final double maxWidth;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

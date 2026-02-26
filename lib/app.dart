import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'l10n/app_strings.dart';

class EnglishBridgeApp extends StatelessWidget {
  const EnglishBridgeApp({super.key, required this.home});

  final Widget home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: home,
    );
  }
}

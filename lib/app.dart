import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import 'core/theme/app_theme.dart';
import 'l10n/app_strings.dart';

class EnglishBridgeApp extends ConsumerWidget {
  const EnglishBridgeApp({super.key, required this.home});

  final Widget home;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final platformBrightness = View.of(context).platformDispatcher.platformBrightness;
    AppColors.setDarkMode(platformBrightness == Brightness.dark);
    
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: home,
    );
  }
}

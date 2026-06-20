import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/auth_provider.dart';
import 'core/providers/shared_preferences_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/login_screen.dart';
import 'features/dashboard/main_shell_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'l10n/app_strings.dart';

class EnglishBridgeApp extends ConsumerWidget {
  const EnglishBridgeApp({super.key});

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
      home: const _AuthGate(),
    );
  }
}

/// Listens to [authStateProvider] and routes the user accordingly:
///
/// - **Loading** → centered spinner
/// - **Unauthenticated** → [LoginScreen]
/// - **Authenticated** → checks `onboarding_complete` in SharedPreferences
///   - Not completed → [OnboardingScreen]
///   - Completed → [MainShellScreen]
class _AuthGate extends ConsumerWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () => Scaffold(
        backgroundColor: AppColors.glassGradientStart,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.glowTerracotta,
          ),
        ),
      ),
      error: (e, st) => const LoginScreen(),
      data: (user) {
        if (user == null) {
          return const LoginScreen();
        }

        // User is authenticated — check onboarding status.
        final prefs = ref.read(sharedPreferencesProvider);
        final onboardingComplete =
            prefs.getBool('onboarding_complete') ?? false;
        final hasLegacyPersona = prefs.getString('persona') != null;

        if (onboardingComplete || hasLegacyPersona) {
          // One-time migration: mark legacy users as onboarded.
          if (!onboardingComplete && hasLegacyPersona) {
            prefs.setBool('onboarding_complete', true);
          }
          return const MainShellScreen();
        }

        return const OnboardingScreen();
      },
    );
  }
}

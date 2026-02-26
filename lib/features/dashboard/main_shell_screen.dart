import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/persona_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_strings.dart';
import '../sos/sos_screen.dart';
import 'glass_home_tab.dart';
import 'library_tab.dart';

/// Root shell with 3-tab bottom nav: Home · Library · S.O.S.
class MainShellScreen extends ConsumerStatefulWidget {
  const MainShellScreen({super.key});

  @override
  ConsumerState<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends ConsumerState<MainShellScreen> {
  int _currentIndex = 0;

  // IndexedStack keeps all tabs alive to preserve state.
  static const List<Widget> _tabs = [
    GlassHomeTab(),
    LibraryTab(),
    SosScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final persona = ref.watch(personaProvider);
    final isSenior = persona?.isSeniorMode ?? false;
    final iconSize = isSenior ? 30.0 : 24.0;

    return Scaffold(
      backgroundColor: AppColors.glassGradientStart,
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: AppColors.glassGradientStart,
        selectedItemColor: AppColors.glowTerracotta,
        unselectedItemColor: AppColors.glassTextMuted,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: isSenior ? 16.0 : 14.0,
        unselectedFontSize: isSenior ? 14.0 : 12.0,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: iconSize),
            label: AppStrings.navHomeEs,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books, size: iconSize),
            label: AppStrings.navLibraryEs,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign, size: iconSize),
            label: AppStrings.navSosEs,
          ),
        ],
      ),
    );
  }
}

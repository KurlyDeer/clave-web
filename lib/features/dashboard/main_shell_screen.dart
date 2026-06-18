import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/persona_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_strings.dart';
import '../companero/companero_screen.dart';
import 'glass_home_tab.dart';
import 'library_tab.dart';

/// Root shell with 3-tab bottom nav: Home · Mi Compañero (center) · Biblioteca
class MainShellScreen extends ConsumerStatefulWidget {
  const MainShellScreen({super.key});

  @override
  ConsumerState<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends ConsumerState<MainShellScreen> {
  int _currentIndex = 0;

  // Ordered: Home (0) · Mi Compañero center (1) · Biblioteca (2)
  static const List<Widget> _tabs = [
    GlassHomeTab(),
    CompaneroScreen(),
    LibraryTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final persona = ref.watch(personaProvider);
    final isSenior = persona?.isSeniorMode ?? false;

    return Scaffold(
      backgroundColor: AppColors.glassGradientStart,
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            final docRef = await FirebaseFirestore.instance.collection('test_collection').add({
              'message': 'Hello from Clave Flutter App!',
              'timestamp': FieldValue.serverTimestamp(),
            });
            debugPrint('Success! Document written with ID: ${docRef.id}');
          } catch (error) {
            debugPrint('Error writing document: $error');
          }
        },
        child: const Icon(Icons.cloud_upload),
      ),
      bottomNavigationBar: _GlassNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        isSenior: isSenior,
      ),
    );
  }
}

// ── Glass Bottom Nav ──────────────────────────────────────────────────────────

class _GlassNavBar extends StatelessWidget {
  const _GlassNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.isSenior,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isSenior;

  @override
  Widget build(BuildContext context) {
    final iconSize = isSenior ? 30.0 : 24.0;
    final labelSize = isSenior ? 14.0 : 12.0;
    final barHeight = isSenior ? 80.0 : 70.0;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          height: barHeight + bottomPad,
          decoration: BoxDecoration(
            color: AppColors.glassSurface,
            border: Border(
              top: BorderSide(color: AppColors.glassBorder, width: 1.0),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                _NavItem(
                  icon: Icons.home,
                  label: AppStrings.navHomeEs,
                  isSelected: currentIndex == 0,
                  iconSize: iconSize,
                  labelSize: labelSize,
                  onTap: () => onTap(0),
                ),
                _CompaneroNavItem(
                  isSelected: currentIndex == 1,
                  iconSize: iconSize,
                  labelSize: labelSize,
                  onTap: () => onTap(1),
                ),
                _NavItem(
                  icon: Icons.library_books,
                  label: AppStrings.navLibraryEs,
                  isSelected: currentIndex == 2,
                  iconSize: iconSize,
                  labelSize: labelSize,
                  onTap: () => onTap(2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.iconSize,
    required this.labelSize,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final double iconSize;
  final double labelSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color =
        isSelected ? AppColors.glowTerracotta : AppColors.glassTextMuted;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: iconSize),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: labelSize,
                color: color,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompaneroNavItem extends StatelessWidget {
  const _CompaneroNavItem({
    required this.isSelected,
    required this.iconSize,
    required this.labelSize,
    required this.onTap,
  });

  final bool isSelected;
  final double iconSize;
  final double labelSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final circleSize = iconSize + 20;
    final color =
        isSelected ? AppColors.glowTerracotta : AppColors.glassTextMuted;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.12),
                border: Border.all(
                  color: color,
                  width: isSelected ? 2.0 : 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.glowTerracotta.withValues(alpha: 0.3),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                color: color,
                size: iconSize,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppStrings.navCompaneroEs,
              style: TextStyle(
                fontSize: labelSize,
                color: color,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../l10n/app_strings.dart';

/// Login / Sign-up screen following the app's glassmorphism design.
///
/// Supports:
/// - Email + password sign-in / sign-up
/// - Anonymous "continue as guest" option
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Translates FirebaseAuth error codes to Spanish messages.
  String _friendlyError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'El correo electrónico no es válido.';
      case 'user-disabled':
        return 'Esta cuenta ha sido desactivada.';
      case 'user-not-found':
        return 'No existe una cuenta con este correo.';
      case 'wrong-password':
        return 'Contraseña incorrecta. Intenta de nuevo.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con este correo.';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres.';
      case 'invalid-credential':
        return 'Credenciales inválidas. Verifica tu correo y contraseña.';
      case 'too-many-requests':
        return 'Demasiados intentos. Espera un momento e intenta de nuevo.';
      default:
        return 'Error de autenticación. Intenta de nuevo.';
    }
  }

  Future<void> _submitEmailPassword() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(
          () => _errorMessage = 'Por favor ingresa tu correo y contraseña.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      if (_isSignUp) {
        await authService.signUpWithEmail(email: email, password: password);
      } else {
        await authService.signInWithEmail(email: email, password: password);
      }
      // AuthGate will handle navigation on auth state change.
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _errorMessage = _friendlyError(e.code));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Error inesperado. Intenta de nuevo.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _continueAsGuest() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authServiceProvider).signInAnonymously();
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _errorMessage = _friendlyError(e.code));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Error inesperado. Intenta de nuevo.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.glassGradientStart,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.glassGradientStart,
              AppColors.glassGradientMid,
              AppColors.glassGradientEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ResponsiveConstrainer(
                maxWidth: ResponsiveBreakpoints.maxNarrowContentWidth,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Logo ──────────────────────────────────────────────
                  const _LogoSection(),
                  const SizedBox(height: 40),

                  // ── Login Form ────────────────────────────────────────
                  GlassContainer(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _isSignUp ? 'Crear Cuenta' : 'Iniciar Sesión',
                          style: TextStyle(
                            fontSize: AppFontSizes.title,
                            fontWeight: FontWeight.w800,
                            color: AppColors.glassText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isSignUp
                              ? 'Crea tu cuenta para guardar tu progreso'
                              : 'Ingresa para continuar tu viaje',
                          style: TextStyle(
                            fontSize: AppFontSizes.body - 2,
                            color: AppColors.glassTextMuted,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Email field
                        _GlassTextField(
                          controller: _emailController,
                          hintText: 'Correo electrónico',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                        ),
                        const SizedBox(height: 16),

                        // Password field
                        _GlassTextField(
                          controller: _passwordController,
                          hintText: 'Contraseña',
                          obscureText: true,
                          prefixIcon: Icons.lock_outline,
                          onSubmitted: (_) => _submitEmailPassword(),
                        ),
                        const SizedBox(height: 8),

                        // Error message
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.errorRed.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    AppColors.errorRed.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline,
                                    color: AppColors.errorRed, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                      fontSize: AppFontSizes.body - 4,
                                      color: AppColors.errorRed,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),

                        // Submit button
                        _PrimaryButton(
                          label: _isSignUp ? 'Crear Cuenta' : 'Entrar',
                          isLoading: _isLoading,
                          onPressed: _submitEmailPassword,
                        ),
                        const SizedBox(height: 16),

                        // Toggle sign-in / sign-up
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isSignUp = !_isSignUp;
                              _errorMessage = null;
                            });
                          },
                          child: Text(
                            _isSignUp
                                ? '¿Ya tienes cuenta? Inicia sesión'
                                : '¿No tienes cuenta? Regístrate',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: AppFontSizes.body - 2,
                              color: AppColors.deepBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Divider ───────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                          child: Divider(
                              color:
                                  AppColors.glassTextMuted.withValues(alpha: 0.3))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'o',
                          style: TextStyle(
                            color: AppColors.glassTextMuted,
                            fontSize: AppFontSizes.body - 2,
                          ),
                        ),
                      ),
                      Expanded(
                          child: Divider(
                              color:
                                  AppColors.glassTextMuted.withValues(alpha: 0.3))),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Continue as Guest ─────────────────────────────────
                  GestureDetector(
                    onTap: _isLoading ? null : _continueAsGuest,
                    child: GlassContainer(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      borderColor: AppColors.glassBorder,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_outline,
                              color: AppColors.glassText, size: 22),
                          const SizedBox(width: 10),
                          Text(
                            'Continuar como invitado',
                            style: TextStyle(
                              fontSize: AppFontSizes.body,
                              fontWeight: FontWeight.w600,
                              color: AppColors.glassText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
  }
}

// ── Logo Section ──────────────────────────────────────────────────────────────

class _LogoSection extends StatelessWidget {
  const _LogoSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GlassContainer(
          padding: const EdgeInsets.all(20),
          borderRadius: 22,
          child: const Text('🌉', style: TextStyle(fontSize: 48)),
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.appName,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppFontSizes.headline,
            fontWeight: FontWeight.w800,
            color: AppColors.glassText,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          AppStrings.appTaglineEs,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppFontSizes.subtitle,
            color: AppColors.glassText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ── Glass Text Field ──────────────────────────────────────────────────────────

class _GlassTextField extends StatelessWidget {
  const _GlassTextField({
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        onSubmitted: onSubmitted,
        style: TextStyle(
          color: AppColors.glassText,
          fontSize: AppFontSizes.body,
        ),
        cursorColor: AppColors.glowTerracotta,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: AppColors.glassTextMuted,
            fontSize: AppFontSizes.body - 2,
          ),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: AppColors.glassTextMuted, size: 22)
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}

// ── Primary Button ────────────────────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.glowTerracotta.withValues(alpha: 0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: SizedBox(
        height: 60,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.glowTerracotta,
            foregroundColor: AppColors.lightText,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: AppColors.lightText,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    fontSize: AppFontSizes.subtitle,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }
}

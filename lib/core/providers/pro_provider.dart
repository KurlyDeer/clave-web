import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/revenue_cat_service.dart';
import 'shared_preferences_provider.dart';

// ── SharedPreferences keys ────────────────────────────────────────────────────

const _kIsPro         = 'is_pro';
const _kSosUsedDate   = 'sos_used_date';
const _kSosUsedCount  = 'sos_used_count';
const _kLibroUsedDate = 'libro_used_date';
const _kLibroUsedCount= 'libro_used_count';

// ── State ─────────────────────────────────────────────────────────────────────

class ProState {
  const ProState({
    this.isPro = false,
    this.isInitialized = false,
    this.sosUsedToday = 0,
    this.libroUsedToday = 0,
    this.isLoading = false,
    this.purchaseError = '',
  });

  final bool   isPro;
  final bool   isInitialized;
  final int    sosUsedToday;
  final int    libroUsedToday;
  final bool   isLoading;
  final String purchaseError;

  static const int freeLimit = 3;

  /// While not yet initialized, optimistically allow (returns true).
  bool get canUseSos   => !isInitialized || isPro || sosUsedToday   < freeLimit;
  bool get canUseLibro => !isInitialized || isPro || libroUsedToday < freeLimit;

  /// -1 when Pro (unlimited); otherwise clamped remaining count.
  int get sosRemaining   => isPro ? -1 : (freeLimit - sosUsedToday).clamp(0, freeLimit);
  int get libroRemaining => isPro ? -1 : (freeLimit - libroUsedToday).clamp(0, freeLimit);

  ProState copyWith({
    bool?   isPro,
    bool?   isInitialized,
    int?    sosUsedToday,
    int?    libroUsedToday,
    bool?   isLoading,
    String? purchaseError,
  }) {
    return ProState(
      isPro:          isPro          ?? this.isPro,
      isInitialized:  isInitialized  ?? this.isInitialized,
      sosUsedToday:   sosUsedToday   ?? this.sosUsedToday,
      libroUsedToday: libroUsedToday ?? this.libroUsedToday,
      isLoading:      isLoading      ?? this.isLoading,
      purchaseError:  purchaseError  ?? this.purchaseError,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class ProNotifier extends StateNotifier<ProState> {
  ProNotifier(this._prefs) : super(const ProState()) {
    _init();
  }

  final SharedPreferences _prefs;

  Future<void> _init() async {
    final isPro = await RevenueCatService.checkIsPro(_prefs);
    final today = _today();

    final sosDate  = _prefs.getString(_kSosUsedDate);
    final sosCount = sosDate == today ? (_prefs.getInt(_kSosUsedCount) ?? 0) : 0;

    final libroDate  = _prefs.getString(_kLibroUsedDate);
    final libroCount = libroDate == today ? (_prefs.getInt(_kLibroUsedCount) ?? 0) : 0;

    state = state.copyWith(
      isPro:          isPro,
      isInitialized:  true,
      sosUsedToday:   sosCount,
      libroUsedToday: libroCount,
    );
  }

  /// Returns false (and does NOT increment) when limit reached.
  bool consumeSos() {
    if (state.isPro) return true;
    if (state.sosUsedToday >= ProState.freeLimit) return false;

    final newCount = state.sosUsedToday + 1;
    _prefs.setString(_kSosUsedDate, _today());
    _prefs.setInt(_kSosUsedCount, newCount);
    state = state.copyWith(sosUsedToday: newCount);
    return true;
  }

  /// Returns false (and does NOT increment) when limit reached.
  bool consumeLibro() {
    if (state.isPro) return true;
    if (state.libroUsedToday >= ProState.freeLimit) return false;

    final newCount = state.libroUsedToday + 1;
    _prefs.setString(_kLibroUsedDate, _today());
    _prefs.setInt(_kLibroUsedCount, newCount);
    state = state.copyWith(libroUsedToday: newCount);
    return true;
  }

  Future<void> purchasePro() async {
    state = state.copyWith(isLoading: true, purchaseError: '');

    if (RevenueCatService.isMockMode) {
      // Mock: just flip the flag in prefs.
      await _prefs.setBool(_kIsPro, true);
      state = state.copyWith(isPro: true, isLoading: false);
      return;
    }

    final success = await RevenueCatService.purchaseLifetime();
    if (success) {
      await _prefs.setBool(_kIsPro, true);
      state = state.copyWith(isPro: true, isLoading: false);
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> restorePurchases() async {
    state = state.copyWith(isLoading: true, purchaseError: '');

    final success = await RevenueCatService.restorePurchases();
    if (success) {
      await _prefs.setBool(_kIsPro, true);
      state = state.copyWith(isPro: true, isLoading: false);
    } else {
      state = state.copyWith(
        isLoading: false,
        purchaseError: 'No se pudieron restaurar las compras.',
      );
    }
  }

  static String _today() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final proProvider = StateNotifierProvider<ProNotifier, ProState>((ref) {
  return ProNotifier(ref.watch(sharedPreferencesProvider));
});

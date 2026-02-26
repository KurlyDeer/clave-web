import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';

/// Wraps RevenueCat purchase logic.
/// Currently runs in mock mode (sentinel API key) — all operations use
/// SharedPreferences so the app works on simulators without the SDK.
class RevenueCatService {
  RevenueCatService._();

  static bool get isMockMode => ApiConfig.rcApiKeyIos == 'REVENUECAT_IOS_KEY';

  static Future<void> initialize() async {
    // No-op in mock mode. Real SDK init goes here when a real key is provided.
  }

  /// Returns true if the user has an active 'pro' entitlement.
  static Future<bool> checkIsPro(SharedPreferences prefs) async {
    return prefs.getBool('is_pro') ?? false;
  }

  /// Purchases the lifetime Pro product.
  /// Returns true on success (mock always succeeds; caller writes to prefs).
  static Future<bool> purchaseLifetime() async {
    return true;
  }

  /// Restores previous purchases.
  /// Returns true if the 'pro' entitlement is now active.
  static Future<bool> restorePurchases() async {
    return false;
  }
}

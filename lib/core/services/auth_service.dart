import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Thin wrapper around [FirebaseAuth] for the Clave app.
///
/// Provides auth-state stream, anonymous sign-in, email auth, and sign-out.
/// All errors are caught, logged, and re-thrown so the UI can display them.
class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  // ── State ──────────────────────────────────────────────────────────────────

  /// The currently signed-in user, or null.
  User? get currentUser => _auth.currentUser;

  /// Stream that emits whenever the auth state changes (sign-in / sign-out).
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Anonymous ──────────────────────────────────────────────────────────────

  /// Signs in anonymously so the user can explore without creating an account.
  Future<UserCredential> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      debugPrint('[AuthService] signInAnonymously error: ${e.code}');
      rethrow;
    }
  }

  // ── Email / Password ───────────────────────────────────────────────────────

  /// Creates a new account with [email] and [password].
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('[AuthService] signUpWithEmail error: ${e.code}');
      rethrow;
    }
  }

  /// Signs in an existing user with [email] and [password].
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('[AuthService] signInWithEmail error: ${e.code}');
      rethrow;
    }
  }

  // ── Sign Out ───────────────────────────────────────────────────────────────

  /// Signs the current user out.
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      debugPrint('[AuthService] signOut error: ${e.code}');
      rethrow;
    }
  }
}

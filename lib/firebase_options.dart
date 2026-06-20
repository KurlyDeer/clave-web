// DEVELOPMENT STUB — replace with real config by running:
//   flutterfire configure
// and adding GoogleService-Info.plist to ios/Runner/

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions not configured for: $defaultTargetPlatform',
        );
    }
  }

  // Dev stub keys: 39-char format required by Firebase SDK validation.
  // These prevent the native ObjC format-check exception.
  // Network calls will fail silently — that is expected in dev without a real project.
  static const _devKey = 'AIzaSyDEV-STUB-KEY-PLACEHOLDER-00000001';

  static FirebaseOptions get web => FirebaseOptions(
    apiKey: dotenv.env['FIREBASE_API_KEY'] ?? '',
    appId: dotenv.env['FIREBASE_APP_ID'] ?? '',
    messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '',
    projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? '',
    authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? '',
    storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '',
    measurementId: dotenv.env['FIREBASE_MEASUREMENT_ID'] ?? '',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: _devKey,
    appId: '1:000000000001:ios:000000000000000000001',
    messagingSenderId: '000000000001',
    projectId: 'clave-app-2ed6e',
    iosBundleId: 'com.example.languageApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: _devKey,
    appId: '1:000000000001:ios:000000000000000000001',
    messagingSenderId: '000000000001',
    projectId: 'clave-app-2ed6e',
    iosBundleId: 'com.example.languageApp',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: _devKey,
    appId: '1:000000000001:android:000000000000000000001',
    messagingSenderId: '000000000001',
    projectId: 'clave-app-2ed6e',
  );
}
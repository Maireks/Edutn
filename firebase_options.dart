// ============================================================
// lib/firebase_options.dart
// هذا الملف يُنشأ تلقائياً بواسطة FlutterFire CLI
// لا تعدّله يدوياً
//
// لإنشائه، شغّل:
//   dart pub global activate flutterfire_cli
//   flutterfire configure
// ============================================================

// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ⚠️ استبدل هذه القيم بقيمك الحقيقية من Firebase Console
  // Project Settings → General → Your apps → SDK setup and configuration
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',           // ← استبدل
    appId: 'YOUR_ANDROID_APP_ID',             // ← استبدل
    messagingSenderId: 'YOUR_SENDER_ID',       // ← استبدل
    projectId: 'edtn-app',                     // ← اسم مشروعك
    storageBucket: 'edtn-app.appspot.com',     // ← استبدل
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',               // ← استبدل
    appId: 'YOUR_IOS_APP_ID',                 // ← استبدل
    messagingSenderId: 'YOUR_SENDER_ID',       // ← استبدل
    projectId: 'edtn-app',                     // ← اسم مشروعك
    storageBucket: 'edtn-app.appspot.com',     // ← استبدل
    iosClientId: 'YOUR_IOS_CLIENT_ID',        // ← استبدل
    iosBundleId: 'com.edtn.app',
  );
}

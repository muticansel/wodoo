// Bu dosyayı firebase_options.dart olarak kaydedin
// Firebase Console'dan aldığınız gerçek değerleri buraya yazın

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError('Windows platform not supported');
      case TargetPlatform.linux:
        throw UnsupportedError('Linux platform not supported');
      default:
        throw UnsupportedError('Platform not supported');
    }
  }

  // Firebase Console'dan aldığınız web konfigürasyonunu buraya yazın
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'BURAYA_FIREBASE_API_KEY_YAZIN',
    appId: 'BURAYA_FIREBASE_APP_ID_YAZIN',
    messagingSenderId: 'BURAYA_MESSAGING_SENDER_ID_YAZIN',
    projectId: 'BURAYA_PROJECT_ID_YAZIN',
    authDomain: 'BURAYA_AUTH_DOMAIN_YAZIN',
    storageBucket: 'BURAYA_STORAGE_BUCKET_YAZIN',
  );

  // Android için (şimdilik aynı değerleri kullanabilirsiniz)
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'BURAYA_FIREBASE_API_KEY_YAZIN',
    appId: 'BURAYA_FIREBASE_APP_ID_YAZIN',
    messagingSenderId: 'BURAYA_MESSAGING_SENDER_ID_YAZIN',
    projectId: 'BURAYA_PROJECT_ID_YAZIN',
    storageBucket: 'BURAYA_STORAGE_BUCKET_YAZIN',
  );

  // iOS için (şimdilik aynı değerleri kullanabilirsiniz)
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'BURAYA_FIREBASE_API_KEY_YAZIN',
    appId: 'BURAYA_FIREBASE_APP_ID_YAZIN',
    messagingSenderId: 'BURAYA_MESSAGING_SENDER_ID_YAZIN',
    projectId: 'BURAYA_PROJECT_ID_YAZIN',
    storageBucket: 'BURAYA_STORAGE_BUCKET_YAZIN',
    iosBundleId: 'com.wodoo.crossfit',
  );

  // macOS için (şimdilik aynı değerleri kullanabilirsiniz)
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'BURAYA_FIREBASE_API_KEY_YAZIN',
    appId: 'BURAYA_FIREBASE_APP_ID_YAZIN',
    messagingSenderId: 'BURAYA_MESSAGING_SENDER_ID_YAZIN',
    projectId: 'BURAYA_PROJECT_ID_YAZIN',
    storageBucket: 'BURAYA_STORAGE_BUCKET_YAZIN',
    iosBundleId: 'com.wodoo.crossfit',
  );
}


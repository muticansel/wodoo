# Deployment Rehberi

## Genel Bakış

Bu rehber, CrossFit antrenman uygulamasının production ortamına deploy edilmesi için gerekli tüm adımları içerir. Flutter frontend, Firebase backend ve external servislerin deployment süreçleri detaylandırılmıştır.

## 1. Firebase Projesi Kurulumu

### 1.1 Firebase Projesi Oluşturma

```bash
# Firebase CLI kurulumu
npm install -g firebase-tools

# Firebase'e giriş yap
firebase login

# Yeni proje oluştur
firebase projects:create crossfit-app-2024

# Proje seç
firebase use crossfit-app-2024

# Firebase servislerini başlat
firebase init
```

### 1.2 Firebase Servisleri Yapılandırması

```bash
# Firestore veritabanı
firebase init firestore

# Cloud Functions
firebase init functions

# Cloud Storage
firebase init storage

# Hosting (admin panel için)
firebase init hosting

# Analytics
firebase init analytics
```

### 1.3 Firebase Güvenlik Kuralları

```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Kullanıcılar sadece kendi verilerine erişebilir
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Programlar sadece abonelik sahibi kullanıcılar görebilir
    match /programs/{programId} {
      allow read: if request.auth != null && 
        exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.subscription.isActive == true;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Kullanıcı antrenmanları sadece sahibi görebilir
    match /user_workouts/{workoutId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // Abonelik bilgileri sadece sahibi görebilir
    match /subscriptions/{subscriptionId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // Bildirimler sadece sahibi görebilir
    match /notifications/{notificationId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
  }
}
```

```javascript
// storage.rules
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Kullanıcı profil fotoğrafları
    match /users/{userId}/profile/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Program görselleri (herkes okuyabilir)
    match /programs/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

## 2. Cloud Functions Deployment

### 2.1 Functions Yapılandırması

```javascript
// functions/package.json
{
  "name": "crossfit-functions",
  "version": "1.0.0",
  "description": "CrossFit app Cloud Functions",
  "main": "index.js",
  "scripts": {
    "serve": "firebase emulators:start --only functions",
    "shell": "firebase functions:shell",
    "start": "npm run shell",
    "deploy": "firebase deploy --only functions",
    "logs": "firebase functions:log"
  },
  "dependencies": {
    "firebase-admin": "^12.0.0",
    "firebase-functions": "^4.5.0",
    "iyizico": "^1.0.0",
    "crypto": "^1.0.1"
  },
  "engines": {
    "node": "18"
  }
}
```

### 2.2 Functions Deployment

```bash
# Functions'ı deploy et
firebase deploy --only functions

# Belirli function'ı deploy et
firebase deploy --only functions:sendNewProgramNotification

# Functions loglarını görüntüle
firebase functions:log

# Functions'ı test et
firebase emulators:start --only functions
```

### 2.3 Environment Variables

```bash
# Firebase Functions environment variables
firebase functions:config:set iyizico.api_key="your_api_key"
firebase functions:config:set iyizico.secret_key="your_secret_key"
firebase functions:config:set iyizico.webhook_secret="your_webhook_secret"
firebase functions:config:set app.notification_key="your_notification_key"

# Deploy with new config
firebase deploy --only functions
```

## 3. Flutter App Deployment

### 3.1 Android Deployment

#### 3.1.1 Release Build Hazırlığı

```bash
# Flutter clean
flutter clean

# Dependencies güncelle
flutter pub get

# Build runner çalıştır
flutter packages pub run build_runner build

# Test çalıştır
flutter test

# Integration test çalıştır
flutter test integration_test/
```

#### 3.1.2 Android Signing

```bash
# Keystore oluştur
keytool -genkey -v -keystore crossfit-release-key.keystore -alias crossfit -keyalg RSA -keysize 2048 -validity 10000

# key.properties dosyası oluştur
echo "storePassword=your_store_password
keyPassword=your_key_password
keyAlias=crossfit
storeFile=crossfit-release-key.keystore" > android/key.properties
```

#### 3.1.3 Android Build Configuration

```gradle
// android/app/build.gradle
android {
    compileSdkVersion 34
    ndkVersion "25.1.8937393"

    defaultConfig {
        applicationId "com.crossfit.app"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

#### 3.1.4 Android Build

```bash
# APK build
flutter build apk --release

# App Bundle build (Play Store için)
flutter build appbundle --release

# Split APKs (boyut optimizasyonu)
flutter build apk --split-per-abi --release
```

#### 3.1.5 Play Store Deployment

```bash
# Google Play Console'a upload
# 1. Play Console'a giriş yap
# 2. Uygulama oluştur
# 3. App Bundle'ı upload et
# 4. Store listing bilgilerini doldur
# 5. Content rating al
# 6. Pricing & distribution ayarla
# 7. Release to production
```

### 3.2 iOS Deployment

#### 3.2.1 iOS Build Hazırlığı

```bash
# iOS dependencies
cd ios && pod install && cd ..

# iOS build
flutter build ios --release
```

#### 3.2.2 Xcode Yapılandırması

```swift
// ios/Runner/Info.plist
<key>CFBundleDisplayName</key>
<string>CrossFit</string>
<key>CFBundleIdentifier</key>
<string>com.crossfit.app</string>
<key>CFBundleVersion</key>
<string>1.0.0</string>
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>

// Push notifications için
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>
```

#### 3.2.3 iOS Archive

```bash
# Xcode'da archive oluştur
# 1. Xcode'u aç
# 2. Product > Archive
# 3. Organizer'da archive'ı seç
# 4. Distribute App
# 5. App Store Connect'e upload
```

#### 3.2.4 App Store Deployment

```bash
# App Store Connect'e upload
# 1. App Store Connect'e giriş yap
# 2. Uygulama oluştur
# 3. Build'i seç
# 4. Store listing bilgilerini doldur
# 5. Review için submit et
```

## 4. Environment Configuration

### 4.1 Development Environment

```dart
// lib/config/environment.dart
class Environment {
  static const String _environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
  
  static bool get isDevelopment => _environment == 'development';
  static bool get isStaging => _environment == 'staging';
  static bool get isProduction => _environment == 'production';
  
  static String get firebaseProjectId {
    switch (_environment) {
      case 'development':
        return 'crossfit-app-dev';
      case 'staging':
        return 'crossfit-app-staging';
      case 'production':
        return 'crossfit-app-2024';
      default:
        return 'crossfit-app-dev';
    }
  }
  
  static String get apiBaseUrl {
    switch (_environment) {
      case 'development':
        return 'https://dev-api.crossfit.com';
      case 'staging':
        return 'https://staging-api.crossfit.com';
      case 'production':
        return 'https://api.crossfit.com';
      default:
        return 'https://dev-api.crossfit.com';
    }
  }
}
```

### 4.2 Build Scripts

```bash
#!/bin/bash
# scripts/build.sh

# Environment check
if [ -z "$1" ]; then
    echo "Usage: ./build.sh [development|staging|production]"
    exit 1
fi

ENVIRONMENT=$1

# Clean
flutter clean
flutter pub get

# Build runner
flutter packages pub run build_runner build --delete-conflicting-outputs

# Tests
flutter test

# Build based on environment
case $ENVIRONMENT in
    "development")
        flutter build apk --debug --dart-define=ENVIRONMENT=development
        ;;
    "staging")
        flutter build apk --release --dart-define=ENVIRONMENT=staging
        ;;
    "production")
        flutter build appbundle --release --dart-define=ENVIRONMENT=production
        ;;
    *)
        echo "Invalid environment: $ENVIRONMENT"
        exit 1
        ;;
esac

echo "Build completed for $ENVIRONMENT"
```

## 5. CI/CD Pipeline

### 5.1 GitHub Actions Workflow

```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
        channel: 'stable'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Run tests
      run: flutter test --coverage
    
    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        file: coverage/lcov.info

  build-android:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
        channel: 'stable'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Build APK
      run: flutter build apk --release
    
    - name: Build App Bundle
      run: flutter build appbundle --release
    
    - name: Upload APK
      uses: actions/upload-artifact@v3
      with:
        name: app-release.apk
        path: build/app/outputs/flutter-apk/app-release.apk
    
    - name: Upload App Bundle
      uses: actions/upload-artifact@v3
      with:
        name: app-release.aab
        path: build/app/outputs/bundle/release/app-release.aab

  build-ios:
    needs: test
    runs-on: macos-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
        channel: 'stable'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Build iOS
      run: flutter build ios --release --no-codesign
    
    - name: Upload iOS build
      uses: actions/upload-artifact@v3
      with:
        name: ios-build
        path: build/ios/iphoneos/Runner.app

  deploy-firebase:
    needs: [test, build-android, build-ios]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
    
    - name: Install Firebase CLI
      run: npm install -g firebase-tools
    
    - name: Deploy Firebase
      run: |
        firebase deploy --only functions,firestore:rules,storage:rules
      env:
        FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}
```

### 5.2 Firebase Functions CI/CD

```yaml
# .github/workflows/functions-deploy.yml
name: Deploy Functions

on:
  push:
    paths:
      - 'functions/**'
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
    
    - name: Install dependencies
      run: |
        cd functions
        npm install
    
    - name: Run tests
      run: |
        cd functions
        npm test
    
    - name: Deploy Functions
      run: |
        firebase deploy --only functions
      env:
        FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}
```

## 6. Monitoring ve Logging

### 6.1 Firebase Analytics

```dart
// lib/core/analytics/analytics_service.dart
class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  static Future<void> logEvent(String name, Map<String, dynamic> parameters) async {
    await _analytics.logEvent(
      name: name,
      parameters: parameters,
    );
  }
  
  static Future<void> setUserProperty(String name, String value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }
  
  static Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }
}
```

### 6.2 Crashlytics

```dart
// lib/main.dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Crashlytics'i başlat
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
      builder: (context, child) {
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          FirebaseCrashlytics.instance.recordError(
            errorDetails.exception,
            errorDetails.stack,
          );
          return ErrorWidget(errorDetails.exception);
        };
        return child!;
      },
    );
  }
}
```

### 6.3 Performance Monitoring

```dart
// lib/core/performance/performance_service.dart
class PerformanceService {
  static final FirebasePerformance _performance = FirebasePerformance.instance;
  
  static Trace startTrace(String name) {
    return _performance.newTrace(name);
  }
  
  static Future<void> logNetworkRequest(String url, int responseCode, int responseTime) async {
    final trace = _performance.newTrace('network_request');
    await trace.start();
    trace.putAttribute('url', url);
    trace.putAttribute('response_code', responseCode.toString());
    trace.putMetric('response_time', responseTime);
    await trace.stop();
  }
}
```

## 7. Security Configuration

### 7.1 API Security

```dart
// lib/core/network/api_client.dart
class ApiClient {
  static const String _baseUrl = 'https://api.crossfit.com';
  static const String _apiKey = 'your_api_key';
  
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_apiKey',
    'X-API-Version': '1.0',
  };
  
  static Future<http.Response> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$_baseUrl$endpoint'),
      headers: _headers,
    );
    
    if (response.statusCode == 401) {
      // Token expired, refresh
      await _refreshToken();
      return await http.get(
        Uri.parse('$_baseUrl$endpoint'),
        headers: _headers,
      );
    }
    
    return response;
  }
}
```

### 7.2 Data Encryption

```dart
// lib/core/security/encryption_service.dart
class EncryptionService {
  static const String _key = 'your_encryption_key';
  
  static String encrypt(String plainText) {
    final key = Key.fromBase64(_key);
    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encrypt(plainText, iv: IV.fromLength(16));
    return encrypted.base64;
  }
  
  static String decrypt(String encryptedText) {
    final key = Key.fromBase64(_key);
    final encrypter = Encrypter(AES(key));
    final encrypted = Encrypted.fromBase64(encryptedText);
    return encrypter.decrypt(encrypted, iv: IV.fromLength(16));
  }
}
```

## 8. Rollback Strategy

### 8.1 App Rollback

```bash
# Android rollback
# 1. Play Console'da önceki versiyonu seç
# 2. Release to production
# 3. Kullanıcılara bildirim gönder

# iOS rollback
# 1. App Store Connect'te önceki versiyonu seç
# 2. Release to App Store
# 3. Kullanıcılara bildirim gönder
```

### 8.2 Firebase Rollback

```bash
# Functions rollback
firebase functions:rollback

# Firestore rules rollback
firebase firestore:rules:rollback

# Storage rules rollback
firebase storage:rules:rollback
```

## 9. Post-Deployment Checklist

### 9.1 Functionality Tests

- [ ] Authentication çalışıyor
- [ ] Program listesi yükleniyor
- [ ] Antrenman detayları görüntüleniyor
- [ ] Abonelik satın alma çalışıyor
- [ ] Bildirimler geliyor
- [ ] Profil ayarları çalışıyor

### 9.2 Performance Tests

- [ ] App launch time < 3 saniye
- [ ] Screen transition < 300ms
- [ ] API response time < 2 saniye
- [ ] Memory usage < 100MB
- [ ] Battery usage normal

### 9.3 Security Tests

- [ ] HTTPS kullanılıyor
- [ ] API key'ler güvenli
- [ ] User data şifreleniyor
- [ ] Firestore rules çalışıyor
- [ ] Authentication güvenli

### 9.4 Monitoring Setup

- [ ] Analytics aktif
- [ ] Crashlytics aktif
- [ ] Performance monitoring aktif
- [ ] Error logging çalışıyor
- [ ] Alert'ler yapılandırıldı

Bu deployment rehberi, CrossFit antrenman uygulamasının production ortamına güvenli ve etkili bir şekilde deploy edilmesi için gerekli tüm adımları içerir. Her adım detaylı olarak açıklanmış ve örneklerle desteklenmiştir.

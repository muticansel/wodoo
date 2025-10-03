# Geliştirme Rehberi

## Proje Kurulumu

### 1. Gereksinimler

#### Flutter Geliştirme Ortamı
```bash
# Flutter SDK (3.16.0 veya üzeri)
flutter --version

# Dart SDK (3.2.0 veya üzeri)
dart --version

# Android Studio / VS Code
# Android SDK (API 21+)
# iOS SDK (iOS 12.0+)
```

#### Firebase Kurulumu
```bash
# Firebase CLI
npm install -g firebase-tools

# FlutterFire CLI
dart pub global activate flutterfire_cli
```

### 2. Proje Oluşturma

```bash
# Flutter projesi oluştur
flutter create crossfit_app
cd crossfit_app

# Firebase projesi oluştur
firebase init

# FlutterFire yapılandırması
flutterfire configure
```

### 3. Bağımlılıklar

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  firebase_storage: ^11.5.6
  firebase_messaging: ^14.7.10
  firebase_analytics: ^10.7.4
  
  # State Management
  provider: ^6.1.1
  riverpod: ^2.4.9
  
  # UI/UX
  material_design_icons_flutter: ^7.0.7296
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0
  
  # Networking
  http: ^1.1.2
  dio: ^5.4.0
  
  # Local Storage
  shared_preferences: ^2.2.2
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # Notifications
  flutter_local_notifications: ^16.3.2
  
  # Payment
  iyizico_flutter: ^1.0.0
  
  # Utilities
  uuid: ^4.2.1
  intl: ^0.19.0
  path_provider: ^2.1.1
  image_picker: ^1.0.4
  
  # Development
  flutter_dotenv: ^5.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  mockito: ^5.4.4
  build_runner: ^2.4.7
  hive_generator: ^2.0.1
  json_annotation: ^4.8.1
  json_serializable: ^6.7.1
```

## Proje Yapısı

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── routes.dart
│   └── theme.dart
├── core/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   ├── utils/
│   └── widgets/
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   ├── presentation/
│   │   └── auth.dart
│   ├── subscription/
│   │   ├── data/
│   │   ├── domain/
│   │   ├── presentation/
│   │   └── subscription.dart
│   ├── programs/
│   │   ├── data/
│   │   ├── domain/
│   │   ├── presentation/
│   │   └── programs.dart
│   ├── workouts/
│   │   ├── data/
│   │   ├── domain/
│   │   ├── presentation/
│   │   └── workouts.dart
│   └── notifications/
│       ├── data/
│       ├── domain/
│       ├── presentation/
│       └── notifications.dart
├── shared/
│   ├── data/
│   ├── domain/
│   └── presentation/
└── test/
    ├── unit/
    ├── widget/
    └── integration/
```

## Clean Architecture Uygulaması

### 1. Domain Layer

```dart
// lib/features/auth/domain/entities/user.dart
class User {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  final Subscription? subscription;
  final UserPreferences preferences;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  
  const User({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    this.subscription,
    required this.preferences,
    required this.createdAt,
    required this.lastLoginAt,
  });
}

// lib/features/auth/domain/repositories/auth_repository.dart
abstract class AuthRepository {
  Future<User?> getCurrentUser();
  Future<User> signInWithGoogle();
  Future<User> signInWithEmail(String email, String password);
  Future<User> signUpWithEmail(String email, String password);
  Future<void> signOut();
  Stream<User?> get authStateChanges;
}

// lib/features/auth/domain/usecases/sign_in_with_google.dart
class SignInWithGoogle {
  final AuthRepository repository;
  
  SignInWithGoogle(this.repository);
  
  Future<Either<Failure, User>> call() async {
    try {
      final user = await repository.signInWithGoogle();
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
```

### 2. Data Layer

```dart
// lib/features/auth/data/datasources/auth_remote_datasource.dart
abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithGoogle();
  Future<UserModel> signInWithEmail(String email, String password);
  Future<UserModel> signUpWithEmail(String email, String password);
  Future<void> signOut();
  Stream<UserModel?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  
  AuthRemoteDataSourceImpl({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
  }) : _firebaseAuth = firebaseAuth,
       _googleSignIn = googleSignIn;
  
  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw ServerException('Google sign in cancelled');
      }
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;
      
      if (firebaseUser == null) {
        throw ServerException('Firebase user is null');
      }
      
      return UserModel.fromFirebaseUser(firebaseUser);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
  
  // Diğer metodlar...
}

// lib/features/auth/data/repositories/auth_repository_impl.dart
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });
  
  @override
  Future<User?> getCurrentUser() async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = await remoteDataSource.getCurrentUser();
        await localDataSource.cacheUser(userModel);
        return userModel.toEntity();
      } catch (e) {
        final cachedUser = await localDataSource.getCachedUser();
        return cachedUser?.toEntity();
      }
    } else {
      final cachedUser = await localDataSource.getCachedUser();
      return cachedUser?.toEntity();
    }
  }
  
  // Diğer metodlar...
}
```

### 3. Presentation Layer

```dart
// lib/features/auth/presentation/providers/auth_provider.dart
class AuthProvider extends StateNotifier<AuthState> {
  final SignInWithGoogle _signInWithGoogle;
  final SignInWithEmail _signInWithEmail;
  final SignUpWithEmail _signUpWithEmail;
  final SignOut _signOut;
  final GetCurrentUser _getCurrentUser;
  
  AuthProvider({
    required SignInWithGoogle signInWithGoogle,
    required SignInWithEmail signInWithEmail,
    required SignUpWithEmail signUpWithEmail,
    required SignOut signOut,
    required GetCurrentUser getCurrentUser,
  }) : _signInWithGoogle = signInWithGoogle,
       _signInWithEmail = signInWithEmail,
       _signUpWithEmail = signUpWithEmail,
       _signOut = signOut,
       _getCurrentUser = getCurrentUser,
       super(AuthInitial());
  
  Future<void> signInWithGoogle() async {
    state = AuthLoading();
    
    final result = await _signInWithGoogle();
    result.fold(
      (failure) => state = AuthError(failure.message),
      (user) => state = AuthAuthenticated(user),
    );
  }
  
  Future<void> signInWithEmail(String email, String password) async {
    state = AuthLoading();
    
    final result = await _signInWithEmail(Params(email: email, password: password));
    result.fold(
      (failure) => state = AuthError(failure.message),
      (user) => state = AuthAuthenticated(user),
    );
  }
  
  // Diğer metodlar...
}

// lib/features/auth/presentation/screens/login_screen.dart
class LoginScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    
    return Scaffold(
      appBar: AppBar(title: Text('Giriş Yap')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Icon(Icons.fitness_center, size: 100, color: Colors.blue),
            SizedBox(height: 32),
            
            // Google ile giriş
            ElevatedButton.icon(
              onPressed: () => ref.read(authProvider.notifier).signInWithGoogle(),
              icon: Icon(Icons.login),
              label: Text('Google ile Giriş Yap'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            
            SizedBox(height: 16),
            
            // E-posta ile giriş
            ElevatedButton.icon(
              onPressed: () => _showEmailLoginDialog(context, ref),
              icon: Icon(Icons.email),
              label: Text('E-posta ile Giriş Yap'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Misafir giriş
            TextButton(
              onPressed: () => _signInAnonymously(context, ref),
              child: Text('Misafir olarak devam et'),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showEmailLoginDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => EmailLoginDialog(),
    );
  }
  
  void _signInAnonymously(BuildContext context, WidgetRef ref) {
    // Anonim giriş implementasyonu
  }
}
```

## State Management (Riverpod)

### 1. Provider Tanımları

```dart
// lib/core/providers/providers.dart
final authProvider = StateNotifierProvider<AuthProvider, AuthState>((ref) {
  return AuthProvider(
    signInWithGoogle: ref.watch(signInWithGoogleProvider),
    signInWithEmail: ref.watch(signInWithEmailProvider),
    signUpWithEmail: ref.watch(signUpWithEmailProvider),
    signOut: ref.watch(signOutProvider),
    getCurrentUser: ref.watch(getCurrentUserProvider),
  );
});

final subscriptionProvider = StateNotifierProvider<SubscriptionProvider, SubscriptionState>((ref) {
  return SubscriptionProvider(
    getSubscriptionStatus: ref.watch(getSubscriptionStatusProvider),
    purchaseSubscription: ref.watch(purchaseSubscriptionProvider),
    cancelSubscription: ref.watch(cancelSubscriptionProvider),
  );
});

final programsProvider = StateNotifierProvider<ProgramsProvider, ProgramsState>((ref) {
  return ProgramsProvider(
    getPrograms: ref.watch(getProgramsProvider),
    getProgramById: ref.watch(getProgramByIdProvider),
  );
});
```

### 2. Dependency Injection

```dart
// lib/core/di/injection_container.dart
final sl = GetIt.instance;

Future<void> init() async {
  // External
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);
  sl.registerLazySingleton(() => FirebaseMessaging.instance);
  sl.registerLazySingleton(() => GoogleSignIn());
  
  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton<AuthLocalDataSource>(() => AuthLocalDataSourceImpl(sl()));
  
  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(
    firebaseAuth: sl(),
    googleSignIn: sl(),
  ));
  
  // Repository
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
    remoteDataSource: sl(),
    localDataSource: sl(),
    networkInfo: sl(),
  ));
  
  // Use cases
  sl.registerLazySingleton(() => SignInWithGoogle(sl()));
  sl.registerLazySingleton(() => SignInWithEmail(sl()));
  sl.registerLazySingleton(() => SignUpWithEmail(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  
  // Providers
  sl.registerFactory(() => AuthProvider(
    signInWithGoogle: sl(),
    signInWithEmail: sl(),
    signUpWithEmail: sl(),
    signOut: sl(),
    getCurrentUser: sl(),
  ));
}
```

## Firebase Yapılandırması

### 1. Firebase Projesi Oluşturma

```bash
# Firebase projesi oluştur
firebase projects:create crossfit-app-2024

# Firebase servislerini etkinleştir
firebase init firestore
firebase init functions
firebase init hosting
firebase init storage
```

### 2. Firestore Güvenlik Kuralları

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

### 3. Cloud Functions

```javascript
// functions/index.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

// Yeni program bildirimi
exports.sendNewProgramNotification = functions.firestore
  .document('programs/{programId}')
  .onCreate(async (snap, context) => {
    const program = snap.data();
    
    if (!program.isPublished) return;
    
    // Aktif abonelik sahibi kullanıcıları al
    const usersSnapshot = await admin.firestore()
      .collection('users')
      .where('subscription.isActive', '==', true)
      .where('preferences.notifications.newProgram', '==', true)
      .get();
    
    const tokens = [];
    usersSnapshot.forEach(doc => {
      if (doc.data().fcmToken) {
        tokens.push(doc.data().fcmToken);
      }
    });
    
    if (tokens.length === 0) return;
    
    const message = {
      notification: {
        title: 'Yeni Program Yüklendi! 🏋️‍♂️',
        body: `${program.title} programı hazır. Hemen başla!`
      },
      data: {
        type: 'new_program',
        programId: context.params.programId,
      },
      tokens: tokens
    };
    
    const response = await admin.messaging().sendMulticast(message);
    console.log(`Bildirim gönderildi: ${response.successCount} başarılı`);
  });

// Ödeme webhook'u
exports.handlePaymentWebhook = functions.https.onRequest(async (req, res) => {
  try {
    const { paymentId, status, amount, userId } = req.body;
    
    if (status === 'success') {
      await processSuccessfulPayment({ paymentId, amount, userId });
    } else {
      await processFailedPayment({ paymentId, userId, reason: status });
    }
    
    res.status(200).send('OK');
  } catch (error) {
    console.error('Webhook error:', error);
    res.status(500).send('Error');
  }
});
```

## Test Stratejisi

### 1. Unit Testler

```dart
// test/features/auth/domain/usecases/sign_in_with_google_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignInWithGoogle usecase;
  late MockAuthRepository mockRepository;
  
  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = SignInWithGoogle(mockRepository);
  });
  
  group('SignInWithGoogle', () {
    const tUser = User(
      uid: '123',
      email: 'test@example.com',
      displayName: 'Test User',
      preferences: UserPreferences.defaultPreferences(),
      createdAt: DateTime(2024, 1, 1),
      lastLoginAt: DateTime(2024, 1, 1),
    );
    
    test('should return User when sign in is successful', () async {
      // arrange
      when(mockRepository.signInWithGoogle()).thenAnswer((_) async => tUser);
      
      // act
      final result = await usecase();
      
      // assert
      expect(result, Right(tUser));
      verify(mockRepository.signInWithGoogle());
      verifyNoMoreInteractions(mockRepository);
    });
    
    test('should return Failure when sign in fails', () async {
      // arrange
      when(mockRepository.signInWithGoogle()).thenThrow(ServerException('Server error'));
      
      // act
      final result = await usecase();
      
      // assert
      expect(result, Left(ServerFailure('Server error')));
      verify(mockRepository.signInWithGoogle());
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
```

### 2. Widget Testler

```dart
// test/features/auth/presentation/screens/login_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('LoginScreen', () {
    testWidgets('should display login buttons', (WidgetTester tester) async {
      // arrange
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      
      // act
      await tester.pumpAndSettle();
      
      // assert
      expect(find.text('Google ile Giriş Yap'), findsOneWidget);
      expect(find.text('E-posta ile Giriş Yap'), findsOneWidget);
      expect(find.text('Misafir olarak devam et'), findsOneWidget);
    });
    
    testWidgets('should show email login dialog when email button is tapped', (WidgetTester tester) async {
      // arrange
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      
      // act
      await tester.tap(find.text('E-posta ile Giriş Yap'));
      await tester.pumpAndSettle();
      
      // assert
      expect(find.byType(EmailLoginDialog), findsOneWidget);
    });
  });
}
```

### 3. Integration Testler

```dart
// integration_test/app_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('App Integration Tests', () {
    testWidgets('complete user journey', (WidgetTester tester) async {
      // Uygulamayı başlat
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();
      
      // Giriş yap
      await tester.tap(find.text('Google ile Giriş Yap'));
      await tester.pumpAndSettle();
      
      // Ana sayfaya yönlendirildiğini kontrol et
      expect(find.text('Haftalık Programlar'), findsOneWidget);
      
      // Program seç
      await tester.tap(find.byKey(Key('program_1')));
      await tester.pumpAndSettle();
      
      // Program detay sayfasında olduğunu kontrol et
      expect(find.text('Antrenman Detayları'), findsOneWidget);
    });
  });
}
```

## Performans Optimizasyonu

### 1. Lazy Loading

```dart
// lib/features/programs/presentation/widgets/program_list.dart
class ProgramList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      itemCount: 1000, // Büyük liste
      itemBuilder: (context, index) {
        return ProgramCard(
          programId: 'program_$index',
          onTap: () => _navigateToProgram(context, 'program_$index'),
        );
      },
    );
  }
}

class ProgramCard extends ConsumerWidget {
  final String programId;
  final VoidCallback onTap;
  
  const ProgramCard({
    Key? key,
    required this.programId,
    required this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sadece görünür olan kartlar için veri yükle
    return FutureBuilder<Program>(
      future: ref.watch(getProgramByIdProvider(programId).future),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Card(
            child: ListTile(
              title: Text(snapshot.data!.title),
              subtitle: Text(snapshot.data!.description),
              onTap: onTap,
            ),
          );
        }
        return Card(
          child: ListTile(
            title: Text('Yükleniyor...'),
          ),
        );
      },
    );
  }
}
```

### 2. Image Caching

```dart
// lib/core/widgets/cached_image.dart
class CachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  
  const CachedImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => Container(
        color: Colors.grey[300],
        child: Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[300],
        child: Icon(Icons.error),
      ),
    );
  }
}
```

### 3. Offline Support

```dart
// lib/core/network/network_info.dart
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final InternetConnectionChecker connectionChecker;
  
  NetworkInfoImpl(this.connectionChecker);
  
  @override
  Future<bool> get isConnected => connectionChecker.hasConnection;
}

// lib/features/programs/data/repositories/programs_repository_impl.dart
class ProgramsRepositoryImpl implements ProgramsRepository {
  final ProgramsRemoteDataSource remoteDataSource;
  final ProgramsLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  
  ProgramsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });
  
  @override
  Future<List<Program>> getPrograms() async {
    if (await networkInfo.isConnected) {
      try {
        final programs = await remoteDataSource.getPrograms();
        await localDataSource.cachePrograms(programs);
        return programs.map((model) => model.toEntity()).toList();
      } catch (e) {
        final cachedPrograms = await localDataSource.getCachedPrograms();
        return cachedPrograms.map((model) => model.toEntity()).toList();
      }
    } else {
      final cachedPrograms = await localDataSource.getCachedPrograms();
      return cachedPrograms.map((model) => model.toEntity()).toList();
    }
  }
}
```

## Deployment

### 1. Android Build

```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release

# App bundle (Play Store için)
flutter build appbundle --release
```

### 2. iOS Build

```bash
# Debug build
flutter build ios --debug

# Release build
flutter build ios --release

# Archive (App Store için)
flutter build ipa --release
```

### 3. Firebase Deploy

```bash
# Cloud Functions deploy
firebase deploy --only functions

# Firestore rules deploy
firebase deploy --only firestore:rules

# Storage rules deploy
firebase deploy --only storage
```

## Monitoring ve Analytics

### 1. Crashlytics

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

### 2. Performance Monitoring

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

// Kullanım
AnalyticsService.logEvent('program_viewed', {
  'program_id': programId,
  'program_title': programTitle,
});

AnalyticsService.setUserProperty('subscription_plan', 'monthly');
```

Bu geliştirme rehberi, CrossFit antrenman uygulamasının tüm teknik yönlerini kapsamlı bir şekilde açıklamaktadır. Clean Architecture prensiplerine uygun olarak geliştirilmiş, test edilebilir ve ölçeklenebilir bir kod yapısı sağlar.

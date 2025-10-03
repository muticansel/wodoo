# Test Stratejisi ve Test Planı

## Test Yaklaşımı

CrossFit antrenman uygulaması için kapsamlı bir test stratejisi geliştirilmiştir. Bu strateji, Clean Architecture prensiplerine uygun olarak her katman için ayrı test türleri içerir.

## Test Piramidi

```
        /\
       /  \
      / E2E \     ← End-to-End Tests (Az sayıda, kritik akışlar)
     /______\
    /        \
   / Widget   \   ← Widget Tests (Orta sayıda, UI bileşenleri)
  /____________\
 /              \
/ Unit Tests     \  ← Unit Tests (Çok sayıda, business logic)
/________________\
```

## 1. Unit Tests

### Test Kapsamı
- **Domain Layer:** Use cases, entities, repositories interfaces
- **Data Layer:** Repository implementations, data sources
- **Business Logic:** Utility functions, validation logic
- **Models:** Data models, serialization/deserialization

### Test Örnekleri

#### Domain Layer Tests

```dart
// test/features/auth/domain/usecases/sign_in_with_google_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';

import 'package:crossfit_app/features/auth/domain/entities/user.dart';
import 'package:crossfit_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:crossfit_app/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:crossfit_app/core/error/failures.dart';

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
    
    test('should return ServerFailure when sign in fails', () async {
      // arrange
      when(mockRepository.signInWithGoogle()).thenThrow(ServerException('Server error'));
      
      // act
      final result = await usecase();
      
      // assert
      expect(result, Left(ServerFailure('Server error')));
      verify(mockRepository.signInWithGoogle());
      verifyNoMoreInteractions(mockRepository);
    });
    
    test('should return NetworkFailure when no internet connection', () async {
      // arrange
      when(mockRepository.signInWithGoogle()).thenThrow(NetworkException('No internet'));
      
      // act
      final result = await usecase();
      
      // assert
      expect(result, Left(NetworkFailure('No internet')));
      verify(mockRepository.signInWithGoogle());
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
```

#### Data Layer Tests

```dart
// test/features/auth/data/repositories/auth_repository_impl_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';

import 'package:crossfit_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:crossfit_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:crossfit_app/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:crossfit_app/core/network/network_info.dart';
import 'package:crossfit_app/core/error/failures.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}
class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}
class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;
  
  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });
  
  group('getCurrentUser', () {
    const tUserModel = UserModel(
      uid: '123',
      email: 'test@example.com',
      displayName: 'Test User',
      preferences: UserPreferencesModel.defaultPreferences(),
      createdAt: DateTime(2024, 1, 1),
      lastLoginAt: DateTime(2024, 1, 1),
    );
    
    test('should return User when network is available and remote call succeeds', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.getCurrentUser()).thenAnswer((_) async => tUserModel);
      when(mockLocalDataSource.cacheUser(any)).thenAnswer((_) async => {});
      
      // act
      final result = await repository.getCurrentUser();
      
      // assert
      expect(result, tUserModel.toEntity());
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.getCurrentUser());
      verify(mockLocalDataSource.cacheUser(tUserModel));
      verifyNoMoreInteractions(mockRemoteDataSource);
      verifyNoMoreInteractions(mockLocalDataSource);
    });
    
    test('should return cached User when network is not available', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(mockLocalDataSource.getCachedUser()).thenAnswer((_) async => tUserModel);
      
      // act
      final result = await repository.getCurrentUser();
      
      // assert
      expect(result, tUserModel.toEntity());
      verify(mockNetworkInfo.isConnected);
      verify(mockLocalDataSource.getCachedUser());
      verifyNoMoreInteractions(mockRemoteDataSource);
      verifyNoMoreInteractions(mockLocalDataSource);
    });
    
    test('should return cached User when remote call fails', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.getCurrentUser()).thenThrow(ServerException('Server error'));
      when(mockLocalDataSource.getCachedUser()).thenAnswer((_) async => tUserModel);
      
      // act
      final result = await repository.getCurrentUser();
      
      // assert
      expect(result, tUserModel.toEntity());
      verify(mockNetworkInfo.isConnected);
      verify(mockRemoteDataSource.getCurrentUser());
      verify(mockLocalDataSource.getCachedUser());
      verifyNoMoreInteractions(mockRemoteDataSource);
      verifyNoMoreInteractions(mockLocalDataSource);
    });
  });
}
```

#### Model Tests

```dart
// test/features/auth/data/models/user_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:crossfit_app/features/auth/data/models/user_model.dart';
import 'package:crossfit_app/features/auth/domain/entities/user.dart';

void main() {
  group('UserModel', () {
    test('should be a subclass of User entity', () {
      // arrange
      const tUserModel = UserModel(
        uid: '123',
        email: 'test@example.com',
        displayName: 'Test User',
        preferences: UserPreferencesModel.defaultPreferences(),
        createdAt: DateTime(2024, 1, 1),
        lastLoginAt: DateTime(2024, 1, 1),
      );
      
      // act
      final result = tUserModel.toEntity();
      
      // assert
      expect(result, isA<User>());
      expect(result.uid, '123');
      expect(result.email, 'test@example.com');
      expect(result.displayName, 'Test User');
    });
    
    test('should create UserModel from Firebase User', () {
      // arrange
      final mockFirebaseUser = MockFirebaseUser();
      when(mockFirebaseUser.uid).thenReturn('123');
      when(mockFirebaseUser.email).thenReturn('test@example.com');
      when(mockFirebaseUser.displayName).thenReturn('Test User');
      when(mockFirebaseUser.photoURL).thenReturn('https://example.com/photo.jpg');
      when(mockFirebaseUser.metadata.creationTime).thenReturn(DateTime(2024, 1, 1));
      when(mockFirebaseUser.metadata.lastSignInTime).thenReturn(DateTime(2024, 1, 1));
      
      // act
      final result = UserModel.fromFirebaseUser(mockFirebaseUser);
      
      // assert
      expect(result.uid, '123');
      expect(result.email, 'test@example.com');
      expect(result.displayName, 'Test User');
      expect(result.photoURL, 'https://example.com/photo.jpg');
    });
    
    test('should create UserModel from JSON', () {
      // arrange
      final tJson = {
        'uid': '123',
        'email': 'test@example.com',
        'displayName': 'Test User',
        'photoURL': 'https://example.com/photo.jpg',
        'preferences': {
          'language': 'tr',
          'theme': 'light',
          'notifications': {
            'push': true,
            'email': true,
            'newProgram': true,
            'subscriptionReminder': true,
            'workoutReminder': true,
            'workoutReminderTime': '09:00'
          }
        },
        'createdAt': '2024-01-01T00:00:00.000Z',
        'lastLoginAt': '2024-01-01T00:00:00.000Z'
      };
      
      // act
      final result = UserModel.fromJson(tJson);
      
      // assert
      expect(result.uid, '123');
      expect(result.email, 'test@example.com');
      expect(result.displayName, 'Test User');
      expect(result.photoURL, 'https://example.com/photo.jpg');
    });
    
    test('should convert UserModel to JSON', () {
      // arrange
      const tUserModel = UserModel(
        uid: '123',
        email: 'test@example.com',
        displayName: 'Test User',
        photoURL: 'https://example.com/photo.jpg',
        preferences: UserPreferencesModel.defaultPreferences(),
        createdAt: DateTime(2024, 1, 1),
        lastLoginAt: DateTime(2024, 1, 1),
      );
      
      // act
      final result = tUserModel.toJson();
      
      // assert
      expect(result['uid'], '123');
      expect(result['email'], 'test@example.com');
      expect(result['displayName'], 'Test User');
      expect(result['photoURL'], 'https://example.com/photo.jpg');
    });
  });
}
```

## 2. Widget Tests

### Test Kapsamı
- **UI Components:** Custom widgets, form validation
- **Screen Widgets:** Complete screen functionality
- **Navigation:** Route testing, navigation flow
- **State Management:** Provider/Riverpod state changes

### Test Örnekleri

#### Login Screen Tests

```dart
// test/features/auth/presentation/screens/login_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';

import 'package:crossfit_app/features/auth/presentation/screens/login_screen.dart';
import 'package:crossfit_app/features/auth/presentation/providers/auth_provider.dart';

class MockAuthProvider extends StateNotifier<AuthState> {
  MockAuthProvider() : super(AuthInitial());
  
  @override
  void signInWithGoogle() {
    state = AuthLoading();
    // Simulate async operation
    Future.delayed(Duration(milliseconds: 100), () {
      state = AuthAuthenticated(User(
        uid: '123',
        email: 'test@example.com',
        displayName: 'Test User',
        preferences: UserPreferences.defaultPreferences(),
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      ));
    });
  }
  
  @override
  void signInWithEmail(String email, String password) {
    state = AuthLoading();
    // Simulate async operation
    Future.delayed(Duration(milliseconds: 100), () {
      state = AuthAuthenticated(User(
        uid: '123',
        email: email,
        displayName: 'Test User',
        preferences: UserPreferences.defaultPreferences(),
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      ));
    });
  }
}

void main() {
  group('LoginScreen', () {
    testWidgets('should display login buttons', (WidgetTester tester) async {
      // arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith((ref) => MockAuthProvider()),
          ],
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
    
    testWidgets('should show loading indicator when signing in with Google', (WidgetTester tester) async {
      // arrange
      final mockProvider = MockAuthProvider();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith((ref) => mockProvider),
          ],
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      
      // act
      await tester.tap(find.text('Google ile Giriş Yap'));
      await tester.pump();
      
      // assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
    
    testWidgets('should show email login dialog when email button is tapped', (WidgetTester tester) async {
      // arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith((ref) => MockAuthProvider()),
          ],
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
    
    testWidgets('should navigate to home screen after successful login', (WidgetTester tester) async {
      // arrange
      final mockProvider = MockAuthProvider();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith((ref) => mockProvider),
          ],
          child: MaterialApp(
            home: LoginScreen(),
            routes: {
              '/home': (context) => HomeScreen(),
            },
          ),
        ),
      );
      
      // act
      await tester.tap(find.text('Google ile Giriş Yap'));
      await tester.pumpAndSettle();
      
      // assert
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}
```

#### Program Card Tests

```dart
// test/features/programs/presentation/widgets/program_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:crossfit_app/features/programs/presentation/widgets/program_card.dart';
import 'package:crossfit_app/features/programs/domain/entities/program.dart';

void main() {
  group('ProgramCard', () {
    const tProgram = Program(
      id: '1',
      weekNumber: 1,
      year: 2024,
      title: 'Hafta 1 - Temel Güç',
      description: 'Temel güç antrenmanları',
      difficulty: 'beginner',
      isActive: true,
      days: [],
      createdAt: DateTime(2024, 1, 1),
    );
    
    testWidgets('should display program information', (WidgetTester tester) async {
      // arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProgramCard(
              program: tProgram,
              onTap: () {},
            ),
          ),
        ),
      );
      
      // act
      await tester.pumpAndSettle();
      
      // assert
      expect(find.text('Hafta 1 - Temel Güç'), findsOneWidget);
      expect(find.text('Temel güç antrenmanları'), findsOneWidget);
      expect(find.text('Başlangıç'), findsOneWidget);
    });
    
    testWidgets('should call onTap when tapped', (WidgetTester tester) async {
      // arrange
      bool wasTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProgramCard(
              program: tProgram,
              onTap: () => wasTapped = true,
            ),
          ),
        ),
      );
      
      // act
      await tester.tap(find.byType(ProgramCard));
      await tester.pumpAndSettle();
      
      // assert
      expect(wasTapped, true);
    });
    
    testWidgets('should display difficulty badge', (WidgetTester tester) async {
      // arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProgramCard(
              program: tProgram,
              onTap: () {},
            ),
          ),
        ),
      );
      
      // act
      await tester.pumpAndSettle();
      
      // assert
      expect(find.text('Başlangıç'), findsOneWidget);
    });
  });
}
```

## 3. Integration Tests

### Test Kapsamı
- **Firebase Integration:** Authentication, Firestore, Storage
- **Payment Integration:** İyizico payment flow
- **Notification Integration:** FCM, local notifications
- **Complete User Flows:** End-to-end user journeys

### Test Örnekleri

#### Authentication Integration Test

```dart
// integration_test/auth_integration_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:crossfit_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Authentication Integration Tests', () {
    setUpAll(() async {
      await Firebase.initializeApp();
    });
    
    tearDownAll(() async {
      await FirebaseAuth.instance.signOut();
    });
    
    testWidgets('should sign in with Google successfully', (WidgetTester tester) async {
      // arrange
      await tester.pumpWidget(app.MyApp());
      await tester.pumpAndSettle();
      
      // act
      await tester.tap(find.text('Google ile Giriş Yap'));
      await tester.pumpAndSettle();
      
      // assert
      expect(find.text('Haftalık Programlar'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);
    });
    
    testWidgets('should sign in with email successfully', (WidgetTester tester) async {
      // arrange
      await tester.pumpWidget(app.MyApp());
      await tester.pumpAndSettle();
      
      // act
      await tester.tap(find.text('E-posta ile Giriş Yap'));
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byKey(Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(Key('password_field')), 'password123');
      await tester.tap(find.text('Giriş Yap'));
      await tester.pumpAndSettle();
      
      // assert
      expect(find.text('Haftalık Programlar'), findsOneWidget);
    });
    
    testWidgets('should sign out successfully', (WidgetTester tester) async {
      // arrange
      await tester.pumpWidget(app.MyApp());
      await tester.pumpAndSettle();
      
      // act
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Çıkış Yap'));
      await tester.pumpAndSettle();
      
      // assert
      expect(find.text('Giriş Yap'), findsOneWidget);
    });
  });
}
```

#### Subscription Integration Test

```dart
// integration_test/subscription_integration_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:crossfit_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Subscription Integration Tests', () {
    testWidgets('should complete subscription flow', (WidgetTester tester) async {
      // arrange
      await tester.pumpWidget(app.MyApp());
      await tester.pumpAndSettle();
      
      // Sign in first
      await tester.tap(find.text('Google ile Giriş Yap'));
      await tester.pumpAndSettle();
      
      // act - Navigate to subscription
      await tester.tap(find.text('Abonelik'));
      await tester.pumpAndSettle();
      
      // Select monthly plan
      await tester.tap(find.text('Aylık'));
      await tester.pumpAndSettle();
      
      // Tap purchase button
      await tester.tap(find.text('Satın Al'));
      await tester.pumpAndSettle();
      
      // assert - Should show payment page
      expect(find.text('Ödeme'), findsOneWidget);
    });
    
    testWidgets('should show subscription status', (WidgetTester tester) async {
      // arrange
      await tester.pumpWidget(app.MyApp());
      await tester.pumpAndSettle();
      
      // Sign in first
      await tester.tap(find.text('Google ile Giriş Yap'));
      await tester.pumpAndSettle();
      
      // act - Navigate to profile
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      
      // assert - Should show subscription status
      expect(find.text('Abonelik'), findsOneWidget);
      expect(find.text('Aktif'), findsOneWidget);
    });
  });
}
```

## 4. Performance Tests

### Test Kapsamı
- **Memory Usage:** Memory leaks, memory consumption
- **CPU Usage:** CPU intensive operations
- **Network Performance:** API response times, data transfer
- **UI Performance:** Frame rates, rendering performance

### Test Örnekleri

#### Memory Leak Tests

```dart
// test/performance/memory_leak_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:crossfit_app/features/programs/presentation/providers/programs_provider.dart';

void main() {
  group('Memory Leak Tests', () {
    test('should not leak memory when disposing providers', () async {
      // arrange
      final provider = ProgramsProvider(
        getPrograms: MockGetPrograms(),
        getProgramById: MockGetProgramById(),
      );
      
      // act
      provider.dispose();
      
      // assert
      // Check that all resources are properly disposed
      expect(provider.isDisposed, true);
    });
    
    test('should not leak memory when navigating between screens', () async {
      // arrange
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();
      
      // act - Navigate between screens multiple times
      for (int i = 0; i < 10; i++) {
        await tester.tap(find.text('Programlar'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Profil'));
        await tester.pumpAndSettle();
      }
      
      // assert
      // Check memory usage hasn't increased significantly
      expect(ProcessInfo.currentRss, lessThan(100 * 1024 * 1024)); // 100MB
    });
  });
}
```

#### Network Performance Tests

```dart
// test/performance/network_performance_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  group('Network Performance Tests', () {
    test('should load programs within acceptable time', () async {
      // arrange
      final stopwatch = Stopwatch()..start();
      
      // act
      final response = await http.get(
        Uri.parse('https://your-api.com/programs'),
        headers: {'Authorization': 'Bearer test-token'},
      );
      
      // assert
      stopwatch.stop();
      expect(response.statusCode, 200);
      expect(stopwatch.elapsedMilliseconds, lessThan(2000)); // 2 seconds
    });
    
    test('should handle network timeout gracefully', () async {
      // arrange
      final client = http.Client();
      
      // act
      try {
        final response = await client.get(
          Uri.parse('https://your-api.com/programs'),
          headers: {'Authorization': 'Bearer test-token'},
        ).timeout(Duration(seconds: 5));
        
        // assert
        expect(response.statusCode, 200);
      } catch (e) {
        // Should handle timeout gracefully
        expect(e, isA<TimeoutException>());
      } finally {
        client.close();
      }
    });
  });
}
```

## 5. Test Utilities

### Mock Classes

```dart
// test/helpers/mock_classes.dart
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockFirebaseUser extends Mock implements User {}
class MockUserCredential extends Mock implements UserCredential {}
class MockFirestore extends Mock implements FirebaseFirestore {}
class MockCollectionReference extends Mock implements CollectionReference {}
class MockDocumentReference extends Mock implements DocumentReference {}
class MockQuerySnapshot extends Mock implements QuerySnapshot {}
class MockDocumentSnapshot extends Mock implements DocumentSnapshot {}
class MockQueryDocumentSnapshot extends Mock implements QueryDocumentSnapshot {}
```

### Test Helpers

```dart
// test/helpers/test_helpers.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Widget createTestableWidget(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      home: child,
    ),
  );
}

Future<void> pumpAndSettle(WidgetTester tester) async {
  await tester.pumpAndSettle();
}

Future<void> tapAndPump(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pump();
}

Future<void> enterTextAndPump(WidgetTester tester, Finder finder, String text) async {
  await tester.enterText(finder, text);
  await tester.pump();
}
```

## 6. Test Configuration

### Test Setup

```dart
// test/test_setup.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mockito/mockito.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  });
  
  setUp(() {
    // Reset mocks before each test
    resetMockitoState();
  });
  
  tearDown(() {
    // Clean up after each test
  });
}
```

### Test Configuration Files

```yaml
# test/flutter_test_config.yaml
test_timeout: 30s
reporter: expanded
coverage:
  include:
    - lib/features/**
    - lib/core/**
  exclude:
    - lib/features/**/presentation/providers/**
    - lib/core/di/**
```

## 7. Continuous Integration

### GitHub Actions Workflow

```yaml
# .github/workflows/test.yml
name: Tests

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
```

### Test Commands

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/features/auth/domain/usecases/sign_in_with_google_test.dart

# Run integration tests
flutter test integration_test/

# Run performance tests
flutter test test/performance/

# Generate test coverage report
genhtml coverage/lcov.info -o coverage/html
```

## 8. Test Metrics

### Coverage Targets

| Component | Target Coverage |
|-----------|----------------|
| Domain Layer | 95% |
| Data Layer | 90% |
| Presentation Layer | 85% |
| Overall | 90% |

### Performance Targets

| Metric | Target |
|--------|--------|
| App Launch Time | < 3 seconds |
| Screen Transition | < 300ms |
| API Response Time | < 2 seconds |
| Memory Usage | < 100MB |
| Battery Usage | < 5% per hour |

Bu kapsamlı test stratejisi, CrossFit antrenman uygulamasının kalitesini ve güvenilirliğini sağlamak için tasarlanmıştır. Her test türü, farklı katmanlarda farklı riskleri ele alır ve genel sistem kalitesini artırır.

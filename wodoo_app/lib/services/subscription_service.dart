import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class SubscriptionService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Abonelik oluşturur
  static Future<void> createSubscription({
    required String userId,
    required String plan,
    required String paymentId,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Check if user document exists
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      if (userDoc.exists) {
        // Update existing user
        await _firestore.collection('users').doc(user.uid).update({
          'subscription.plan': plan,
          'subscription.isActive': true,
          'subscription.startDate': DateTime.now().toIso8601String(),
          'subscription.endDate': plan == 'monthly'
              ? DateTime.now().add(const Duration(days: 30)).toIso8601String()
              : plan == 'semi_annual'
                  ? DateTime.now().add(const Duration(days: 180)).toIso8601String()
                  : DateTime.now().add(const Duration(days: 365)).toIso8601String(),
          'subscription.paymentId': paymentId,
        });
      } else {
        // Create new user
        final newUser = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? '',
          subscription: Subscription(
            plan: plan,
            isActive: true,
            startDate: DateTime.now(),
            endDate: plan == 'monthly'
                ? DateTime.now().add(const Duration(days: 30))
                : plan == 'semi_annual'
                    ? DateTime.now().add(const Duration(days: 180))
                    : DateTime.now().add(const Duration(days: 365)),
          ),
          preferences: UserPreferences(
            language: 'tr',
            notifications: true,
            theme: 'light',
            mainLifts: const {},
          ),
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
      }
    } catch (e) {
      throw Exception('Abonelik oluşturulamadı: $e');
    }
  }

  /// Kullanıcının abonelik durumunu kontrol eder
  static Future<bool> isUserSubscribed() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return false;

      final userData = UserModel.fromMap(doc.data()!);
      return userData.subscription.isActive && !userData.subscription.isExpired;
    } catch (e) {
      print('Abonelik kontrol hatası: $e');
      return false;
    }
  }

  /// Kullanıcının abonelik bilgilerini getirir
  static Future<Subscription?> getUserSubscription() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;

      final userData = UserModel.fromMap(doc.data()!);
      return userData.subscription;
    } catch (e) {
      print('Abonelik bilgisi alma hatası: $e');
      return null;
    }
  }

  /// Kullanıcının abonelik süresini kontrol eder
  static Future<Map<String, dynamic>> getSubscriptionStatus() async {
    final subscription = await getUserSubscription();
    
    if (subscription == null) {
      return {
        'isSubscribed': false,
        'isExpired': true,
        'daysRemaining': 0,
        'plan': 'free',
        'message': 'Abonelik bulunamadı'
      };
    }

    final isExpired = subscription.isExpired;
    final daysRemaining = subscription.daysRemaining;

    return {
      'isSubscribed': subscription.isActive && !isExpired,
      'isExpired': isExpired,
      'daysRemaining': daysRemaining,
      'plan': subscription.plan,
      'message': isExpired 
          ? 'Aboneliğiniz süresi dolmuş'
          : 'Aboneliğiniz aktif'
    };
  }

  /// Abonelik süresini uzatır
  static Future<bool> extendSubscription(int days) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      
      if (doc.exists) {
        final userData = UserModel.fromMap(doc.data()!);
        final newEndDate = userData.subscription.endDate.add(Duration(days: days));

        await _firestore.collection('users').doc(user.uid).update({
          'subscription.endDate': newEndDate.millisecondsSinceEpoch,
          'subscription.isActive': true,
        });
      } else {
        // Belge yoksa ücretsiz deneme başlat
        return await startFreeTrial();
      }

      return true;
    } catch (e) {
      print('Abonelik uzatma hatası: $e');
      return false;
    }
  }

  /// Aboneliği iptal eder
  static Future<bool> cancelSubscription() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      
      if (doc.exists) {
        await _firestore.collection('users').doc(user.uid).update({
          'subscription.isActive': false,
        });
      } else {
        // Belge yoksa zaten abonelik yok
        return true;
      }

      return true;
    } catch (e) {
      print('Abonelik iptal hatası: $e');
      return false;
    }
  }

  /// Ücretsiz deneme başlatır
  static Future<bool> startFreeTrial() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final now = DateTime.now();
      final trialEndDate = now.add(const Duration(days: 7));

      // Kullanıcı belgesini kontrol et
      final doc = await _firestore.collection('users').doc(user.uid).get();
      
      if (doc.exists) {
        // Belge varsa güncelle
        await _firestore.collection('users').doc(user.uid).update({
          'subscription.plan': 'trial',
          'subscription.startDate': now.millisecondsSinceEpoch,
          'subscription.endDate': trialEndDate.millisecondsSinceEpoch,
          'subscription.isActive': true,
        });
      } else {
        // Belge yoksa oluştur
        final userModel = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? '',
          photoURL: user.photoURL,
          createdAt: now,
          lastLoginAt: now,
          preferences: UserPreferences(
            language: 'tr',
            notifications: true,
            theme: 'light',
            mainLifts: {},
          ),
          subscription: Subscription(
            plan: 'trial',
            startDate: now,
            endDate: trialEndDate,
            isActive: true,
            paymentId: null,
          ),
        );

        await _firestore.collection('users').doc(user.uid).set(userModel.toMap());
      }

      return true;
    } catch (e) {
      print('Ücretsiz deneme başlatma hatası: $e');
      return false;
    }
  }
}
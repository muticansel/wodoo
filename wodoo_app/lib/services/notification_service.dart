import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Notification permissions
  static Future<bool> requestPermission() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      return settings.authorizationStatus == AuthorizationStatus.authorized ||
             settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      debugPrint('Notification permission error: $e');
      return false;
    }
  }

  // Get FCM token
  static Future<String?> getToken() async {
    try {
      final token = await _messaging.getToken();
      debugPrint('FCM Token: $token');
      return token;
    } catch (e) {
      debugPrint('Get token error: $e');
      return null;
    }
  }

  // Save token to Firestore
  static Future<void> saveTokenToFirestore(String token) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'fcmToken': token,
          'tokenUpdatedAt': FieldValue.serverTimestamp(),
        });
        debugPrint('Token saved to Firestore');
      }
    } catch (e) {
      debugPrint('Save token error: $e');
    }
  }

  // Initialize notification service
  static Future<void> initialize() async {
    try {
      // Request permission
      final hasPermission = await requestPermission();
      if (!hasPermission) {
        debugPrint('Notification permission denied');
        return;
      }

      // Get and save token
      final token = await getToken();
      if (token != null) {
        await saveTokenToFirestore(token);
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        debugPrint('Token refreshed: $newToken');
        saveTokenToFirestore(newToken);
      });

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Foreground message received: ${message.notification?.title}');
        _handleForegroundMessage(message);
      });

      // Handle notification tap when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('Notification tapped: ${message.notification?.title}');
        _handleNotificationTap(message);
      });

      // Handle notification tap when app is terminated
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('App opened from notification: ${initialMessage.notification?.title}');
        _handleNotificationTap(initialMessage);
      }

    } catch (e) {
      debugPrint('Notification service initialization error: $e');
    }
  }

  // Handle foreground messages
  static void _handleForegroundMessage(RemoteMessage message) {
    // You can show in-app notifications here
    debugPrint('Message data: ${message.data}');
    debugPrint('Message notification: ${message.notification?.title}');
  }

  // Handle notification tap
  static void _handleNotificationTap(RemoteMessage message) {
    // Navigate to specific screen based on notification data
    final data = message.data;
    final type = data['type'];
    
    switch (type) {
      case 'pr_update':
        // Navigate to PR screen
        debugPrint('Navigate to PR screen');
        break;
      case 'subscription':
        // Navigate to subscription screen
        debugPrint('Navigate to subscription screen');
        break;
      case 'program_update':
        // Navigate to program screen
        debugPrint('Navigate to program screen');
        break;
      default:
        // Navigate to home screen
        debugPrint('Navigate to home screen');
        break;
    }
  }

  // Send test notification (for development)
  static Future<void> sendTestNotification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // This would typically be done via Cloud Functions
      // For now, we'll just log it
      debugPrint('Sending test notification to user: ${user.uid}');
    } catch (e) {
      debugPrint('Send test notification error: $e');
    }
  }

  // Update notification preferences
  static Future<void> updateNotificationPreferences({
    required bool prUpdates,
    required bool subscriptionNotifications,
    required bool programUpdates,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('users').doc(user.uid).update({
        'notificationPreferences': {
          'prUpdates': prUpdates,
          'subscriptionNotifications': subscriptionNotifications,
          'programUpdates': programUpdates,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      });

      debugPrint('Notification preferences updated');
    } catch (e) {
      debugPrint('Update notification preferences error: $e');
    }
  }

  // Get notification preferences
  static Future<Map<String, bool>?> getNotificationPreferences() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data();
      
      if (data != null && data['notificationPreferences'] != null) {
        return Map<String, bool>.from(data['notificationPreferences']);
      }
      
      // Return default preferences
      return {
        'prUpdates': true,
        'subscriptionNotifications': true,
        'programUpdates': true,
      };
    } catch (e) {
      debugPrint('Get notification preferences error: $e');
      return null;
    }
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message received: ${message.notification?.title}');
  // Handle background message here
}

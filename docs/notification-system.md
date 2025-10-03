# Bildirim Sistemi Dokümantasyonu

## Genel Bakış

CrossFit antrenman uygulaması, Firebase Cloud Messaging (FCM) ve Cloud Functions kullanarak kullanıcılara çeşitli bildirimler gönderir. Bildirim sistemi, kullanıcı tercihlerine göre özelleştirilebilir ve hedefli mesajlar gönderebilir.

## Bildirim Türleri

### 1. Yeni Program Bildirimi
- **Tetikleyici:** Admin yeni haftalık program yüklediğinde
- **Hedef:** Aktif abonelik sahibi tüm kullanıcılar
- **İçerik:** Program başlığı ve kısa açıklama

### 2. Abonelik Hatırlatması
- **Tetikleyici:** Abonelik bitmeden 3 gün önce
- **Hedef:** Aboneliği bitmek üzere olan kullanıcılar
- **İçerik:** Yenileme teşviki ve indirim bilgisi

### 3. Antrenman Hatırlatması
- **Tetikleyici:** Kullanıcının belirlediği saatte
- **Hedef:** Bildirim açık olan kullanıcılar
- **İçerik:** Günlük antrenman programı

### 4. Ödeme Bildirimleri
- **Başarılı Ödeme:** Abonelik satın alındığında
- **Başarısız Ödeme:** Ödeme işlemi başarısız olduğunda
- **Abonelik İptali:** Kullanıcı aboneliği iptal ettiğinde

### 5. Sistem Bildirimleri
- **Uygulama Güncellemesi:** Yeni özellikler hakkında
- **Bakım Bildirimi:** Planlı bakım çalışmaları
- **Genel Duyurular:** Önemli duyurular

## FCM Entegrasyonu

### 1. Flutter FCM Kurulumu

```yaml
# pubspec.yaml
dependencies:
  firebase_messaging: ^14.7.10
  firebase_core: ^2.24.2
  flutter_local_notifications: ^16.3.2
```

### 2. FCM Servisi

```dart
// lib/services/fcm_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  
  // FCM'yi başlat
  static Future<void> initialize() async {
    // FCM izinleri iste
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('FCM izinleri verildi');
      
      // Token'ı al ve kaydet
      String? token = await _messaging.getToken();
      if (token != null) {
        await _saveTokenToFirestore(token);
      }
      
      // Token yenileme dinleyicisi
      _messaging.onTokenRefresh.listen(_saveTokenToFirestore);
      
      // Foreground mesaj dinleyicisi
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      
      // Background mesaj dinleyicisi
      FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
      
      // Tıklanan mesaj dinleyicisi
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
      
    } else {
      print('FCM izinleri reddedildi');
    }
  }
  
  // Token'ı Firestore'a kaydet
  static Future<void> _saveTokenToFirestore(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'fcmToken': token,
        'tokenUpdatedAt': FieldValue.serverTimestamp(),
      });
    }
  }
  
  // Foreground mesaj işle
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Foreground mesaj alındı: ${message.notification?.title}');
    
    // Yerel bildirim göster
    await _showLocalNotification(message);
  }
  
  // Background mesaj işle
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('Background mesaj alındı: ${message.notification?.title}');
    
    // Background'da işlem yapılacaksa burada yapılır
    // Örnek: Veritabanı güncelleme, analitik kaydetme
  }
  
  // Tıklanan mesaj işle
  static Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    print('Mesaj tıklandı: ${message.notification?.title}');
    
    // Mesaj verisine göre sayfa yönlendirme
    final data = message.data;
    if (data['type'] == 'new_program') {
      // Program detay sayfasına git
      // Navigator.pushNamed(context, '/program-detail', arguments: data['programId']);
    } else if (data['type'] == 'subscription_reminder') {
      // Abonelik sayfasına git
      // Navigator.pushNamed(context, '/subscription');
    }
  }
  
  // Yerel bildirim göster
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'crossfit_notifications',
      'CrossFit Bildirimleri',
      channelDescription: 'CrossFit antrenman uygulaması bildirimleri',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _localNotifications.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      platformDetails,
      payload: message.data.toString(),
    );
  }
  
  // Yerel bildirimleri başlat
  static Future<void> initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosSettings = 
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(initSettings);
  }
}
```

### 3. Bildirim Tercihleri Yönetimi

```dart
// lib/services/notification_preferences_service.dart
class NotificationPreferencesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Bildirim tercihlerini al
  Future<NotificationPreferences> getPreferences() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Kullanıcı giriş yapmamış');
    
    final doc = await _firestore.collection('users').doc(user.uid).get();
    final data = doc.data();
    
    if (data == null) return NotificationPreferences.defaultPreferences();
    
    final prefs = data['preferences']?['notifications'] as Map<String, dynamic>?;
    if (prefs == null) return NotificationPreferences.defaultPreferences();
    
    return NotificationPreferences.fromMap(prefs);
  }
  
  // Bildirim tercihlerini güncelle
  Future<void> updatePreferences(NotificationPreferences preferences) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Kullanıcı giriş yapmamış');
    
    await _firestore.collection('users').doc(user.uid).update({
      'preferences.notifications': preferences.toMap(),
    });
  }
  
  // Antrenman hatırlatma saatini güncelle
  Future<void> updateWorkoutReminderTime(TimeOfDay time) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Kullanıcı giriş yapmamış');
    
    final timeString = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    
    await _firestore.collection('users').doc(user.uid).update({
      'preferences.workoutReminderTime': timeString,
    });
  }
}

class NotificationPreferences {
  final bool push;
  final bool email;
  final bool newProgram;
  final bool subscriptionReminder;
  final bool workoutReminder;
  final String workoutReminderTime;
  
  const NotificationPreferences({
    required this.push,
    required this.email,
    required this.newProgram,
    required this.subscriptionReminder,
    required this.workoutReminder,
    required this.workoutReminderTime,
  });
  
  factory NotificationPreferences.defaultPreferences() {
    return const NotificationPreferences(
      push: true,
      email: true,
      newProgram: true,
      subscriptionReminder: true,
      workoutReminder: true,
      workoutReminderTime: '09:00',
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'push': push,
      'email': email,
      'newProgram': newProgram,
      'subscriptionReminder': subscriptionReminder,
      'workoutReminder': workoutReminder,
      'workoutReminderTime': workoutReminderTime,
    };
  }
  
  factory NotificationPreferences.fromMap(Map<String, dynamic> map) {
    return NotificationPreferences(
      push: map['push'] ?? true,
      email: map['email'] ?? true,
      newProgram: map['newProgram'] ?? true,
      subscriptionReminder: map['subscriptionReminder'] ?? true,
      workoutReminder: map['workoutReminder'] ?? true,
      workoutReminderTime: map['workoutReminderTime'] ?? '09:00',
    );
  }
}
```

## Cloud Functions - Bildirim Gönderimi

### 1. Yeni Program Bildirimi

```javascript
// functions/src/notifications.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Yeni program yüklendiğinde bildirim gönder
exports.sendNewProgramNotification = functions.firestore
  .document('programs/{programId}')
  .onCreate(async (snap, context) => {
    const program = snap.data();
    
    // Sadece yayınlanmış programlar için bildirim gönder
    if (!program.isPublished) {
      console.log('Program yayınlanmamış, bildirim gönderilmiyor');
      return;
    }
    
    try {
      // Aktif abonelik sahibi kullanıcıları al
      const usersSnapshot = await admin.firestore()
        .collection('users')
        .where('subscription.isActive', '==', true)
        .where('preferences.notifications.newProgram', '==', true)
        .get();
      
      if (usersSnapshot.empty) {
        console.log('Bildirim gönderilecek kullanıcı bulunamadı');
        return;
      }
      
      // FCM token'larını topla
      const tokens = [];
      const userIds = [];
      
      usersSnapshot.forEach(doc => {
        const userData = doc.data();
        if (userData.fcmToken) {
          tokens.push(userData.fcmToken);
          userIds.push(doc.id);
        }
      });
      
      if (tokens.length === 0) {
        console.log('FCM token bulunamadı');
        return;
      }
      
      // Bildirim mesajı hazırla
      const message = {
        notification: {
          title: 'Yeni Program Yüklendi! 🏋️‍♂️',
          body: `${program.title} programı hazır. Hemen başla!`
        },
        data: {
          type: 'new_program',
          programId: context.params.programId,
          weekNumber: program.weekNumber.toString(),
          year: program.year.toString(),
        },
        tokens: tokens
      };
      
      // Bildirim gönder
      const response = await admin.messaging().sendMulticast(message);
      
      // Başarılı/başarısız gönderimleri logla
      console.log(`Bildirim gönderildi: ${response.successCount} başarılı, ${response.failureCount} başarısız`);
      
      // Bildirim geçmişini kaydet
      await saveNotificationHistory(userIds, {
        type: 'new_program',
        title: message.notification.title,
        body: message.notification.body,
        data: message.data,
        programId: context.params.programId
      });
      
      // Başarısız token'ları temizle
      if (response.failureCount > 0) {
        const failedTokens = [];
        response.responses.forEach((resp, idx) => {
          if (!resp.success) {
            failedTokens.push(tokens[idx]);
          }
        });
        await cleanupFailedTokens(failedTokens);
      }
      
    } catch (error) {
      console.error('Bildirim gönderme hatası:', error);
    }
  });
```

### 2. Abonelik Hatırlatması

```javascript
// Abonelik bitmeden 3 gün önce hatırlatma
exports.sendSubscriptionReminder = functions.pubsub
  .schedule('0 10 * * *') // Her gün saat 10:00
  .timeZone('Europe/Istanbul')
  .onRun(async (context) => {
    const db = admin.firestore();
    const now = new Date();
    const threeDaysFromNow = new Date(now.getTime() + (3 * 24 * 60 * 60 * 1000));
    
    try {
      // 3 gün içinde bitecek abonelikleri bul
      const expiringSubscriptions = await db.collection('users')
        .where('subscription.isActive', '==', true)
        .where('subscription.endDate', '<=', admin.firestore.Timestamp.fromDate(threeDaysFromNow))
        .where('subscription.endDate', '>', admin.firestore.Timestamp.fromDate(now))
        .where('preferences.notifications.subscriptionReminder', '==', true)
        .get();
      
      if (expiringSubscriptions.empty) {
        console.log('Hatırlatma gönderilecek abonelik bulunamadı');
        return;
      }
      
      for (const doc of expiringSubscriptions.docs) {
        const user = doc.data();
        const endDate = user.subscription.endDate.toDate();
        const daysLeft = Math.ceil((endDate - now) / (1000 * 60 * 60 * 24));
        
        if (user.fcmToken) {
          const message = {
            notification: {
              title: 'Aboneliğiniz Bitiyor! ⏰',
              body: `Aboneliğiniz ${daysLeft} gün sonra bitiyor. Yenilemeyi unutmayın!`
            },
            data: {
              type: 'subscription_reminder',
              daysLeft: daysLeft.toString(),
              plan: user.subscription.plan
            },
            token: user.fcmToken
          };
          
          try {
            await admin.messaging().send(message);
            console.log(`Hatırlatma gönderildi: ${doc.id}`);
            
            // Bildirim geçmişini kaydet
            await saveNotificationHistory([doc.id], {
              type: 'subscription_reminder',
              title: message.notification.title,
              body: message.notification.body,
              data: message.data
            });
            
          } catch (error) {
            console.error(`Hatırlatma gönderme hatası (${doc.id}):`, error);
          }
        }
      }
      
    } catch (error) {
      console.error('Abonelik hatırlatma hatası:', error);
    }
  });
```

### 3. Antrenman Hatırlatması

```javascript
// Günlük antrenman hatırlatması
exports.sendWorkoutReminder = functions.pubsub
  .schedule('0 9 * * *') // Her gün saat 09:00
  .timeZone('Europe/Istanbul')
  .onRun(async (context) => {
    const db = admin.firestore();
    const now = new Date();
    const today = now.toISOString().split('T')[0]; // YYYY-MM-DD formatı
    
    try {
      // Antrenman hatırlatması açık olan kullanıcıları al
      const usersSnapshot = await db.collection('users')
        .where('preferences.notifications.workoutReminder', '==', true)
        .where('subscription.isActive', '==', true)
        .get();
      
      if (usersSnapshot.empty) {
        console.log('Antrenman hatırlatması gönderilecek kullanıcı bulunamadı');
        return;
      }
      
      // Bugünün programını al
      const programsSnapshot = await db.collection('programs')
        .where('isActive', '==', true)
        .where('isPublished', '==', true)
        .orderBy('year', 'desc')
        .orderBy('weekNumber', 'desc')
        .limit(1)
        .get();
      
      if (programsSnapshot.empty) {
        console.log('Aktif program bulunamadı');
        return;
      }
      
      const currentProgram = programsSnapshot.docs[0].data();
      const todayWorkouts = getTodayWorkouts(currentProgram, now);
      
      if (todayWorkouts.length === 0) {
        console.log('Bugün için antrenman bulunamadı');
        return;
      }
      
      // Her kullanıcıya hatırlatma gönder
      for (const doc of usersSnapshot.docs) {
        const user = doc.data();
        
        if (user.fcmToken) {
          const workoutText = todayWorkouts.length === 1 
            ? todayWorkouts[0].title 
            : `${todayWorkouts.length} antrenman`;
          
          const message = {
            notification: {
              title: 'Antrenman Zamanı! 💪',
              body: `Bugün ${workoutText} var. Hadi başlayalım!`
            },
            data: {
              type: 'workout_reminder',
              programId: programsSnapshot.docs[0].id,
              workoutCount: todayWorkouts.length.toString()
            },
            token: user.fcmToken
          };
          
          try {
            await admin.messaging().send(message);
            console.log(`Antrenman hatırlatması gönderildi: ${doc.id}`);
            
            // Bildirim geçmişini kaydet
            await saveNotificationHistory([doc.id], {
              type: 'workout_reminder',
              title: message.notification.title,
              body: message.notification.body,
              data: message.data
            });
            
          } catch (error) {
            console.error(`Antrenman hatırlatması gönderme hatası (${doc.id}):`, error);
          }
        }
      }
      
    } catch (error) {
      console.error('Antrenman hatırlatması hatası:', error);
    }
  });

// Bugünün antrenmanlarını al
function getTodayWorkouts(program, date) {
  const dayOfWeek = date.getDay(); // 0 = Pazar, 1 = Pazartesi, ...
  const dayNumber = dayOfWeek === 0 ? 7 : dayOfWeek; // Pazar = 7
  
  const day = program.days.find(d => d.dayNumber === dayNumber);
  if (!day || day.isRestDay) {
    return [];
  }
  
  return day.workouts || [];
}
```

### 4. Bildirim Geçmişi Kaydetme

```javascript
// Bildirim geçmişini kaydet
async function saveNotificationHistory(userIds, notificationData) {
  const db = admin.firestore();
  const batch = db.batch();
  
  for (const userId of userIds) {
    const notificationRef = db.collection('notifications').doc();
    batch.set(notificationRef, {
      userId,
      type: notificationData.type,
      title: notificationData.title,
      body: notificationData.body,
      data: notificationData.data,
      sentAt: admin.firestore.FieldValue.serverTimestamp(),
      status: 'sent'
    });
  }
  
  await batch.commit();
}

// Başarısız FCM token'ları temizle
async function cleanupFailedTokens(failedTokens) {
  const db = admin.firestore();
  const batch = db.batch();
  
  for (const token of failedTokens) {
    const usersSnapshot = await db.collection('users')
      .where('fcmToken', '==', token)
      .get();
    
    usersSnapshot.forEach(doc => {
      batch.update(doc.ref, {
        fcmToken: admin.firestore.FieldValue.delete(),
        tokenUpdatedAt: admin.firestore.FieldValue.serverTimestamp()
      });
    });
  }
  
  await batch.commit();
  console.log(`${failedTokens.length} başarısız token temizlendi`);
}
```

## Bildirim UI Bileşenleri

### 1. Bildirim Ayarları Sayfası

```dart
// lib/screens/notification_settings_screen.dart
class NotificationSettingsScreen extends StatefulWidget {
  @override
  _NotificationSettingsScreenState createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final NotificationPreferencesService _preferencesService = NotificationPreferencesService();
  NotificationPreferences _preferences = NotificationPreferences.defaultPreferences();
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }
  
  Future<void> _loadPreferences() async {
    try {
      final prefs = await _preferencesService.getPreferences();
      setState(() {
        _preferences = prefs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ayarlar yüklenemedi: $e')),
      );
    }
  }
  
  Future<void> _updatePreference(String key, bool value) async {
    try {
      final updatedPrefs = _preferences.copyWith(key: key, value: value);
      await _preferencesService.updatePreferences(updatedPrefs);
      setState(() {
        _preferences = updatedPrefs;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ayar güncellenemedi: $e')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Bildirim Ayarları')),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Bildirim Ayarları'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Genel Bildirimler'),
          _buildSwitchTile(
            'Push Bildirimleri',
            'Uygulama bildirimlerini al',
            _preferences.push,
            (value) => _updatePreference('push', value),
          ),
          _buildSwitchTile(
            'E-posta Bildirimleri',
            'E-posta bildirimlerini al',
            _preferences.email,
            (value) => _updatePreference('email', value),
          ),
          
          SizedBox(height: 24),
          _buildSectionHeader('Program Bildirimleri'),
          _buildSwitchTile(
            'Yeni Program',
            'Yeni program yüklendiğinde bildirim al',
            _preferences.newProgram,
            (value) => _updatePreference('newProgram', value),
          ),
          
          SizedBox(height: 24),
          _buildSectionHeader('Abonelik Bildirimleri'),
          _buildSwitchTile(
            'Abonelik Hatırlatması',
            'Abonelik bitmeden önce hatırlatma al',
            _preferences.subscriptionReminder,
            (value) => _updatePreference('subscriptionReminder', value),
          ),
          
          SizedBox(height: 24),
          _buildSectionHeader('Antrenman Hatırlatması'),
          _buildSwitchTile(
            'Günlük Hatırlatma',
            'Her gün antrenman hatırlatması al',
            _preferences.workoutReminder,
            (value) => _updatePreference('workoutReminder', value),
          ),
          if (_preferences.workoutReminder) ...[
            SizedBox(height: 16),
            _buildTimePicker(),
          ],
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }
  
  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Card(
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blue,
      ),
    );
  }
  
  Widget _buildTimePicker() {
    final time = TimeOfDay.fromDateTime(
      DateTime.parse('1970-01-01 ${_preferences.workoutReminderTime}:00')
    );
    
    return Card(
      child: ListTile(
        title: Text('Hatırlatma Saati'),
        subtitle: Text('${time.format(context)}'),
        trailing: Icon(Icons.access_time),
        onTap: () async {
          final selectedTime = await showTimePicker(
            context: context,
            initialTime: time,
          );
          
          if (selectedTime != null) {
            await _preferencesService.updateWorkoutReminderTime(selectedTime);
            setState(() {
              _preferences = _preferences.copyWith(
                workoutReminderTime: '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}'
              );
            });
          }
        },
      ),
    );
  }
}
```

### 2. Bildirim Geçmişi Sayfası

```dart
// lib/screens/notification_history_screen.dart
class NotificationHistoryScreen extends StatefulWidget {
  @override
  _NotificationHistoryScreenState createState() => _NotificationHistoryScreenState();
}

class _NotificationHistoryScreenState extends State<NotificationHistoryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<NotificationHistory> _notifications = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }
  
  Future<void> _loadNotifications() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', '==', user.uid)
          .orderBy('sentAt', descending: true)
          .limit(50)
          .get();
      
      setState(() {
        _notifications = snapshot.docs
            .map((doc) => NotificationHistory.fromMap(doc.data(), doc.id))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bildirimler yüklenemedi: $e')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Bildirim Geçmişi')),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Bildirim Geçmişi'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Henüz bildirim yok',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return _buildNotificationCard(notification);
              },
            ),
    );
  }
  
  Widget _buildNotificationCard(NotificationHistory notification) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getNotificationColor(notification.type),
          child: Icon(
            _getNotificationIcon(notification.type),
            color: Colors.white,
          ),
        ),
        title: Text(notification.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.body),
            SizedBox(height: 4),
            Text(
              _formatDate(notification.sentAt),
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: _buildStatusIcon(notification.status),
        onTap: () => _handleNotificationTap(notification),
      ),
    );
  }
  
  Color _getNotificationColor(String type) {
    switch (type) {
      case 'new_program': return Colors.green;
      case 'subscription_reminder': return Colors.orange;
      case 'workout_reminder': return Colors.blue;
      case 'payment_success': return Colors.green;
      case 'payment_failed': return Colors.red;
      default: return Colors.grey;
    }
  }
  
  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'new_program': return Icons.fitness_center;
      case 'subscription_reminder': return Icons.schedule;
      case 'workout_reminder': return Icons.alarm;
      case 'payment_success': return Icons.check_circle;
      case 'payment_failed': return Icons.error;
      default: return Icons.notifications;
    }
  }
  
  Widget _buildStatusIcon(String status) {
    switch (status) {
      case 'read': return Icon(Icons.done_all, color: Colors.blue);
      case 'clicked': return Icon(Icons.touch_app, color: Colors.green);
      default: return Icon(Icons.done, color: Colors.grey);
    }
  }
  
  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }
  
  void _handleNotificationTap(NotificationHistory notification) {
    // Bildirime tıklandığında ilgili sayfaya yönlendir
    switch (notification.type) {
      case 'new_program':
        // Program detay sayfasına git
        break;
      case 'subscription_reminder':
        // Abonelik sayfasına git
        break;
      case 'workout_reminder':
        // Antrenman sayfasına git
        break;
    }
  }
}

class NotificationHistory {
  final String id;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final Timestamp sentAt;
  final String status;
  
  NotificationHistory({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    required this.sentAt,
    required this.status,
  });
  
  factory NotificationHistory.fromMap(Map<String, dynamic> map, String id) {
    return NotificationHistory(
      id: id,
      type: map['type'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      data: Map<String, dynamic>.from(map['data'] ?? {}),
      sentAt: map['sentAt'] ?? Timestamp.now(),
      status: map['status'] ?? 'sent',
    );
  }
}
```

## Performans Optimizasyonu

### 1. Batch Bildirim Gönderimi
- Çok sayıda kullanıcıya bildirim gönderirken `sendMulticast` kullan
- Maksimum 500 token'a kadar batch gönderimi yap
- Başarısız token'ları temizle

### 2. Bildirim Sınırlaması
- Kullanıcı başına günlük maksimum bildirim sayısı
- Spam koruması için rate limiting
- Kullanıcı tercihlerine göre filtreleme

### 3. Offline Desteği
- Bildirim tercihlerini local storage'da sakla
- Offline durumda bile ayarlar çalışsın
- Senkronizasyon için background sync

Bu bildirim sistemi, kullanıcı deneyimini artıran ve etkili iletişim sağlayan kapsamlı bir çözümdür. FCM ve Cloud Functions entegrasyonu ile güvenilir ve ölçeklenebilir bildirim gönderimi sağlanır.

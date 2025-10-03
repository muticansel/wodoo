# Firestore Veri Modeli Detayları

## Koleksiyon Yapısı ve Alan Açıklamaları

### 1. users Koleksiyonu

Kullanıcı bilgilerini ve abonelik durumlarını saklar.

```json
{
  "uid": "string (required)",
  "email": "string (required)",
  "displayName": "string (optional)",
  "photoURL": "string (optional)",
  "subscription": {
    "plan": "monthly|quarterly|semi-annual|9-month|yearly",
    "startDate": "timestamp",
    "endDate": "timestamp",
    "isActive": "boolean",
    "paymentId": "string",
    "autoRenew": "boolean"
  },
  "preferences": {
    "language": "tr|en",
    "notifications": {
      "push": "boolean",
      "email": "boolean",
      "newProgram": "boolean",
      "subscriptionReminder": "boolean",
      "workoutReminder": "boolean"
    },
    "theme": "light|dark|system",
    "workoutReminderTime": "string (HH:mm format)"
  },
  "profile": {
    "fitnessLevel": "beginner|intermediate|advanced",
    "goals": ["string"],
    "injuries": ["string"],
    "equipment": ["string"]
  },
  "fcmToken": "string (for push notifications)",
  "createdAt": "timestamp",
  "lastLoginAt": "timestamp",
  "lastActiveAt": "timestamp"
}
```

**Alan Açıklamaları:**
- `uid`: Firebase Auth'dan gelen benzersiz kullanıcı ID'si
- `subscription.plan`: Abonelik planı türü
- `subscription.autoRenew`: Otomatik yenileme durumu
- `preferences.notifications`: Bildirim tercihleri detayları
- `profile.fitnessLevel`: Kullanıcının fitness seviyesi
- `profile.goals`: Kullanıcının hedefleri (örn: ["weight_loss", "muscle_gain"])
- `profile.injuries`: Kullanıcının yaralanma geçmişi
- `profile.equipment`: Kullanıcının sahip olduğu ekipmanlar

### 2. programs Koleksiyonu

Haftalık antrenman programlarını saklar.

```json
{
  "id": "string (auto-generated)",
  "weekNumber": "number (1-52)",
  "year": "number (2024, 2025, etc.)",
  "title": "string (e.g., 'Hafta 1 - Temel Güç')",
  "description": "string (program açıklaması)",
  "difficulty": "beginner|intermediate|advanced|mixed",
  "isActive": "boolean",
  "isPublished": "boolean",
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "createdBy": "string (admin user ID)",
  "tags": ["string"],
  "estimatedDuration": "number (minutes)",
  "days": [
    {
      "dayNumber": "number (1-7)",
      "dayName": "string (Pazartesi, Salı, etc.)",
      "isRestDay": "boolean",
      "focus": "string (e.g., 'Upper Body', 'Cardio')",
      "workouts": [
        {
          "id": "string (auto-generated)",
          "type": "wod|strength|metcon|plyo|accessory|mobility",
          "title": "string",
          "description": "string",
          "duration": "number (minutes)",
          "difficulty": "beginner|intermediate|advanced",
          "equipment": ["string"],
          "exercises": [
            {
              "id": "string",
              "name": "string",
              "description": "string",
              "sets": "number",
              "reps": "string (e.g., '10-12', 'AMRAP 5 min')",
              "weight": "string (e.g., 'Bodyweight', '50% 1RM')",
              "restTime": "string (e.g., '60 seconds', '2 minutes')",
              "notes": "string",
              "videoUrl": "string (optional)",
              "imageUrl": "string (optional)"
            }
          ],
          "warmup": [
            {
              "exercise": "string",
              "duration": "string",
              "description": "string"
            }
          ],
          "cooldown": [
            {
              "exercise": "string",
              "duration": "string",
              "description": "string"
            }
          ]
        }
      ]
    }
  ]
}
```

**Alan Açıklamaları:**
- `difficulty`: Program genel zorluk seviyesi
- `tags`: Program etiketleri (örn: ["strength", "cardio", "beginner"])
- `estimatedDuration`: Tüm haftanın tahmini süresi
- `days.isRestDay`: Dinlenme günü olup olmadığı
- `days.focus`: Günün odak noktası
- `workouts.equipment`: Gerekli ekipmanlar
- `exercises.videoUrl`: Egzersiz video linki (gelecek sürümler için)
- `warmup/cooldown`: Isınma ve soğuma egzersizleri

### 3. user_workouts Koleksiyonu

Kullanıcıların tamamladığı antrenmanları saklar.

```json
{
  "id": "string (auto-generated)",
  "userId": "string (users collection reference)",
  "programId": "string (programs collection reference)",
  "workoutId": "string (workout reference within program)",
  "dayNumber": "number (1-7)",
  "completedAt": "timestamp",
  "startedAt": "timestamp",
  "duration": "number (minutes)",
  "notes": "string (user notes)",
  "rating": "number (1-5)",
  "difficulty": "number (1-5, user's perceived difficulty)",
  "exercises": [
    {
      "exerciseId": "string",
      "completedSets": "number",
      "completedReps": "string",
      "weightUsed": "string",
      "restTime": "number (seconds)",
      "notes": "string"
    }
  ],
  "isCompleted": "boolean",
  "isPartial": "boolean"
}
```

**Alan Açıklamaları:**
- `startedAt`: Antrenman başlama zamanı
- `duration`: Gerçek antrenman süresi
- `rating`: Kullanıcının antrenman değerlendirmesi (1-5)
- `difficulty`: Kullanıcının algıladığı zorluk (1-5)
- `exercises.completedSets`: Tamamlanan set sayısı
- `exercises.weightUsed`: Kullanılan ağırlık
- `isPartial`: Kısmen tamamlanan antrenman

### 4. subscriptions Koleksiyonu

Abonelik bilgilerini ve ödeme detaylarını saklar.

```json
{
  "id": "string (auto-generated)",
  "userId": "string (users collection reference)",
  "plan": "monthly|quarterly|semi-annual|9-month|yearly",
  "status": "active|expired|cancelled|pending|failed",
  "startDate": "timestamp",
  "endDate": "timestamp",
  "cancelledAt": "timestamp (optional)",
  "paymentId": "string (İyizico payment ID)",
  "amount": "number (price in kuruş)",
  "currency": "string (TRY)",
  "paymentMethod": "string (credit_card|bank_card|digital_wallet)",
  "autoRenew": "boolean",
  "nextBillingDate": "timestamp",
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "refundAmount": "number (optional)",
  "refundDate": "timestamp (optional)",
  "refundReason": "string (optional)"
}
```

**Alan Açıklamaları:**
- `status.pending`: Ödeme bekleniyor
- `status.failed`: Ödeme başarısız
- `amount`: Fiyat kuruş cinsinden (örn: 9900 = ₺99.00)
- `paymentMethod`: Kullanılan ödeme yöntemi
- `nextBillingDate`: Sonraki faturalandırma tarihi
- `refundAmount`: İade edilen miktar
- `refundReason`: İade sebebi

### 5. notifications Koleksiyonu

Gönderilen bildirimlerin geçmişini saklar.

```json
{
  "id": "string (auto-generated)",
  "userId": "string (users collection reference)",
  "type": "new_program|subscription_reminder|workout_reminder|payment_success|payment_failed",
  "title": "string",
  "body": "string",
  "data": {
    "programId": "string (optional)",
    "subscriptionId": "string (optional)",
    "workoutId": "string (optional)"
  },
  "sentAt": "timestamp",
  "readAt": "timestamp (optional)",
  "clickedAt": "timestamp (optional)",
  "status": "sent|delivered|failed|read|clicked"
}
```

**Alan Açıklamaları:**
- `type`: Bildirim türü
- `data`: Bildirimle birlikte gönderilen ek veriler
- `status`: Bildirimin durumu
- `readAt`: Kullanıcının bildirimi okuduğu zaman
- `clickedAt`: Kullanıcının bildirime tıkladığı zaman

### 6. app_settings Koleksiyonu

Uygulama genel ayarlarını saklar.

```json
{
  "id": "string (auto-generated)",
  "key": "string (unique key)",
  "value": "any (string|number|boolean|object)",
  "description": "string",
  "updatedAt": "timestamp",
  "updatedBy": "string (admin user ID)"
}
```

**Örnek Veriler:**
```json
{
  "key": "subscription_prices",
  "value": {
    "monthly": 9900,
    "quarterly": 24900,
    "semi_annual": 45900,
    "9_month": 63900,
    "yearly": 79900
  },
  "description": "Abonelik fiyatları (kuruş cinsinden)"
}
```

## İndeksler

### Firestore İndeksleri

```javascript
// users koleksiyonu için
users: [
  { fields: ["subscription.isActive"], order: ["subscription.isActive"] },
  { fields: ["preferences.notifications.push"], order: ["preferences.notifications.push"] },
  { fields: ["createdAt"], order: ["createdAt", "desc"] }
]

// programs koleksiyonu için
programs: [
  { fields: ["isActive", "isPublished"], order: ["isActive", "isPublished"] },
  { fields: ["year", "weekNumber"], order: ["year", "weekNumber", "desc"] },
  { fields: ["difficulty"], order: ["difficulty"] },
  { fields: ["tags"], order: ["tags"] }
]

// user_workouts koleksiyonu için
user_workouts: [
  { fields: ["userId", "completedAt"], order: ["userId", "completedAt", "desc"] },
  { fields: ["userId", "isCompleted"], order: ["userId", "isCompleted"] },
  { fields: ["programId", "dayNumber"], order: ["programId", "dayNumber"] }
]

// subscriptions koleksiyonu için
subscriptions: [
  { fields: ["userId", "status"], order: ["userId", "status"] },
  { fields: ["status", "endDate"], order: ["status", "endDate"] },
  { fields: ["paymentId"], order: ["paymentId"] }
]

// notifications koleksiyonu için
notifications: [
  { fields: ["userId", "sentAt"], order: ["userId", "sentAt", "desc"] },
  { fields: ["userId", "status"], order: ["userId", "status"] },
  { fields: ["type", "sentAt"], order: ["type", "sentAt", "desc"] }
]
```

## Veri Doğrulama Kuralları

### Firestore Security Rules ile Veri Doğrulama

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Kullanıcı verileri doğrulama
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Abonelik verisi doğrulama
      function validateSubscription() {
        return request.resource.data.subscription.plan in ['monthly', 'quarterly', 'semi-annual', '9-month', 'yearly'] &&
               request.resource.data.subscription.isActive is bool &&
               request.resource.data.subscription.startDate is timestamp &&
               request.resource.data.subscription.endDate is timestamp;
      }
      
      allow update: if request.auth != null && 
        request.auth.uid == userId && 
        validateSubscription();
    }
    
    // Program verileri doğrulama
    match /programs/{programId} {
      allow read: if request.auth != null && 
        exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.subscription.isActive == true;
      
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
      
      // Program verisi doğrulama
      function validateProgram() {
        return request.resource.data.weekNumber >= 1 && 
               request.resource.data.weekNumber <= 52 &&
               request.resource.data.year >= 2024 &&
               request.resource.data.isActive is bool &&
               request.resource.data.isPublished is bool;
      }
      
      allow create, update: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin' &&
        validateProgram();
    }
  }
}
```

## Performans Optimizasyonu

### 1. Veri Pagination
```javascript
// Programları sayfalama ile getir
const getPrograms = async (lastDoc = null, limit = 10) => {
  let query = db.collection('programs')
    .where('isActive', '==', true)
    .where('isPublished', '==', true)
    .orderBy('year', 'desc')
    .orderBy('weekNumber', 'desc')
    .limit(limit);
    
  if (lastDoc) {
    query = query.startAfter(lastDoc);
  }
  
  return await query.get();
};
```

### 2. Veri Caching
```javascript
// Offline cache için
const enableOfflinePersistence = () => {
  db.enablePersistence()
    .catch((err) => {
      if (err.code == 'failed-precondition') {
        console.log('Multiple tabs open, persistence can only be enabled in one tab at a time.');
      } else if (err.code == 'unimplemented') {
        console.log('The current browser does not support all features required for persistence');
      }
    });
};
```

### 3. Compound Queries
```javascript
// Kullanıcının tamamladığı antrenmanları getir
const getUserCompletedWorkouts = async (userId, programId) => {
  return await db.collection('user_workouts')
    .where('userId', '==', userId)
    .where('programId', '==', programId)
    .where('isCompleted', '==', true)
    .orderBy('completedAt', 'desc')
    .get();
};
```

Bu detaylı Firestore şeması, CrossFit antrenman uygulamasının tüm veri ihtiyaçlarını karşılayacak şekilde tasarlanmıştır. Performans, güvenlik ve ölçeklenebilirlik göz önünde bulundurularak optimize edilmiştir.

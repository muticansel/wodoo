# CrossFit Antrenman Programı Mobil Uygulaması

## Proje Genel Bakış

Bu proje, CrossFit sporuyla ilgilenen atletler için online haftalık antrenman programı sunan bir mobil uygulamadır. Flutter frontend ve Firebase backend teknolojileri kullanılarak geliştirilmiştir.

## İçindekiler

1. [Proje Amacı ve Hedef Kitle](#proje-amacı-ve-hedef-kitle)
2. [Kullanıcı Rolleri](#kullanıcı-rolleri)
3. [Özellikler](#özellikler)
4. [Firebase Servisleri](#firebase-servisleri)
5. [Mimari Şema](#mimari-şema)
6. [Veri Modeli](#veri-modeli)
7. [Kullanıcı Akış Diyagramları](#kullanıcı-akış-diyagramları)
8. [Ekran Tasarımları](#ekran-tasarımları)
9. [Güvenlik](#güvenlik)
10. [Test Planı](#test-planı)
11. [Geliştirme Roadmap'i](#geliştirme-roadmapi)
12. [Abonelik Modeli](#abonelik-modeli)
13. [Bildirim Sistemi](#bildirim-sistemi)

## Proje Amacı ve Hedef Kitle

### Amaç
CrossFit antrenmanlarını sistematik bir şekilde takip etmek isteyen atletler için haftalık programlar sunan, abonelik tabanlı bir mobil uygulama geliştirmek.

### Hedef Kitle
- CrossFit sporuna yeni başlayanlar
- Orta seviye CrossFit atletleri
- İleri seviye CrossFit atletleri
- Antrenman programlarını takip etmek isteyen fitness meraklıları

## Kullanıcı Rolleri

### Admin
- **Yetkiler:**
  - Firebase konsolundan haftalık program ekleme
  - Program içeriklerini düzenleme
  - Kullanıcı yönetimi
  - Abonelik durumlarını görüntüleme
  - Analitik verileri inceleme

### Athlete (Atlet)
- **Yetkiler:**
  - Mobil uygulamadan programları görüntüleme
  - Antrenman geçmişini takip etme
  - Abonelik yönetimi
  - Profil ayarları
  - Bildirim tercihleri

## Özellikler

### 1. Authentication (Kimlik Doğrulama)
- **Google Sign-In:** Hızlı ve güvenli giriş
- **E-posta/Şifre:** Geleneksel giriş yöntemi
- **Sosyal Medya Girişi:** Facebook, Apple ID entegrasyonu
- **Anonim Giriş:** Demo amaçlı sınırlı erişim

### 2. Program Yönetimi
- **Haftalık Programlar:** 7 günlük antrenman döngüleri
- **Antrenman Türleri:**
  - WOD (Workout of the Day)
  - Strength (Güç antrenmanları)
  - Metcon (Metabolik kondisyon)
  - Plyo (Pliometrik antrenmanlar)
  - Accessory (Yardımcı egzersizler)
- **Program Geçmişi:** Önceki haftaların programlarına erişim

### 3. Antrenman Ekranı
- **Metin Tabanlı İçerik:** Detaylı antrenman açıklamaları
- **Egzersiz Listesi:** Adım adım talimatlar
- **Set/Rep Bilgileri:** Tekrar ve set sayıları
- **Dinlenme Süreleri:** Antrenman arası molalar
- **Not Alma:** Kişisel antrenman notları
- **YENİ:** **Egzersiz Sıra Numaraları:** 1, 2, 3... numaralandırma
- **YENİ:** **Akıllı Ağırlık Hesaplama:** % bazlı otomatik hesaplama
- **YENİ:** **Complex Lift Detection:** Power lift'lerden otomatik yüzde alma
- **YENİ:** **PR's Entegrasyonu:** Kişisel rekorlardan ağırlık hesaplama

### 4. Abonelik Sistemi
- **Abonelik Seçenekleri:**
  - Aylık: ₺99/ay
  - 3 Aylık: ₺249 (₺83/ay)
  - 6 Aylık: ₺459 (₺76.5/ay)
  - 9 Aylık: ₺639 (₺71/ay)
  - Yıllık: ₺799 (₺66.6/ay)
- **Otomatik Yenileme:** Abonelik süresi dolmadan önce uyarı
- **İptal Etme:** Anytime iptal seçeneği

### 5. Ödeme Entegrasyonu
- **İyizico Entegrasyonu:** Flutter SDK ve REST API
- **Güvenli Ödeme:** SSL şifreleme
- **Çoklu Ödeme Yöntemi:** Kredi kartı, banka kartı, dijital cüzdan
- **Fatura Sistemi:** Otomatik fatura oluşturma

### 6. Bildirimler
- **Push Notifications:** Yeni program yüklendiğinde
- **Abonelik Hatırlatmaları:** Süre dolmadan önce uyarı
- **Antrenman Hatırlatmaları:** Günlük antrenman bildirimleri
- **Özelleştirilebilir:** Kullanıcı tercihlerine göre ayarlanabilir

### 7. Çoklu Dil Desteği
- **Desteklenen Diller:** Türkçe, İngilizce
- **intl Paketi:** Flutter'ın resmi çoklu dil paketi
- **Dinamik Dil Değişimi:** Uygulama içinde dil değiştirme
- **Yerelleştirme:** Tarih, sayı formatları

### 8. Tasarım
- **Modern Gradient Tasarım:** B22B69 (Pembe) ve 2889B8 (Mavi) renk paleti
- **Material Design 3:** Modern Android tasarım dili
- **Custom Components:** Özel butonlar, input alanları, kartlar
- **Animasyonlar:** Smooth transitions ve micro-interactions
- **Skeleton Loading:** Loading states için modern skeleton screens
- **Responsive:** Farklı ekran boyutlarına uyum
- **YENİ:** **PR's Sistemi:** 13 farklı lift için kişisel rekor takibi

## Firebase Servisleri

### 1. Authentication
- Kullanıcı kimlik doğrulama
- Çoklu giriş yöntemleri
- Güvenli oturum yönetimi

### 2. Firestore
- NoSQL veritabanı
- Gerçek zamanlı veri senkronizasyonu
- Offline veri desteği

### 3. Cloud Storage
- Antrenman görselleri
- Video içerikleri (gelecek sürümler için)
- Dosya yönetimi

### 4. Cloud Functions
- Ödeme doğrulama
- Abonelik yönetimi
- Bildirim gönderimi
- Veri işleme

### 5. Cloud Messaging (FCM)
- Push notification gönderimi
- Hedefli bildirimler
- Bildirim analitikleri

### 6. Analytics
- Kullanıcı davranış analizi
- Uygulama performans metrikleri
- Özelleştirilmiş raporlar

## Mimari Şema

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │    │   Firebase      │    │   External      │
│                 │    │   Backend       │    │   Services      │
├─────────────────┤    ├─────────────────┤    ├─────────────────┤
│ • UI Layer      │◄──►│ • Authentication│    │ • İyizico       │
│ • State Mgmt    │    │ • Firestore     │    │ • FCM           │
│ • Business Logic│    │ • Cloud Functions│   │ • Analytics     │
│ • Data Layer    │    │ • Cloud Storage │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Veri Modeli (Firestore Koleksiyon Yapısı)

### 1. users
```json
{
  "uid": "string",
  "email": "string",
  "displayName": "string",
  "photoURL": "string",
  "subscription": {
    "plan": "monthly|quarterly|semi-annual|9-month|yearly",
    "startDate": "timestamp",
    "endDate": "timestamp",
    "isActive": "boolean",
    "paymentId": "string"
  },
  "preferences": {
    "language": "tr|en",
    "notifications": "boolean",
    "theme": "light|dark"
  },
  "createdAt": "timestamp",
  "lastLoginAt": "timestamp"
}
```

### 2. programs
```json
{
  "id": "string",
  "weekNumber": "number",
  "year": "number",
  "title": "string",
  "description": "string",
  "isActive": "boolean",
  "createdAt": "timestamp",
  "createdBy": "string",
  "days": [
    {
      "dayNumber": "number",
      "dayName": "string",
      "workouts": [
        {
          "id": "string",
          "type": "wod|strength|metcon|plyo|accessory",
          "title": "string",
          "description": "string",
          "exercises": [
            {
              "name": "string",
              "sets": "number",
              "reps": "string",
              "weight": "string",
              "restTime": "string",
              "notes": "string"
            }
          ],
          "duration": "string",
          "difficulty": "beginner|intermediate|advanced"
        }
      ]
    }
  ]
}
```

### 3. user_workouts
```json
{
  "id": "string",
  "userId": "string",
  "programId": "string",
  "workoutId": "string",
  "completedAt": "timestamp",
  "notes": "string",
  "rating": "number",
  "duration": "number"
}
```

### 4. subscriptions
```json
{
  "id": "string",
  "userId": "string",
  "plan": "string",
  "status": "active|expired|cancelled",
  "startDate": "timestamp",
  "endDate": "timestamp",
  "paymentId": "string",
  "amount": "number",
  "currency": "string",
  "createdAt": "timestamp"
}
```

## Kullanıcı Akış Diyagramları

### Kayıt/Giriş Akışı
```
Başlangıç
    ↓
Uygulama Açılışı
    ↓
Giriş Yapılmış mı?
    ├─ Evet → Ana Sayfa
    └─ Hayır → Giriş/Kayıt Ekranı
                ↓
            Giriş Yöntemi Seç
                ↓
        ┌─────────────────┐
        │ Google | Email | Sosyal │
        └─────────────────┘
                ↓
            Kimlik Doğrulama
                ↓
            Başarılı mı?
            ├─ Evet → Ana Sayfa
            └─ Hayır → Hata Mesajı
```

### Abonelik Akışı
```
Ana Sayfa
    ↓
Abonelik Var mı?
├─ Evet → Program Listesi
└─ Hayır → Abonelik Seçenekleri
            ↓
        Plan Seç
            ↓
        Ödeme Ekranı
            ↓
        İyizico Ödeme
            ↓
        Ödeme Başarılı?
        ├─ Evet → Cloud Function → Erişim Aç
        └─ Hayır → Hata Mesajı
```

## Ekran Tasarımları (Wireframe)

### 1. Login Ekranı
```
┌─────────────────────────┐
│     CrossFit App        │
│                         │
│    [Logo/Icon]          │
│                         │
│  ┌─────────────────┐    │
│  │  Google ile     │    │
│  │  Giriş Yap      │    │
│  └─────────────────┘    │
│                         │
│  ┌─────────────────┐    │
│  │  E-posta ile    │    │
│  │  Giriş Yap      │    │
│  └─────────────────┘    │
│                         │
│  ┌─────────────────┐    │
│  │  Misafir Giriş  │    │
│  └─────────────────┘    │
└─────────────────────────┘
```

### 2. Abonelik Satın Alma Ekranı
```
┌─────────────────────────┐
│  ← Abonelik Planları    │
│                         │
│  ┌─────────────────┐    │
│  │   Aylık         │    │
│  │   ₺99/ay        │    │
│  │   [Seç]         │    │
│  └─────────────────┘    │
│                         │
│  ┌─────────────────┐    │
│  │   3 Aylık       │    │
│  │   ₺249          │    │
│  │   [Seç]         │    │
│  └─────────────────┘    │
│                         │
│  ┌─────────────────┐    │
│  │   Yıllık        │    │
│  │   ₺799          │    │
│  │   [Seç]         │    │
│  └─────────────────┘    │
│                         │
│  ┌─────────────────┐    │
│  │   Ödemeye Geç   │    │
│  └─────────────────┘    │
└─────────────────────────┘
```

### 3. Haftalık Program Listesi
```
┌─────────────────────────┐
│  ≡ Haftalık Programlar  │
│                         │
│  Hafta 1 (2024)         │
│  ┌─────────────────┐    │
│  │ Pazartesi       │    │
│  │ WOD + Strength  │    │
│  │ 45 dk           │    │
│  └─────────────────┘    │
│                         │
│  ┌─────────────────┐    │
│  │ Salı            │    │
│  │ Metcon          │    │
│  │ 30 dk           │    │
│  └─────────────────┘    │
│                         │
│  ┌─────────────────┐    │
│  │ Çarşamba        │    │
│  │ Rest Day        │    │
│  └─────────────────┘    │
└─────────────────────────┘
```

### 4. Antrenman Detay Ekranı
```
┌─────────────────────────┐
│  ← WOD + Strength       │
│                         │
│  Süre: 45 dakika        │
│  Zorluk: Orta           │
│                         │
│  ┌─────────────────┐    │
│  │ WARM-UP         │    │
│  │ • 5 dk koşu     │    │
│  │ • Dinamik       │    │
│  │   esneme        │    │
│  └─────────────────┘    │
│                         │
│  ┌─────────────────┐    │
│  │ WOD             │    │
│  │ 3 Rounds:       │    │
│  │ • 15 Burpees    │    │
│  │ • 20 Air Squats │    │
│  │ • 400m Run      │    │
│  └─────────────────┘    │
│                         │
│  ┌─────────────────┐    │
│  │ [Başla]         │    │
│  └─────────────────┘    │
└─────────────────────────┘
```

### 5. Profil Ekranı
```
┌─────────────────────────┐
│  ← Profil               │
│                         │
│  [Profil Fotoğrafı]     │
│  Kullanıcı Adı          │
│  user@email.com         │
│                         │
│  ┌─────────────────┐    │
│  │ Abonelik        │    │
│  │ Aylık - Aktif   │    │
│  │ 15 gün kaldı    │    │
│  └─────────────────┘    │
│                         │
│  ┌─────────────────┐    │
│  │ Dil Seçimi      │    │
│  │ Türkçe ▼        │    │
│  └─────────────────┘    │
│                         │
│  ┌─────────────────┐    │
│  │ Bildirimler     │    │
│  │ Açık            │    │
│  └─────────────────┘    │
│                         │
│  ┌─────────────────┐    │
│  │ Çıkış Yap       │    │
│  └─────────────────┘    │
└─────────────────────────┘
```

## Güvenlik

### Firestore Güvenlik Kuralları

```javascript
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
  }
}
```

### Ek Güvenlik Önlemleri
- **HTTPS Zorunluluğu:** Tüm API çağrıları HTTPS üzerinden
- **API Rate Limiting:** Cloud Functions'da istek sınırlaması
- **Veri Şifreleme:** Hassas verilerin şifrelenmesi
- **Token Yönetimi:** JWT token'ların güvenli yönetimi

## Test Planı

### 1. Unit Testler
- **Authentication servisleri**
- **Veri modelleri**
- **Business logic fonksiyonları**
- **Utility fonksiyonları**

### 2. Widget Testler
- **UI bileşenleri**
- **Form validasyonları**
- **Navigasyon testleri**
- **State yönetimi testleri**

### 3. Entegrasyon Testleri
- **Firebase bağlantıları**
- **Ödeme entegrasyonu**
- **Bildirim sistemi**
- **Çoklu dil desteği**

### 4. E2E Testler
- **Kullanıcı akışları**
- **Abonelik süreçleri**
- **Antrenman takibi**
- **Bildirim alımı**

## Geliştirme Roadmap'i

### MVP (Minimum Viable Product) - 4 Hafta ✅ TAMAMLANDI
- [x] Temel Flutter proje yapısı
- [x] Firebase Authentication entegrasyonu (E-posta/Şifre, Anonim)
- [x] Modern UI/UX tasarımı (Material Design 3, Gradient themes)
- [x] Firestore veri modeli (Programs, Users, Subscriptions)
- [x] Program görüntüleme sistemi
- [x] **YENİ:** PR's (Personal Records) sistemi - 13 farklı lift
- [x] **YENİ:** Akıllı Complex Lift Detection sistemi
- [x] **YENİ:** Otomatik ağırlık hesaplama (% bazlı)
- [x] **YENİ:** Egzersiz sıra numaraları
- [x] **YENİ:** Abonelik sistemi (Premium/Free)
- [x] **YENİ:** Modern navigation (Bottom Tab + Drawer)
- [x] **YENİ:** Profil yönetimi
- [x] **YENİ:** Skeleton loading states
- [x] **YENİ:** Animasyonlar ve transitions

### Faz 1 - Çoklu Dil Desteği - 1 Hafta
- [ ] intl paketi entegrasyonu
- [ ] Türkçe/İngilizce çeviriler
- [ ] Dinamik dil değişimi
- [ ] Yerelleştirme testleri

### Faz 2 - Bildirim Sistemi - 2 Hafta
- [ ] FCM entegrasyonu
- [ ] Cloud Functions bildirim servisi
- [ ] Bildirim tercihleri
- [ ] Hedefli bildirimler

### Faz 3 - Gelişmiş Özellikler - 3 Hafta
- [ ] Offline cache sistemi
- [ ] Antrenman geçmişi
- [ ] İstatistikler ve analitikler
- [ ] Sosyal özellikler

### Faz 4 - Ödeme Entegrasyonu - 2 Hafta
- [ ] İyizico SDK entegrasyonu
- [ ] Abonelik yönetimi
- [ ] Cloud Functions ödeme doğrulama
- [ ] Güvenlik kuralları

### Faz 5 - Optimizasyon - 2 Hafta
- [ ] Performans optimizasyonu
- [ ] UI/UX iyileştirmeleri
- [ ] Test coverage artırma
- [ ] Dokümantasyon tamamlama

## Abonelik Modeli

### Ödeme Akış Diyagramı
```
Kullanıcı Plan Seçer
        ↓
İyizico Ödeme Sayfası
        ↓
Ödeme İşlemi
        ↓
İyizico Webhook → Cloud Function
        ↓
Ödeme Doğrulama
        ↓
Firestore'da Abonelik Oluştur
        ↓
Kullanıcıya Erişim Ver
        ↓
Başarı Bildirimi Gönder
```

### Abonelik Yönetimi
- **Otomatik Yenileme:** Abonelik bitmeden 3 gün önce uyarı
- **İptal Etme:** Anytime iptal, mevcut dönem sonuna kadar erişim
- **Plan Değiştirme:** Mevcut planı iptal et, yeni plan satın al
- **Fatura Yönetimi:** E-posta ile otomatik fatura gönderimi

## Bildirim Sistemi

### Cloud Functions + FCM Entegrasyonu

```javascript
// Cloud Function - Yeni Program Bildirimi
exports.sendNewProgramNotification = functions.firestore
  .document('programs/{programId}')
  .onCreate(async (snap, context) => {
    const program = snap.data();
    
    // Aktif abonelik sahibi kullanıcıları al
    const users = await admin.firestore()
      .collection('users')
      .where('subscription.isActive', '==', true)
      .get();
    
    const tokens = [];
    users.forEach(doc => {
      if (doc.data().preferences.notifications) {
        tokens.push(doc.data().fcmToken);
      }
    });
    
    // Bildirim gönder
    const message = {
      notification: {
        title: 'Yeni Program Yüklendi!',
        body: `${program.title} programı hazır.`
      },
      data: {
        type: 'new_program',
        programId: context.params.programId
      },
      tokens: tokens
    };
    
    return admin.messaging().sendMulticast(message);
  });
```

### Bildirim Türleri
1. **Yeni Program:** Haftalık program yüklendiğinde
2. **Abonelik Hatırlatması:** Süre dolmadan 3 gün önce
3. **Antrenman Hatırlatması:** Günlük antrenman zamanı
4. **Ödeme Başarılı:** Abonelik satın alındığında
5. **Ödeme Hatası:** Ödeme işlemi başarısız olduğunda

---

Bu dokümantasyon, CrossFit antrenman programı mobil uygulamasının tüm teknik detaylarını içermektedir. Proje geliştirme sürecinde bu dokümantasyon güncellenerek takip edilecektir.

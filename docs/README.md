# CrossFit Antrenman Programı Mobil Uygulaması - Dokümantasyon

Bu dokümantasyon, Flutter frontend ve Firebase backend kullanılarak geliştirilmiş CrossFit antrenman programı mobil uygulamasının tüm teknik detaylarını içerir.

## 📋 İçindekiler

### 1. [Ana Dokümantasyon](./README.md)
- Proje genel bakışı
- Kullanıcı rolleri ve özellikler
- Firebase servisleri
- Mimari şema
- Veri modeli
- Kullanıcı akış diyagramları
- Ekran tasarımları
- Güvenlik
- Test planı
- Geliştirme roadmap'i

### 2. [Firestore Veri Modeli](./firestore-schema.md)
- Detaylı koleksiyon yapısı
- Alan açıklamaları
- İndeksler ve performans optimizasyonu
- Veri doğrulama kuralları
- Güvenlik kuralları

### 3. [Abonelik Modeli ve Ödeme Akışı](./subscription-flow.md)
- Abonelik planları ve fiyatlandırma
- İyizico entegrasyonu
- Cloud Functions ödeme doğrulama
- Abonelik yönetimi
- Güvenlik önlemleri

### 4. [Bildirim Sistemi](./notification-system.md)
- FCM entegrasyonu
- Bildirim türleri ve akışları
- Cloud Functions bildirim servisi
- Bildirim tercihleri yönetimi
- UI bileşenleri

### 5. [Mimari Diyagramları](./architecture-diagrams.md)
- Sistem mimarisi
- Veri akış diyagramları
- Kullanıcı rolleri ve yetkileri
- Firebase servisleri entegrasyonu
- Performans optimizasyonu
- Hata yönetimi

### 6. [Geliştirme Rehberi](./development-guide.md)
- Proje kurulumu
- Clean Architecture uygulaması
- State Management (Riverpod)
- Firebase yapılandırması
- Test stratejisi
- Performans optimizasyonu

### 7. [API Dokümantasyonu](./api-documentation.md)
- Firebase Cloud Functions API
- İyizico Payment API
- Error responses ve hata kodları
- Rate limiting
- Webhooks
- SDK örnekleri

### 8. [Test Stratejisi](./testing-strategy.md)
- Test yaklaşımı ve piramidi
- Unit testler
- Widget testler
- Integration testler
- Performance testler
- CI/CD entegrasyonu

### 9. [Deployment Rehberi](./deployment-guide.md)
- Firebase projesi kurulumu
- Cloud Functions deployment
- Flutter app deployment
- Environment yapılandırması
- CI/CD pipeline
- Monitoring ve logging

### 10. [Proje Özeti](./project-summary.md)
- Teknoloji stack'i
- Ana özellikler
- Mimari yapı
- Veri modeli
- Güvenlik
- Performans optimizasyonu
- Test stratejisi
- Deployment
- Monitoring ve analytics
- Roadmap
- Başarı metrikleri
- Risk analizi

## 🚀 Hızlı Başlangıç

### Gereksinimler
- Flutter SDK 3.16.0+
- Dart SDK 3.2.0+
- Firebase CLI
- Android Studio / VS Code
- Node.js 18+

### Kurulum
```bash
# Projeyi klonla
git clone https://github.com/your-org/crossfit-app.git
cd crossfit-app

# Dependencies yükle
flutter pub get

# Firebase yapılandırması
firebase init
flutterfire configure

# Uygulamayı çalıştır
flutter run
```

## 📱 Özellikler

### Kullanıcı Özellikleri
- **Authentication:** Google, e-posta, sosyal giriş
- **Program Görüntüleme:** Haftalık antrenman programları
- **Antrenman Takibi:** Detaylı antrenman içerikleri
- **Abonelik Yönetimi:** 5 farklı abonelik planı
- **Bildirimler:** Push notification desteği
- **Çoklu Dil:** Türkçe ve İngilizce

### Admin Özellikleri
- **Program Yönetimi:** Haftalık program oluşturma/düzenleme
- **Kullanıcı Yönetimi:** Kullanıcı bilgileri ve abonelik durumu
- **Analitik:** Kullanıcı davranış analizi
- **Bildirim Gönderimi:** Hedefli bildirimler

## 🏗️ Mimari

### Clean Architecture
```
┌─────────────────┐
│  Presentation   │ ← UI, State Management
├─────────────────┤
│    Domain       │ ← Business Logic
├─────────────────┤
│     Data        │ ← Repositories, Data Sources
└─────────────────┘
```

### Teknoloji Stack
- **Frontend:** Flutter, Dart, Riverpod
- **Backend:** Firebase (Auth, Firestore, Functions, Storage)
- **Payment:** İyizico
- **Notifications:** FCM
- **Analytics:** Firebase Analytics

## 🔒 Güvenlik

### Firebase Security Rules
- Kullanıcılar sadece kendi verilerine erişebilir
- Programlar sadece abonelik sahibi kullanıcılar görebilir
- Admin kullanıcılar program oluşturabilir/düzenleyebilir

### API Güvenliği
- HTTPS zorunluluğu
- JWT token doğrulama
- Rate limiting
- Input validation

## 🧪 Test

### Test Coverage
- **Domain Layer:** 95%
- **Data Layer:** 90%
- **Presentation Layer:** 85%
- **Overall:** 90%

### Test Türleri
- Unit Tests
- Widget Tests
- Integration Tests
- E2E Tests
- Performance Tests

## 📊 Monitoring

### Firebase Services
- Analytics
- Crashlytics
- Performance Monitoring
- Remote Config

### Custom Metrics
- User Engagement
- Subscription Metrics
- Workout Completion
- Performance Metrics

## 🚀 Deployment

### Platform Desteği
- **Android:** API 21+ (Android 5.0+)
- **iOS:** iOS 12.0+
- **Firebase:** Multi-region

### CI/CD
- GitHub Actions
- Automated Testing
- Firebase Deployment
- Flutter Build

## 📈 Roadmap

### MVP (4 Hafta)
- [x] Temel proje yapısı
- [x] Firebase entegrasyonu
- [x] UI/UX tasarımı
- [x] Veri modeli
- [x] Program görüntüleme

### Faz 1 - Ödeme (2 Hafta)
- [ ] İyizico entegrasyonu
- [ ] Abonelik yönetimi
- [ ] Cloud Functions
- [ ] Güvenlik kuralları

### Faz 2 - Çoklu Dil (1 Hafta)
- [ ] intl paketi
- [ ] Çeviriler
- [ ] Dinamik dil değişimi
- [ ] Testler

### Faz 3 - Bildirimler (2 Hafta)
- [ ] FCM entegrasyonu
- [ ] Cloud Functions
- [ ] Bildirim tercihleri
- [ ] Hedefli bildirimler

### Faz 4 - Gelişmiş Özellikler (3 Hafta)
- [ ] Offline cache
- [ ] Antrenman geçmişi
- [ ] İstatistikler
- [ ] Sosyal özellikler

### Faz 5 - Optimizasyon (2 Hafta)
- [ ] Performans
- [ ] UI/UX
- [ ] Test coverage
- [ ] Dokümantasyon

## 📞 İletişim

- **Proje Yöneticisi:** [İsim] - [email]
- **Teknik Lider:** [İsim] - [email]
- **UI/UX Tasarımcı:** [İsim] - [email]
- **Backend Geliştirici:** [İsim] - [email]
- **Mobile Geliştirici:** [İsim] - [email]

## 📄 Lisans

Bu proje [MIT Lisansı](LICENSE) altında lisanslanmıştır.

## 🤝 Katkıda Bulunma

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Commit yapın (`git commit -m 'Add amazing feature'`)
4. Push yapın (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

## 📚 Ek Kaynaklar

- [Flutter Dokümantasyonu](https://flutter.dev/docs)
- [Firebase Dokümantasyonu](https://firebase.google.com/docs)
- [Riverpod Dokümantasyonu](https://riverpod.dev/docs)
- [İyizico Dokümantasyonu](https://dev.iyizico.com/)
- [Material Design 3](https://m3.material.io/)

---

Bu dokümantasyon, CrossFit antrenman uygulamasının tüm teknik detaylarını kapsamlı bir şekilde açıklamaktadır. Her bölüm, projenin farklı bir yönünü detaylandırarak geliştirme ekibinin projeyi daha iyi anlamasını sağlar.


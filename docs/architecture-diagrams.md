# Mimari Diyagramları ve Sistem Şemaları

## 1. Genel Sistem Mimarisi

```mermaid
graph TB
    subgraph "Client Layer"
        A[Flutter Mobile App]
        B[Admin Web Panel]
    end
    
    subgraph "Firebase Backend"
        C[Authentication]
        D[Firestore Database]
        E[Cloud Storage]
        F[Cloud Functions]
        G[Cloud Messaging]
        H[Analytics]
    end
    
    subgraph "External Services"
        I[İyizico Payment]
        J[Push Notifications]
        K[Email Service]
    end
    
    A --> C
    A --> D
    A --> E
    A --> F
    A --> G
    A --> H
    
    B --> C
    B --> D
    B --> E
    B --> F
    
    F --> I
    F --> J
    F --> K
    
    D --> F
    G --> A
```

## 2. Veri Akış Diyagramı

```mermaid
sequenceDiagram
    participant U as User
    participant A as Flutter App
    participant F as Firebase Auth
    participant D as Firestore
    participant CF as Cloud Functions
    participant P as İyizico
    
    U->>A: Uygulamayı aç
    A->>F: Kimlik doğrula
    F-->>A: Token döndür
    
    U->>A: Abonelik satın al
    A->>P: Ödeme isteği
    P-->>A: Ödeme sayfası
    U->>P: Ödeme bilgileri
    P->>CF: Webhook (başarılı ödeme)
    CF->>D: Abonelik oluştur
    CF->>A: Bildirim gönder
    A->>D: Programları getir
    
    U->>A: Antrenman görüntüle
    A->>D: Program verisi al
    D-->>A: Antrenman detayları
    A-->>U: Antrenman göster
```

## 3. Kullanıcı Rolleri ve Yetkileri

```mermaid
graph TD
    subgraph "Admin Role"
        A1[Program Oluşturma]
        A2[Program Düzenleme]
        A3[Kullanıcı Yönetimi]
        A4[Analitik Görüntüleme]
        A5[Bildirim Gönderme]
    end
    
    subgraph "Athlete Role"
        B1[Program Görüntüleme]
        B2[Antrenman Takibi]
        B3[Profil Yönetimi]
        B4[Abonelik Yönetimi]
        B5[Bildirim Ayarları]
    end
    
    subgraph "Guest Role"
        C1[Sınırlı Program Görüntüleme]
        C2[Kayıt Olma]
        C3[Demo Erişim]
    end
    
    A1 --> A2
    A2 --> A3
    A3 --> A4
    A4 --> A5
    
    B1 --> B2
    B2 --> B3
    B3 --> B4
    B4 --> B5
    
    C1 --> C2
    C2 --> B1
```

## 4. Firebase Servisleri Entegrasyonu

```mermaid
graph LR
    subgraph "Flutter App"
        A[UI Layer]
        B[Business Logic]
        C[Data Layer]
    end
    
    subgraph "Firebase Services"
        D[Authentication]
        E[Firestore]
        F[Storage]
        G[Functions]
        H[Messaging]
        I[Analytics]
    end
    
    A --> B
    B --> C
    C --> D
    C --> E
    C --> F
    C --> G
    C --> H
    C --> I
    
    D --> B
    E --> B
    F --> B
    G --> B
    H --> A
    I --> B
```

## 5. Abonelik Yaşam Döngüsü

```mermaid
stateDiagram-v2
    [*] --> Guest: Uygulama açılışı
    Guest --> Trial: 7 gün ücretsiz deneme
    Trial --> Subscribed: Ödeme yapıldı
    Trial --> Expired: Deneme süresi bitti
    Subscribed --> Renewed: Otomatik yenileme
    Subscribed --> Cancelled: Kullanıcı iptal etti
    Subscribed --> Expired: Ödeme başarısız
    Renewed --> Subscribed: Yenileme başarılı
    Cancelled --> Expired: İptal edildi
    Expired --> Subscribed: Yeni abonelik
    Expired --> [*]: Uygulamadan çıkış
```

## 6. Bildirim Sistemi Akışı

```mermaid
graph TD
    A[Trigger Event] --> B{Event Type?}
    
    B -->|New Program| C[Admin Program Yükledi]
    B -->|Subscription| D[Abonelik Durumu Değişti]
    B -->|Workout| E[Antrenman Hatırlatması]
    B -->|Payment| F[Ödeme İşlemi]
    
    C --> G[Cloud Function: sendNewProgramNotification]
    D --> H[Cloud Function: sendSubscriptionNotification]
    E --> I[Cloud Function: sendWorkoutReminder]
    F --> J[Cloud Function: sendPaymentNotification]
    
    G --> K[FCM Token'ları Al]
    H --> K
    I --> K
    J --> K
    
    K --> L[Multicast Message Gönder]
    L --> M[Başarılı/Başarısız Logla]
    M --> N[Notification History Kaydet]
    
    N --> O[Kullanıcı Bildirimi Alır]
    O --> P[Bildirime Tıklar]
    P --> Q[İlgili Sayfaya Yönlendir]
```

## 7. Veri Modeli İlişkileri

```mermaid
erDiagram
    USERS ||--o{ SUBSCRIPTIONS : has
    USERS ||--o{ USER_WORKOUTS : completes
    USERS ||--o{ NOTIFICATIONS : receives
    
    PROGRAMS ||--o{ USER_WORKOUTS : contains
    PROGRAMS ||--o{ NOTIFICATIONS : triggers
    
    USERS {
        string uid PK
        string email
        string displayName
        object subscription
        object preferences
        string fcmToken
        timestamp createdAt
    }
    
    PROGRAMS {
        string id PK
        number weekNumber
        number year
        string title
        boolean isActive
        array days
        timestamp createdAt
    }
    
    SUBSCRIPTIONS {
        string id PK
        string userId FK
        string plan
        string status
        timestamp startDate
        timestamp endDate
        string paymentId
    }
    
    USER_WORKOUTS {
        string id PK
        string userId FK
        string programId FK
        string workoutId
        timestamp completedAt
        boolean isCompleted
        number rating
    }
    
    NOTIFICATIONS {
        string id PK
        string userId FK
        string type
        string title
        string body
        timestamp sentAt
        string status
    }
```

## 8. Güvenlik Katmanları

```mermaid
graph TD
    subgraph "Client Security"
        A[HTTPS Only]
        B[Token Validation]
        C[Input Sanitization]
        D[Local Storage Encryption]
    end
    
    subgraph "Firebase Security"
        E[Firestore Rules]
        F[Authentication Rules]
        G[Cloud Functions Auth]
        H[Storage Rules]
    end
    
    subgraph "External Security"
        I[İyizico SSL]
        J[Webhook Verification]
        K[Rate Limiting]
        L[API Key Protection]
    end
    
    A --> E
    B --> F
    C --> G
    D --> H
    
    E --> I
    F --> J
    G --> K
    H --> L
```

## 9. Performans Optimizasyonu

```mermaid
graph LR
    subgraph "Client Optimization"
        A[Lazy Loading]
        B[Image Caching]
        C[Data Pagination]
        D[Offline Support]
    end
    
    subgraph "Backend Optimization"
        E[Firestore Indexes]
        F[Cloud Functions Caching]
        G[Batch Operations]
        H[Connection Pooling]
    end
    
    subgraph "Network Optimization"
        I[CDN Usage]
        J[Compression]
        K[Request Batching]
        L[Background Sync]
    end
    
    A --> E
    B --> F
    C --> G
    D --> H
    
    E --> I
    F --> J
    G --> K
    H --> L
```

## 10. Hata Yönetimi ve Loglama

```mermaid
graph TD
    A[Error Occurs] --> B{Error Type?}
    
    B -->|Client Error| C[Flutter Error Handler]
    B -->|Network Error| D[Retry Logic]
    B -->|Server Error| E[Cloud Functions Error Handler]
    B -->|Payment Error| F[İyizico Error Handler]
    
    C --> G[User-Friendly Message]
    D --> H[Exponential Backoff]
    E --> I[Server Logs]
    F --> J[Payment Retry]
    
    G --> K[Error Analytics]
    H --> K
    I --> K
    J --> K
    
    K --> L[Crashlytics]
    L --> M[Error Monitoring]
    M --> N[Performance Metrics]
```

## 11. Test Stratejisi

```mermaid
graph TD
    subgraph "Unit Tests"
        A[Business Logic Tests]
        B[Data Model Tests]
        C[Utility Function Tests]
    end
    
    subgraph "Widget Tests"
        D[UI Component Tests]
        E[Form Validation Tests]
        F[Navigation Tests]
    end
    
    subgraph "Integration Tests"
        G[Firebase Integration]
        H[Payment Integration]
        I[Notification Integration]
    end
    
    subgraph "E2E Tests"
        J[User Journey Tests]
        K[Subscription Flow Tests]
        L[Cross-Platform Tests]
    end
    
    A --> D
    B --> E
    C --> F
    
    D --> G
    E --> H
    F --> I
    
    G --> J
    H --> K
    I --> L
```

## 12. Deployment Pipeline

```mermaid
graph LR
    A[Code Commit] --> B[CI/CD Pipeline]
    B --> C[Unit Tests]
    C --> D[Integration Tests]
    D --> E[Build Flutter App]
    E --> F[Deploy Cloud Functions]
    F --> G[Update Firestore Rules]
    G --> H[Deploy to Firebase]
    H --> I[App Store/Play Store]
    
    C -->|Fail| J[Fix Issues]
    D -->|Fail| J
    J --> A
```

## 13. Monitoring ve Analytics

```mermaid
graph TD
    subgraph "User Analytics"
        A[User Behavior]
        B[Feature Usage]
        C[Retention Metrics]
        D[Conversion Rates]
    end
    
    subgraph "Performance Analytics"
        E[App Performance]
        F[Network Latency]
        G[Error Rates]
        H[Crash Reports]
    end
    
    subgraph "Business Analytics"
        I[Subscription Metrics]
        J[Revenue Tracking]
        K[User Acquisition]
        L[Churn Analysis]
    end
    
    A --> M[Firebase Analytics]
    B --> M
    C --> M
    D --> M
    
    E --> N[Performance Monitoring]
    F --> N
    G --> N
    H --> N
    
    I --> O[Custom Dashboards]
    J --> O
    K --> O
    L --> O
```

## 14. Backup ve Disaster Recovery

```mermaid
graph TD
    A[Data Backup Strategy] --> B[Firestore Backup]
    A --> C[Cloud Storage Backup]
    A --> D[Functions Backup]
    
    B --> E[Daily Automated Backups]
    C --> F[Versioned Storage]
    D --> G[Code Repository Backup]
    
    E --> H[Cross-Region Replication]
    F --> H
    G --> H
    
    H --> I[Disaster Recovery Plan]
    I --> J[Data Restoration]
    I --> K[Service Recovery]
    I --> L[User Communication]
```

Bu mimari diyagramları, CrossFit antrenman uygulamasının tüm teknik yönlerini görsel olarak açıklamaktadır. Her diyagram, sistemin farklı bir katmanını veya sürecini detaylandırarak geliştirme ekibinin projeyi daha iyi anlamasını sağlar.

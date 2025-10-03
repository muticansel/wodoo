# API Dokümantasyonu

## Firebase Cloud Functions API

### 1. Authentication Endpoints

#### Google Sign-In
```http
POST /auth/google
Content-Type: application/json

{
  "idToken": "string",
  "accessToken": "string"
}
```

**Response:**
```json
{
  "success": true,
  "user": {
    "uid": "string",
    "email": "string",
    "displayName": "string",
    "photoURL": "string",
    "subscription": {
      "plan": "monthly|quarterly|semi-annual|9-month|yearly",
      "isActive": boolean,
      "startDate": "timestamp",
      "endDate": "timestamp"
    }
  }
}
```

#### Email Sign-In
```http
POST /auth/email
Content-Type: application/json

{
  "email": "string",
  "password": "string"
}
```

**Response:**
```json
{
  "success": true,
  "user": {
    "uid": "string",
    "email": "string",
    "displayName": "string",
    "subscription": {
      "plan": "string",
      "isActive": boolean,
      "startDate": "timestamp",
      "endDate": "timestamp"
    }
  }
}
```

### 2. Subscription Endpoints

#### Get Subscription Status
```http
GET /subscription/status
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "subscription": {
    "plan": "monthly",
    "status": "active|expired|cancelled",
    "startDate": "2024-01-01T00:00:00Z",
    "endDate": "2024-02-01T00:00:00Z",
    "isActive": true,
    "autoRenew": true,
    "daysRemaining": 15
  }
}
```

#### Create Subscription
```http
POST /subscription/create
Authorization: Bearer {token}
Content-Type: application/json

{
  "plan": "monthly|quarterly|semi-annual|9-month|yearly",
  "paymentMethod": "credit_card|bank_card|digital_wallet"
}
```

**Response:**
```json
{
  "success": true,
  "paymentUrl": "string",
  "paymentId": "string",
  "amount": 9900,
  "currency": "TRY"
}
```

#### Cancel Subscription
```http
POST /subscription/cancel
Authorization: Bearer {token}
Content-Type: application/json

{
  "reason": "string"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Subscription cancelled successfully",
  "cancelledAt": "2024-01-15T10:30:00Z"
}
```

### 3. Programs Endpoints

#### Get Programs List
```http
GET /programs
Authorization: Bearer {token}
Query Parameters:
  - page: number (default: 1)
  - limit: number (default: 10)
  - year: number (optional)
  - difficulty: string (optional)
```

**Response:**
```json
{
  "success": true,
  "programs": [
    {
      "id": "string",
      "weekNumber": 1,
      "year": 2024,
      "title": "Hafta 1 - Temel Güç",
      "description": "string",
      "difficulty": "beginner|intermediate|advanced",
      "isActive": true,
      "createdAt": "2024-01-01T00:00:00Z",
      "days": [
        {
          "dayNumber": 1,
          "dayName": "Pazartesi",
          "isRestDay": false,
          "focus": "Upper Body",
          "workouts": [
            {
              "id": "string",
              "type": "wod|strength|metcon|plyo|accessory",
              "title": "WOD + Strength",
              "duration": 45,
              "difficulty": "intermediate",
              "equipment": ["barbell", "plates"]
            }
          ]
        }
      ]
    }
  ],
  "pagination": {
    "currentPage": 1,
    "totalPages": 10,
    "totalItems": 100,
    "hasNext": true,
    "hasPrevious": false
  }
}
```

#### Get Program by ID
```http
GET /programs/{programId}
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "program": {
    "id": "string",
    "weekNumber": 1,
    "year": 2024,
    "title": "Hafta 1 - Temel Güç",
    "description": "string",
    "difficulty": "beginner",
    "isActive": true,
    "createdAt": "2024-01-01T00:00:00Z",
    "days": [
      {
        "dayNumber": 1,
        "dayName": "Pazartesi",
        "isRestDay": false,
        "focus": "Upper Body",
        "workouts": [
          {
            "id": "string",
            "type": "wod",
            "title": "WOD + Strength",
            "description": "string",
            "duration": 45,
            "difficulty": "intermediate",
            "equipment": ["barbell", "plates"],
            "exercises": [
              {
                "id": "string",
                "name": "Deadlift",
                "description": "string",
                "sets": 5,
                "reps": "5",
                "weight": "Bodyweight",
                "restTime": "2 minutes",
                "notes": "string"
              }
            ],
            "warmup": [
              {
                "exercise": "5 dk koşu",
                "duration": "5 minutes",
                "description": "string"
              }
            ],
            "cooldown": [
              {
                "exercise": "Stretching",
                "duration": "10 minutes",
                "description": "string"
              }
            ]
          }
        ]
      }
    ]
  }
}
```

### 4. Workouts Endpoints

#### Get Today's Workouts
```http
GET /workouts/today
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "workouts": [
    {
      "id": "string",
      "programId": "string",
      "dayNumber": 1,
      "type": "wod",
      "title": "WOD + Strength",
      "description": "string",
      "duration": 45,
      "difficulty": "intermediate",
      "equipment": ["barbell", "plates"],
      "exercises": [
        {
          "id": "string",
          "name": "Deadlift",
          "description": "string",
          "sets": 5,
          "reps": "5",
          "weight": "Bodyweight",
          "restTime": "2 minutes",
          "notes": "string"
        }
      ]
    }
  ]
}
```

#### Start Workout
```http
POST /workouts/{workoutId}/start
Authorization: Bearer {token}
Content-Type: application/json

{
  "startedAt": "2024-01-15T10:00:00Z"
}
```

**Response:**
```json
{
  "success": true,
  "workoutSession": {
    "id": "string",
    "workoutId": "string",
    "userId": "string",
    "startedAt": "2024-01-15T10:00:00Z",
    "status": "in_progress"
  }
}
```

#### Complete Workout
```http
POST /workouts/{workoutId}/complete
Authorization: Bearer {token}
Content-Type: application/json

{
  "completedAt": "2024-01-15T10:45:00Z",
  "duration": 45,
  "notes": "string",
  "rating": 4,
  "difficulty": 3,
  "exercises": [
    {
      "exerciseId": "string",
      "completedSets": 5,
      "completedReps": "5",
      "weightUsed": "100kg",
      "restTime": 120,
      "notes": "string"
    }
  ]
}
```

**Response:**
```json
{
  "success": true,
  "workoutSession": {
    "id": "string",
    "workoutId": "string",
    "userId": "string",
    "completedAt": "2024-01-15T10:45:00Z",
    "duration": 45,
    "notes": "string",
    "rating": 4,
    "difficulty": 3,
    "isCompleted": true
  }
}
```

#### Get Workout History
```http
GET /workouts/history
Authorization: Bearer {token}
Query Parameters:
  - page: number (default: 1)
  - limit: number (default: 20)
  - startDate: string (ISO 8601)
  - endDate: string (ISO 8601)
```

**Response:**
```json
{
  "success": true,
  "workouts": [
    {
      "id": "string",
      "workoutId": "string",
      "programId": "string",
      "dayNumber": 1,
      "title": "WOD + Strength",
      "completedAt": "2024-01-15T10:45:00Z",
      "duration": 45,
      "rating": 4,
      "difficulty": 3,
      "isCompleted": true
    }
  ],
  "pagination": {
    "currentPage": 1,
    "totalPages": 5,
    "totalItems": 100,
    "hasNext": true,
    "hasPrevious": false
  }
}
```

### 5. Notifications Endpoints

#### Get Notification Preferences
```http
GET /notifications/preferences
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "preferences": {
    "push": true,
    "email": true,
    "newProgram": true,
    "subscriptionReminder": true,
    "workoutReminder": true,
    "workoutReminderTime": "09:00"
  }
}
```

#### Update Notification Preferences
```http
PUT /notifications/preferences
Authorization: Bearer {token}
Content-Type: application/json

{
  "push": true,
  "email": false,
  "newProgram": true,
  "subscriptionReminder": true,
  "workoutReminder": true,
  "workoutReminderTime": "08:00"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Preferences updated successfully"
}
```

#### Get Notification History
```http
GET /notifications/history
Authorization: Bearer {token}
Query Parameters:
  - page: number (default: 1)
  - limit: number (default: 20)
  - type: string (optional)
```

**Response:**
```json
{
  "success": true,
  "notifications": [
    {
      "id": "string",
      "type": "new_program",
      "title": "Yeni Program Yüklendi!",
      "body": "Hafta 1 programı hazır.",
      "sentAt": "2024-01-15T10:00:00Z",
      "readAt": "2024-01-15T10:05:00Z",
      "clickedAt": "2024-01-15T10:05:00Z",
      "status": "clicked"
    }
  ],
  "pagination": {
    "currentPage": 1,
    "totalPages": 3,
    "totalItems": 50,
    "hasNext": true,
    "hasPrevious": false
  }
}
```

### 6. User Profile Endpoints

#### Get User Profile
```http
GET /user/profile
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "user": {
    "uid": "string",
    "email": "string",
    "displayName": "string",
    "photoURL": "string",
    "subscription": {
      "plan": "monthly",
      "isActive": true,
      "startDate": "2024-01-01T00:00:00Z",
      "endDate": "2024-02-01T00:00:00Z"
    },
    "preferences": {
      "language": "tr",
      "theme": "light",
      "notifications": {
        "push": true,
        "email": true,
        "newProgram": true,
        "subscriptionReminder": true,
        "workoutReminder": true,
        "workoutReminderTime": "09:00"
      }
    },
    "profile": {
      "fitnessLevel": "intermediate",
      "goals": ["weight_loss", "muscle_gain"],
      "injuries": [],
      "equipment": ["barbell", "plates", "kettlebell"]
    },
    "createdAt": "2024-01-01T00:00:00Z",
    "lastLoginAt": "2024-01-15T10:00:00Z"
  }
}
```

#### Update User Profile
```http
PUT /user/profile
Authorization: Bearer {token}
Content-Type: application/json

{
  "displayName": "string",
  "photoURL": "string",
  "preferences": {
    "language": "tr|en",
    "theme": "light|dark|system",
    "notifications": {
      "push": true,
      "email": true,
      "newProgram": true,
      "subscriptionReminder": true,
      "workoutReminder": true,
      "workoutReminderTime": "09:00"
    }
  },
  "profile": {
    "fitnessLevel": "beginner|intermediate|advanced",
    "goals": ["string"],
    "injuries": ["string"],
    "equipment": ["string"]
  }
}
```

**Response:**
```json
{
  "success": true,
  "message": "Profile updated successfully"
}
```

## İyizico Payment API

### 1. Create Payment

```http
POST https://api.iyizico.com/payment/create
Content-Type: application/json
Authorization: Bearer {api_key}

{
  "price": "99.00",
  "paidPrice": "99.00",
  "currency": "TRY",
  "installment": 1,
  "paymentChannel": "WEB",
  "paymentGroup": "SUBSCRIPTION",
  "conversationId": "user_123",
  "callbackUrl": "https://yourapp.com/payment/callback",
  "items": [
    {
      "id": "monthly_subscription",
      "name": "CrossFit Subscription - Monthly",
      "category1": "Fitness",
      "itemType": "VIRTUAL",
      "price": "99.00"
    }
  ]
}
```

**Response:**
```json
{
  "status": "success",
  "paymentId": "string",
  "paymentPageUrl": "https://sandbox.iyizico.com/payment/...",
  "token": "string"
}
```

### 2. Check Payment Status

```http
POST https://api.iyizico.com/payment/check
Content-Type: application/json
Authorization: Bearer {api_key}

{
  "paymentId": "string"
}
```

**Response:**
```json
{
  "status": "success",
  "paymentId": "string",
  "amount": 99.00,
  "currency": "TRY",
  "paidAt": "2024-01-15T10:30:00Z",
  "paymentMethod": "credit_card",
  "cardNumber": "****1234"
}
```

## Error Responses

### Standard Error Format

```json
{
  "success": false,
  "error": {
    "code": "string",
    "message": "string",
    "details": "string"
  }
}
```

### Error Codes

| Code | HTTP Status | Description |
|------|-------------|-------------|
| `AUTH_REQUIRED` | 401 | Authentication required |
| `INVALID_TOKEN` | 401 | Invalid or expired token |
| `INSUFFICIENT_PERMISSIONS` | 403 | Insufficient permissions |
| `SUBSCRIPTION_REQUIRED` | 403 | Active subscription required |
| `VALIDATION_ERROR` | 400 | Request validation failed |
| `NOT_FOUND` | 404 | Resource not found |
| `RATE_LIMIT_EXCEEDED` | 429 | Rate limit exceeded |
| `PAYMENT_FAILED` | 402 | Payment processing failed |
| `SUBSCRIPTION_EXPIRED` | 403 | Subscription has expired |
| `INTERNAL_ERROR` | 500 | Internal server error |

### Example Error Responses

#### Authentication Required
```json
{
  "success": false,
  "error": {
    "code": "AUTH_REQUIRED",
    "message": "Authentication required",
    "details": "Please provide a valid authentication token"
  }
}
```

#### Subscription Required
```json
{
  "success": false,
  "error": {
    "code": "SUBSCRIPTION_REQUIRED",
    "message": "Active subscription required",
    "details": "Please subscribe to access this content"
  }
}
```

#### Validation Error
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed",
    "details": "The 'email' field is required and must be a valid email address"
  }
}
```

## Rate Limiting

### Limits

| Endpoint | Limit | Window |
|----------|-------|--------|
| Authentication | 10 requests | 1 minute |
| Subscription | 5 requests | 1 minute |
| Programs | 100 requests | 1 minute |
| Workouts | 200 requests | 1 minute |
| Notifications | 50 requests | 1 minute |
| User Profile | 20 requests | 1 minute |

### Rate Limit Headers

```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1640995200
```

## Webhooks

### Payment Webhook

```http
POST /webhooks/payment
Content-Type: application/json
X-Iyizico-Signature: {signature}

{
  "paymentId": "string",
  "status": "success|failed",
  "amount": 99.00,
  "currency": "TRY",
  "userId": "string",
  "plan": "monthly",
  "paidAt": "2024-01-15T10:30:00Z"
}
```

### Notification Webhook

```http
POST /webhooks/notification
Content-Type: application/json
X-Firebase-Signature: {signature}

{
  "type": "new_program|subscription_reminder|workout_reminder",
  "userId": "string",
  "title": "string",
  "body": "string",
  "data": {
    "programId": "string",
    "workoutId": "string"
  }
}
```

## SDK Examples

### Flutter SDK

```dart
// API Client
class CrossFitAPI {
  final String baseUrl = 'https://your-api.com';
  final String apiKey;
  
  CrossFitAPI({required this.apiKey});
  
  Future<Map<String, dynamic>> getPrograms({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/programs?page=$page&limit=$limit'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load programs');
    }
  }
  
  Future<Map<String, dynamic>> createSubscription({
    required String plan,
    required String paymentMethod,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/subscription/create'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'plan': plan,
        'paymentMethod': paymentMethod,
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create subscription');
    }
  }
}
```

### JavaScript SDK

```javascript
class CrossFitAPI {
  constructor(apiKey) {
    this.baseUrl = 'https://your-api.com';
    this.apiKey = apiKey;
  }
  
  async getPrograms(page = 1, limit = 10) {
    const response = await fetch(`${this.baseUrl}/programs?page=${page}&limit=${limit}`, {
      headers: {
        'Authorization': `Bearer ${this.apiKey}`,
        'Content-Type': 'application/json',
      },
    });
    
    if (response.ok) {
      return await response.json();
    } else {
      throw new Error('Failed to load programs');
    }
  }
  
  async createSubscription(plan, paymentMethod) {
    const response = await fetch(`${this.baseUrl}/subscription/create`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${this.apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        plan,
        paymentMethod,
      }),
    });
    
    if (response.ok) {
      return await response.json();
    } else {
      throw new Error('Failed to create subscription');
    }
  }
}
```

Bu API dokümantasyonu, CrossFit antrenman uygulamasının tüm backend servislerini kapsamlı bir şekilde açıklamaktadır. Her endpoint için detaylı request/response örnekleri, hata kodları ve kullanım örnekleri sağlanmıştır.

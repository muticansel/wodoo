class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoURL;
  final Subscription subscription;
  final UserPreferences preferences;
  final DateTime createdAt;
  final DateTime lastLoginAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoURL,
    required this.subscription,
    required this.preferences,
    required this.createdAt,
    required this.lastLoginAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoURL: map['photoURL'],
      subscription: Subscription.fromMap(map['subscription'] ?? {}),
      preferences: UserPreferences.fromMap(map['preferences'] ?? {}),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      lastLoginAt: DateTime.fromMillisecondsSinceEpoch(map['lastLoginAt'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'subscription': subscription.toMap(),
      'preferences': preferences.toMap(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastLoginAt': lastLoginAt.millisecondsSinceEpoch,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    Subscription? subscription,
    UserPreferences? preferences,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      subscription: subscription ?? this.subscription,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}

class Subscription {
  final String plan;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final String? paymentId;

  Subscription({
    required this.plan,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    this.paymentId,
  });

  factory Subscription.fromMap(Map<String, dynamic> map) {
    return Subscription(
      plan: map['plan'] ?? 'monthly',
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate'] ?? 0),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['endDate'] ?? 0),
      isActive: map['isActive'] ?? false,
      paymentId: map['paymentId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'plan': plan,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch,
      'isActive': isActive,
      'paymentId': paymentId,
    };
  }

  bool get isExpired => DateTime.now().isAfter(endDate);
  int get daysRemaining => endDate.difference(DateTime.now()).inDays;
}

class UserPreferences {
  final String language;
  final bool notifications;
  final String theme;
  final Map<String, double> mainLifts; // Main lift PR'ları

  UserPreferences({
    required this.language,
    required this.notifications,
    required this.theme,
    this.mainLifts = const {},
  });

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      language: map['language'] ?? 'tr',
      notifications: map['notifications'] ?? true,
      theme: map['theme'] ?? 'light',
      mainLifts: Map<String, double>.from(map['mainLifts'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'language': language,
      'notifications': notifications,
      'theme': theme,
      'mainLifts': mainLifts,
    };
  }

  UserPreferences copyWith({
    String? language,
    bool? notifications,
    String? theme,
    Map<String, double>? mainLifts,
  }) {
    return UserPreferences(
      language: language ?? this.language,
      notifications: notifications ?? this.notifications,
      theme: theme ?? this.theme,
      mainLifts: mainLifts ?? this.mainLifts,
    );
  }
}


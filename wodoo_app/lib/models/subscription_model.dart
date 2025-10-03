class SubscriptionModel {
  final String id;
  final String userId;
  final String plan;
  final SubscriptionStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final String? paymentId;
  final double amount;
  final String currency;
  final DateTime createdAt;

  SubscriptionModel({
    required this.id,
    required this.userId,
    required this.plan,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.paymentId,
    required this.amount,
    required this.currency,
    required this.createdAt,
  });

  factory SubscriptionModel.fromMap(Map<String, dynamic> map) {
    return SubscriptionModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      plan: map['plan'] ?? 'monthly',
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => SubscriptionStatus.expired,
      ),
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate'] ?? 0),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['endDate'] ?? 0),
      paymentId: map['paymentId'],
      amount: (map['amount'] ?? 0).toDouble(),
      currency: map['currency'] ?? 'TRY',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'plan': plan,
      'status': status.name,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch,
      'paymentId': paymentId,
      'amount': amount,
      'currency': currency,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  bool get isActive => status == SubscriptionStatus.active && !isExpired;
  bool get isExpired => DateTime.now().isAfter(endDate);
  int get daysRemaining => endDate.difference(DateTime.now()).inDays;

  SubscriptionModel copyWith({
    String? id,
    String? userId,
    String? plan,
    SubscriptionStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    String? paymentId,
    double? amount,
    String? currency,
    DateTime? createdAt,
  }) {
    return SubscriptionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      plan: plan ?? this.plan,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      paymentId: paymentId ?? this.paymentId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum SubscriptionStatus {
  active,
  expired,
  cancelled,
}

class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final int durationInDays;
  final double monthlyPrice;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.durationInDays,
    required this.monthlyPrice,
  });

  static const List<SubscriptionPlan> plans = [
    SubscriptionPlan(
      id: 'monthly',
      name: 'Aylık',
      description: 'Aylık abonelik',
      price: 99.0,
      currency: 'TRY',
      durationInDays: 30,
      monthlyPrice: 99.0,
    ),
    SubscriptionPlan(
      id: 'quarterly',
      name: '3 Aylık',
      description: '3 aylık abonelik',
      price: 249.0,
      currency: 'TRY',
      durationInDays: 90,
      monthlyPrice: 83.0,
    ),
    SubscriptionPlan(
      id: 'semi-annual',
      name: '6 Aylık',
      description: '6 aylık abonelik',
      price: 459.0,
      currency: 'TRY',
      durationInDays: 180,
      monthlyPrice: 76.5,
    ),
    SubscriptionPlan(
      id: '9-month',
      name: '9 Aylık',
      description: '9 aylık abonelik',
      price: 639.0,
      currency: 'TRY',
      durationInDays: 270,
      monthlyPrice: 71.0,
    ),
    SubscriptionPlan(
      id: 'yearly',
      name: 'Yıllık',
      description: 'Yıllık abonelik',
      price: 799.0,
      currency: 'TRY',
      durationInDays: 365,
      monthlyPrice: 66.6,
    ),
  ];
}


class NotificationPreferences {
  final bool prUpdates;
  final bool subscriptionNotifications;
  final bool programUpdates;
  final DateTime? updatedAt;

  NotificationPreferences({
    required this.prUpdates,
    required this.subscriptionNotifications,
    required this.programUpdates,
    this.updatedAt,
  });

  factory NotificationPreferences.fromMap(Map<String, dynamic> map) {
    return NotificationPreferences(
      prUpdates: map['prUpdates'] ?? true,
      subscriptionNotifications: map['subscriptionNotifications'] ?? true,
      programUpdates: map['programUpdates'] ?? true,
      updatedAt: map['updatedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'prUpdates': prUpdates,
      'subscriptionNotifications': subscriptionNotifications,
      'programUpdates': programUpdates,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  NotificationPreferences copyWith({
    bool? prUpdates,
    bool? subscriptionNotifications,
    bool? programUpdates,
    DateTime? updatedAt,
  }) {
    return NotificationPreferences(
      prUpdates: prUpdates ?? this.prUpdates,
      subscriptionNotifications: subscriptionNotifications ?? this.subscriptionNotifications,
      programUpdates: programUpdates ?? this.programUpdates,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Check if any notifications are enabled
  bool get hasAnyNotificationsEnabled {
    return prUpdates || subscriptionNotifications || programUpdates;
  }

  // Get enabled notification types
  List<String> get enabledNotificationTypes {
    List<String> types = [];
    if (prUpdates) types.add('prUpdates');
    if (subscriptionNotifications) types.add('subscriptionNotifications');
    if (programUpdates) types.add('programUpdates');
    return types;
  }
}

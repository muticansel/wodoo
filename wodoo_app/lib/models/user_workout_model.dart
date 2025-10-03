class UserWorkoutModel {
  final String id;
  final String userId;
  final String programId;
  final String workoutId;
  final DateTime completedAt;
  final String? notes;
  final int? rating;
  final int? duration; // in minutes

  UserWorkoutModel({
    required this.id,
    required this.userId,
    required this.programId,
    required this.workoutId,
    required this.completedAt,
    this.notes,
    this.rating,
    this.duration,
  });

  factory UserWorkoutModel.fromMap(Map<String, dynamic> map) {
    return UserWorkoutModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      programId: map['programId'] ?? '',
      workoutId: map['workoutId'] ?? '',
      completedAt: DateTime.fromMillisecondsSinceEpoch(map['completedAt'] ?? 0),
      notes: map['notes'],
      rating: map['rating'],
      duration: map['duration'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'programId': programId,
      'workoutId': workoutId,
      'completedAt': completedAt.millisecondsSinceEpoch,
      'notes': notes,
      'rating': rating,
      'duration': duration,
    };
  }

  UserWorkoutModel copyWith({
    String? id,
    String? userId,
    String? programId,
    String? workoutId,
    DateTime? completedAt,
    String? notes,
    int? rating,
    int? duration,
  }) {
    return UserWorkoutModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      programId: programId ?? this.programId,
      workoutId: workoutId ?? this.workoutId,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
      rating: rating ?? this.rating,
      duration: duration ?? this.duration,
    );
  }
}


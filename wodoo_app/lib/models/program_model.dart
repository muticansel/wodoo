class ProgramModel {
  final String id;
  final String title;
  final String description;
  final String difficulty;
  final String duration; // Program süresi (örn: "45 dakika", "1 hafta")
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ProgramDay> days; // Haftalık program günleri

  ProgramModel({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.duration,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    required this.days,
  });

  factory ProgramModel.fromMap(Map<String, dynamic> map, String id) {
    return ProgramModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      difficulty: map['difficulty'] ?? 'Başlangıç',
      duration: map['duration'] ?? '1 hafta',
      category: map['category'] ?? 'CrossFit',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
      days: (map['days'] as List<dynamic>? ?? [])
          .map((day) => ProgramDay.fromMap(day))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'difficulty': difficulty,
      'duration': duration,
      'category': category,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'days': days.map((day) => day.toMap()).toList(),
    };
  }

  ProgramModel copyWith({
    String? id,
    String? title,
    String? description,
    String? difficulty,
    String? duration,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ProgramDay>? days,
  }) {
    return ProgramModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      duration: duration ?? this.duration,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      days: days ?? this.days,
    );
  }
}

class ProgramDay {
  final int dayNumber;
  final String dayName; // "GÜN 1", "GÜN 2", etc.
  final List<WorkoutSection> sections; // Plyo, STR, Metcon, ACC, etc.

  ProgramDay({
    required this.dayNumber,
    required this.dayName,
    required this.sections,
  });

  factory ProgramDay.fromMap(Map<String, dynamic> map) {
    return ProgramDay(
      dayNumber: map['dayNumber'] ?? 0,
      dayName: map['dayName'] ?? '',
      sections: (map['sections'] as List<dynamic>? ?? [])
          .map((section) => WorkoutSection.fromMap(section))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dayNumber': dayNumber,
      'dayName': dayName,
      'sections': sections.map((section) => section.toMap()).toList(),
    };
  }
}

// Workout bölüm türleri
enum WorkoutSectionType {
  plyo,        // Plyometrics
  strength,    // STR
  metcon,      // Metabolic Conditioning
  accessory,   // ACC
  conditioning, // Cond
  gripAndCore, // Grip + Core
  warmUp,      // Isınma
  coolDown,    // Soğuma
}

class WorkoutSection {
  final String id;
  final String title; // "Plyo", "STR", "Metcon P.1", "ACC"
  final WorkoutSectionType type;
  final String? instructions; // "Every 5:00 x 4", "For Time", "Amrap 30"
  final String? restNotes; // "*Rest for the remaining time", "*Aim at least 2.45 for the rest"
  final List<Exercise> exercises;

  WorkoutSection({
    required this.id,
    required this.title,
    required this.type,
    this.instructions,
    this.restNotes,
    required this.exercises,
  });

  factory WorkoutSection.fromMap(Map<String, dynamic> map) {
    return WorkoutSection(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      type: WorkoutSectionType.values.firstWhere(
        (e) => e.toString().split('.').last == (map['type'] ?? 'strength'),
        orElse: () => WorkoutSectionType.strength,
      ),
      instructions: map['instructions'],
      restNotes: map['restNotes'],
      exercises: (map['exercises'] as List<dynamic>? ?? [])
          .map((exercise) => Exercise.fromMap(exercise))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type.toString().split('.').last,
      'instructions': instructions,
      'restNotes': restNotes,
      'exercises': exercises.map((exercise) => exercise.toMap()).toList(),
    };
  }
}

// Egzersiz türleri
enum ExerciseType {
  reps,      // 5x3, 6-9, 20
  time,      // 30 Sec Row Sprint
  distance,  // 1k/800m Row, 15m HS walk
  calories,  // 50 cal Bike
  amrap,     // As Many Rounds As Possible
  emom,      // Every Minute On the Minute
  forTime,   // For Time
}

class Exercise {
  final String id;
  final String name; // "Power Snatch", "Back Squat", "Thrusters"
  final String? description; // "8 Consecutive Hurdle Jumps", "Repeat for other leg"
  final ExerciseType exerciseType;
  final String? sets; // "4 Sets", "6 Sets", "5 x 3", "6x1"
  final String? reps; // "3-5", "6-9", "20", "10"
  final String? weight; // "60-40", "80-50", "25-17.5", "100-60"
  final double? percentage; // 80.0, 110.0
  final String? mainLiftKey; // "Snatch", "Back Squat"
  final String? timeDomain; // "Every 5:00 x 4", "Amrap 30", "For Time"
  final String? restTime; // "2:30", "as needed", "3 more mins"
  final List<String>? equipment; // ["Hurdle", "Bar", "DB", "Wall Balls"]
  final String? notes; // "kip or strict", "1 pirouette at 7.5 if possible"

  Exercise({
    required this.id,
    required this.name,
    this.description,
    this.exerciseType = ExerciseType.reps,
    this.sets,
    this.reps,
    this.weight,
    this.percentage,
    this.mainLiftKey,
    this.timeDomain,
    this.restTime,
    this.equipment,
    this.notes,
  });

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'],
      exerciseType: ExerciseType.values.firstWhere(
        (e) => e.toString().split('.').last == (map['exerciseType'] ?? 'reps'),
        orElse: () => ExerciseType.reps,
      ),
      sets: map['sets'],
      reps: map['reps'],
      weight: map['weight'],
      percentage: (map['percentage'] as num?)?.toDouble(),
      mainLiftKey: map['mainLiftKey'],
      timeDomain: map['timeDomain'],
      restTime: map['restTime'],
      equipment: (map['equipment'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'exerciseType': exerciseType.toString().split('.').last,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'percentage': percentage,
      'mainLiftKey': mainLiftKey,
      'timeDomain': timeDomain,
      'restTime': restTime,
      'equipment': equipment,
      'notes': notes,
    };
  }
}



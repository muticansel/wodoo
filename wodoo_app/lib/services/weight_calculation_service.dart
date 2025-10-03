import '../models/program_model.dart';

class WeightCalculationService {
  // Main lift isimlerini eşleştirme
  static const Map<String, String> _liftMappings = {
    'Back Squat': 'Back Squat',
    'Front Squat': 'Front Squat',
    'Overhead Squat': 'Overhead Squat',
    'Snatch': 'Snatch',
    'Clean': 'Clean',
    'Clean & Jerk': 'Clean & Jerk',
    'Jerk': 'Jerk',
    'Power Snatch': 'Power Snatch',
    'Power Clean': 'Power Clean',
    'Power Jerk': 'Power Jerk',
    'Snatch Balance': 'Snatch Balance',
    'Push Press': 'Push Press',
    'Deadlift': 'Deadlift',
  };

  /// Egzersiz için hesaplanmış ağırlığı döndürür
  static double? calculateWeight(Exercise exercise, Map<String, double> userMainLifts) {
    if (exercise.percentage == null || exercise.mainLiftKey == null) {
      return null;
    }

    final mainLiftKey = exercise.mainLiftKey!;
    final userMaxWeight = userMainLifts[mainLiftKey];

    if (userMaxWeight == null || userMaxWeight <= 0) {
      return null;
    }

    // Yüzde hesaplama: (percentage / 100) * maxWeight
    final calculatedWeight = (exercise.percentage! / 100) * userMaxWeight;
    
    // 2.5kg'ye yuvarla (halter plakaları için)
    return _roundToNearestPlate(calculatedWeight);
  }

  /// Egzersiz için ağırlık bilgisini formatlanmış string olarak döndürür
  static String getWeightDisplay(Exercise exercise, Map<String, double> userMainLifts) {
    final calculatedWeight = calculateWeight(exercise, userMainLifts);
    
    if (calculatedWeight == null) {
      return '${exercise.sets}x${exercise.reps}';
    }

    return '${exercise.sets}x${exercise.reps} @ ${calculatedWeight.toStringAsFixed(1)}kg';
  }

  /// Egzersiz için ağırlık bilgisini detaylı string olarak döndürür
  static String getDetailedWeightDisplay(Exercise exercise, Map<String, double> userMainLifts) {
    final calculatedWeight = calculateWeight(exercise, userMainLifts);
    
    if (calculatedWeight == null) {
      return '${exercise.sets}x${exercise.reps}';
    }

    final userMaxWeight = userMainLifts[exercise.mainLiftKey!] ?? 0;
    return '${exercise.sets}x${exercise.reps} @ ${calculatedWeight.toStringAsFixed(1)}kg (${exercise.percentage!.toInt()}% of ${userMaxWeight.toStringAsFixed(1)}kg)';
  }

  /// Egzersizin ağırlık hesaplaması yapılıp yapılamayacağını kontrol eder
  static bool canCalculateWeight(Exercise exercise, Map<String, double> userMainLifts) {
    return exercise.percentage != null && 
           exercise.mainLiftKey != null && 
           userMainLifts.containsKey(exercise.mainLiftKey!) &&
           userMainLifts[exercise.mainLiftKey!]! > 0;
  }

  /// Kullanıcının main lift verilerini kontrol eder
  static List<String> getMissingMainLifts(List<Exercise> exercises, Map<String, double> userMainLifts) {
    final requiredLifts = <String>{};
    
    for (final exercise in exercises) {
      if (exercise.mainLiftKey != null) {
        requiredLifts.add(exercise.mainLiftKey!);
      }
    }

    final missingLifts = <String>[];
    for (final lift in requiredLifts) {
      if (!userMainLifts.containsKey(lift) || userMainLifts[lift]! <= 0) {
        missingLifts.add(lift);
      }
    }

    return missingLifts;
  }

  /// Ağırlığı en yakın kg'a yuvarlar (1kg artışlarla)
  static double _roundToNearestPlate(double weight) {
    return weight.round().toDouble();
  }

  /// Egzersiz adından main lift key'ini bulur
  static String? findMainLiftKey(String exerciseName) {
    // Complex lift detection için önce complex'leri kontrol et
    final complexKey = _findComplexLiftKey(exerciseName);
    if (complexKey != null) {
      return complexKey;
    }

    // Tek lift kontrolü
    for (final entry in _liftMappings.entries) {
      if (exerciseName.toLowerCase().contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }

  /// Complex lift'lerden main lift key'ini bulur
  static String? _findComplexLiftKey(String exerciseName) {
    final lowerName = exerciseName.toLowerCase();
    
    // Power lift'ler - EN YÜKSEK ÖNCELİK (önce kontrol edilmeli)
    if (lowerName.contains('power snatch')) {
      return 'Power Snatch';
    }
    if (lowerName.contains('power clean')) {
      return 'Power Clean';
    }
    if (lowerName.contains('power jerk')) {
      return 'Power Jerk';
    }
    
    // Clean & Jerk varsa ondan al
    if (lowerName.contains('clean') && lowerName.contains('jerk')) {
      return 'Clean & Jerk';
    }
    
    // En kolay lift'leri kontrol et
    if (lowerName.contains('push press')) {
      return 'Push Press';
    }
    if (lowerName.contains('snatch balance')) {
      return 'Snatch Balance';
    }
    if (lowerName.contains('overhead squat')) {
      return 'Overhead Squat';
    }
    if (lowerName.contains('front squat')) {
      return 'Front Squat';
    }
    if (lowerName.contains('back squat')) {
      return 'Back Squat';
    }
    
    // Ana lift'ler - EN DÜŞÜK ÖNCELİK
    if (lowerName.contains('snatch')) {
      return 'Snatch';
    }
    if (lowerName.contains('clean')) {
      return 'Clean';
    }
    if (lowerName.contains('jerk')) {
      return 'Jerk';
    }
    if (lowerName.contains('deadlift')) {
      return 'Deadlift';
    }
    
    return null;
  }
}

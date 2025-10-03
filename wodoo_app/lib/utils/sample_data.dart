import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/program_model.dart';

class SampleData {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Örnek program verilerini Firestore'a ekle
  static Future<void> addSamplePrograms() async {
    try {
      print('Örnek program verileri ekleniyor...');

      // Gerçek CrossFit Programı - 1. Hafta
      final crossfitProgram = ProgramModel(
        id: 'crossfit_week1_2024',
        title: 'CrossFit Programı - 1. Hafta',
        description: 'Gerçek CrossFit programı - 5 günlük haftalık program',
        difficulty: 'Orta',
        duration: '1 hafta',
        category: 'CrossFit',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        days: [
          // 1.Gün - Gerçek CrossFit Programı
          ProgramDay(
            dayNumber: 1,
            dayName: '1.Gün',
            sections: [
              // Plyo.
              WorkoutSection(
                id: 'day1_plyo',
                title: 'Plyo.',
                type: WorkoutSectionType.plyo,
                exercises: [
                  Exercise(
                    id: 'day1_plyo_1',
                    name: 'Consecutive Hurdle Jumps',
                    description: '8 Consecutive Hurdle Jumps',
                    exerciseType: ExerciseType.reps,
                    sets: '4 Sets',
                    reps: '8',
                    equipment: ['Hurdle'],
                  ),
                  Exercise(
                    id: 'day1_plyo_2',
                    name: 'Single Leg Broad Jumps',
                    description: '6 Single Leg Broad Jumps',
                    exerciseType: ExerciseType.reps,
                    sets: '4 Sets',
                    reps: '6',
                    notes: 'Repeat for other leg',
                  ),
                ],
              ),
              // STR
              WorkoutSection(
                id: 'day1_str',
                title: 'STR',
                type: WorkoutSectionType.strength,
                exercises: [
                  Exercise(
                    id: 'day1_str_1',
                    name: 'Power Snatch + OHS',
                    description: '2 Power Snatch + 1 OHS',
                    exerciseType: ExerciseType.reps,
                    sets: '6 Sets',
                    reps: '2+1',
                    percentage: 80.0,
                    mainLiftKey: 'Snatch',
                  ),
                  Exercise(
                    id: 'day1_str_2',
                    name: 'Back Squat',
                    description: 'Back Squat',
                    exerciseType: ExerciseType.reps,
                    sets: '5 x 3',
                    reps: '3',
                    percentage: 87.5, // 85-90 ortalaması
                    mainLiftKey: 'Back Squat',
                  ),
                ],
              ),
              // Metcon P.1
              WorkoutSection(
                id: 'day1_metcon',
                title: 'Metcon P.1',
                type: WorkoutSectionType.metcon,
                instructions: 'Every 5:00 x 4',
                restNotes: '*Rest for the remaining time\n*Aim at least 2.45 for the rest',
                exercises: [
                  Exercise(
                    id: 'day1_metcon_1',
                    name: 'Lateral Burpee Over Bar',
                    exerciseType: ExerciseType.reps,
                    reps: '20',
                    equipment: ['Bar'],
                  ),
                  Exercise(
                    id: 'day1_metcon_2',
                    name: 'Thrusters',
                    exerciseType: ExerciseType.reps,
                    reps: '10',
                    weight: '60-40',
                    equipment: ['Bar'],
                  ),
                ],
              ),
              // ACC
              WorkoutSection(
                id: 'day1_acc',
                title: 'ACC',
                type: WorkoutSectionType.accessory,
                exercises: [
                  Exercise(
                    id: 'day1_acc_1',
                    name: 'Weighted Chest to Bar Pull Ups',
                    exerciseType: ExerciseType.reps,
                    sets: '5 Sets',
                    reps: '3-5',
                    percentage: 30.0,
                    equipment: ['Bar'],
                  ),
                ],
              ),
            ],
          ),
          // 2.Gün
          ProgramDay(
            dayNumber: 2,
            dayName: '2.Gün',
            sections: [
              WorkoutSection(
                id: 'day2_rest',
                title: 'Rest Day',
                type: WorkoutSectionType.conditioning,
                exercises: [
                  Exercise(
                    id: 'day2_rest_1',
                    name: 'Active Recovery',
                    description: 'Light stretching and mobility work',
                    exerciseType: ExerciseType.reps,
                    reps: '30 min',
                  ),
                ],
              ),
            ],
          ),
          // 3.Gün
          ProgramDay(
            dayNumber: 3,
            dayName: '3.Gün',
            sections: [
              WorkoutSection(
                id: 'day3_workout',
                title: 'STR',
                type: WorkoutSectionType.strength,
                exercises: [
                  Exercise(
                    id: 'day3_str_1',
                    name: 'Deadlift',
                    exerciseType: ExerciseType.reps,
                    sets: '5 x 5',
                    reps: '5',
                    percentage: 85.0,
                    mainLiftKey: 'Deadlift',
                  ),
                ],
              ),
            ],
          ),
          // 4.Gün
          ProgramDay(
            dayNumber: 4,
            dayName: '4.Gün',
            sections: [
              WorkoutSection(
                id: 'day4_workout',
                title: 'Metcon',
                type: WorkoutSectionType.metcon,
                instructions: 'For Time',
                exercises: [
                  Exercise(
                    id: 'day4_metcon_1',
                    name: 'Fran',
                    exerciseType: ExerciseType.forTime,
                    reps: '21-15-9',
                    equipment: ['Bar', 'Pull-up Bar'],
                  ),
                ],
              ),
            ],
          ),
          // 5.Gün
          ProgramDay(
            dayNumber: 5,
            dayName: '5.Gün',
            sections: [
              WorkoutSection(
                id: 'day5_workout',
                title: 'ACC',
                type: WorkoutSectionType.accessory,
                exercises: [
                  Exercise(
                    id: 'day5_acc_1',
                    name: 'Core Work',
                    exerciseType: ExerciseType.reps,
                    sets: '3 Rounds',
                    reps: '50',
                    equipment: ['Mat'],
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      // Firestore'a kaydet
      await _firestore.collection('programs').doc(crossfitProgram.id).set(crossfitProgram.toMap());
      
      print('✅ Örnek program başarıyla eklendi!');
      print('Program ID: ${crossfitProgram.id}');
      print('Program Adı: ${crossfitProgram.title}');
      print('Gün Sayısı: ${crossfitProgram.days.length}');
      
    } catch (e) {
      print('❌ Örnek veri ekleme hatası: $e');
    }
  }
}
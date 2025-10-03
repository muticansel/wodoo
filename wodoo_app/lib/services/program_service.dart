import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/program_model.dart';

class ProgramService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all programs
  Stream<List<ProgramModel>> getActivePrograms() {
    return _firestore
        .collection('programs')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ProgramModel.fromMap(doc.data()!, doc.id))
          .toList();
    });
  }

  // Get program by ID
  Future<ProgramModel?> getProgramById(String programId) async {
    try {
      final doc = await _firestore.collection('programs').doc(programId).get();
      if (doc.exists) {
        return ProgramModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Get Program By ID Error: $e');
      return null;
    }
  }

  // Get programs by category
  Future<List<ProgramModel>> getProgramsByCategory(String category) async {
    try {
      final querySnapshot = await _firestore
          .collection('programs')
          .where('category', isEqualTo: category)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ProgramModel.fromMap(doc.data()!, doc.id))
          .toList();
    } catch (e) {
      print('Get Programs By Category Error: $e');
      return [];
    }
  }

  // Get workout section by ID from a program
  Future<WorkoutSection?> getWorkoutSectionById(String programId, String sectionId) async {
    try {
      final program = await getProgramById(programId);
      if (program != null) {
        for (final day in program.days) {
          for (final section in day.sections) {
            if (section.id == sectionId) {
              return section;
            }
          }
        }
      }
      return null;
    } catch (e) {
      print('Get Workout Section By ID Error: $e');
      return null;
    }
  }

  // Get sections for a specific day
  Future<List<WorkoutSection>> getSectionsForDay(String programId, int dayNumber) async {
    try {
      final program = await getProgramById(programId);
      if (program != null) {
        final day = program.days.firstWhere(
          (d) => d.dayNumber == dayNumber,
          orElse: () => ProgramDay(dayNumber: 0, dayName: '', sections: []),
        );
        return day.sections;
      }
      return [];
    } catch (e) {
      print('Get Sections For Day Error: $e');
      return [];
    }
  }

  // Search programs by title
  Stream<List<ProgramModel>> searchPrograms(String query) {
    return _firestore
        .collection('programs')
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThan: query + 'z')
        .orderBy('title')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ProgramModel.fromMap(doc.data()!, doc.id))
          .toList();
    });
  }

  // Get program statistics
  Future<Map<String, int>> getProgramStats() async {
    try {
      final querySnapshot = await _firestore
          .collection('programs')
          .get();

      int totalPrograms = querySnapshot.docs.length;
      int totalDays = 0;
      int totalSections = 0;

      for (final doc in querySnapshot.docs) {
        final program = ProgramModel.fromMap(doc.data()!, doc.id);
        totalDays += program.days.length;
        for (final day in program.days) {
          totalSections += day.sections.length;
        }
      }

      return {
        'totalPrograms': totalPrograms,
        'totalDays': totalDays,
        'totalSections': totalSections,
      };
    } catch (e) {
      print('Get Program Stats Error: $e');
      return {'totalPrograms': 0, 'totalDays': 0, 'totalSections': 0};
    }
  }
}


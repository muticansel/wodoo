import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_workout_model.dart';

class UserWorkoutService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Complete a workout
  Future<bool> completeWorkout({
    required String userId,
    required String programId,
    required String workoutId,
    String? notes,
    int? rating,
    int? duration,
  }) async {
    try {
      final userWorkout = UserWorkoutModel(
        id: _firestore.collection('user_workouts').doc().id,
        userId: userId,
        programId: programId,
        workoutId: workoutId,
        completedAt: DateTime.now(),
        notes: notes,
        rating: rating,
        duration: duration,
      );

      await _firestore
          .collection('user_workouts')
          .doc(userWorkout.id)
          .set(userWorkout.toMap());

      return true;
    } catch (e) {
      print('Complete Workout Error: $e');
      return false;
    }
  }

  // Get user's completed workouts
  Stream<List<UserWorkoutModel>> getUserWorkouts(String userId) {
    return _firestore
        .collection('user_workouts')
        .where('userId', isEqualTo: userId)
        .orderBy('completedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UserWorkoutModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  // Get user's workouts for a specific program
  Stream<List<UserWorkoutModel>> getUserWorkoutsForProgram(String userId, String programId) {
    return _firestore
        .collection('user_workouts')
        .where('userId', isEqualTo: userId)
        .where('programId', isEqualTo: programId)
        .orderBy('completedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UserWorkoutModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  // Get user's workouts for a specific day
  Future<List<UserWorkoutModel>> getUserWorkoutsForDay(String userId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final querySnapshot = await _firestore
          .collection('user_workouts')
          .where('userId', isEqualTo: userId)
          .where('completedAt', isGreaterThanOrEqualTo: startOfDay)
          .where('completedAt', isLessThan: endOfDay)
          .orderBy('completedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => UserWorkoutModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Get User Workouts For Day Error: $e');
      return [];
    }
  }

  // Check if workout is completed
  Future<bool> isWorkoutCompleted(String userId, String workoutId) async {
    try {
      final querySnapshot = await _firestore
          .collection('user_workouts')
          .where('userId', isEqualTo: userId)
          .where('workoutId', isEqualTo: workoutId)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Is Workout Completed Error: $e');
      return false;
    }
  }

  // Get workout completion statistics
  Future<Map<String, dynamic>> getWorkoutStats(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('user_workouts')
          .where('userId', isEqualTo: userId)
          .get();

      int totalWorkouts = querySnapshot.docs.length;
      int totalDuration = 0;
      double totalRating = 0;
      int ratedWorkouts = 0;

      for (final doc in querySnapshot.docs) {
        final workout = UserWorkoutModel.fromMap({...doc.data(), 'id': doc.id});
        
        if (workout.duration != null) {
          totalDuration += workout.duration!;
        }
        
        if (workout.rating != null) {
          totalRating += workout.rating!;
          ratedWorkouts++;
        }
      }

      final averageRating = ratedWorkouts > 0 ? totalRating / ratedWorkouts : 0.0;
      final averageDuration = totalWorkouts > 0 ? totalDuration / totalWorkouts : 0.0;

      return {
        'totalWorkouts': totalWorkouts,
        'totalDuration': totalDuration,
        'averageDuration': averageDuration,
        'averageRating': averageRating,
        'ratedWorkouts': ratedWorkouts,
      };
    } catch (e) {
      print('Get Workout Stats Error: $e');
      return {
        'totalWorkouts': 0,
        'totalDuration': 0,
        'averageDuration': 0.0,
        'averageRating': 0.0,
        'ratedWorkouts': 0,
      };
    }
  }

  // Get workout streak
  Future<int> getWorkoutStreak(String userId) async {
    try {
      final now = DateTime.now();
      int streak = 0;
      DateTime currentDate = DateTime(now.year, now.month, now.day);

      while (true) {
        final workouts = await getUserWorkoutsForDay(userId, currentDate);
        if (workouts.isNotEmpty) {
          streak++;
          currentDate = currentDate.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }

      return streak;
    } catch (e) {
      print('Get Workout Streak Error: $e');
      return 0;
    }
  }

  // Update workout notes
  Future<bool> updateWorkoutNotes(String workoutId, String notes) async {
    try {
      await _firestore
          .collection('user_workouts')
          .doc(workoutId)
          .update({'notes': notes});
      return true;
    } catch (e) {
      print('Update Workout Notes Error: $e');
      return false;
    }
  }

  // Update workout rating
  Future<bool> updateWorkoutRating(String workoutId, int rating) async {
    try {
      await _firestore
          .collection('user_workouts')
          .doc(workoutId)
          .update({'rating': rating});
      return true;
    } catch (e) {
      print('Update Workout Rating Error: $e');
      return false;
    }
  }

  // Delete workout
  Future<bool> deleteWorkout(String workoutId) async {
    try {
      await _firestore
          .collection('user_workouts')
          .doc(workoutId)
          .delete();
      return true;
    } catch (e) {
      print('Delete Workout Error: $e');
      return false;
    }
  }
}


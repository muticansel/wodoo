import 'package:flutter/foundation.dart';
import '../models/program_model.dart';
import '../services/program_service.dart';

class ProgramProvider with ChangeNotifier {
  final ProgramService _programService = ProgramService();
  
  List<ProgramModel> _programs = [];
  ProgramModel? _currentProgram;
  List<Workout> _todayWorkouts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ProgramModel> get programs => _programs;
  ProgramModel? get currentProgram => _currentProgram;
  List<Workout> get todayWorkouts => _todayWorkouts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ProgramProvider() {
    // Basit başlatma - hiçbir otomatik yükleme yok
    print('ProgramProvider initialized - Simple version');
  }

  Future<void> _loadActivePrograms() async {
    _setLoading(true);
    _clearError();

    try {
      _programService.getActivePrograms().listen((programs) {
        if (_programs != programs) {
          _programs = programs;
          notifyListeners();
        }
      });
    } catch (e) {
      _setError('Programlar yüklenirken hata oluştu: $e');
    }
    _setLoading(false);
  }

  Future<void> _loadCurrentWeekProgram() async {
    try {
      _currentProgram = await _programService.getCurrentWeekProgram();
      if (_currentProgram != null) {
        _loadTodayWorkouts();
      }
      notifyListeners();
    } catch (e) {
      _setError('Mevcut hafta programı yüklenirken hata oluştu: $e');
    }
  }

  Future<void> _loadTodayWorkouts() async {
    if (_currentProgram == null) return;

    try {
      final today = DateTime.now();
      final dayNumber = today.weekday; // 1 = Monday, 7 = Sunday
      
      _todayWorkouts = await _programService.getWorkoutsForDay(
        _currentProgram!.id,
        dayNumber,
      );
      notifyListeners();
    } catch (e) {
      _setError('Bugünkü antrenmanlar yüklenirken hata oluştu: $e');
    }
  }

  Future<void> loadProgramById(String programId) async {
    _setLoading(true);
    _clearError();

    try {
      _currentProgram = await _programService.getProgramById(programId);
      if (_currentProgram != null) {
        _loadTodayWorkouts();
      }
      _setLoading(false);
    } catch (e) {
      _setError('Program yüklenirken hata oluştu: $e');
      _setLoading(false);
    }
  }

  Future<void> loadProgramByWeek(int weekNumber, int year) async {
    _setLoading(true);
    _clearError();

    try {
      _currentProgram = await _programService.getProgramByWeek(weekNumber, year);
      if (_currentProgram != null) {
        _loadTodayWorkouts();
      }
      _setLoading(false);
    } catch (e) {
      _setError('Hafta programı yüklenirken hata oluştu: $e');
      _setLoading(false);
    }
  }

  Future<Workout?> getWorkoutById(String workoutId) async {
    if (_currentProgram == null) return null;

    try {
      return await _programService.getWorkoutById(_currentProgram!.id, workoutId);
    } catch (e) {
      _setError('Antrenman yüklenirken hata oluştu: $e');
      return null;
    }
  }

  Future<List<Workout>> getWorkoutsForDay(int dayNumber) async {
    if (_currentProgram == null) return [];

    try {
      return await _programService.getWorkoutsForDay(_currentProgram!.id, dayNumber);
    } catch (e) {
      _setError('Günlük antrenmanlar yüklenirken hata oluştu: $e');
      return [];
    }
  }

  Future<void> searchPrograms(String query) async {
    _setLoading(true);
    _clearError();

    try {
      _programService.searchPrograms(query).listen((programs) {
        if (_programs != programs) {
          _programs = programs;
          notifyListeners();
        }
      });
    } catch (e) {
      _setError('Program arama sırasında hata oluştu: $e');
    }
    _setLoading(false);
  }

  Future<Map<String, int>> getProgramStats() async {
    try {
      return await _programService.getProgramStats();
    } catch (e) {
      _setError('Program istatistikleri yüklenirken hata oluştu: $e');
      return {'totalPrograms': 0, 'totalWorkouts': 0};
    }
  }

  void refreshPrograms() {
    _loadActivePrograms();
    _loadCurrentWeekProgram();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    // notifyListeners() çağırmıyoruz - bu sonsuz döngüyü önler
  }

  void _setError(String error) {
    _errorMessage = error;
    // notifyListeners() çağırmıyoruz - bu sonsuz döngüyü önler
  }

  void _clearError() {
    _errorMessage = null;
    // notifyListeners() çağırmıyoruz - bu sonsuz döngüyü önler
  }

  void clearError() {
    _clearError();
  }
}


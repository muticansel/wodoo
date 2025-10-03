import 'package:flutter/material.dart';
import '../models/program_model.dart';
import '../services/weight_calculation_service.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProgramDetailScreen extends StatefulWidget {
  final ProgramModel program;

  const ProgramDetailScreen({
    Key? key,
    required this.program,
  }) : super(key: key);

  @override
  State<ProgramDetailScreen> createState() => _ProgramDetailScreenState();
}

class _ProgramDetailScreenState extends State<ProgramDetailScreen> {
  Map<String, double> _userMainLifts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserMainLifts();
  }

  Future<void> _loadUserMainLifts() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData = await AuthService().getUserData(user.uid);
        if (userData != null && mounted) {
          setState(() {
            _userMainLifts = userData.preferences.mainLifts;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Main lifts yükleme hatası: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF2D3748),
              size: 20,
            ),
          ),
        ),
        title: Text(
          widget.program.title,
          style: const TextStyle(
            color: Color(0xFF2D3748),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB22B69)),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Program Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFB22B69),
                          Color(0xFF2889B8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFB22B69).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.program.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.program.description,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            _buildInfoChip(
                              icon: Icons.schedule,
                              label: 'Süre',
                              value: widget.program.duration,
                            ),
                            _buildInfoChip(
                              icon: Icons.trending_up,
                              label: 'Zorluk',
                              value: widget.program.difficulty,
                            ),
                            _buildInfoChip(
                              icon: Icons.category,
                              label: 'Kategori',
                              value: widget.program.category,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Days List
                  ...widget.program.days.map((day) => _buildDayCard(context, day)),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              '$label: $value',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCard(BuildContext context, ProgramDay day) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey[50]!,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB22B69).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFB22B69).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          expansionTileTheme: const ExpansionTileThemeData(
            iconColor: Color(0xFFB22B69),
            collapsedIconColor: Color(0xFFB22B69),
          ),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          childrenPadding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
          leading: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFB22B69),
                  Color(0xFF2889B8),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFB22B69).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '${day.dayNumber}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          title: Text(
            day.dayName,
            style: const TextStyle(
              color: Color(0xFF2D3748),
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Icon(
                  Icons.fitness_center,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 6),
                Text(
                  '${day.sections.length} antrenman bölümü',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          children: [
            // Sections List
            ...day.sections.map((section) => _buildWorkoutCard(context, section)),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutCard(BuildContext context, WorkoutSection section) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getSectionColor(section.type).withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: _getSectionColor(section.type).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          expansionTileTheme: ExpansionTileThemeData(
            iconColor: _getSectionColor(section.type),
            collapsedIconColor: _getSectionColor(section.type),
            backgroundColor: Colors.transparent,
            collapsedBackgroundColor: Colors.transparent,
          ),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          childrenPadding: const EdgeInsets.only(bottom: 16, left: 12, right: 12),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getSectionColor(section.type),
                  _getSectionColor(section.type).withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: _getSectionColor(section.type).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _getSectionIcon(section.type),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          title: Text(
            section.title,
            style: const TextStyle(
              color: Color(0xFF2D3748),
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          subtitle: section.instructions != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          section.instructions!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : null,
          children: [
            // Exercises
            ...section.exercises.asMap().entries.map((entry) {
              final index = entry.key;
              final exercise = entry.value;
              return _buildExerciseItem(exercise, index + 1);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseItem(Exercise exercise, [int? exerciseNumber]) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey[50]!,
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise Name
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFB22B69),
                      Color(0xFF2889B8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              // Exercise Number (if provided)
              if (exerciseNumber != null) ...[
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFB22B69),
                        Color(0xFF2889B8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFB22B69).withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$exerciseNumber',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  exercise.name,
                  style: const TextStyle(
                    color: Color(0xFF2D3748),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Exercise Details
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (exercise.sets != null)
                _buildDetailChip(
                  icon: Icons.repeat,
                  label: 'Sets',
                  value: exercise.sets!,
                  color: const Color(0xFF2889B8),
                ),
              
              if (exercise.reps != null)
                _buildDetailChip(
                  icon: Icons.fitness_center,
                  label: 'Reps',
                  value: exercise.reps!,
                  color: const Color(0xFFB22B69),
                ),
              
              if (exercise.weight != null)
                _buildDetailChip(
                  icon: Icons.scale,
                  label: 'Weight',
                  value: exercise.weight!,
                  color: const Color(0xFF4A5568),
                ),
              
              if (exercise.percentage != null)
                _buildDetailChip(
                  icon: Icons.percent,
                  label: 'Percentage',
                  value: '${exercise.percentage!.toInt()}%',
                  color: const Color(0xFF38A169),
                ),
              
              if (exercise.percentage != null && exercise.mainLiftKey != null)
                _buildDetailChip(
                  icon: Icons.scale,
                  label: 'Weight',
                  value: _calculateWeight(exercise),
                  color: const Color(0xFF805AD5),
                ),
            ],
          ),
          
          // Description
          if (exercise.description != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.blue[200]!,
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue[600],
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      exercise.description!,
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Notes
          if (exercise.notes != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.orange[200]!,
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Colors.orange[600],
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      exercise.notes!,
                      style: TextStyle(
                        color: Colors.orange[800],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getSectionColor(WorkoutSectionType type) {
    switch (type) {
      case WorkoutSectionType.plyo:
        return const Color(0xFFE53E3E); // Red
      case WorkoutSectionType.strength:
        return const Color(0xFF3182CE); // Blue
      case WorkoutSectionType.metcon:
        return const Color(0xFF38A169); // Green
      case WorkoutSectionType.accessory:
        return const Color(0xFF805AD5); // Purple
      case WorkoutSectionType.conditioning:
        return const Color(0xFFD69E2E); // Yellow
      case WorkoutSectionType.gripAndCore:
        return const Color(0xFFDD6B20); // Orange
      case WorkoutSectionType.warmUp:
        return const Color(0xFF319795); // Teal
      case WorkoutSectionType.coolDown:
        return const Color(0xFF718096); // Gray
    }
  }

  String _getSectionIcon(WorkoutSectionType type) {
    switch (type) {
      case WorkoutSectionType.plyo:
        return 'P';
      case WorkoutSectionType.strength:
        return 'S';
      case WorkoutSectionType.metcon:
        return 'M';
      case WorkoutSectionType.accessory:
        return 'A';
      case WorkoutSectionType.conditioning:
        return 'C';
      case WorkoutSectionType.gripAndCore:
        return 'G';
      case WorkoutSectionType.warmUp:
        return 'W';
      case WorkoutSectionType.coolDown:
        return 'C';
    }
  }

  String _calculateWeight(Exercise exercise) {
    if (exercise.percentage == null) {
      return 'N/A';
    }

    // Main lift key'i otomatik bul - her zaman yeniden hesapla
    String? mainLiftKey = WeightCalculationService.findMainLiftKey(exercise.name);

    if (mainLiftKey == null) {
      return 'PR gerekli';
    }

    final userMainLift = _userMainLifts[mainLiftKey];
    
    if (userMainLift == null || userMainLift == 0) {
      return 'PR gerekli';
    }

    // Exercise'ı mainLiftKey ile güncelle
    final updatedExercise = Exercise(
      id: exercise.id,
      name: exercise.name,
      sets: exercise.sets,
      reps: exercise.reps,
      weight: exercise.weight,
      percentage: exercise.percentage,
      mainLiftKey: mainLiftKey,
      description: exercise.description,
      notes: exercise.notes,
      exerciseType: exercise.exerciseType,
      timeDomain: exercise.timeDomain,
      restTime: exercise.restTime,
      equipment: exercise.equipment,
    );

    final calculatedWeight = WeightCalculationService.calculateWeight(
      updatedExercise,
      _userMainLifts,
    );

    if (calculatedWeight == null) {
      return 'PR gerekli';
    }

    return '${calculatedWeight.toInt()}kg';
  }
}
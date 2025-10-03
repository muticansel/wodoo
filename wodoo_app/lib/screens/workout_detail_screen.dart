import 'package:flutter/material.dart';
import '../models/program_model.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final Workout workout;

  const WorkoutDetailScreen({
    super.key,
    required this.workout,
  });

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  bool _isCompleted = false;
  final TextEditingController _notesController = TextEditingController();
  int _rating = 0;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFB22B69),
                Color(0xFF2889B8),
              ],
            ),
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
        title: Text(
          widget.workout.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 20, top: 8, bottom: 8),
            child: GestureDetector(
              onTap: _shareWorkout,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.share,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Workout Header
            _buildWorkoutHeader(),
            
            const SizedBox(height: 24),
            
            // Workout Description
            if (widget.workout.description.isNotEmpty) ...[
              _buildSection(
                'Açıklama',
                Text(
                  widget.workout.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            // Exercises
            _buildSection(
              'Egzersizler',
              Column(
                children: widget.workout.exercises.map((exercise) => 
                  _buildExerciseCard(exercise)
                ).toList(),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Workout Notes
            _buildSection(
              'Notlar',
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Antrenman notlarınızı buraya yazın...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Rating
            _buildSection(
              'Değerlendirme',
              Row(
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () {
                      setState(() {
                        _rating = index + 1;
                      });
                    },
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                  );
                }),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Complete Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isCompleted ? null : _completeWorkout,
                icon: _isCompleted 
                    ? const Icon(Icons.check_circle)
                    : const Icon(Icons.play_arrow),
                label: Text(
                  _isCompleted ? 'Tamamlandı' : 'Antrenmanı Başlat',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: _isCompleted ? Colors.green : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getWorkoutIcon('strength'),
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.workout.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Güç Antrenmanı',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Workout Info
            Row(
              children: [
                _buildInfoItem(
                  Icons.schedule,
                  'Süre',
                  '${widget.workout.duration} dk',
                ),
                const SizedBox(width: 24),
                _buildInfoItem(
                  Icons.trending_up,
                  'Zorluk',
                  widget.workout.difficulty,
                ),
                const SizedBox(width: 24),
                _buildInfoItem(
                  Icons.fitness_center,
                  'Egzersizler',
                  '${widget.workout.exercises.length}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildExerciseCard(Exercise exercise) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exercise.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            if (exercise.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                exercise.description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            
            const SizedBox(height: 12),
            
            // Exercise Details
            Row(
              children: [
                if (exercise.sets > 0) ...[
                  _buildDetailChip('${exercise.sets} Set'),
                  const SizedBox(width: 8),
                ],
                if (exercise.reps > 0) ...[
                  _buildDetailChip('${exercise.reps} Rep'),
                  const SizedBox(width: 8),
                ],
                if (exercise.restTime > 0) ...[
                  _buildDetailChip('${exercise.restTime} dk dinlenme'),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  IconData _getWorkoutIcon(String type) {
    switch (type) {
      case 'wod':
        return Icons.fitness_center;
      case 'strength':
        return Icons.fitness_center;
      case 'metcon':
        return Icons.speed;
      case 'plyo':
        return Icons.sports_gymnastics;
      case 'accessory':
        return Icons.sports_gymnastics;
      default:
        return Icons.fitness_center;
    }
  }

  String _getWorkoutTypeText(String type) {
    switch (type) {
      case 'wod':
        return 'WOD (Workout of the Day)';
      case 'strength':
        return 'Güç Antrenmanı';
      case 'metcon':
        return 'Metabolik Kondisyon';
      case 'plyo':
        return 'Pliometrik Antrenman';
      case 'accessory':
        return 'Yardımcı Egzersiz';
      default:
        return 'Antrenman';
    }
  }

  String _getDifficultyText(String difficulty) {
    switch (difficulty) {
      case 'beginner':
        return 'Başlangıç';
      case 'intermediate':
        return 'Orta';
      case 'advanced':
        return 'İleri';
      default:
        return 'Başlangıç';
    }
  }

  void _shareWorkout() {
    // TODO: Implement workout sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Paylaşım özelliği yakında eklenecek')),
    );
  }

  void _completeWorkout() {
    setState(() {
      _isCompleted = true;
    });
    
    // TODO: Save workout completion to Firestore
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Antrenman tamamlandı!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

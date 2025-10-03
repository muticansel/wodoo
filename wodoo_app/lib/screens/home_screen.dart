import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/program_provider.dart';
import 'login_screen.dart';
import 'subscription_screen.dart';
import 'workout_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isAuthenticated) {
          return const LoginScreen();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Wodoo'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  Provider.of<ProgramProvider>(context, listen: false)
                      .refreshPrograms();
                },
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'logout') {
                    _handleLogout(context, authProvider);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'logout',
                    child: Text('Çıkış Yap'),
                  ),
                ],
              ),
            ],
          ),
          body: IndexedStack(
            index: _currentIndex,
            children: const [
              _HomeTab(),
              _ProgramsTab(),
              _ProfileTab(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Ana Sayfa',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.fitness_center),
                label: 'Programlar',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleLogout(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Çıkış yapmak istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await authProvider.signOut();
            },
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ProgramProvider>(
      builder: (context, authProvider, programProvider, child) {
        // Check subscription status
        if (!authProvider.user!.subscription.isActive) {
          return _buildSubscriptionRequired(context);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Text(
                'Hoş geldin, ${authProvider.user!.displayName}!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bugünkü antrenmanınızı başlatmaya hazır mısınız?',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Today's Workouts
              if (programProvider.currentProgram != null) ...[
                Text(
                  'Bugünkü Antrenmanlar',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                if (programProvider.todayWorkouts.isNotEmpty) ...[
                  ...programProvider.todayWorkouts.map((workout) => 
                    _buildWorkoutCard(context, workout)
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.hotel,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Bugün dinlenme günü!',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Yarın yeni antrenmanlarınızı görebilirsiniz.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.fitness_center,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Henüz program yüklenmedi',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Yeni programlar yüklendiğinde burada görünecek.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubscriptionRequired(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'Abonelik Gerekli',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Antrenman programlarına erişmek için abonelik satın almanız gerekiyor.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SubscriptionScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text('Abonelik Satın Al'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutCard(BuildContext context, workout) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getWorkoutIcon(workout.type.name),
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(
          workout.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(workout.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  workout.duration,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.trending_up,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  _getDifficultyText(workout.difficulty.name),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => WorkoutDetailScreen(workout: workout),
            ),
          );
        },
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
}

class _ProgramsTab extends StatelessWidget {
  const _ProgramsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgramProvider>(
      builder: (context, programProvider, child) {
        if (programProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (programProvider.programs.isEmpty) {
          return const Center(
            child: Text('Henüz program bulunamadı'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: programProvider.programs.length,
          itemBuilder: (context, index) {
            final program = programProvider.programs[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.calendar_today,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                title: Text(
                  program.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Hafta ${program.weekNumber} - ${program.year}',
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Navigate to program detail
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user!;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile Header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: user.photoURL != null
                            ? NetworkImage(user.photoURL!)
                            : null,
                        child: user.photoURL == null
                            ? const Icon(Icons.person, size: 40)
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.displayName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Subscription Status
              Card(
                child: ListTile(
                  leading: Icon(
                    user.subscription.isActive ? Icons.check_circle : Icons.cancel,
                    color: user.subscription.isActive ? Colors.green : Colors.red,
                  ),
                  title: Text(
                    user.subscription.isActive ? 'Aktif Abonelik' : 'Abonelik Yok',
                  ),
                  subtitle: user.subscription.isActive
                      ? Text('${user.subscription.daysRemaining} gün kaldı')
                      : const Text('Abonelik satın alın'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SubscriptionScreen(),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Settings
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.language),
                      title: const Text('Dil'),
                      subtitle: Text(user.preferences.language == 'tr' ? 'Türkçe' : 'English'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // Navigate to language settings
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.notifications),
                      title: const Text('Bildirimler'),
                      subtitle: Text(user.preferences.notifications ? 'Açık' : 'Kapalı'),
                      trailing: Switch(
                        value: user.preferences.notifications,
                        onChanged: (value) {
                          // Update notification preference
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.dark_mode),
                      title: const Text('Tema'),
                      subtitle: Text(user.preferences.theme == 'light' ? 'Açık' : 'Koyu'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // Navigate to theme settings
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

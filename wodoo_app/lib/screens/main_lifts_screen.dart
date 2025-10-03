import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/subscription_model.dart';

class MainLiftsScreen extends StatefulWidget {
  const MainLiftsScreen({super.key});

  @override
  State<MainLiftsScreen> createState() => _MainLiftsScreenState();
}

class _MainLiftsScreenState extends State<MainLiftsScreen> with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  Map<String, double> _mainLifts = {};
  bool _isLoading = false;
  bool _isSaving = false;
  Map<String, TextEditingController> _controllers = {};
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> _liftNames = [
    'Snatch',
    'Clean & Jerk',
    'Clean',
    'Jerk',
    'Power Snatch',
    'Power Clean',
    'Power Jerk',
    'Back Squat',
    'Front Squat',
    'Overhead Squat',
    'Snatch Balance',
    'Push Press',
    'Deadlift',
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _checkAuthState();
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    // Dispose all controllers
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _checkAuthState() {
    _auth.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() {
          _user = user;
        });
        if (user != null) {
          _loadMainLifts();
        }
      }
    });
  }

  void _createControllers() {
    for (String liftName in _liftNames) {
      if (!_controllers.containsKey(liftName)) {
        _controllers[liftName] = TextEditingController(
          text: _mainLifts[liftName]?.toStringAsFixed(0) ?? '',
        );
      }
    }
  }

  Future<void> _loadMainLifts() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final userDoc = await _firestore.collection('users').doc(_user!.uid).get();
      if (userDoc.exists) {
        final userData = UserModel.fromMap(userDoc.data()!);
            if (mounted) {
              setState(() {
                _mainLifts = userData.preferences.mainLifts;
                _isLoading = false;
              });
              _createControllers();
            }
      } else {
        if (mounted) {
          setState(() {
            _mainLifts = {};
            _isLoading = false;
          });
          _createControllers();
        }
      }
    } catch (e) {
      print('Main lifts yükleme hatası: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _createControllers();
      }
    }
  }

  Future<void> _saveMainLifts() async {
    if (mounted) {
      setState(() {
        _isSaving = true;
      });
    }

    try {
      final userDoc = await _firestore.collection('users').doc(_user!.uid).get();
      
      if (userDoc.exists) {
        // Update existing user
        await _firestore.collection('users').doc(_user!.uid).update({
          'preferences.mainLifts': _mainLifts,
        });
      } else {
        // Create new user
        final newUser = UserModel(
          uid: _user!.uid,
          email: _user!.email ?? '',
          displayName: _user!.displayName ?? '',
          subscription: Subscription(
            plan: 'free',
            isActive: false,
            startDate: DateTime.now(),
            endDate: DateTime.now(),
          ),
          preferences: UserPreferences(
            language: 'tr',
            notifications: true,
            theme: 'light',
            mainLifts: _mainLifts,
          ),
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
        await _firestore.collection('users').doc(_user!.uid).set(newUser.toMap());
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Ana lifts başarıyla kaydedildi!'),
              ],
            ),
            backgroundColor: const Color(0xFF38A169),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      print('Kaydetme hatası: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Kaydetme hatası: $e')),
              ],
            ),
            backgroundColor: const Color(0xFFE53E3E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB22B69)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: CustomScrollView(
            slivers: [
              // App Bar
              _buildAppBar(),
              
              // Content
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: _isLoading
                    ? _buildLoadingState()
                    : _buildMainLiftsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 100,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
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
        child: FlexibleSpaceBar(
                 title: const Text(
                   'PR\'s',
                   style: TextStyle(
                     color: Colors.white,
                     fontSize: 20,
                     fontWeight: FontWeight.w800,
                     letterSpacing: 0.5,
                   ),
                 ),
          titlePadding: const EdgeInsets.only(left: 0, bottom: 16),
          centerTitle: true,
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 20, top: 8, bottom: 8),
          child: GestureDetector(
            onTap: _isSaving ? null : _saveMainLifts,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _isSaving 
                    ? Colors.white.withOpacity(0.3)
                    : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.save,
                      color: Colors.white,
                      size: 20,
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB22B69)),
            ),
            const SizedBox(height: 20),
            Text(
              'Ana lifts yükleniyor...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainLiftsList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final liftName = _liftNames[index];
          return _buildLiftCard(liftName, index);
        },
        childCount: _liftNames.length,
      ),
    );
  }

  Widget _buildLiftCard(String liftName, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 300 + (50 * index)),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Opacity(
              opacity: value,
              child: child,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey[50]!,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFB22B69).withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(
              color: const Color(0xFFB22B69).withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Lift Icon
              Container(
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
                child: const Icon(
                  Icons.fitness_center,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              
              const SizedBox(width: 20),
              
              // Lift Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      liftName,
                      style: const TextStyle(
                        color: Color(0xFF2D3748),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kişisel rekorunuzu girin',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Weight Input
              Container(
                width: 100,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey[200]!,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _controllers[liftName],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF2D3748),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    suffixText: 'kg',
                    suffixStyle: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onChanged: (value) {
                    final weight = double.tryParse(value);
                    if (weight != null) {
                      _mainLifts[liftName] = weight;
                    } else if (value.isEmpty) {
                      _mainLifts.remove(liftName);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
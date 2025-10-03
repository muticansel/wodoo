import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'simple_home_screen.dart';
import 'profile_screen.dart';
import 'subscription_plans_screen.dart';
import 'login_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> with TickerProviderStateMixin {
  int _currentIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _isLoading = true;
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _initializeApp();
    _setupAuthListener();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    try {
      final user = _auth.currentUser;
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
        _fadeController.forward();
        _slideController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _user = null;
          _isLoading = false;
        });
      }
    }
  }

  void _setupAuthListener() {
    _auth.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() {
          _user = user;
        });
      }
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _getCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return const SimpleHomeScreen();
      case 1:
        return const SubscriptionPlansScreen();
      case 2:
        return const ProfileScreen();
      default:
        return const SimpleHomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
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
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                SizedBox(height: 20),
                Text(
                  'Wodoo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_user == null) {
      return const LoginScreen();
    }

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: _getCurrentScreen(),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFF7FAFC),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Ana Sayfa',
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.subscriptions_outlined,
                  activeIcon: Icons.subscriptions,
                  label: 'Abonelik',
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Profil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isActive = _currentIndex == index;
    
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFB22B69),
                    Color(0xFF2889B8),
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFFB22B69).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? activeIcon : icon,
                key: ValueKey(isActive),
                color: isActive ? Colors.white : Colors.grey[600],
                size: 20,
              ),
            ),
            const SizedBox(height: 2),
            Flexible(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey[600],
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
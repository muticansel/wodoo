import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'login_screen.dart';
import 'main_lifts_screen.dart';
import 'subscription_plans_screen.dart';
import '../services/subscription_service.dart';
import '../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  bool _isLoading = false;
  bool _isSubscribed = false;
  bool _isLoadingSubscription = true;
  UserModel? _userModel;
  
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
    super.dispose();
  }

  void _checkAuthState() {
    _auth.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() {
          _user = user;
        });
        if (user != null) {
          _loadUserData();
          _checkSubscription();
        }
      }
    });
  }

  Future<void> _loadUserData() async {
    if (_user == null) return;
    
    try {
      final userDoc = await _firestore.collection('users').doc(_user!.uid).get();
      if (userDoc.exists && mounted) {
        setState(() {
          _userModel = UserModel.fromMap(userDoc.data()!);
        });
      }
    } catch (e) {
      print('Kullanıcı verileri yüklenirken hata oluştu: $e');
    }
  }

  Future<void> _checkSubscription() async {
    if (mounted) {
      setState(() {
        _isLoadingSubscription = true;
      });
    }

    try {
      final isSubscribed = await SubscriptionService.isUserSubscribed();
      if (mounted) {
        setState(() {
          _isSubscribed = isSubscribed;
          _isLoadingSubscription = false;
        });
      }
    } catch (e) {
      print('Abonelik kontrol hatası: $e');
      if (mounted) {
        setState(() {
          _isSubscribed = false;
          _isLoadingSubscription = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      await _auth.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      print('Çıkış hatası: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Profile Header
                    _buildProfileHeader(),
                    
                    const SizedBox(height: 24),
                    
                    // Subscription Info
                    _buildSubscriptionInfoCard(),
                    
                    const SizedBox(height: 24),
                    
                    // Menu Items
                    _buildMenuSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Sign Out Button
                    _buildSignOutButton(),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
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
            'Profil',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Color(0xFFF7FAFC),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB22B69).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFB22B69).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
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
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _user!.displayName?.isNotEmpty == true
                    ? _user!.displayName![0].toUpperCase()
                    : _user!.email![0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 20),
          
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _user!.displayName ?? 'Kullanıcı',
                  style: const TextStyle(
                    color: Color(0xFF2D3748),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _user!.email ?? '',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _user!.isAnonymous 
                        ? Colors.orange[100] 
                        : Colors.green[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _user!.isAnonymous 
                          ? Colors.orange[300]! 
                          : Colors.green[300]!,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _user!.isAnonymous ? 'Misafir' : 'Üye',
                    style: TextStyle(
                      color: _user!.isAnonymous 
                          ? Colors.orange[800] 
                          : Colors.green[800],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionInfoCard() {
    if (_isLoadingSubscription) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB22B69)),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _isSubscribed
              ? [
                  const Color(0xFF38A169),
                  const Color(0xFF48BB78),
                ]
              : [
                  const Color(0xFFE53E3E),
                  const Color(0xFFFC8181),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (_isSubscribed ? Colors.green : Colors.red).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              _isSubscribed ? Icons.check_circle : Icons.cancel,
              color: Colors.white,
              size: 28,
            ),
          ),
          
          const SizedBox(width: 20),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isSubscribed ? 'Premium Üye' : 'Ücretsiz Üye',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isSubscribed 
                      ? 'Plan: ${_userModel?.subscription.plan ?? 'Bilinmiyor'}'
                      : 'Premium programlara erişim için abone olun',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_isSubscribed && _userModel?.subscription.endDate != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Bitiş: ${DateFormat('dd/MM/yyyy').format(_userModel!.subscription.endDate)}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          if (!_isSubscribed)
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SubscriptionPlansScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Text(
                  'Abone Ol',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.fitness_center,
            title: 'PR\'s',
            subtitle: 'Kişisel rekorlarınızı kaydedin',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MainLiftsScreen(),
                ),
              );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.settings,
            title: 'Ayarlar',
            subtitle: 'Uygulama ayarları',
            onTap: () {
              // TODO: Implement settings
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.help_outline,
            title: 'Yardım',
            subtitle: 'Sık sorulan sorular',
            onTap: () {
              // TODO: Implement help
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.info_outline,
            title: 'Hakkında',
            subtitle: 'Uygulama bilgileri',
            onTap: () {
              // TODO: Implement about
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFB22B69),
                      Color(0xFF2889B8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF2D3748),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 1,
      color: Colors.grey[200],
    );
  }

  Widget _buildSignOutButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE53E3E),
            Color(0xFFFC8181),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE53E3E).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _signOut,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.logout,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Çıkış Yap',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
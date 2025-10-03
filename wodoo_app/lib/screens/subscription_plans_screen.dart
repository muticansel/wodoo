import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/subscription_model.dart';

class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  State<SubscriptionPlansScreen> createState() => _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, dynamic>> _plans = [
    {
      'id': 'monthly',
      'name': 'Wodoo Aylık',
      'price': '₺829',
      'period': '/ay',
      'description': 'Tüm programlara sınırsız erişim',
      'features': [
        'Tüm antrenman programları',
        'Otomatik ağırlık hesaplama',
        'İlerleme takibi',
        'Premium destek',
        'Reklamsız deneyim'
      ],
      'isPopular': false,
    },
    {
      'id': 'semi_annual',
      'name': 'Wodoo 6 Aylık',
      'price': '₺4.199',
      'period': '/6 ay',
      'description': 'En iyi değer - %15 indirim!',
      'features': [
        'Tüm antrenman programları',
        'Otomatik ağırlık hesaplama',
        'İlerleme takibi',
        'Premium destek',
        'Reklamsız deneyim',
        'Özel içerikler',
        'Kişisel antrenör desteği'
      ],
      'isPopular': false,
    },
    {
      'id': 'yearly',
      'name': 'Wodoo Yıllık',
      'price': '₺7.999',
      'period': '/yıl',
      'description': 'En büyük tasarruf - %20 indirim!',
      'features': [
        'Tüm antrenman programları',
        'Otomatik ağırlık hesaplama',
        'İlerleme takibi',
        'Premium destek',
        'Reklamsız deneyim',
        'Özel içerikler',
        'Kişisel antrenör desteği',
        'Öncelikli müşteri hizmetleri'
      ],
      'isPopular': false,
    },
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
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _handleSubscriptionPurchase(String planId) async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Check if user document exists
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      if (userDoc.exists) {
        // Update existing user
        await _firestore.collection('users').doc(user.uid).update({
          'subscription.plan': planId,
          'subscription.isActive': true,
          'subscription.startDate': DateTime.now().toIso8601String(),
                 'subscription.endDate': planId == 'monthly'
                     ? DateTime.now().add(const Duration(days: 30)).toIso8601String()
                     : planId == 'semi_annual'
                         ? DateTime.now().add(const Duration(days: 180)).toIso8601String()
                         : DateTime.now().add(const Duration(days: 365)).toIso8601String(),
        });
      } else {
        // Create new user
        final newUser = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? '',
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
            mainLifts: const {},
          ),
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
        
        // Update subscription
        await _firestore.collection('users').doc(user.uid).update({
          'subscription.plan': planId,
          'subscription.isActive': true,
          'subscription.startDate': DateTime.now().toIso8601String(),
                 'subscription.endDate': planId == 'monthly'
                     ? DateTime.now().add(const Duration(days: 30)).toIso8601String()
                     : planId == 'semi_annual'
                         ? DateTime.now().add(const Duration(days: 180)).toIso8601String()
                         : DateTime.now().add(const Duration(days: 365)).toIso8601String(),
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Abonelik başarıyla aktifleştirildi!'),
              ],
            ),
            backgroundColor: const Color(0xFF38A169),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('Abonelik hatası: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Abonelik hatası: $e')),
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
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    // Header
                    _buildHeader(),
                    
                    const SizedBox(height: 32),
                    
                    // Plans
                    ..._plans.asMap().entries.map((entry) {
                      final index = entry.key;
                      final plan = entry.value;
                      return _buildPlanCard(plan, index);
                    }).toList(),
                    
                    const SizedBox(height: 32),
                    
                    // Footer
                    _buildFooter(),
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
            'Abonelik Planları',
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

  Widget _buildHeader() {
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
      child: Column(
        children: [
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
            child: const Icon(
              Icons.star,
              color: Colors.white,
              size: 40,
            ),
          ),
          
          const SizedBox(height: 20),
          
          const Text(
            'Premium\'a Geçin',
            style: TextStyle(
              color: Color(0xFF2D3748),
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Tüm CrossFit programlarına sınırsız erişim\nve özel özelliklerden yararlanın',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 400 + (100 * index)),
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
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Stack(
            children: [
              
              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Plan Name
                    Text(
                      plan['name'],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Description
                    Text(
                      plan['description'],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          plan['price'],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          plan['period'],
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Features
                    ...plan['features'].map<Widget>((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.white.withOpacity(0.9),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              feature,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                    
                    const SizedBox(height: 24),
                    
                    // Subscribe Button
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isLoading ? null : () => _handleSubscriptionPurchase(plan['id']),
                          borderRadius: BorderRadius.circular(16),
                          child: Center(
                            child: _isLoading
                                ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        const Color(0xFFB22B69),
                                      ),
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Abone Ol',
                                    style: TextStyle(
                                      color: const Color(0xFFB22B69),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
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
      child: Column(
        children: [
          Icon(
            Icons.security,
            color: Colors.grey[600],
            size: 32,
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Güvenli Ödeme',
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Tüm ödemeleriniz SSL ile korunur.\nİstediğiniz zaman iptal edebilirsiniz.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
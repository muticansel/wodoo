import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main_navigation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  bool _isSignUp = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
      begin: const Offset(0, 0.3),
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
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _setLoading(bool loading) {
    if (mounted) {
      setState(() {
        _isLoading = loading;
      });
    }
  }

  void _setError(String? error) {
    if (mounted) {
      setState(() {
        _errorMessage = error;
      });
    }
  }

  Future<void> _handleEmailAuth() async {
    _setLoading(true);
    _setError(null);

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _setError('Lütfen tüm alanları doldurun');
      _setLoading(false);
      return;
    }

    try {
      if (_isSignUp) {
        await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        
        if (_displayNameController.text.isNotEmpty) {
          await _auth.currentUser?.updateDisplayName(_displayNameController.text.trim());
        }
      } else {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainNavigation()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Bir hata oluştu';
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Kullanıcı bulunamadı';
          break;
        case 'wrong-password':
          errorMessage = 'Yanlış şifre';
          break;
        case 'email-already-in-use':
          errorMessage = 'Bu email zaten kullanımda';
          break;
        case 'weak-password':
          errorMessage = 'Şifre çok zayıf';
          break;
        case 'invalid-email':
          errorMessage = 'Geçersiz email adresi';
          break;
      }
      _setError(errorMessage);
    } catch (e) {
      _setError('Beklenmeyen bir hata oluştu');
    }

    _setLoading(false);
  }

  Future<void> _handleGuestSignIn() async {
    _setLoading(true);
    _setError(null);

    try {
      await _auth.signInAnonymously();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainNavigation()),
        );
      }
    } catch (e) {
      _setError('Misafir girişi başarısız');
      _setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFB22B69),
              Color(0xFF2889B8),
              Color(0xFF2D3748),
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo & Title
                      _buildHeader(),
                      
                      const SizedBox(height: 48),
                      
                      // Login Form
                      _buildLoginForm(),
                      
                      const SizedBox(height: 32),
                      
                      // Auth Buttons
                      _buildAuthButtons(),
                      
                      const SizedBox(height: 24),
                      
                      // Guest Sign In
                      _buildGuestButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Color(0xFFF7FAFC),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.fitness_center,
            size: 50,
            color: Color(0xFFB22B69),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Title
        const Text(
          'Wodoo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'CrossFit Antrenman Programları',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Toggle Sign In/Up
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isSignUp = false;
                        _errorMessage = null;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: _isSignUp ? Colors.transparent : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: _isSignUp ? null : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'Giriş Yap',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _isSignUp ? Colors.grey[600] : const Color(0xFF2D3748),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isSignUp = true;
                        _errorMessage = null;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: _isSignUp ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: _isSignUp ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ] : null,
                      ),
                      child: Text(
                        'Kayıt Ol',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _isSignUp ? const Color(0xFF2D3748) : Colors.grey[600],
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Display Name (Sign Up only)
          if (_isSignUp) ...[
            _buildInputField(
              controller: _displayNameController,
              label: 'Ad Soyad',
              icon: Icons.person_outline,
              isPassword: false,
            ),
            const SizedBox(height: 20),
          ],
          
          // Email
          _buildInputField(
            controller: _emailController,
            label: 'Email',
            icon: Icons.email_outlined,
            isPassword: false,
            keyboardType: TextInputType.emailAddress,
          ),
          
          const SizedBox(height: 20),
          
          // Password
          _buildInputField(
            controller: _passwordController,
            label: 'Şifre',
            icon: Icons.lock_outline,
            isPassword: true,
          ),
          
          const SizedBox(height: 24),
          
          // Error Message
          if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[600], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.red[800],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isPassword,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: isPassword ? _obscurePassword : false,
        style: const TextStyle(
          color: Color(0xFF2D3748),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            icon,
            color: const Color(0xFFB22B69),
            size: 20,
          ),
          suffixIcon: isPassword
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  child: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildAuthButtons() {
    return Column(
      children: [
        // Primary Auth Button
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFB22B69),
                Color(0xFF2889B8),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFB22B69).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isLoading ? null : _handleEmailAuth,
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
                    : Text(
                        _isSignUp ? 'Kayıt Ol' : 'Giriş Yap',
                        style: const TextStyle(
                          color: Colors.white,
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
    );
  }

  Widget _buildGuestButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _handleGuestSignIn,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_outline,
                  color: Colors.white.withOpacity(0.9),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Misafir Olarak Devam Et',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
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
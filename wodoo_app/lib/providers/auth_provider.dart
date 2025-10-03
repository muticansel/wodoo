import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    // Basit başlatma - hiçbir listener yok
    print('AuthProvider initialized - Simple version');
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();

    try {
      _user = await _authService.signInWithGoogle();
      _setLoading(false);
      return _user != null;
    } catch (e) {
      _setError('Google ile giriş yapılırken hata oluştu: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      _user = await _authService.signInWithEmailAndPassword(email, password);
      _setLoading(false);
      return _user != null;
    } catch (e) {
      _setError('E-posta ile giriş yapılırken hata oluştu: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> registerWithEmailAndPassword(String email, String password, String displayName) async {
    _setLoading(true);
    _clearError();

    try {
      _user = await _authService.registerWithEmailAndPassword(email, password, displayName);
      _setLoading(false);
      return _user != null;
    } catch (e) {
      _setError('Kayıt olurken hata oluştu: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signInAnonymously() async {
    _setLoading(true);
    _clearError();

    try {
      _user = await _authService.signInAnonymously();
      _setLoading(false);
      return _user != null;
    } catch (e) {
      _setError('Misafir girişi yapılırken hata oluştu: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.signOut();
      _user = null;
      _setLoading(false);
    } catch (e) {
      _setError('Çıkış yapılırken hata oluştu: $e');
      _setLoading(false);
    }
  }

  Future<bool> updateUserPreferences(UserPreferences preferences) async {
    if (_user == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final success = await _authService.updateUserPreferences(_user!.uid, preferences);
      if (success) {
        _user = _user!.copyWith(preferences: preferences);
        notifyListeners();
      }
      _setLoading(false);
      return success;
    } catch (e) {
      _setError('Kullanıcı tercihleri güncellenirken hata oluştu: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteAccount() async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _authService.deleteAccount();
      if (success) {
        _user = null;
      }
      _setLoading(false);
      return success;
    } catch (e) {
      _setError('Hesap silinirken hata oluştu: $e');
      _setLoading(false);
      return false;
    }
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


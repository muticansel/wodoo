import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current user
  User? get currentUser => _auth.currentUser;

  // Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      // TODO: Google Sign-In web client ID ayarlanacak
      // Şimdilik geçici olarak devre dışı
      print('Google Sign-In web client ID ayarlanması gerekiyor');
      return null;
    } catch (e) {
      print('Google Sign In Error: $e');
      return null;
    }
  }

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = userCredential.user;

      if (user != null) {
        return await _createOrUpdateUser(user);
      }
      return null;
    } catch (e) {
      print('Email Sign In Error: $e');
      return null;
    }
  }

  // Register with email and password
  Future<UserModel?> registerWithEmailAndPassword(String email, String password, String displayName) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = userCredential.user;

      if (user != null) {
        await user.updateDisplayName(displayName);
        return await _createOrUpdateUser(user);
      }
      return null;
    } catch (e) {
      print('Email Registration Error: $e');
      return null;
    }
  }

  // Sign in anonymously
  Future<UserModel?> signInAnonymously() async {
    try {
      final UserCredential userCredential = await _auth.signInAnonymously();
      final User? user = userCredential.user;

      if (user != null) {
        return await _createOrUpdateUser(user);
      }
      return null;
    } catch (e) {
      print('Anonymous Sign In Error: $e');
      return null;
    }
  }

  // Create or update user in Firestore
  Future<UserModel?> _createOrUpdateUser(User user) async {
    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      if (userDoc.exists) {
        // Update last login
        await _firestore.collection('users').doc(user.uid).update({
          'lastLoginAt': DateTime.now().millisecondsSinceEpoch,
        });
        
        return UserModel.fromMap(userDoc.data()!);
      } else {
        // Create new user
        final newUser = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? '',
          photoURL: user.photoURL,
          subscription: Subscription(
            plan: 'monthly',
            startDate: DateTime.now(),
            endDate: DateTime.now(),
            isActive: false,
          ),
          preferences: UserPreferences(
            language: 'tr',
            notifications: true,
            theme: 'light',
          ),
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
        return newUser;
      }
    } catch (e) {
      print('Create/Update User Error: $e');
      return null;
    }
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return UserModel.fromMap(userDoc.data()!);
      }
      return null;
    } catch (e) {
      print('Get User Data Error: $e');
      return null;
    }
  }

  // Update user preferences
  Future<bool> updateUserPreferences(String uid, UserPreferences preferences) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'preferences': preferences.toMap(),
      });
      return true;
    } catch (e) {
      print('Update User Preferences Error: $e');
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Sign Out Error: $e');
    }
  }

  // Delete account
  Future<bool> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Delete user data from Firestore
        await _firestore.collection('users').doc(user.uid).delete();
        
        // Delete user from Firebase Auth
        await user.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Delete Account Error: $e');
      return false;
    }
  }
}

// lib/core/providers/auth_provider.dart
import 'package:balanced_meal/core/models/user_data_model.dart';
import 'package:balanced_meal/core/providers/app_state_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user?.isLoggedIn ?? false;
  bool get hasUserData => _user?.hasUserData ?? false;
  bool get isProfileComplete => _user?.isProfileComplete ?? false;
  String? get error => _error;

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser != null) {
      await _loadUserData(firebaseUser);
    } else {
      _user = null;
      // Clear user data from app state when logged out
    }
    notifyListeners();
  }

  Future<void> _loadUserData(User firebaseUser) async {
    try {
      _user = UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email,
        displayName: firebaseUser.displayName,
        photoUrl: firebaseUser.photoURL,
        phoneNumber: firebaseUser.phoneNumber,
        emailVerified: firebaseUser.emailVerified,
      );

      // Try to load user health data from Firestore
      final userDataDoc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .collection('health_data')
          .doc('current')
          .get();

      if (userDataDoc.exists) {
        final userData = UserDataModel.fromFirestore(
          userDataDoc.data()!,
          firebaseUser.uid,
        );
        _user = _user!.copyWith(userData: userData);
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      _error = 'Failed to load user data';
    }
  }

  Future<void> saveUserData(
      UserDataModel userData, AppStateProvider appStateProvider) async {
    if (_user == null) throw Exception('User not logged in');

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Save to Firestore
      await _firestore
          .collection('users')
          .doc(_user!.uid)
          .collection('health_data')
          .doc('current')
          .set(userData.toFirestore());

      // Update local user model
      _user = _user!.copyWith(userData: userData);

      // Update app state
      appStateProvider.setUserData(userData);

      // Save to shared preferences for offline access
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', userData.toFirestore().toString());
    } catch (e) {
      debugPrint('Error saving user data: $e');
      _error = 'Failed to save user data';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInAnonymously() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _auth.signInAnonymously();
    } catch (e) {
      debugPrint('Error signing in anonymously: $e');
      _error = 'Failed to sign in';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _auth.signOut();

      // Clear shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      debugPrint('Error signing out: $e');
      _error = 'Failed to sign out';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

// Load user data from SharedPreferences when offline
  Future<void> loadUserDataFromPrefs(AppStateProvider appStateProvider) async {
    if (_user?.hasUserData == false) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final userDataString = prefs.getString('user_data');
        if (userDataString != null) {
          // Parse and set user data - you'll need to implement proper JSON parsing
          // This is a simplified version
        }
      } catch (e) {
        debugPrint('Error loading user data from preferences: $e');
      }
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Updated UserModel with UserData integration
class UserModel {
  final String? uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? phoneNumber;
  final bool emailVerified;
  final UserDataModel? userData; // Added user health data

  const UserModel({
    this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.phoneNumber,
    this.emailVerified = false,
    this.userData,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      displayName: map['displayName'],
      photoUrl: map['photoUrl'],
      phoneNumber: map['phoneNumber'],
      emailVerified: map['emailVerified'] ?? false,
      userData: map['userData'] != null
          ? UserDataModel.fromFirestore(map['userData'], map['uid'] ?? '')
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'emailVerified': emailVerified,
      'userData': userData?.toFirestore(),
    };
  }

  // Helper method to create a copy with updated userData
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    bool? emailVerified,
    UserDataModel? userData,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emailVerified: emailVerified ?? this.emailVerified,
      userData: userData ?? this.userData,
    );
  }

  bool get isLoggedIn => uid != null;
  bool get hasUserData => userData != null;
  bool get isProfileComplete => isLoggedIn && hasUserData;
}

// UserDataModel remains the same but with added helper methods
class UserDataModel {
  final String id;
  final String gender;
  final double weight;
  final double height;
  final double age;
  final double bmi;
  final String bmiCategory;
  final int bmr;
  final DateTime createdAt;

  const UserDataModel({
    required this.id,
    required this.gender,
    required this.weight,
    required this.height,
    required this.age,
    required this.bmi,
    required this.bmiCategory,
    required this.bmr,
    required this.createdAt,
  });

  factory UserDataModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserDataModel(
      id: id,
      gender: data['gender'] ?? '',
      weight: (data['weight'] ?? 0).toDouble(),
      height: (data['height'] ?? 0).toDouble(),
      age: (data['age'] ?? 0).toDouble(),
      bmi: (data['bmi'] ?? 0).toDouble(),
      bmiCategory: data['bmi_category'] ?? '',
      bmr: data['bmr'] ?? 0,
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'gender': gender,
      'weight': weight,
      'height': height,
      'age': age,
      'bmi': bmi,
      'bmi_category': bmiCategory,
      'bmr': bmr,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  // Helper methods for health calculations
  static double calculateBMI(double weight, double height) {
    if (height <= 0) return 0;
    return weight / ((height / 100) * (height / 100));
  }

  static String getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal weight';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  static int calculateBMR(
      double weight, double height, double age, String gender) {
    // Mifflin-St Jeor Equation
    double bmr = (10 * weight) + (6.25 * height) - (5 * age);
    return gender.toLowerCase() == 'male'
        ? (bmr + 5).round()
        : (bmr - 161).round();
  }

  // Factory constructor for creating UserDataModel with calculations
  factory UserDataModel.create({
    required String id,
    required String gender,
    required double weight,
    required double height,
    required double age,
  }) {
    final bmi = calculateBMI(weight, height);
    final bmiCategory = getBMICategory(bmi);
    final bmr = calculateBMR(weight, height, age, gender);

    return UserDataModel(
      id: id,
      gender: gender,
      weight: weight,
      height: height,
      age: age,
      bmi: bmi,
      bmiCategory: bmiCategory,
      bmr: bmr,
      createdAt: DateTime.now(),
    );
  }

  UserDataModel copyWith({
    String? id,
    String? gender,
    double? weight,
    double? height,
    double? age,
    double? bmi,
    String? bmiCategory,
    int? bmr,
    DateTime? createdAt,
  }) {
    return UserDataModel(
      id: id ?? this.id,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      age: age ?? this.age,
      bmi: bmi ?? this.bmi,
      bmiCategory: bmiCategory ?? this.bmiCategory,
      bmr: bmr ?? this.bmr,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// Updated AuthProvider with UserData integration
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
      // Load user data from Firestore
      await _loadUserData(firebaseUser);
    } else {
      _user = null;
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

  Future<void> saveUserData(UserDataModel userData) async {
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
}

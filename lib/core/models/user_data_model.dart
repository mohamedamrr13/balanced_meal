import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String? uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? phoneNumber;
  final bool emailVerified;
  final UserDataModel? userData;

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
      userData: map['userData'] != null && map['uid'] != null
          ? UserDataModel.fromFirestore(map['userData'], map['uid'])
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
    DateTime createdAt;
    final createdAtRaw = data['created_at'];
    if (createdAtRaw is Timestamp) {
      createdAt = createdAtRaw.toDate();
    } else if (createdAtRaw is DateTime) {
      createdAt = createdAtRaw;
    } else {
      createdAt = DateTime.now();
    }

    return UserDataModel(
      id: id,
      gender: data['gender'] ?? '',
      weight: (data['weight'] ?? 0).toDouble(),
      height: (data['height'] ?? 0).toDouble(),
      age: (data['age'] ?? 0).toDouble(),
      bmi: (data['bmi'] ?? 0).toDouble(),
      bmiCategory: data['bmi_category'] ?? '',
      bmr: data['bmr'] ?? 0,
      createdAt: createdAt,
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
    double bmr = (10 * weight) + (6.25 * height) - (5 * age);
    return gender.toLowerCase() == 'male'
        ? (bmr + 5).round()
        : (bmr - 161).round();
  }

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

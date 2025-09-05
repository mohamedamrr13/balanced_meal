import 'package:cloud_firestore/cloud_firestore.dart';

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
}

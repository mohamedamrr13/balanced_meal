import 'package:balanced_meal/core/models/food_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SavedMealItemModel {
  final String id;
  final String foodName;
  final String imageUrl;
  final int calories;
  final int price;
  final String category;
  final int quantity;

  const SavedMealItemModel({
    required this.id,
    required this.foodName,
    required this.imageUrl,
    required this.calories,
    required this.price,
    required this.category,
    required this.quantity,
  });

  factory SavedMealItemModel.fromMap(Map<String, dynamic> data) {
    return SavedMealItemModel(
      id: data['id'] ?? '',
      foodName: data['food_name'] ?? '',
      imageUrl: data['image_url'] ?? '',
      calories: data['calories'] ?? 0,
      price: data['price'] ?? 0,
      category: data['category'] ?? '',
      quantity: data['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'food_name': foodName,
      'image_url': imageUrl,
      'calories': calories,
      'price': price,
      'category': category,
      'quantity': quantity,
    };
  }

  int get totalCalories => calories * quantity;
  int get totalPrice => price * quantity;
}

class SavedMealModel {
  final String id;
  final String mealName;
  final List<SavedMealItemModel> items;
  final int totalCalories;
  final int totalPrice;
  final DateTime savedAt;
  final String userId;

  const SavedMealModel({
    required this.id,
    required this.mealName,
    required this.items,
    required this.totalCalories,
    required this.totalPrice,
    required this.savedAt,
    required this.userId,
  });

  factory SavedMealModel.fromFirestore(Map<String, dynamic> data, String id) {
    final itemsData = data['items'] as List<dynamic>? ?? [];
    final items = itemsData
        .map((item) => SavedMealItemModel.fromMap(item as Map<String, dynamic>))
        .toList();

    return SavedMealModel(
      id: id,
      mealName: data['meal_name'] ?? '',
      items: items,
      totalCalories: data['total_calories'] ?? 0,
      totalPrice: data['total_price'] ?? 0,
      savedAt: (data['saved_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userId: data['user_id'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'meal_name': mealName,
      'items': items.map((item) => item.toMap()).toList(),
      'total_calories': totalCalories,
      'total_price': totalPrice,
      'saved_at': Timestamp.fromDate(savedAt),
      'user_id': userId,
    };
  }
}

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Food Items
  Stream<List<FoodItemModel>> getVegetables() {
    return _firestore.collection('vegetables').snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => FoodItemModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Stream<List<FoodItemModel>> getMeat() {
    return _firestore.collection('meat').snapshots().map((snapshot) => snapshot
        .docs
        .map((doc) => FoodItemModel.fromFirestore(doc.data(), doc.id))
        .toList());
  }

  Stream<List<FoodItemModel>> getCarbs() {
    return _firestore.collection('carbs').snapshots().map((snapshot) => snapshot
        .docs
        .map((doc) => FoodItemModel.fromFirestore(doc.data(), doc.id))
        .toList());
  }

  // Saved Meals Operations
  Future<void> saveMeal(SavedMealModel meal) async {
    try {
      await _firestore.collection('saved_meals').add(meal.toFirestore());
    } catch (e) {
      debugPrint('Error saving meal: $e');
      rethrow;
    }
  }

  Stream<List<SavedMealModel>> getSavedMeals(String userId) {
    return _firestore
        .collection('saved_meals')
        .where('user_id', isEqualTo: userId)
        .orderBy('saved_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SavedMealModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Future<void> deleteSavedMeal(String mealId) async {
    try {
      await _firestore.collection('saved_meals').doc(mealId).delete();
    } catch (e) {
      debugPrint('Error deleting saved meal: $e');
      rethrow;
    }
  }

  Future<void> updateSavedMeal(String mealId, SavedMealModel meal) async {
    try {
      await _firestore
          .collection('saved_meals')
          .doc(mealId)
          .update(meal.toFirestore());
    } catch (e) {
      debugPrint('Error updating saved meal: $e');
      rethrow;
    }
  }

  // User Data Operations
  Future<void> saveUserData(
      String userId, Map<String, dynamic> userData) async {
    try {
      await _firestore.collection('user_data').doc(userId).set(userData);
    } catch (e) {
      debugPrint('Error saving user data: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('user_data').doc(userId).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      debugPrint('Error getting user data: $e');
      return null;
    }
  }

  // Analytics and Stats
  Future<Map<String, dynamic>> getMealStats(String userId) async {
    try {
      final mealsSnapshot = await _firestore
          .collection('saved_meals')
          .where('user_id', isEqualTo: userId)
          .get();

      if (mealsSnapshot.docs.isEmpty) {
        return {
          'total_meals': 0,
          'avg_calories': 0,
          'avg_price': 0,
          'most_used_category': '',
        };
      }

      final meals = mealsSnapshot.docs
          .map((doc) => SavedMealModel.fromFirestore(doc.data(), doc.id))
          .toList();

      final totalMeals = meals.length;
      final totalCalories =
          meals.fold(0, (sum, meal) => sum + meal.totalCalories);
      final totalPrice = meals.fold(0, (sum, meal) => sum + meal.totalPrice);
      final avgCalories = totalCalories ~/ totalMeals;
      final avgPrice = totalPrice ~/ totalMeals;

      // Calculate most used category
      final categoryCount = <String, int>{};
      for (final meal in meals) {
        for (final item in meal.items) {
          categoryCount[item.category] =
              (categoryCount[item.category] ?? 0) + 1;
        }
      }

      final mostUsedCategory = categoryCount.isNotEmpty
          ? categoryCount.entries
              .reduce((a, b) => a.value > b.value ? a : b)
              .key
          : '';

      return {
        'total_meals': totalMeals,
        'avg_calories': avgCalories,
        'avg_price': avgPrice,
        'most_used_category': mostUsedCategory,
      };
    } catch (e) {
      debugPrint('Error getting meal stats: $e');
      return {
        'total_meals': 0,
        'avg_calories': 0,
        'avg_price': 0,
        'most_used_category': '',
      };
    }
  }

  // Clear all user data (for reset functionality)
  Future<void> clearAllUserData(String userId) async {
    final batch = _firestore.batch();

    try {
      // Delete saved meals
      final mealsSnapshot = await _firestore
          .collection('saved_meals')
          .where('user_id', isEqualTo: userId)
          .get();

      for (final doc in mealsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete user data
      final userDataRef = _firestore.collection('user_data').doc(userId);
      batch.delete(userDataRef);

      await batch.commit();
    } catch (e) {
      debugPrint('Error clearing user data: $e');
      rethrow;
    }
  }
}

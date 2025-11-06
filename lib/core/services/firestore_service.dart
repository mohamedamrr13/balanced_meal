import 'package:balanced_meal/core/models/food_model.dart';
import 'package:balanced_meal/core/models/saved_meal_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Service class for all Firestore database operations.
///
/// This class provides methods for:
/// - Fetching food items by category
/// - Managing saved meals (CRUD operations)
/// - Toggling meal favorites
/// - User data management
/// - Analytics and statistics
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

  /// Toggles the favorite status of a saved meal.
  ///
  /// This method updates the `is_favorite` field in Firestore.
  Future<void> toggleMealFavorite(String mealId, bool isFavorite) async {
    try {
      await _firestore
          .collection('saved_meals')
          .doc(mealId)
          .update({'is_favorite': isFavorite});
    } catch (e) {
      debugPrint('Error toggling meal favorite: $e');
      rethrow;
    }
  }

  /// Gets only the favorite meals for a user.
  ///
  /// Returns a stream of meals where `is_favorite` is true.
  Stream<List<SavedMealModel>> getFavoriteMeals(String userId) {
    return _firestore
        .collection('saved_meals')
        .where('user_id', isEqualTo: userId)
        .where('is_favorite', isEqualTo: true)
        .orderBy('saved_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SavedMealModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// Gets saved meals with pagination support.
  ///
  /// [userId] - The user ID to filter by
  /// [limit] - Maximum number of meals to fetch
  /// [lastDocument] - Last document from previous query (for pagination)
  Future<({QueryDocumentSnapshot<Object?>? lastDoc, List meals})>
      getSavedMealsPaginated({
    required String userId,
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _firestore
          .collection('saved_meals')
          .where('user_id', isEqualTo: userId)
          .orderBy('saved_at', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();
      final meals = snapshot.docs
          .map((doc) => SavedMealModel.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      final lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;

      return (meals: meals, lastDoc: lastDoc);
    } catch (e) {
      debugPrint('Error getting paginated meals: $e');
      return (meals: [], lastDoc: null);
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

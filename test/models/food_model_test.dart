import 'package:flutter_test/flutter_test.dart';
import 'package:balanced_meal/core/models/food_model.dart';

/// Unit tests for FoodItemModel
///
/// Tests cover:
/// - Model creation
/// - Firestore serialization/deserialization
/// - Getter methods
/// - copyWith functionality
void main() {
  group('FoodItemModel', () {
    test('should create a FoodItemModel with all required fields', () {
      // Arrange & Act
      const foodItem = FoodItemModel(
        id: 'test_id',
        foodName: 'Chicken Breast',
        imageUrl: 'https://example.com/chicken.jpg',
        calories: 165,
        price: 500,
        category: 'meat',
        protein: 31.0,
        carbs: 0.0,
        fat: 3.6,
      );

      // Assert
      expect(foodItem.id, 'test_id');
      expect(foodItem.foodName, 'Chicken Breast');
      expect(foodItem.imageUrl, 'https://example.com/chicken.jpg');
      expect(foodItem.calories, 165);
      expect(foodItem.price, 500);
      expect(foodItem.category, 'meat');
      expect(foodItem.protein, 31.0);
      expect(foodItem.carbs, 0.0);
      expect(foodItem.fat, 3.6);
    });

    test('should create FoodItemModel with default macro values', () {
      // Arrange & Act
      const foodItem = FoodItemModel(
        id: 'test_id',
        foodName: 'Apple',
        imageUrl: 'https://example.com/apple.jpg',
        calories: 95,
        price: 50,
        category: 'vegetables',
      );

      // Assert
      expect(foodItem.protein, 0.0);
      expect(foodItem.carbs, 0.0);
      expect(foodItem.fat, 0.0);
      expect(foodItem.description, null);
    });

    test('should convert to Firestore map correctly', () {
      // Arrange
      const foodItem = FoodItemModel(
        id: 'test_id',
        foodName: 'Chicken Breast',
        imageUrl: 'https://example.com/chicken.jpg',
        calories: 165,
        price: 500,
        category: 'meat',
        protein: 31.0,
        carbs: 0.0,
        fat: 3.6,
        description: 'Lean protein source',
      );

      // Act
      final firestoreData = foodItem.toFirestore();

      // Assert
      expect(firestoreData['food_name'], 'Chicken Breast');
      expect(firestoreData['image_url'], 'https://example.com/chicken.jpg');
      expect(firestoreData['calories'], 165);
      expect(firestoreData['price'], 500);
      expect(firestoreData['category'], 'meat');
      expect(firestoreData['protein'], 31.0);
      expect(firestoreData['carbs'], 0.0);
      expect(firestoreData['fat'], 3.6);
      expect(firestoreData['description'], 'Lean protein source');
    });

    test('should create FoodItemModel from Firestore map', () {
      // Arrange
      final firestoreData = {
        'food_name': 'Chicken Breast',
        'image_url': 'https://example.com/chicken.jpg',
        'calories': 165,
        'price': 500,
        'category': 'meat',
        'protein': 31.0,
        'carbs': 0.0,
        'fat': 3.6,
        'description': 'Lean protein source',
      };

      // Act
      final foodItem = FoodItemModel.fromFirestore(firestoreData, 'test_id');

      // Assert
      expect(foodItem.id, 'test_id');
      expect(foodItem.foodName, 'Chicken Breast');
      expect(foodItem.imageUrl, 'https://example.com/chicken.jpg');
      expect(foodItem.calories, 165);
      expect(foodItem.price, 500);
      expect(foodItem.category, 'meat');
      expect(foodItem.protein, 31.0);
      expect(foodItem.carbs, 0.0);
      expect(foodItem.fat, 3.6);
      expect(foodItem.description, 'Lean protein source');
    });

    test('should handle missing fields in Firestore data with defaults', () {
      // Arrange
      final firestoreData = <String, dynamic>{};

      // Act
      final foodItem = FoodItemModel.fromFirestore(firestoreData, 'test_id');

      // Assert
      expect(foodItem.id, 'test_id');
      expect(foodItem.foodName, '');
      expect(foodItem.imageUrl, '');
      expect(foodItem.calories, 0);
      expect(foodItem.price, 0);
      expect(foodItem.category, '');
      expect(foodItem.protein, 0.0);
      expect(foodItem.carbs, 0.0);
      expect(foodItem.fat, 0.0);
      expect(foodItem.description, null);
    });

    test('should calculate total macros correctly', () {
      // Arrange
      const foodItem = FoodItemModel(
        id: 'test_id',
        foodName: 'Mixed Meal',
        imageUrl: 'https://example.com/meal.jpg',
        calories: 400,
        price: 800,
        category: 'mixed',
        protein: 30.0,
        carbs: 40.0,
        fat: 10.0,
      );

      // Act
      final totalMacros = foodItem.totalMacros;

      // Assert
      expect(totalMacros, 80.0); // 30 + 40 + 10
    });

    test('should correctly identify if food has complete nutrition data', () {
      // Arrange
      const foodWithNutrition = FoodItemModel(
        id: 'test_id',
        foodName: 'Chicken',
        imageUrl: 'url',
        calories: 165,
        price: 500,
        category: 'meat',
        protein: 31.0,
      );

      const foodWithoutNutrition = FoodItemModel(
        id: 'test_id',
        foodName: 'Unknown',
        imageUrl: 'url',
        calories: 100,
        price: 200,
        category: 'misc',
      );

      // Assert
      expect(foodWithNutrition.hasCompleteNutrition, true);
      expect(foodWithoutNutrition.hasCompleteNutrition, false);
    });

    test('should create a copy with updated fields using copyWith', () {
      // Arrange
      const original = FoodItemModel(
        id: 'test_id',
        foodName: 'Chicken',
        imageUrl: 'url',
        calories: 165,
        price: 500,
        category: 'meat',
        protein: 31.0,
      );

      // Act
      final updated = original.copyWith(
        calories: 200,
        protein: 35.0,
      );

      // Assert
      expect(updated.id, 'test_id'); // unchanged
      expect(updated.foodName, 'Chicken'); // unchanged
      expect(updated.calories, 200); // changed
      expect(updated.protein, 35.0); // changed
      expect(updated.carbs, 0.0); // unchanged
    });

    test('should correctly convert integer nutrition values to double', () {
      // Arrange
      final firestoreData = {
        'food_name': 'Rice',
        'image_url': 'url',
        'calories': 130,
        'price': 100,
        'category': 'carbs',
        'protein': 3, // integer
        'carbs': 28, // integer
        'fat': 0, // integer
      };

      // Act
      final foodItem = FoodItemModel.fromFirestore(firestoreData, 'test_id');

      // Assert
      expect(foodItem.protein, isA<double>());
      expect(foodItem.protein, 3.0);
      expect(foodItem.carbs, isA<double>());
      expect(foodItem.carbs, 28.0);
      expect(foodItem.fat, isA<double>());
      expect(foodItem.fat, 0.0);
    });

    test('should not include description in Firestore map if null', () {
      // Arrange
      const foodItem = FoodItemModel(
        id: 'test_id',
        foodName: 'Apple',
        imageUrl: 'url',
        calories: 95,
        price: 50,
        category: 'vegetables',
      );

      // Act
      final firestoreData = foodItem.toFirestore();

      // Assert
      expect(firestoreData.containsKey('description'), false);
    });

    test('should include description in Firestore map if provided', () {
      // Arrange
      const foodItem = FoodItemModel(
        id: 'test_id',
        foodName: 'Apple',
        imageUrl: 'url',
        calories: 95,
        price: 50,
        category: 'vegetables',
        description: 'Fresh fruit',
      );

      // Act
      final firestoreData = foodItem.toFirestore();

      // Assert
      expect(firestoreData.containsKey('description'), true);
      expect(firestoreData['description'], 'Fresh fruit');
    });
  });
}

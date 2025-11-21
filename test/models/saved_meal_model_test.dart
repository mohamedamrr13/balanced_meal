import 'package:flutter_test/flutter_test.dart';
import 'package:balanced_meal/core/models/saved_meal_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Unit tests for SavedMealModel and SavedMealItemModel
///
/// Tests cover:
/// - Model creation
/// - Calculated properties (totals, macros)
/// - Firestore serialization/deserialization
/// - Date formatting
/// - copyWith functionality
void main() {
  group('SavedMealItemModel', () {
    test('should create SavedMealItemModel with all fields', () {
      // Arrange & Act
      const item = SavedMealItemModel(
        id: 'item_1',
        foodName: 'Chicken Breast',
        imageUrl: 'url',
        calories: 165,
        price: 500,
        category: 'meat',
        quantity: 2,
        protein: 31.0,
        carbs: 0.0,
        fat: 3.6,
      );

      // Assert
      expect(item.id, 'item_1');
      expect(item.foodName, 'Chicken Breast');
      expect(item.quantity, 2);
      expect(item.protein, 31.0);
    });

    test('should calculate total calories correctly', () {
      // Arrange
      const item = SavedMealItemModel(
        id: 'item_1',
        foodName: 'Chicken',
        imageUrl: 'url',
        calories: 165,
        price: 500,
        category: 'meat',
        quantity: 3,
      );

      // Act & Assert
      expect(item.totalCalories, 495); // 165 * 3
    });

    test('should calculate total price correctly', () {
      // Arrange
      const item = SavedMealItemModel(
        id: 'item_1',
        foodName: 'Chicken',
        imageUrl: 'url',
        calories: 165,
        price: 500,
        category: 'meat',
        quantity: 2,
      );

      // Act & Assert
      expect(item.totalPrice, 1000); // 500 * 2
    });

    test('should calculate total protein correctly', () {
      // Arrange
      const item = SavedMealItemModel(
        id: 'item_1',
        foodName: 'Chicken',
        imageUrl: 'url',
        calories: 165,
        price: 500,
        category: 'meat',
        quantity: 2,
        protein: 31.0,
      );

      // Act & Assert
      expect(item.totalProtein, 62.0); // 31 * 2
    });

    test('should calculate total carbs correctly', () {
      // Arrange
      const item = SavedMealItemModel(
        id: 'item_1',
        foodName: 'Rice',
        imageUrl: 'url',
        calories: 130,
        price: 100,
        category: 'carbs',
        quantity: 3,
        carbs: 28.0,
      );

      // Act & Assert
      expect(item.totalCarbs, 84.0); // 28 * 3
    });

    test('should calculate total fat correctly', () {
      // Arrange
      const item = SavedMealItemModel(
        id: 'item_1',
        foodName: 'Avocado',
        imageUrl: 'url',
        calories: 234,
        price: 300,
        category: 'vegetables',
        quantity: 2,
        fat: 21.0,
      );

      // Act & Assert
      expect(item.totalFat, 42.0); // 21 * 2
    });

    test('should convert to map correctly', () {
      // Arrange
      const item = SavedMealItemModel(
        id: 'item_1',
        foodName: 'Chicken',
        imageUrl: 'url',
        calories: 165,
        price: 500,
        category: 'meat',
        quantity: 2,
        protein: 31.0,
        carbs: 0.0,
        fat: 3.6,
      );

      // Act
      final map = item.toMap();

      // Assert
      expect(map['id'], 'item_1');
      expect(map['food_name'], 'Chicken');
      expect(map['quantity'], 2);
      expect(map['protein'], 31.0);
      expect(map['carbs'], 0.0);
      expect(map['fat'], 3.6);
    });

    test('should create from map correctly', () {
      // Arrange
      final map = {
        'id': 'item_1',
        'food_name': 'Chicken',
        'image_url': 'url',
        'calories': 165,
        'price': 500,
        'category': 'meat',
        'quantity': 2,
        'protein': 31.0,
        'carbs': 0.0,
        'fat': 3.6,
      };

      // Act
      final item = SavedMealItemModel.fromMap(map);

      // Assert
      expect(item.id, 'item_1');
      expect(item.foodName, 'Chicken');
      expect(item.quantity, 2);
      expect(item.protein, 31.0);
    });
  });

  group('SavedMealModel', () {
    final mockItems = [
      const SavedMealItemModel(
        id: 'item_1',
        foodName: 'Chicken',
        imageUrl: 'url',
        calories: 165,
        price: 500,
        category: 'meat',
        quantity: 2,
        protein: 31.0,
        carbs: 0.0,
        fat: 3.6,
      ),
      const SavedMealItemModel(
        id: 'item_2',
        foodName: 'Rice',
        imageUrl: 'url',
        calories: 130,
        price: 100,
        category: 'carbs',
        quantity: 1,
        protein: 3.0,
        carbs: 28.0,
        fat: 0.3,
      ),
    ];

    test('should create SavedMealModel with all fields', () {
      // Arrange
      final savedAt = DateTime(2024, 1, 15);

      // Act
      final meal = SavedMealModel(
        id: 'meal_1',
        mealName: 'Lunch',
        items: mockItems,
        totalCalories: 460,
        totalPrice: 1100,
        savedAt: savedAt,
        userId: 'user_123',
        isFavorite: true,
      );

      // Assert
      expect(meal.id, 'meal_1');
      expect(meal.mealName, 'Lunch');
      expect(meal.items.length, 2);
      expect(meal.totalCalories, 460);
      expect(meal.isFavorite, true);
    });

    test('should have default isFavorite as false', () {
      // Arrange & Act
      final meal = SavedMealModel(
        id: 'meal_1',
        mealName: 'Lunch',
        items: mockItems,
        totalCalories: 460,
        totalPrice: 1100,
        savedAt: DateTime.now(),
        userId: 'user_123',
      );

      // Assert
      expect(meal.isFavorite, false);
    });

    test('should calculate total protein across all items', () {
      // Arrange
      final meal = SavedMealModel(
        id: 'meal_1',
        mealName: 'Lunch',
        items: mockItems,
        totalCalories: 460,
        totalPrice: 1100,
        savedAt: DateTime.now(),
        userId: 'user_123',
      );

      // Act
      final totalProtein = meal.totalProtein;

      // Assert
      // (31 * 2) + (3 * 1) = 62 + 3 = 65
      expect(totalProtein, 65.0);
    });

    test('should calculate total carbs across all items', () {
      // Arrange
      final meal = SavedMealModel(
        id: 'meal_1',
        mealName: 'Lunch',
        items: mockItems,
        totalCalories: 460,
        totalPrice: 1100,
        savedAt: DateTime.now(),
        userId: 'user_123',
      );

      // Act
      final totalCarbs = meal.totalCarbs;

      // Assert
      // (0 * 2) + (28 * 1) = 0 + 28 = 28
      expect(totalCarbs, 28.0);
    });

    test('should calculate total fat across all items', () {
      // Arrange
      final meal = SavedMealModel(
        id: 'meal_1',
        mealName: 'Lunch',
        items: mockItems,
        totalCalories: 460,
        totalPrice: 1100,
        savedAt: DateTime.now(),
        userId: 'user_123',
      );

      // Act
      final totalFat = meal.totalFat;

      // Assert
      // (3.6 * 2) + (0.3 * 1) = 7.2 + 0.3 = 7.5
      expect(totalFat, 7.5);
    });

    test('should return correct item count', () {
      // Arrange
      final meal = SavedMealModel(
        id: 'meal_1',
        mealName: 'Lunch',
        items: mockItems,
        totalCalories: 460,
        totalPrice: 1100,
        savedAt: DateTime.now(),
        userId: 'user_123',
      );

      // Assert
      expect(meal.itemCount, 2);
    });

    test('should format date as "Today" for today', () {
      // Arrange
      final meal = SavedMealModel(
        id: 'meal_1',
        mealName: 'Lunch',
        items: mockItems,
        totalCalories: 460,
        totalPrice: 1100,
        savedAt: DateTime.now(),
        userId: 'user_123',
      );

      // Assert
      expect(meal.formattedDate, 'Today');
    });

    test('should format date as "Yesterday" for yesterday', () {
      // Arrange
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final meal = SavedMealModel(
        id: 'meal_1',
        mealName: 'Lunch',
        items: mockItems,
        totalCalories: 460,
        totalPrice: 1100,
        savedAt: yesterday,
        userId: 'user_123',
      );

      // Assert
      expect(meal.formattedDate, 'Yesterday');
    });

    test('should format date as "X days ago" for recent dates', () {
      // Arrange
      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      final meal = SavedMealModel(
        id: 'meal_1',
        mealName: 'Lunch',
        items: mockItems,
        totalCalories: 460,
        totalPrice: 1100,
        savedAt: threeDaysAgo,
        userId: 'user_123',
      );

      // Assert
      expect(meal.formattedDate, '3 days ago');
    });

    test('should format date as DD/MM/YYYY for older dates', () {
      // Arrange
      final oldDate = DateTime(2024, 1, 15);
      final meal = SavedMealModel(
        id: 'meal_1',
        mealName: 'Lunch',
        items: mockItems,
        totalCalories: 460,
        totalPrice: 1100,
        savedAt: oldDate,
        userId: 'user_123',
      );

      // Assert
      expect(meal.formattedDate, '15/1/2024');
    });

    test('should create copy with updated fields using copyWith', () {
      // Arrange
      final original = SavedMealModel(
        id: 'meal_1',
        mealName: 'Lunch',
        items: mockItems,
        totalCalories: 460,
        totalPrice: 1100,
        savedAt: DateTime.now(),
        userId: 'user_123',
        isFavorite: false,
      );

      // Act
      final updated = original.copyWith(
        mealName: 'Dinner',
        isFavorite: true,
      );

      // Assert
      expect(updated.id, 'meal_1'); // unchanged
      expect(updated.mealName, 'Dinner'); // changed
      expect(updated.isFavorite, true); // changed
      expect(updated.totalCalories, 460); // unchanged
    });

    test('should convert to Firestore map correctly', () {
      // Arrange
      final savedAt = DateTime(2024, 1, 15, 12, 30);
      final meal = SavedMealModel(
        id: 'meal_1',
        mealName: 'Lunch',
        items: mockItems,
        totalCalories: 460,
        totalPrice: 1100,
        savedAt: savedAt,
        userId: 'user_123',
        isFavorite: true,
      );

      // Act
      final firestoreData = meal.toFirestore();

      // Assert
      expect(firestoreData['meal_name'], 'Lunch');
      expect(firestoreData['total_calories'], 460);
      expect(firestoreData['total_price'], 1100);
      expect(firestoreData['user_id'], 'user_123');
      expect(firestoreData['is_favorite'], true);
      expect(firestoreData['items'], isA<List>());
      expect((firestoreData['items'] as List).length, 2);
      expect(firestoreData['saved_at'], isA<Timestamp>());
    });

    test('should create from Firestore map correctly', () {
      // Arrange
      final firestoreData = {
        'meal_name': 'Lunch',
        'total_calories': 460,
        'total_price': 1100,
        'user_id': 'user_123',
        'is_favorite': true,
        'saved_at': Timestamp.fromDate(DateTime(2024, 1, 15)),
        'items': [
          {
            'id': 'item_1',
            'food_name': 'Chicken',
            'image_url': 'url',
            'calories': 165,
            'price': 500,
            'category': 'meat',
            'quantity': 2,
            'protein': 31.0,
            'carbs': 0.0,
            'fat': 3.6,
          },
        ],
      };

      // Act
      final meal = SavedMealModel.fromFirestore(firestoreData, 'meal_1');

      // Assert
      expect(meal.id, 'meal_1');
      expect(meal.mealName, 'Lunch');
      expect(meal.totalCalories, 460);
      expect(meal.isFavorite, true);
      expect(meal.items.length, 1);
      expect(meal.items.first.foodName, 'Chicken');
    });

    test('should handle empty items list', () {
      // Arrange
      final meal = SavedMealModel(
        id: 'meal_1',
        mealName: 'Empty Meal',
        items: const [],
        totalCalories: 0,
        totalPrice: 0,
        savedAt: DateTime.now(),
        userId: 'user_123',
      );

      // Assert
      expect(meal.itemCount, 0);
      expect(meal.totalProtein, 0.0);
      expect(meal.totalCarbs, 0.0);
      expect(meal.totalFat, 0.0);
    });
  });
}

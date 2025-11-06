// lib/core/models/saved_meal_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single food item within a saved meal, including quantity.
///
/// This model extends the basic food item with quantity tracking and
/// calculated totals for calories and price.
class SavedMealItemModel {
  /// Unique identifier for the food item
  final String id;

  /// Display name of the food item
  final String foodName;

  /// URL to the food item's image
  final String imageUrl;

  /// Calories per single serving
  final int calories;

  /// Price per single serving
  final int price;

  /// Category classification (e.g., 'vegetables', 'meat', 'carbs')
  final String category;

  /// Number of servings in this meal
  final int quantity;

  /// Protein content in grams per serving
  final double protein;

  /// Carbohydrate content in grams per serving
  final double carbs;

  /// Fat content in grams per serving
  final double fat;

  const SavedMealItemModel({
    required this.id,
    required this.foodName,
    required this.imageUrl,
    required this.calories,
    required this.price,
    required this.category,
    required this.quantity,
    this.protein = 0.0,
    this.carbs = 0.0,
    this.fat = 0.0,
  });

  /// Creates a SavedMealItemModel from a map
  factory SavedMealItemModel.fromMap(Map<String, dynamic> data) {
    return SavedMealItemModel(
      id: data['id'] ?? '',
      foodName: data['food_name'] ?? '',
      imageUrl: data['image_url'] ?? '',
      calories: data['calories'] ?? 0,
      price: data['price'] ?? 0,
      category: data['category'] ?? '',
      quantity: data['quantity'] ?? 1,
      protein: (data['protein'] ?? 0).toDouble(),
      carbs: (data['carbs'] ?? 0).toDouble(),
      fat: (data['fat'] ?? 0).toDouble(),
    );
  }

  /// Converts the SavedMealItemModel to a map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'food_name': foodName,
      'image_url': imageUrl,
      'calories': calories,
      'price': price,
      'category': category,
      'quantity': quantity,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }

  /// Calculates total calories for this item (calories × quantity)
  int get totalCalories => calories * quantity;

  /// Calculates total price for this item (price × quantity)
  int get totalPrice => price * quantity;

  /// Calculates total protein for this item (protein × quantity)
  double get totalProtein => protein * quantity;

  /// Calculates total carbs for this item (carbs × quantity)
  double get totalCarbs => carbs * quantity;

  /// Calculates total fat for this item (fat × quantity)
  double get totalFat => fat * quantity;
}

/// Represents a complete saved meal with all items and metadata.
///
/// This model contains the full meal information including all food items,
/// totals for calories/price/macros, and user preferences like favorites.
class SavedMealModel {
  /// Unique identifier for the saved meal
  final String id;

  /// User-provided name for the meal
  final String mealName;

  /// List of all food items in this meal
  final List<SavedMealItemModel> items;

  /// Total calories for the entire meal
  final int totalCalories;

  /// Total price for the entire meal
  final int totalPrice;

  /// Timestamp when the meal was saved
  final DateTime savedAt;

  /// User ID who created this meal
  final String userId;

  /// Whether this meal is marked as a favorite
  final bool isFavorite;

  const SavedMealModel({
    required this.id,
    required this.mealName,
    required this.items,
    required this.totalCalories,
    required this.totalPrice,
    required this.savedAt,
    required this.userId,
    this.isFavorite = false,
  });

  /// Creates a SavedMealModel from Firestore document data
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
      isFavorite: data['is_favorite'] ?? false,
    );
  }

  /// Converts the SavedMealModel to a Firestore-compatible map
  Map<String, dynamic> toFirestore() {
    return {
      'meal_name': mealName,
      'items': items.map((item) => item.toMap()).toList(),
      'total_calories': totalCalories,
      'total_price': totalPrice,
      'saved_at': Timestamp.fromDate(savedAt),
      'user_id': userId,
      'is_favorite': isFavorite,
    };
  }

  /// Calculates total protein across all items in the meal
  double get totalProtein {
    return items.fold(0.0, (sum, item) => sum + item.totalProtein);
  }

  /// Calculates total carbohydrates across all items in the meal
  double get totalCarbs {
    return items.fold(0.0, (sum, item) => sum + item.totalCarbs);
  }

  /// Calculates total fat across all items in the meal
  double get totalFat {
    return items.fold(0.0, (sum, item) => sum + item.totalFat);
  }

  /// Returns the number of items in this meal
  int get itemCount => items.length;

  /// Returns a formatted date string for display
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(savedAt);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${savedAt.day}/${savedAt.month}/${savedAt.year}';
    }
  }

  /// Creates a copy of this SavedMealModel with optionally updated fields
  SavedMealModel copyWith({
    String? id,
    String? mealName,
    List<SavedMealItemModel>? items,
    int? totalCalories,
    int? totalPrice,
    DateTime? savedAt,
    String? userId,
    bool? isFavorite,
  }) {
    return SavedMealModel(
      id: id ?? this.id,
      mealName: mealName ?? this.mealName,
      items: items ?? this.items,
      totalCalories: totalCalories ?? this.totalCalories,
      totalPrice: totalPrice ?? this.totalPrice,
      savedAt: savedAt ?? this.savedAt,
      userId: userId ?? this.userId,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

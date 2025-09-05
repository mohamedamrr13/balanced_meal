// lib/core/models/saved_meal_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

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

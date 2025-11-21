import 'package:cloud_firestore/cloud_firestore.dart';

class SavedMealItemModel {
  final String id;
  final String foodName;
  final String imageUrl;
  final int calories;
  final int price;
  final String category;
  final int quantity;
  final double protein;
  final double carbs;
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

  int get totalCalories => calories * quantity;
  int get totalPrice => price * quantity;
  double get totalProtein => protein * quantity;
  double get totalCarbs => carbs * quantity;
  double get totalFat => fat * quantity;
}

class SavedMealModel {
  final String id;
  final String mealName;
  final List<SavedMealItemModel> items;
  final int totalCalories;
  final int totalPrice;
  final DateTime savedAt;
  final String userId;
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

  double get totalProtein {
    return items.fold(0.0, (sum, item) => sum + item.totalProtein);
  }

  double get totalCarbs {
    return items.fold(0.0, (sum, item) => sum + item.totalCarbs);
  }

  double get totalFat {
    return items.fold(0.0, (sum, item) => sum + item.totalFat);
  }

  int get itemCount => items.length;

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

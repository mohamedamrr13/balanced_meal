class FoodItemModel {
  final String id;
  final String foodName;
  final String imageUrl;
  final int calories;
  final int price;
  final String category;
  final double protein;
  final double carbs;
  final double fat;
  final String? description;

  const FoodItemModel({
    required this.id,
    required this.foodName,
    required this.imageUrl,
    required this.calories,
    required this.price,
    required this.category,
    this.protein = 0.0,
    this.carbs = 0.0,
    this.fat = 0.0,
    this.description,
  });

  factory FoodItemModel.fromFirestore(Map<String, dynamic> data, String id) {
    return FoodItemModel(
      id: id,
      foodName: data['food_name'] ?? '',
      imageUrl: data['image_url'] ?? '',
      calories: data['calories'] ?? 0,
      price: data['price'] ?? 0,
      category: data['category'] ?? '',
      protein: (data['protein'] ?? 0).toDouble(),
      carbs: (data['carbs'] ?? 0).toDouble(),
      fat: (data['fat'] ?? 0).toDouble(),
      description: data['description'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'food_name': foodName,
      'image_url': imageUrl,
      'calories': calories,
      'price': price,
      'category': category,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      if (description != null) 'description': description,
    };
  }

  double get totalMacros => protein + carbs + fat;

  bool get hasCompleteNutrition => protein > 0 || carbs > 0 || fat > 0;

  FoodItemModel copyWith({
    String? id,
    String? foodName,
    String? imageUrl,
    int? calories,
    int? price,
    String? category,
    double? protein,
    double? carbs,
    double? fat,
    String? description,
  }) {
    return FoodItemModel(
      id: id ?? this.id,
      foodName: foodName ?? this.foodName,
      imageUrl: imageUrl ?? this.imageUrl,
      calories: calories ?? this.calories,
      price: price ?? this.price,
      category: category ?? this.category,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      description: description ?? this.description,
    );
  }
}

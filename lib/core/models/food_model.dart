/// Represents a food item with complete nutritional information.
///
/// This model contains all the necessary data for displaying food items
/// in the meal builder, including macronutrient breakdown (protein, carbs, fat).
class FoodItemModel {
  /// Unique identifier for the food item
  final String id;

  /// Display name of the food item
  final String foodName;

  /// URL to the food item's image
  final String imageUrl;

  /// Total calories per serving
  final int calories;

  /// Price per serving (in cents or smallest currency unit)
  final int price;

  /// Category classification (e.g., 'vegetables', 'meat', 'carbs')
  final String category;

  /// Protein content in grams per serving
  final double protein;

  /// Carbohydrate content in grams per serving
  final double carbs;

  /// Fat content in grams per serving
  final double fat;

  /// Optional description or additional notes
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

  /// Creates a FoodItemModel from Firestore document data
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

  /// Converts the FoodItemModel to a Firestore-compatible map
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

  /// Calculates total macronutrients in grams
  double get totalMacros => protein + carbs + fat;

  /// Returns true if this food item has complete nutritional data
  bool get hasCompleteNutrition => protein > 0 || carbs > 0 || fat > 0;

  /// Creates a copy of this FoodItemModel with optionally updated fields
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

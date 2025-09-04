class FoodItemModel {
  final String id;
  final String foodName;
  final String imageUrl;
  final int calories;
  final int price;
  final String category;

  const FoodItemModel({
    required this.id,
    required this.foodName,
    required this.imageUrl,
    required this.calories,
    required this.price,
    required this.category,
  });

  factory FoodItemModel.fromFirestore(Map<String, dynamic> data, String id) {
    return FoodItemModel(
      id: id,
      foodName: data['food_name'] ?? '',
      imageUrl: data['image_url'] ?? '',
      calories: data['calories'] ?? 0,
      price: data['price'] ?? 0,
      category: data['category'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'food_name': foodName,
      'image_url': imageUrl,
      'calories': calories,
      'price': price,
      'category': category,
    };
  }
}

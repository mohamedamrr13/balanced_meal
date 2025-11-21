import 'food_model.dart';

class MealItem {
  final FoodItemModel food;
  int quantity;

  MealItem({required this.food, this.quantity = 1});

  int get totalCalories => food.calories * quantity;
  int get totalPrice => food.price * quantity;
}

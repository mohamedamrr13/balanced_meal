class CaloriesCalculator {
  static int calculateBasalMetabolicRate({
    required String gender,
    required double weight,
    required double height,
    required double age,
  }) {
    if (gender.toLowerCase() == 'female') {
      return (655.1 + (9.56 * weight) + (1.85 * height) - (4.67 * age)).toInt();
    } else {
      return (666.47 + (13.75 * weight) + (5 * height) - (6.75 * age)).toInt();
    }
  }

  static bool canAddItem({
    required int currentCalories,
    required int itemCalories,
    required int targetCalories,
  }) {
    final maxAllowedCalories = (targetCalories * 1.1).round();
    return (currentCalories + itemCalories) <= maxAllowedCalories;
  }

  static bool isValidOrder({
    required int currentCalories,
    required int targetCalories,
  }) {
    final minCalories = (targetCalories * 0.9).round();
    final maxCalories = (targetCalories * 1.1).round();
    return currentCalories >= minCalories && currentCalories <= maxCalories;
  }
}

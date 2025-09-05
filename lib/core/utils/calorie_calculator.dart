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

  static double calculateBMI({
    required double weight,
    required double height,
  }) {
    // Height should be in meters, so convert from cm
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  static String getBMICategory(double bmi) {
    if (bmi < 18.5) {
      return 'Underweight';
    } else if (bmi < 25) {
      return 'Normal weight';
    } else if (bmi < 30) {
      return 'Overweight';
    } else {
      return 'Obese';
    }
  }

  static List<String> getRecommendedFoods(double bmi, String bmiCategory) {
    if (bmi < 18.5) {
      // Underweight - need calorie-dense, nutritious foods
      return [
        'Nuts and nut butters',
        'Avocados',
        'Quinoa',
        'Lean meats',
        'Sweet potatoes',
        'Whole grain breads',
        'Protein smoothies',
        'Olive oil',
      ];
    } else if (bmi < 25) {
      // Normal weight - balanced nutrition
      return [
        'Lean proteins (chicken, fish, tofu)',
        'Whole grains (brown rice, oats)',
        'Fresh vegetables',
        'Fruits',
        'Low-fat dairy',
        'Legumes',
        'Healthy fats (olive oil, nuts)',
      ];
    } else if (bmi < 30) {
      // Overweight - focus on low-calorie, high-nutrition foods
      return [
        'Leafy green vegetables',
        'Lean proteins (fish, chicken breast)',
        'Fresh fruits (berries, apples)',
        'Whole grains in moderation',
        'Low-fat dairy',
        'Vegetables with high water content',
        'Herbs and spices for flavor',
      ];
    } else {
      // Obese - emphasize low-calorie, nutrient-dense foods
      return [
        'Non-starchy vegetables',
        'Lean proteins',
        'Fresh fruits (in moderation)',
        'Whole grains (small portions)',
        'Low-fat or fat-free dairy',
        'Water-rich foods',
        'Foods high in fiber',
      ];
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

  static bool isValidWeight(String weight) {
    final numWeight = double.tryParse(weight);
    return numWeight != null && numWeight > 0 && numWeight < 500;
  }

  static bool isValidHeight(String height) {
    final numHeight = double.tryParse(height);
    return numHeight != null && numHeight > 50 && numHeight < 300;
  }

  static bool isValidAge(String age) {
    final numAge = double.tryParse(age);
    return numAge != null && numAge > 0 && numAge < 120;
  }
}

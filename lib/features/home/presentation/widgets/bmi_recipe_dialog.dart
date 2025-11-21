import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/user_data_model.dart';
import '../../../../core/utils/calorie_calculator.dart';

class BMIRecipeDialog extends StatelessWidget {
  final UserDataModel userData;

  const BMIRecipeDialog({
    super.key,
    required this.userData,
  });

  void _navigateToCreateOrder(BuildContext context) {
    Navigator.of(context).pop();
    context.push('/create-order');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recommendedFoods = CaloriesCalculator.getRecommendedFoods(
      userData.bmi,
      userData.bmiCategory,
    );

    return AlertDialog(
      title: Text('Recommended Foods for ${userData.bmiCategory}'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your BMI: ${userData.bmi.toStringAsFixed(1)} (${userData.bmiCategory})',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Recommended foods:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ...recommendedFoods.map(
              (food) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(child: Text(food)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: () => _navigateToCreateOrder(context),
          child: const Text('Create Meal'),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/models/user_data_model.dart';

class HealthProfileCard extends StatelessWidget {
  final UserDataModel userData;

  const HealthProfileCard({
    super.key,
    required this.userData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Health Profile',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _HealthStat(
                  value: userData.bmi.toStringAsFixed(1),
                  label: 'BMI',
                ),
              ),
              Expanded(
                child: _HealthStat(
                  value: '${userData.bmr}',
                  label: 'Daily Calories',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Category: ${userData.bmiCategory}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthStat extends StatelessWidget {
  final String value;
  final String label;

  const _HealthStat({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70),
        ),
      ],
    );
  }
}

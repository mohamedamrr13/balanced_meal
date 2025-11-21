import 'package:balanced_meal/core/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:balanced_meal/core/models/user_data_model.dart';
import 'package:balanced_meal/core/models/saved_meal_model.dart';
import 'package:balanced_meal/core/services/firestore_service.dart';
import 'package:balanced_meal/core/widgets/empty_state.dart';

class MealHistoryPage extends StatelessWidget {
  const MealHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.user?.uid;
    final userData = authProvider.user?.userData;

    if (userId == null) {
      return const Scaffold(
        body: EmptyProfileState(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal History & Stats'),
      ),
      body: StreamBuilder<List<SavedMealModel>>(
        stream: FirestoreService().getSavedMeals(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return ErrorState(
              message: 'Failed to load meal history: ${snapshot.error}',
              onRetry: () {},
            );
          }

          final meals = snapshot.data ?? [];

          if (meals.isEmpty) {
            return const EmptySavedMealsState();
          }

          return MealHistoryContent(
            meals: meals,
            userData: userData,
          );
        },
      ),
    );
  }
}

class MealHistoryContent extends StatelessWidget {
  final List<SavedMealModel> meals;
  final UserDataModel? userData;

  const MealHistoryContent({
    super.key,
    required this.meals,
    this.userData,
  });

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats(meals);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SummaryCards(stats: stats),
          const SizedBox(height: 24),
          CalorieTrendChart(meals: meals, userData: userData),
          const SizedBox(height: 24),
          CategoryDistributionChart(meals: meals),
          const SizedBox(height: 24),
          RecentMealsList(meals: meals.take(5).toList()),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculateStats(List<SavedMealModel> meals) {
    if (meals.isEmpty) {
      return {
        'totalMeals': 0,
        'avgCalories': 0,
        'avgPrice': 0,
        'totalCalories': 0,
      };
    }

    final totalCalories = meals.fold<int>(
      0,
      (sum, meal) => sum + meal.totalCalories,
    );
    final totalPrice = meals.fold<int>(
      0,
      (sum, meal) => sum + meal.totalPrice,
    );

    return {
      'totalMeals': meals.length,
      'avgCalories': (totalCalories / meals.length).round(),
      'avgPrice': (totalPrice / meals.length).round(),
      'totalCalories': totalCalories,
    };
  }
}

class SummaryCards extends StatelessWidget {
  final Map<String, dynamic> stats;

  const SummaryCards({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Total Meals',
                value: '${stats['totalMeals']}',
                icon: Icons.restaurant_menu,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Avg Calories',
                value: '${stats['avgCalories']}',
                subtitle: 'per meal',
                icon: Icons.local_fire_department,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall,
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10,
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
              ),
            ),
        ],
      ),
    );
  }
}

class CalorieTrendChart extends StatelessWidget {
  final List<SavedMealModel> meals;
  final UserDataModel? userData;

  const CalorieTrendChart({
    super.key,
    required this.meals,
    this.userData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recentMeals = meals.take(7).toList().reversed.toList();
    final bmr = userData?.bmr ?? 2000;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Calorie Trend',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (userData != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Target: $bmr kcal',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 500,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: theme.colorScheme.outlineVariant.withOpacity(0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= recentMeals.length) {
                          return const SizedBox();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'M${value.toInt() + 1}',
                            style: theme.textTheme.bodySmall,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}',
                          style: theme.textTheme.bodySmall,
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: recentMeals.asMap().entries.map((entry) {
                      return FlSpot(
                        entry.key.toDouble(),
                        entry.value.totalCalories.toDouble(),
                      );
                    }).toList(),
                    isCurved: true,
                    color: theme.colorScheme.primary,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: theme.colorScheme.primary.withOpacity(0.1),
                    ),
                  ),
                  if (userData != null)
                    LineChartBarData(
                      spots: List.generate(
                        recentMeals.length,
                        (index) => FlSpot(index.toDouble(), bmr.toDouble()),
                      ),
                      isCurved: false,
                      color: theme.colorScheme.secondary.withOpacity(0.5),
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      dashArray: [5, 5],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryDistributionChart extends StatelessWidget {
  final List<SavedMealModel> meals;

  const CategoryDistributionChart({super.key, required this.meals});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final categoryCount = <String, int>{};
    for (final meal in meals) {
      for (final item in meal.items) {
        categoryCount[item.category] = (categoryCount[item.category] ?? 0) + 1;
      }
    }

    final total = categoryCount.values.fold(0, (sum, count) => sum + count);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category Distribution',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ...categoryCount.entries.map((entry) {
            final percentage = (entry.value / total * 100).round();
            final color = _getCategoryColor(entry.key);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: theme.textTheme.bodyMedium,
                      ),
                      Text(
                        '$percentage%',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: color.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'vegetables':
        return Colors.green;
      case 'meat':
        return Colors.red;
      case 'carbs':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}

class RecentMealsList extends StatelessWidget {
  final List<SavedMealModel> meals;

  const RecentMealsList({super.key, required this.meals});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Meals',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...meals.map((meal) => RecentMealCard(meal: meal)).toList(),
      ],
    );
  }
}

class RecentMealCard extends StatelessWidget {
  final SavedMealModel meal;

  const RecentMealCard({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.restaurant_menu,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.mealName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  meal.formattedDate,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${meal.totalCalories} kcal',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              Text(
                '${meal.itemCount} items',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

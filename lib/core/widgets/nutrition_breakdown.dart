import 'package:flutter/material.dart';
import 'dart:math' as math;

/// A widget that displays macronutrient breakdown in a visually appealing way.
///
/// Shows protein, carbohydrates, and fat with progress bars and percentages.
class NutritionBreakdown extends StatelessWidget {
  /// Protein in grams
  final double protein;

  /// Carbohydrates in grams
  final double carbs;

  /// Fat in grams
  final double fat;

  /// Total calories (optional, will be calculated if not provided)
  final int? totalCalories;

  /// Whether to show compact view (smaller, horizontal layout)
  final bool compact;

  const NutritionBreakdown({
    super.key,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.totalCalories,
    this.compact = false,
  });

  // Nutritional constants: calories per gram
  static const double _proteinCalPerGram = 4.0;
  static const double _carbsCalPerGram = 4.0;
  static const double _fatCalPerGram = 9.0;

  /// Calculates total calories from macros
  int get _calculatedCalories {
    return ((protein * _proteinCalPerGram) +
            (carbs * _carbsCalPerGram) +
            (fat * _fatCalPerGram))
        .round();
  }

  /// Gets the total calories (provided or calculated)
  int get calories => totalCalories ?? _calculatedCalories;

  /// Calculates percentage of total calories from protein
  double get _proteinPercentage {
    if (calories == 0) return 0;
    return (protein * _proteinCalPerGram / calories * 100);
  }

  /// Calculates percentage of total calories from carbs
  double get _carbsPercentage {
    if (calories == 0) return 0;
    return (carbs * _carbsCalPerGram / calories * 100);
  }

  /// Calculates percentage of total calories from fat
  double get _fatPercentage {
    if (calories == 0) return 0;
    return (fat * _fatCalPerGram / calories * 100);
  }

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompactView(context);
    }
    return _buildFullView(context);
  }

  Widget _buildFullView(BuildContext context) {
    final theme = Theme.of(context);

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
            'Nutritional Breakdown',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Protein
          _MacroRow(
            label: 'Protein',
            grams: protein,
            percentage: _proteinPercentage,
            color: Colors.blue,
            icon: Icons.fitness_center,
          ),
          const SizedBox(height: 16),

          // Carbs
          _MacroRow(
            label: 'Carbs',
            grams: carbs,
            percentage: _carbsPercentage,
            color: Colors.orange,
            icon: Icons.grain,
          ),
          const SizedBox(height: 16),

          // Fat
          _MacroRow(
            label: 'Fat',
            grams: fat,
            percentage: _fatPercentage,
            color: Colors.green,
            icon: Icons.water_drop,
          ),
          const SizedBox(height: 20),

          // Total calories
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Calories',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$calories kcal',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactView(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CompactMacro(
            label: 'P',
            value: protein.toStringAsFixed(0),
            color: Colors.blue,
          ),
          const SizedBox(width: 12),
          _CompactMacro(
            label: 'C',
            value: carbs.toStringAsFixed(0),
            color: Colors.orange,
          ),
          const SizedBox(width: 12),
          _CompactMacro(
            label: 'F',
            value: fat.toStringAsFixed(0),
            color: Colors.green,
          ),
        ],
      ),
    );
  }
}

/// A row displaying a single macronutrient with progress bar.
class _MacroRow extends StatelessWidget {
  final String label;
  final double grams;
  final double percentage;
  final Color color;
  final IconData icon;

  const _MacroRow({
    required this.label,
    required this.grams,
    required this.percentage,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clampedPercentage = math.min(percentage, 100.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '${grams.toStringAsFixed(1)}g',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${clampedPercentage.toStringAsFixed(0)}%)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: clampedPercentage / 100,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

/// Compact macro display for horizontal layouts.
class _CompactMacro extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _CompactMacro({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '${value}g',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// A circular chart showing macro distribution.
///
/// Displays a pie chart with color-coded sections for each macronutrient.
class MacroPieChart extends StatelessWidget {
  /// Protein in grams
  final double protein;

  /// Carbohydrates in grams
  final double carbs;

  /// Fat in grams
  final double fat;

  /// Size of the chart
  final double size;

  const MacroPieChart({
    super.key,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    final total = protein + carbs + fat;
    if (total == 0) {
      return SizedBox(
        width: size,
        height: size,
        child: const Center(child: Text('No data')),
      );
    }

    final proteinAngle = (protein / total) * 2 * math.pi;
    final carbsAngle = (carbs / total) * 2 * math.pi;
    final fatAngle = (fat / total) * 2 * math.pi;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _PieChartPainter(
          proteinAngle: proteinAngle,
          carbsAngle: carbsAngle,
          fatAngle: fatAngle,
        ),
      ),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final double proteinAngle;
  final double carbsAngle;
  final double fatAngle;

  _PieChartPainter({
    required this.proteinAngle,
    required this.carbsAngle,
    required this.fatAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // Draw protein section
    final proteinPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      proteinAngle,
      true,
      proteinPaint,
    );

    // Draw carbs section
    final carbsPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2 + proteinAngle,
      carbsAngle,
      true,
      carbsPaint,
    );

    // Draw fat section
    final fatPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2 + proteinAngle + carbsAngle,
      fatAngle,
      true,
      fatPaint,
    );
  }

  @override
  bool shouldRepaint(_PieChartPainter oldDelegate) {
    return proteinAngle != oldDelegate.proteinAngle ||
        carbsAngle != oldDelegate.carbsAngle ||
        fatAngle != oldDelegate.fatAngle;
  }
}

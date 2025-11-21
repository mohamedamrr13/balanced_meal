import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:balanced_meal/core/widgets/nutrition_breakdown.dart';

/// Widget tests for NutritionBreakdown component
///
/// Tests cover:
/// - Widget rendering
/// - Macro display
/// - Calorie calculation
/// - Compact vs full view
void main() {
  group('NutritionBreakdown Widget', () {
    testWidgets('should render nutrition breakdown with all macros', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NutritionBreakdown(
              protein: 30.0,
              carbs: 40.0,
              fat: 10.0,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Nutritional Breakdown'), findsOneWidget);
      expect(find.text('Protein'), findsOneWidget);
      expect(find.text('Carbs'), findsOneWidget);
      expect(find.text('Fat'), findsOneWidget);
    });

    testWidgets('should display protein value correctly', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NutritionBreakdown(
              protein: 31.5,
              carbs: 0.0,
              fat: 0.0,
            ),
          ),
        ),
      );

      // Assert
      expect(find.textContaining('31.5g'), findsOneWidget);
    });

    testWidgets('should display carbs value correctly', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NutritionBreakdown(
              protein: 0.0,
              carbs: 42.3,
              fat: 0.0,
            ),
          ),
        ),
      );

      // Assert
      expect(find.textContaining('42.3g'), findsOneWidget);
    });

    testWidgets('should display fat value correctly', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NutritionBreakdown(
              protein: 0.0,
              carbs: 0.0,
              fat: 15.7,
            ),
          ),
        ),
      );

      // Assert
      expect(find.textContaining('15.7g'), findsOneWidget);
    });

    testWidgets('should calculate and display total calories', (tester) async {
      // Arrange
      // protein: 30g * 4 = 120 kcal
      // carbs: 40g * 4 = 160 kcal
      // fat: 10g * 9 = 90 kcal
      // total = 370 kcal
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NutritionBreakdown(
              protein: 30.0,
              carbs: 40.0,
              fat: 10.0,
            ),
          ),
        ),
      );

      // Assert
      expect(find.textContaining('370 kcal'), findsOneWidget);
    });

    testWidgets('should use provided total calories over calculated', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NutritionBreakdown(
              protein: 30.0,
              carbs: 40.0,
              fat: 10.0,
              totalCalories: 500, // Override calculated value
            ),
          ),
        ),
      );

      // Assert
      expect(find.textContaining('500 kcal'), findsOneWidget);
    });

    testWidgets('should render compact view when compact is true', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NutritionBreakdown(
              protein: 30.0,
              carbs: 40.0,
              fat: 10.0,
              compact: true,
            ),
          ),
        ),
      );

      // Assert - compact view uses abbreviated labels
      expect(find.textContaining('P:'), findsOneWidget);
      expect(find.textContaining('C:'), findsOneWidget);
      expect(find.textContaining('F:'), findsOneWidget);
      // Should not show full title in compact mode
      expect(find.text('Nutritional Breakdown'), findsNothing);
    });

    testWidgets('should display progress indicators in full view', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NutritionBreakdown(
              protein: 30.0,
              carbs: 40.0,
              fat: 10.0,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(LinearProgressIndicator), findsNWidgets(3));
    });

    testWidgets('should not display progress indicators in compact view', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NutritionBreakdown(
              protein: 30.0,
              carbs: 40.0,
              fat: 10.0,
              compact: true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('should handle zero macros gracefully', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NutritionBreakdown(
              protein: 0.0,
              carbs: 0.0,
              fat: 0.0,
            ),
          ),
        ),
      );

      // Assert - should not crash
      expect(find.text('Nutritional Breakdown'), findsOneWidget);
      expect(find.textContaining('0 kcal'), findsOneWidget);
    });

    testWidgets('should display percentage for each macro', (tester) async {
      // Arrange
      // protein: 30g * 4 = 120 kcal (32.4%)
      // carbs: 40g * 4 = 160 kcal (43.2%)
      // fat: 10g * 9 = 90 kcal (24.3%)
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NutritionBreakdown(
              protein: 30.0,
              carbs: 40.0,
              fat: 10.0,
            ),
          ),
        ),
      );

      // Assert - find percentage text (rounded)
      expect(find.textContaining('32%'), findsOneWidget); // protein
      expect(find.textContaining('43%'), findsOneWidget); // carbs
      expect(find.textContaining('24%'), findsOneWidget); // fat
    });
  });

  group('MacroPieChart Widget', () {
    testWidgets('should render pie chart', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MacroPieChart(
              protein: 30.0,
              carbs: 40.0,
              fat: 10.0,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(CustomPaint), findsOneWidget);
    });

    testWidgets('should render pie chart with custom size', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MacroPieChart(
              protein: 30.0,
              carbs: 40.0,
              fat: 10.0,
              size: 200,
            ),
          ),
        ),
      );

      // Assert
      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, 200);
      expect(sizedBox.height, 200);
    });

    testWidgets('should handle zero macros in pie chart', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MacroPieChart(
              protein: 0.0,
              carbs: 0.0,
              fat: 0.0,
            ),
          ),
        ),
      );

      // Assert - should show "No data" message
      expect(find.text('No data'), findsOneWidget);
    });
  });
}

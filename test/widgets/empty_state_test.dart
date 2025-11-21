import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:balanced_meal/core/widgets/empty_state.dart';

/// Widget tests for EmptyState and related components
///
/// Tests cover:
/// - Empty state rendering
/// - Button interactions
/// - Different empty state variants
/// - Icon display (emoji vs IconData)
void main() {
  group('EmptyState Widget', () {
    testWidgets('should render title and subtitle', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: '😊',
              title: 'Test Title',
              subtitle: 'Test Subtitle',
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Subtitle'), findsOneWidget);
    });

    testWidgets('should display emoji icon', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: '🎉',
              title: 'Title',
              subtitle: 'Subtitle',
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('🎉'), findsOneWidget);
    });

    testWidgets('should display IconData icon', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.info,
              title: 'Title',
              subtitle: 'Subtitle',
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.info), findsOneWidget);
    });

    testWidgets('should render action button when provided', (tester) async {
      // Arrange
      var buttonTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: '📦',
              title: 'Empty',
              subtitle: 'Nothing here',
              actionText: 'Add Item',
              onAction: () => buttonTapped = true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Add Item'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);

      // Act
      await tester.tap(find.text('Add Item'));
      await tester.pump();

      // Assert
      expect(buttonTapped, true);
    });

    testWidgets('should not render action button when not provided', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: '📦',
              title: 'Empty',
              subtitle: 'Nothing here',
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('should render secondary action button when provided', (tester) async {
      // Arrange
      var secondaryTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: '📦',
              title: 'Empty',
              subtitle: 'Nothing here',
              actionText: 'Primary',
              onAction: () {},
              secondaryActionText: 'Secondary',
              onSecondaryAction: () => secondaryTapped = true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Secondary'), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);

      // Act
      await tester.tap(find.text('Secondary'));
      await tester.pump();

      // Assert
      expect(secondaryTapped, true);
    });
  });

  group('EmptySavedMealsState', () {
    testWidgets('should render with correct message', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptySavedMealsState(),
          ),
        ),
      );

      // Assert
      expect(find.text('No Saved Meals Yet'), findsOneWidget);
      expect(find.textContaining('Start creating balanced meals'), findsOneWidget);
      expect(find.text('🍽️'), findsOneWidget);
    });

    testWidgets('should call callback when button tapped', (tester) async {
      // Arrange
      var createMealCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptySavedMealsState(
              onCreateMeal: () => createMealCalled = true,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Create Your First Meal'));
      await tester.pump();

      // Assert
      expect(createMealCalled, true);
    });
  });

  group('EmptySearchState', () {
    testWidgets('should display search query in message', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptySearchState(searchQuery: 'chicken'),
          ),
        ),
      );

      // Assert
      expect(find.text('No Results Found'), findsOneWidget);
      expect(find.textContaining('chicken'), findsOneWidget);
      expect(find.text('🔍'), findsOneWidget);
    });

    testWidgets('should call callback when clear search tapped', (tester) async {
      // Arrange
      var clearCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptySearchState(
              searchQuery: 'test',
              onClearSearch: () => clearCalled = true,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Clear Search'));
      await tester.pump();

      // Assert
      expect(clearCalled, true);
    });
  });

  group('EmptyFavoritesState', () {
    testWidgets('should render with correct message', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyFavoritesState(),
          ),
        ),
      );

      // Assert
      expect(find.text('No Favorite Meals'), findsOneWidget);
      expect(find.textContaining('Mark meals as favorites'), findsOneWidget);
      expect(find.text('⭐'), findsOneWidget);
    });
  });

  group('ErrorState', () {
    testWidgets('should display error message', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorState(
              message: 'Something went wrong',
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Something Went Wrong'), findsOneWidget);
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('⚠️'), findsOneWidget);
    });

    testWidgets('should show retry button when callback provided', (tester) async {
      // Arrange
      var retryCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorState(
              message: 'Error occurred',
              onRetry: () => retryCalled = true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Try Again'), findsOneWidget);

      // Act
      await tester.tap(find.text('Try Again'));
      await tester.pump();

      // Assert
      expect(retryCalled, true);
    });

    testWidgets('should not show retry button when callback not provided', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorState(
              message: 'Error occurred',
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Try Again'), findsNothing);
    });

    testWidgets('should use custom icon when provided', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorState(
              message: 'Custom error',
              icon: Icons.error_outline,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      // Should not show default emoji
      expect(find.text('⚠️'), findsNothing);
    });
  });

  group('NetworkErrorState', () {
    testWidgets('should display network error message', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NetworkErrorState(),
          ),
        ),
      );

      // Assert
      expect(find.text('Something Went Wrong'), findsOneWidget);
      expect(find.textContaining('Unable to connect'), findsOneWidget);
      expect(find.text('📡'), findsOneWidget);
    });
  });

  group('EmptyProfileState', () {
    testWidgets('should render with correct message', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyProfileState(),
          ),
        ),
      );

      // Assert
      expect(find.text('Complete Your Profile'), findsOneWidget);
      expect(find.textContaining('Add your health information'), findsOneWidget);
      expect(find.text('👤'), findsOneWidget);
    });
  });
}

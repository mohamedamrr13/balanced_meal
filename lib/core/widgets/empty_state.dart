import 'package:flutter/material.dart';

/// A customizable empty state widget to show when lists or content are empty.
///
/// This widget provides a professional, user-friendly way to communicate
/// when no data is available, with optional actions the user can take.
class EmptyState extends StatelessWidget {
  /// Icon to display (can be an emoji or IconData)
  final dynamic icon;

  /// Title text displayed prominently
  final String title;

  /// Subtitle text providing more context
  final String subtitle;

  /// Optional action button text
  final String? actionText;

  /// Callback when action button is pressed
  final VoidCallback? onAction;

  /// Optional secondary action button text
  final String? secondaryActionText;

  /// Callback when secondary action button is pressed
  final VoidCallback? onSecondaryAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionText,
    this.onAction,
    this.secondaryActionText,
    this.onSecondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon or Emoji
            if (icon is String)
              Text(
                icon as String,
                style: const TextStyle(fontSize: 80),
              )
            else if (icon is IconData)
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon as IconData,
                  size: 60,
                  color: theme.colorScheme.primary,
                ),
              ),
            const SizedBox(height: 24),

            // Title
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Subtitle
            Text(
              subtitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Action buttons
            if (actionText != null && onAction != null)
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(actionText!),
              ),

            if (secondaryActionText != null && onSecondaryAction != null) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: onSecondaryAction,
                child: Text(secondaryActionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty state specifically for saved meals list.
class EmptySavedMealsState extends StatelessWidget {
  /// Callback when "Create Meal" button is pressed
  final VoidCallback? onCreateMeal;

  const EmptySavedMealsState({
    super.key,
    this.onCreateMeal,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: '🍽️',
      title: 'No Saved Meals Yet',
      subtitle:
          'Start creating balanced meals and save them here for quick access later.',
      actionText: 'Create Your First Meal',
      onAction: onCreateMeal,
    );
  }
}

/// Empty state for when search results are empty.
class EmptySearchState extends StatelessWidget {
  /// The search query that returned no results
  final String searchQuery;

  /// Callback when "Clear Search" button is pressed
  final VoidCallback? onClearSearch;

  const EmptySearchState({
    super.key,
    required this.searchQuery,
    this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: '🔍',
      title: 'No Results Found',
      subtitle:
          'We couldn\'t find any meals matching "$searchQuery". Try a different search term.',
      actionText: 'Clear Search',
      onAction: onClearSearch,
    );
  }
}

/// Empty state for when favorites list is empty.
class EmptyFavoritesState extends StatelessWidget {
  /// Callback when "Browse Meals" button is pressed
  final VoidCallback? onBrowseMeals;

  const EmptyFavoritesState({
    super.key,
    this.onBrowseMeals,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: '⭐',
      title: 'No Favorite Meals',
      subtitle:
          'Mark meals as favorites by tapping the star icon. They\'ll appear here for quick access.',
      actionText: 'Browse All Meals',
      onAction: onBrowseMeals,
    );
  }
}

/// Empty state for when no food items are available in a category.
class EmptyFoodCategoryState extends StatelessWidget {
  /// The category that has no items
  final String category;

  const EmptyFoodCategoryState({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: '📦',
      title: 'No $category Available',
      subtitle:
          'There are currently no food items in this category. Check back later!',
    );
  }
}

/// Empty state for error scenarios with retry option.
class ErrorState extends StatelessWidget {
  /// Error message to display
  final String message;

  /// Callback when "Retry" button is pressed
  final VoidCallback? onRetry;

  /// Optional icon override
  final dynamic icon;

  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: icon ?? '⚠️',
      title: 'Something Went Wrong',
      subtitle: message,
      actionText: onRetry != null ? 'Try Again' : null,
      onAction: onRetry,
    );
  }
}

/// Empty state for when network connection is lost.
class NetworkErrorState extends StatelessWidget {
  /// Callback when "Retry" button is pressed
  final VoidCallback? onRetry;

  const NetworkErrorState({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorState(
      icon: '📡',
      message:
          'Unable to connect to the internet. Please check your connection and try again.',
      onRetry: onRetry,
    );
  }
}

/// Empty state for when user has no profile data yet.
class EmptyProfileState extends StatelessWidget {
  /// Callback when "Complete Profile" button is pressed
  final VoidCallback? onCompleteProfile;

  const EmptyProfileState({
    super.key,
    this.onCompleteProfile,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: '👤',
      title: 'Complete Your Profile',
      subtitle:
          'Add your health information to get personalized meal recommendations and calorie tracking.',
      actionText: 'Get Started',
      onAction: onCompleteProfile,
    );
  }
}

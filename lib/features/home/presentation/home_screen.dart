import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/app_state_providers.dart';
import '../../../core/widgets/app_button.dart';
import 'widgets/custom_drawer.dart';
import 'widgets/option_card.dart';
import 'widgets/health_profile_card.dart';
import 'widgets/bmi_recipe_dialog.dart';
import 'widgets/reset_data_dialog.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _showBMIRecipeDialog(BuildContext context) {
    final userData = context.read<AppStateProvider>().userData;
    if (userData == null) return;

    showDialog(
      context: context,
      builder: (context) => BMIRecipeDialog(userData: userData),
    );
  }

  void _showResetDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ResetDataDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Balanced Meal',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(
              Icons.menu,
              color: theme.colorScheme.onSurface,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const CustomDrawer(),
      body: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          final userData = appState.userData;

          if (userData == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HealthProfileCard(userData: userData),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'What would you like to do?',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                OptionCard(
                  title: 'Recipe Recommendations',
                  description:
                      'Get personalized food recommendations based on your BMI',
                  icon: Icons.restaurant_menu,
                  onTap: () => _showBMIRecipeDialog(context),
                ),
                OptionCard(
                  title: 'Create Custom Meal',
                  description:
                      'Build your own balanced meal from our food selection',
                  icon: Icons.add_circle_outline,
                  onTap: () => context.push('/create-order'),
                ),
                OptionCard(
                  title: 'My Saved Meals',
                  description: 'View and manage your previously saved meals',
                  icon: Icons.bookmark,
                  onTap: () => context.push('/saved-meals'),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}

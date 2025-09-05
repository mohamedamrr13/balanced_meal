import 'package:balanced_meal/core/models/food_model.dart';
import 'package:balanced_meal/core/providers/app_state_providers.dart';
import 'package:balanced_meal/core/providers/auth_provider.dart';
import 'package:balanced_meal/core/services/firestore_service.dart';
import 'package:balanced_meal/core/utils/calorie_calculator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/food_item_card.dart';

class MealItem {
  final FoodItemModel food;
  int quantity;

  MealItem({required this.food, this.quantity = 1});

  int get totalCalories => food.calories * quantity;
  int get totalPrice => food.price * quantity;
}

class CreateOrderPage extends StatefulWidget {
  const CreateOrderPage({super.key});

  @override
  State<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final Map<String, MealItem> _currentMeal = {};
  bool _isSaving = false;

  void _addToMeal(FoodItemModel item) {
    final appState = context.read<AppStateProvider>();

    final currentTotalCalories = _currentMeal.values
        .fold(0, (sum, mealItem) => sum + mealItem.totalCalories);

    if (!CaloriesCalculator.canAddItem(
      currentCalories: currentTotalCalories,
      itemCalories: item.calories,
      targetCalories: appState.userCalories,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adding this item would exceed your calorie limit'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      if (_currentMeal.containsKey(item.id)) {
        _currentMeal[item.id]!.quantity++;
      } else {
        _currentMeal[item.id] = MealItem(food: item);
      }
    });

    _updateTotals();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.foodName} added to meal'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _removeFromMeal(String itemId) {
    setState(() {
      if (_currentMeal.containsKey(itemId)) {
        if (_currentMeal[itemId]!.quantity > 1) {
          _currentMeal[itemId]!.quantity--;
        } else {
          _currentMeal.remove(itemId);
        }
      }
    });
    _updateTotals();
  }

  void _updateTotals() {
    final totalCalories =
        _currentMeal.values.fold(0, (sum, item) => sum + item.totalCalories);
    final totalPrice =
        _currentMeal.values.fold(0, (sum, item) => sum + item.totalPrice);

    context
        .read<AppStateProvider>()
        .updateMealTotals(totalCalories, totalPrice);
  }

  void _clearMeal() {
    setState(() {
      _currentMeal.clear();
    });
    _updateTotals();
  }

  Future<void> _saveMeal() async {
    if (_currentMeal.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add some items to your meal first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final appState = context.read<AppStateProvider>();
    if (!appState.canSaveMeal) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Meal calories should be within 90-110% of your daily requirement'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show meal name dialog
    final mealName = await _showMealNameDialog();
    if (mealName == null || mealName.isEmpty) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.user?.uid ?? '';

      final mealItems = _currentMeal.values
          .map((mealItem) => SavedMealItemModel(
                id: mealItem.food.id,
                foodName: mealItem.food.foodName,
                imageUrl: mealItem.food.imageUrl,
                calories: mealItem.food.calories,
                price: mealItem.food.price,
                category: mealItem.food.category,
                quantity: mealItem.quantity,
              ))
          .toList();

      final meal = SavedMealModel(
        id: '',
        mealName: mealName,
        items: mealItems,
        totalCalories: appState.currentMealCalories,
        totalPrice: appState.currentMealPrice,
        savedAt: DateTime.now(),
        userId: userId,
      );

      await _firestoreService.saveMeal(meal);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meal saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        _clearMeal();
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save meal. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<String?> _showMealNameDialog() async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Meal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Give your meal a name:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'e.g., "Healthy Lunch", "Post-workout meal"',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.of(context).pop(name);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentMealSection() {
    if (_currentMeal.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Meal',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              TextButton(
                onPressed: _clearMeal,
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._currentMeal.values.map((mealItem) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        mealItem.food.imageUrl,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 40,
                          height: 40,
                          color: Colors.grey[300],
                          child:
                              const Icon(Icons.image_not_supported, size: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mealItem.food.foodName,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          Text(
                            '${mealItem.totalCalories} cal • \$${mealItem.totalPrice}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => _removeFromMeal(mealItem.food.id),
                          icon: const Icon(Icons.remove_circle_outline),
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                        Text('${mealItem.quantity}'),
                        IconButton(
                          onPressed: () => _addToMeal(mealItem.food),
                          icon: const Icon(Icons.add_circle_outline),
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildFoodSection(String title, Stream<List<FoodItemModel>> stream) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 220,
          child: StreamBuilder<List<FoodItemModel>>(
            stream: stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No items available'));
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final item = snapshot.data![index];
                  return FoodItemCard(
                    item: item,
                    onAddPressed: () => _addToMeal(item),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Your Meal'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_currentMeal.isNotEmpty)
            IconButton(
              onPressed: _clearMeal,
              icon: const Icon(Icons.clear_all),
              tooltip: 'Clear meal',
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildCurrentMealSection(),
                  const SizedBox(height: 20),
                  _buildFoodSection(
                      'Vegetables', _firestoreService.getVegetables()),
                  const SizedBox(height: 24),
                  _buildFoodSection('Meat', _firestoreService.getMeat()),
                  const SizedBox(height: 24),
                  _buildFoodSection('Carbs', _firestoreService.getCarbs()),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
          // Bottom Summary Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(24),
            child: Consumer<AppStateProvider>(
              builder: (context, appState, child) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Calories',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          '${appState.currentMealCalories} / ${appState.userCalories} cal',
                          style: TextStyle(
                            color: appState.canSaveMeal
                                ? Colors.green
                                : const Color(0xFF959595),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Price',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          '\$${appState.currentMealPrice}',
                          style: const TextStyle(
                            color: Color(0xFFF25700),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    AppButton(
                      text: 'Save Meal',
                      onPressed: _currentMeal.isNotEmpty ? _saveMeal : null,
                      isLoading: _isSaving,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

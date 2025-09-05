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

class _CreateOrderPageState extends State<CreateOrderPage>
    with TickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  final Map<String, MealItem> _currentMeal = {};
  bool _isSaving = false;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _fabAnimationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _addToMeal(FoodItemModel item) {
    final appState = context.read<AppStateProvider>();

    final currentTotalCalories = _currentMeal.values
        .fold(0, (sum, mealItem) => sum + mealItem.totalCalories);

    if (!CaloriesCalculator.canAddItem(
      currentCalories: currentTotalCalories,
      itemCalories: item.calories,
      targetCalories: appState.userCalories,
    )) {
      _showSnackBar(
        'Adding this item would exceed your calorie limit',
        Colors.red,
        Icons.warning,
      );
      return;
    }

    setState(() {
      if (_currentMeal.containsKey(item.id)) {
        _currentMeal[item.id]!.quantity++;
      } else {
        _currentMeal[item.id] = MealItem(food: item);
        _fabAnimationController.forward();
      }
    });

    _updateTotals();
    _showSnackBar(
      '${item.foodName} added to meal',
      Colors.green,
      Icons.check_circle,
    );
  }

  void _removeFromMeal(String itemId) {
    setState(() {
      if (_currentMeal.containsKey(itemId)) {
        if (_currentMeal[itemId]!.quantity > 1) {
          _currentMeal[itemId]!.quantity--;
        } else {
          _currentMeal.remove(itemId);
          if (_currentMeal.isEmpty) {
            _fabAnimationController.reverse();
          }
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
    _fabAnimationController.reverse();
    _updateTotals();
  }

  void _showSnackBar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _saveMeal() async {
    if (_currentMeal.isEmpty) {
      _showSnackBar(
        'Please add some items to your meal first',
        Colors.orange,
        Icons.info,
      );
      return;
    }

    final appState = context.read<AppStateProvider>();
    if (!appState.canSaveMeal) {
      _showSnackBar(
        'Meal calories should be within 90-110% of your daily requirement',
        Colors.orange,
        Icons.warning,
      );
      return;
    }

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
        _showSnackBar(
          'Meal saved successfully!',
          Colors.green,
          Icons.check_circle,
        );
        _clearMeal();
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          'Failed to save meal. Please try again.',
          Colors.red,
          Icons.error,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.restaurant_menu,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Save Meal'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Give your meal a memorable name:'),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'e.g., "Healthy Lunch", "Post-workout meal"',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.edit),
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.words,
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
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentMealSection() {
    if (_currentMeal.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Colors.grey[50]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.restaurant,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Current Meal',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: _clearMeal,
                icon: const Icon(Icons.clear_all, size: 18),
                label: const Text('Clear'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red[400],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(_currentMeal.values.length, (index) {
            final mealItem = _currentMeal.values.elementAt(index);
            return AnimatedContainer(
              duration: Duration(milliseconds: 300 + (index * 50)),
              curve: Curves.easeOutBack,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Hero(
                    tag: 'meal_item_${mealItem.food.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        mealItem.food.imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child:
                              const Icon(Icons.image_not_supported, size: 24),
                        ),
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
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        Text(
                          '${mealItem.totalCalories} cal • \$${mealItem.totalPrice}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _removeFromMeal(mealItem.food.id),
                          icon: const Icon(Icons.remove, size: 18),
                          style: IconButton.styleFrom(
                            minimumSize: const Size(32, 32),
                          ),
                        ),
                        Text(
                          '${mealItem.quantity}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        IconButton(
                          onPressed: () => _addToMeal(mealItem.food),
                          icon: const Icon(Icons.add, size: 18),
                          style: IconButton.styleFrom(
                            minimumSize: const Size(32, 32),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFoodSection(String title, Stream<List<FoodItemModel>> stream) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 240,
          child: StreamBuilder<List<FoodItemModel>>(
            stream: stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.restaurant_menu,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No items available',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final item = snapshot.data![index];
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300 + (index * 100)),
                    curve: Curves.easeOutBack,
                    child: FoodItemCard(
                      item: item,
                      onAddPressed: () => _addToMeal(item),
                    ),
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Create Your Meal',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_currentMeal.isNotEmpty)
            ScaleTransition(
              scale: _fabAnimation,
              child: IconButton(
                onPressed: _clearMeal,
                icon: const Icon(Icons.clear_all),
                tooltip: 'Clear meal',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  foregroundColor: Colors.red[600],
                ),
              ),
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
                  const SizedBox(height: 8),
                  _buildFoodSection(
                      'Vegetables', _firestoreService.getVegetables()),
                  const SizedBox(height: 32),
                  _buildFoodSection(
                      'Meat & Protein', _firestoreService.getMeat()),
                  const SizedBox(height: 32),
                  _buildFoodSection(
                      'Carbohydrates', _firestoreService.getCarbs()),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Consumer<AppStateProvider>(
            builder: (context, appState, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Calories',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${appState.currentMealCalories} / ${appState.userCalories}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: appState.canSaveMeal
                                  ? Colors.green[600]
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Total Price',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '\$${appState.currentMealPrice}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFF25700),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: AppButton(
                      text: _isSaving ? 'Saving...' : 'Save Meal',
                      onPressed: _currentMeal.isNotEmpty ? _saveMeal : null,
                      isLoading: _isSaving,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

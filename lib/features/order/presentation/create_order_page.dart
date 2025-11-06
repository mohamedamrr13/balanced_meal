import 'package:balanced_meal/core/models/food_model.dart';
import 'package:balanced_meal/core/models/meal_model.dart';
import 'package:balanced_meal/core/models/saved_meal_model.dart';
import 'package:balanced_meal/core/providers/app_state_providers.dart';
import 'package:balanced_meal/core/providers/auth_provider.dart';
import 'package:balanced_meal/core/services/firestore_service.dart';
import 'package:balanced_meal/core/utils/calorie_calculator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/food_item_card.dart';

class CreateMealPage extends StatefulWidget {
  const CreateMealPage({super.key});

  @override
  State<CreateMealPage> createState() => _CreateMealPageState();
}

class _CreateMealPageState extends State<CreateMealPage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final FirestoreService _firestoreService = FirestoreService();
  final Map<String, MealItem> _currentMeal = {};
  final ScrollController _scrollController = ScrollController();
  final Map<String, bool> _addingStates =
      {}; // Track individual item loading states
  bool _isSaving = false;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  // Cache for food streams to prevent unnecessary rebuilds
  late Stream<List<FoodItemModel>> _vegetablesStream;
  late Stream<List<FoodItemModel>> _meatStream;
  late Stream<List<FoodItemModel>> _carbsStream;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeStreams();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _fabAnimationController, curve: Curves.elasticOut),
    );
  }

  void _initializeStreams() {
    _vegetablesStream = _firestoreService.getVegetables();
    _meatStream = _firestoreService.getMeat();
    _carbsStream = _firestoreService.getCarbs();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _addToMeal(FoodItemModel item) async {
    // Prevent multiple rapid taps
    if (_addingStates[item.id] == true) return;

    setState(() {
      _addingStates[item.id] = true;
    });

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
      setState(() {
        _addingStates[item.id] = false;
      });
      return;
    }

    // Store scroll position before adding item to prevent auto-scroll
    final scrollPosition = _scrollController.hasClients ? _scrollController.offset : 0.0;

    // Small delay to show loading state
    await Future.delayed(const Duration(milliseconds: 150));

    if (mounted) {
      setState(() {
        if (_currentMeal.containsKey(item.id)) {
          _currentMeal[item.id]!.quantity++;
        } else {
          _currentMeal[item.id] = MealItem(food: item);
          _fabAnimationController.forward();
        }
        _addingStates[item.id] = false;
      });

      // Restore scroll position after state update to prevent auto-scroll
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients && scrollPosition > 0) {
          _scrollController.jumpTo(scrollPosition);
        }
      });

      _updateTotals();
      _showSnackBar(
        '${item.foodName} added to meal',
        Colors.green,
        Icons.check_circle,
      );
    }
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
      _addingStates.clear();
    });
    _fabAnimationController.reverse();
    _updateTotals();
  }

  void _showSnackBar(String message, Color color, IconData icon) {
    if (!mounted) return;

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

      if (userId.isEmpty) {
        throw Exception('User not logged in');
      }

      final mealItems = _currentMeal.values
          .map((mealItem) => SavedMealItemModel(
                id: mealItem.food.id,
                foodName: mealItem.food.foodName,
                imageUrl: mealItem.food.imageUrl,
                calories: mealItem.food.calories,
                price: mealItem.food.price,
                category: mealItem.food.category,
                quantity: mealItem.quantity,
                protein: mealItem.food.protein,
                carbs: mealItem.food.carbs,
                fat: mealItem.food.fat,
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
          'Failed to save meal: ${e.toString()}',
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
    final theme = Theme.of(context);

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
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
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
        color: Theme.of(context).colorScheme.surface,
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
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                ),
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
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
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
                  final isAdding = _addingStates[item.id] ?? false;

                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300 + (index * 100)),
                    curve: Curves.easeOutBack,
                    child: FoodItemCard(
                      item: item,
                      onAddPressed: () => _addToMeal(item),
                      isAddingToCart: isAdding,
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
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
              controller: _scrollController,
              child: Column(
                children: [
                  _buildCurrentMealSection(),
                  const SizedBox(height: 8),
                  _buildFoodSection('Vegetables', _vegetablesStream),
                  const SizedBox(height: 32),
                  _buildFoodSection('Meat & Protein', _meatStream),
                  const SizedBox(height: 32),
                  _buildFoodSection('Carbohydrates', _carbsStream),
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
          color: Theme.of(context).colorScheme.surface,
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
                      onPressed: _currentMeal.isNotEmpty && !_isSaving
                          ? _saveMeal
                          : null,
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

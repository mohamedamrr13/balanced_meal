import 'package:balanced_meal/core/models/cart_model.dart';
import 'package:balanced_meal/core/models/food_model.dart';
import 'package:balanced_meal/core/providers/app_state_providers.dart';
import 'package:balanced_meal/core/services/firestore_service.dart';
import 'package:balanced_meal/core/utils/calorie_calculator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/food_item_card.dart';

class CreateOrderPage extends StatefulWidget {
  const CreateOrderPage({super.key});

  @override
  State<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> {
  final FirestoreService _firestoreService = FirestoreService();
  String? _addingItemId;

  Future<void> _addToCart(FoodItemModel item) async {
    final appState = context.read<AppStateProvider>();

    if (!CaloriesCalculator.canAddItem(
      currentCalories: appState.currentCalories,
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
      _addingItemId = item.id;
    });

    try {
      await _firestoreService.addToCart(item);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.foodName} added to cart'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add item to cart'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _addingItemId = null;
      });
    }
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
                    onAddPressed: () => _addToCart(item),
                    isAddingToCart: _addingItemId == item.id,
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
        title: const Text('Create Your Order'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 40),
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
            child: StreamBuilder<List<CartItemModel>>(
              stream: _firestoreService.getCartItems(),
              builder: (context, snapshot) {
                final cartItems = snapshot.data ?? [];
                final totalCalories =
                    cartItems.fold(0, (sum, item) => sum + item.totalCalories);
                final totalPrice =
                    cartItems.fold(0, (sum, item) => sum + item.totalPrice);

                // Update app state
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context
                      .read<AppStateProvider>()
                      .updateCartTotals(totalCalories, totalPrice);
                });

                return Consumer<AppStateProvider>(
                  builder: (context, appState, child) {
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Cal',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              '$totalCalories Cals out of ${appState.userCalories} Cals',
                              style: const TextStyle(
                                color: Color(0xFF959595),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Price',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              '\$ $totalPrice',
                              style: const TextStyle(
                                color: Color(0xFFF25700),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        AppButton(
                          text: 'Place Order',
                          onPressed: appState.canPlaceOrder
                              ? () => context.go('/cart')
                              : null,
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

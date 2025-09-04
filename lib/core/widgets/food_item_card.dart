// lib/core/widgets/food_item_card.dart
import 'package:balanced_meal/core/models/food_model.dart';
import 'package:flutter/material.dart';
import 'app_button.dart';

class FoodItemCard extends StatelessWidget {
  final FoodItemModel item;
  final VoidCallback? onAddPressed;
  final bool isAddingToCart;

  const FoodItemCard({
    super.key,
    required this.item,
    this.onAddPressed,
    this.isAddingToCart = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(right: 12),
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.imageUrl,
                width: double.infinity,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: double.infinity,
                  height: 100,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.foodName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${item.calories} Cals',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 14,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${item.price}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                AppButton(
                  text: 'Add',
                  onPressed: onAddPressed,
                  isLoading: isAddingToCart,
                  width: 65,
                  height: 32,
                  padding: const EdgeInsets.all(8),
                  fontSize: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

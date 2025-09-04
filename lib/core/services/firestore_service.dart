import 'package:balanced_meal/core/models/cart_model.dart';
import 'package:balanced_meal/core/models/food_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Food Items
  Stream<List<FoodItemModel>> getVegetables() {
    return _firestore.collection('vegetables').snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => FoodItemModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Stream<List<FoodItemModel>> getMeat() {
    return _firestore.collection('meat').snapshots().map((snapshot) => snapshot
        .docs
        .map((doc) => FoodItemModel.fromFirestore(doc.data(), doc.id))
        .toList());
  }

  Stream<List<FoodItemModel>> getCarbs() {
    return _firestore.collection('carbs').snapshots().map((snapshot) => snapshot
        .docs
        .map((doc) => FoodItemModel.fromFirestore(doc.data(), doc.id))
        .toList());
  }

  // Cart Operations
  Future<void> addToCart(FoodItemModel item) async {
    final cartItem = CartItemModel(
      id: '',
      foodName: item.foodName,
      imageUrl: item.imageUrl,
      calories: item.calories,
      price: item.price,
      category: item.category,
      quantity: 1,
      timestamp: DateTime.now(),
    );

    await _firestore.collection('cart').add(cartItem.toFirestore());
  }

  Stream<List<CartItemModel>> getCartItems() {
    return _firestore
        .collection('cart')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CartItemModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Future<void> clearCart() async {
    final batch = _firestore.batch();
    final cartItems = await _firestore.collection('cart').get();

    for (final doc in cartItems.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  // Order Operations
  Future<bool> placeOrder(List<CartItemModel> items) async {
    try {
      final orderData = {
        'items': items
            .map((item) => {
                  'name': item.foodName,
                  'total_price': item.totalPrice,
                  'quantity': item.quantity,
                })
            .toList(),
        'timestamp': FieldValue.serverTimestamp(),
        'total_calories':
            items.fold(0, (sum, item) => sum + item.totalCalories),
        'total_price': items.fold(0, (sum, item) => sum + item.totalPrice),
      };

      await _firestore.collection('orders').add(orderData);
      await clearCart();
      return true;
    } catch (e) {
      debugPrint('Error placing order: $e');
      return false;
    }
  }
}

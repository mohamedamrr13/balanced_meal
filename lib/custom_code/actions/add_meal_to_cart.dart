// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:cloud_firestore/cloud_firestore.dart';

Future<bool> addMealToCart(
  String foodName,
  int calories,
  int price,
  String imageUrl,
  String category,
) async {
  try {
    final targetCalories = FFAppState().userCalories;
    final currentCalories = FFAppState().currentCalories;
    final maxAllowedCalories = (targetCalories * 1.1).round();

    if (currentCalories + calories > maxAllowedCalories) {
      print('❌ Cannot add item: Would exceed calorie limit.');
      return false;
    }

    final cartRef = FirebaseFirestore.instance.collection('cart');

    await cartRef.add({
      'food_name': foodName,
      'calories': calories,
      'price': price,
      'image_url': imageUrl,
      'category': category,
      'quantity': 1,
      'timestamp': FieldValue.serverTimestamp(),
    });

    print('✅ Added new item: $foodName');

    final cartItems = await cartRef.get();

    int totalCalories = 0;
    int totalPrice = 0;

    for (final doc in cartItems.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final qty = (data['quantity'] ?? 1) as int;
      final cal = (data['calories'] ?? 0) as int;
      final prc = (data['price'] ?? 0) as int;

      totalCalories += cal * qty;
      totalPrice += prc * qty;
    }

    FFAppState().currentCalories = totalCalories;
    FFAppState().totalPrice = totalPrice;

    final minCalories = (targetCalories * 0.9).round();
    FFAppState().canPlaceOrder =
        totalCalories >= minCalories && totalCalories <= maxAllowedCalories;

    print('🎯 Totals: $totalCalories cal, $totalPrice EGP');
    print('🟢 Can place order: ${FFAppState().canPlaceOrder}');

    return true;
  } catch (e) {
    print('🔥 Error in addMealToCart: $e');
    return false;
  }
}

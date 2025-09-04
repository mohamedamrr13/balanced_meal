import 'package:flutter/material.dart';

class AppStateProvider extends ChangeNotifier {
  int _userCalories = 0;
  int _currentCalories = 0;
  int _totalPrice = 0;
  bool _canPlaceOrder = false;

  int get userCalories => _userCalories;
  int get currentCalories => _currentCalories;
  int get totalPrice => _totalPrice;
  bool get canPlaceOrder => _canPlaceOrder;

  void setUserCalories(int calories) {
    _userCalories = calories;
    _updateOrderStatus();
    notifyListeners();
  }

  void updateCartTotals(int calories, int price) {
    _currentCalories = calories;
    _totalPrice = price;
    _updateOrderStatus();
    notifyListeners();
  }

  void _updateOrderStatus() {
    final minCalories = (_userCalories * 0.9).round();
    final maxCalories = (_userCalories * 1.1).round();
    _canPlaceOrder =
        _currentCalories >= minCalories && _currentCalories <= maxCalories;
  }

  void clearCart() {
    _currentCalories = 0;
    _totalPrice = 0;
    _canPlaceOrder = false;
    notifyListeners();
  }
}

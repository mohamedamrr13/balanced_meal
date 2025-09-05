import 'package:balanced_meal/core/models/user_data_model.dart';
import 'package:flutter/material.dart';



class AppStateProvider extends ChangeNotifier {
  UserDataModel? _userData;
  int _currentMealCalories = 0;
  int _currentMealPrice = 0;
  bool _canSaveMeal = false;

  UserDataModel? get userData => _userData;
  int get currentMealCalories => _currentMealCalories;
  int get currentMealPrice => _currentMealPrice;
  bool get canSaveMeal => _canSaveMeal;

  int get userCalories => _userData?.bmr ?? 0;
  double get userBMI => _userData?.bmi ?? 0;
  String get bmiCategory => _userData?.bmiCategory ?? '';

  void setUserData(UserDataModel userData) {
    _userData = userData;
    _updateMealStatus();
    notifyListeners();
  }

  void updateMealTotals(int calories, int price) {
    _currentMealCalories = calories;
    _currentMealPrice = price;
    _updateMealStatus();
    notifyListeners();
  }

  void _updateMealStatus() {
    if (_userData == null) {
      _canSaveMeal = false;
      return;
    }

    final minCalories = (_userData!.bmr * 0.9).round();
    final maxCalories = (_userData!.bmr * 1.1).round();
    _canSaveMeal = _currentMealCalories >= minCalories &&
        _currentMealCalories <= maxCalories;
  }

  void clearCurrentMeal() {
    _currentMealCalories = 0;
    _currentMealPrice = 0;
    _canSaveMeal = false;
    notifyListeners();
  }

  void resetUserData() {
    _userData = null;
    _currentMealCalories = 0;
    _currentMealPrice = 0;
    _canSaveMeal = false;
    notifyListeners();
  }
}

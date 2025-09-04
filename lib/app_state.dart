import 'package:flutter/material.dart';
import '/backend/backend.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flutter_flow/flutter_flow_util.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {}

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  int _userCalories = 0;
  int get userCalories => _userCalories;
  set userCalories(int value) {
    _userCalories = value;
  }

  int _currentCalories = 0;
  int get currentCalories => _currentCalories;
  set currentCalories(int value) {
    _currentCalories = value;
  }

  bool _canPlaceOrder = false;
  bool get canPlaceOrder => _canPlaceOrder;
  set canPlaceOrder(bool value) {
    _canPlaceOrder = value;
  }

  int _totalPrice = 0;
  int get totalPrice => _totalPrice;
  set totalPrice(int value) {
    _totalPrice = value;
  }
}

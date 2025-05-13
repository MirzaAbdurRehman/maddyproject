import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalCartProvider extends ChangeNotifier {
  int _totalCount = 0;
  double _totalPrice = 0.0;

  int get totalCount => _totalCount;
  double get totalPrice => _totalPrice;

  GlobalCartProvider() {
    _loadCartData(); // Load saved data on initialization
  }

  Future<void> _loadCartData() async {
    final prefs = await SharedPreferences.getInstance();
    _totalCount = prefs.getInt('cart_count') ?? 0;
    _totalPrice = prefs.getDouble('cart_price') ?? 0.0;
    notifyListeners();
  }

  Future<void> _saveCartData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('cart_count', _totalCount);
    await prefs.setDouble('cart_price', _totalPrice);
  }

  void setTotalCountAndPrice(int count, double price) {
    _totalCount = count;
    _totalPrice = price;
    _saveCartData();
    notifyListeners();
  }

  void clearCart() async {
    _totalCount = 0;
    _totalPrice = 0.0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cart_count');
    await prefs.remove('cart_price');
    notifyListeners();
  }

  void increaseCount(double price) {
    _totalCount++;
    _totalPrice += price;
    _saveCartData();
    notifyListeners();
  }

  void decreaseCount(double price) {
    if (_totalCount > 0) {
      _totalCount--;
      _totalPrice -= price;
      _saveCartData();
      notifyListeners();
    }
  }
}

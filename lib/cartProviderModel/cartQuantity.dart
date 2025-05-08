import 'package:flutter/material.dart';

class CartItemProvider extends ChangeNotifier {
  int _count;
  int _productPrice;

  CartItemProvider({required int count, required int productPrice})
      : _count = count,
        _productPrice = productPrice;

  int get count => _count;
  int get totalPrice => _count * _productPrice;

  void increase() {
    _count++;
    notifyListeners();
  }

  void decrease() {
    if (_count > 1) {
      _count--;
      notifyListeners();
    }
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteProvider extends ChangeNotifier {
  late String userId;
  Map<String, bool> _favorites = {}; // pid => isFavorite

  FavoriteProvider() {
    _initUser();
  }

  // Initialize user and fetch favorites using SharedPreferences email
  Future<void> _initUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');

    if (email != null) {
      userId = email;
      await _fetchFavorites();
    } else {
      userId = '';
      print("Email not found in SharedPreferences");
    }
  }

  bool isFavorite(String pid) => _favorites[pid] ?? false;

  // Fetch user's favorites from Firestore
  Future<void> _fetchFavorites() async {
    if (userId.isEmpty) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('FavoritesData')
          .where('userID', isEqualTo: userId)
          .get();

      _favorites.clear();
      for (var doc in snapshot.docs) {
        _favorites[doc['pid']] = true;
      }
      notifyListeners();
      print("Favorites fetched: ${_favorites.keys.toList()}");
    } catch (e) {
      print("Error fetching favorites: $e");
    }
  }

  // Toggle favorite status, also update cart accordingly
  Future<void> toggleFavorite({
    required String pid,
    required String productName,
    required String productImage,
    required String productPrice1,
  }) async {
    if (userId.isEmpty) {
      print("User email not set - cannot toggle favorite");
      return;
    }

    final favoritesRef = FirebaseFirestore.instance.collection('FavoritesData');
    final cartRef = FirebaseFirestore.instance.collection('AddtoCartData');
    final price = double.tryParse(productPrice1) ?? 0.0;

    try {
      if (_favorites[pid] == true) {
        // Remove from favorites
        final existingFav = await favoritesRef
            .where('userID', isEqualTo: userId)
            .where('pid', isEqualTo: pid)
            .get();
        if (existingFav.docs.isNotEmpty) {
          await favoritesRef.doc(existingFav.docs.first.id).delete();
          print("Removed favorite doc: ${existingFav.docs.first.id}");
        }

        // Remove from cart
        final existingCart = await cartRef
            .where('userID', isEqualTo: userId)
            .where('pid', isEqualTo: pid)
            .get();
        if (existingCart.docs.isNotEmpty) {
          await cartRef.doc(existingCart.docs.first.id).delete();
          print("Removed cart doc: ${existingCart.docs.first.id}");
        }

        _favorites[pid] = false;
      } else {
        // Add to favorites
        final favDoc = await favoritesRef.add({
          'pid': pid,
          'userID': userId,
          'productName': productName,
          'productImage': productImage,
          'productPrice': productPrice1,
        });
        print("Added favorite doc: ${favDoc.id}");

        // Add to cart or update existing cart item
        final existingCart = await cartRef
            .where('userID', isEqualTo: userId)
            .where('pid', isEqualTo: pid)
            .get();

        if (existingCart.docs.isNotEmpty) {
          final doc = existingCart.docs.first;
          int count = doc['count'];
          double total = double.parse(doc['total_price'].toString());
          await cartRef.doc(doc.id).update({
            'count': count + 1,
            'total_price': total + price,
          });
          print("Updated cart doc: ${doc.id}");
        } else {
          final newCartDoc = await cartRef.add({
            'pid': pid,
            'userID': userId,
            'count': 1,
            'total_price': price,
            'productName': productName,
            'productPrice': productPrice1,
            'productImage': productImage,
          });
          print("Added new cart doc: ${newCartDoc.id}");
        }

        _favorites[pid] = true;
      }

      notifyListeners();
    } catch (e) {
      print("Error toggling favorite: $e");
    }
  }
}

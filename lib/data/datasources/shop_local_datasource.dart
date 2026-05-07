import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mummymap/data/models/shop_product_model.dart';

class ShopLocalDataSource {
  static const _cartKey = 'shop_cart';
  static const _wishlistKey = 'shop_wishlist';

  Future<List<CartItem>> getCart() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_cartKey);
    if (json == null) return [];
    final List decoded = jsonDecode(json) as List;
    return decoded
        .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveCart(List<CartItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _cartKey,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  Future<List<String>> getWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_wishlistKey);
    if (json == null) return [];
    return List<String>.from(jsonDecode(json) as List);
  }

  Future<void> saveWishlist(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_wishlistKey, jsonEncode(ids));
  }

  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }
}
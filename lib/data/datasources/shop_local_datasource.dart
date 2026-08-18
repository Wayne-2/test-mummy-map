import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mummymap/data/models/shop_product_model.dart';

class ShopLocalDataSource {
  static const _boxName = 'shop_box';
  static const _cartKey = 'shop_cart';
  static const _wishlistKey = 'shop_wishlist';

  Box<String> get _box => Hive.box<String>(_boxName);

  Future<List<CartItem>> getCart(String userId) async {
    final json = _box.get('${_cartKey}_$userId');
    if (json == null) return [];
    try {
      final List decoded = jsonDecode(json) as List;
      return decoded
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveCart(String userId, List<CartItem> items) async {
    await _box.put(
      '${_cartKey}_$userId',
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  Future<List<String>> getWishlist(String userId) async {
    final json = _box.get('${_wishlistKey}_$userId');
    if (json == null) return [];
    try {
      return List<String>.from(jsonDecode(json) as List);
    } catch (_) {
      return [];
    }
  }

  Future<void> saveWishlist(String userId, List<String> ids) async {
    await _box.put('${_wishlistKey}_$userId', jsonEncode(ids));
  }

  Future<void> clearCart(String userId) async {
    await _box.delete('${_cartKey}_$userId');
  }
}
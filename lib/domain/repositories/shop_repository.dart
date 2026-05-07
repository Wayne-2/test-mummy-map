import 'package:mummymap/data/models/shop_product_model.dart';

abstract class ShopRepository {
  Future<List<ShopProduct>> getProducts();
  Future<List<String>> getCategories();
  Future<List<CartItem>> getCart();
  Future<void> saveCart(List<CartItem> items);
  Future<List<String>> getWishlist();
  Future<void> saveWishlist(List<String> ids);
  Future<void> addToWishlistRemote(String productId);
  Future<void> removeFromWishlistRemote(String productId);
  Future<void> placeOrder(List<CartItem> items);
  Future<void> clearCart();
}
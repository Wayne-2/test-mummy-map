import 'package:mummymap/data/models/shop_product_model.dart';

abstract class ShopRepository {
  Future<List<ShopProduct>> getProducts({
    String? category,
    num? minPrice,
    num? maxPrice,
  });

  Future<List<CartItem>> getLocalCart();
  Future<List<CartItem>> getCart();
  Future<List<CartItem>> addToCart(ShopProduct product, int quantity);
  Future<List<CartItem>> updateCartItem(ShopProduct product, int quantity);
  Future<List<CartItem>> clearCart();

  Future<String> placeOrder({String? notes});

  Future<List<String>> getWishlist();
  Future<void> saveWishlist(List<String> ids);
  Future<void> flushPendingCartOps();
}
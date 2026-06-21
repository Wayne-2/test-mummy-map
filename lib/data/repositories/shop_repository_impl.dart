import 'package:mummymap/data/datasources/shop_local_datasource.dart';
import 'package:mummymap/data/datasources/shop_remote_datasource.dart';
import 'package:mummymap/data/models/shop_product_model.dart';
import 'package:mummymap/domain/repositories/shop_repository.dart';

class ShopRepositoryImpl implements ShopRepository {
  final ShopLocalDataSource _local;
  final ShopRemoteDataSource _remote;

  ShopRepositoryImpl(this._local, this._remote);

  @override
  Future<List<ShopProduct>> getProducts({
    String? category,
    num? minPrice,
    num? maxPrice,
  }) {
    return _remote.getProducts(
      category: category,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
  }

  @override
  Future<List<CartItem>> getLocalCart() => _local.getCart();

  @override
  Future<List<CartItem>> getCart() async {
    try {
      final cart = await _remote.getCart();
      await _local.saveCart(cart);
      return cart;
    } catch (_) {
      return _local.getCart();
    }
  }

  @override
  Future<List<CartItem>> addToCart(ShopProduct product, int quantity) async {
    try {
      final cart = await _remote.addToCart(product.id, quantity);
      await _local.saveCart(cart);
      return cart;
    } catch (_) {
      final merged = _mergeLocal(await _local.getCart(), product, quantity);
      await _local.saveCart(merged);
      return merged;
    }
  }

  @override
  Future<List<CartItem>> updateCartItem(
      ShopProduct product, int quantity) async {
    try {
      final cart = await _remote.updateCartItem(product.id, quantity);
      await _local.saveCart(cart);
      return cart;
    } catch (_) {
      final current = await _local.getCart();
      final updated = <CartItem>[];
      for (final item in current) {
        if (item.product.id == product.id) {
          if (quantity > 0) updated.add(item.copyWith(quantity: quantity));
        } else {
          updated.add(item);
        }
      }
      await _local.saveCart(updated);
      return updated;
    }
  }

  @override
  Future<List<CartItem>> clearCart() async {
    try {
      await _remote.clearCart();
    } catch (_) {}
    await _local.clearCart();
    return const [];
  }

  @override
  Future<String> placeOrder({String? notes}) async {
    final orderId = await _remote.placeOrder(notes: notes);
    await _local.clearCart();
    return orderId;
  }

  @override
  Future<List<String>> getWishlist() => _local.getWishlist();

  @override
  Future<void> saveWishlist(List<String> ids) => _local.saveWishlist(ids);

  List<CartItem> _mergeLocal(
      List<CartItem> current, ShopProduct product, int quantity) {
    final items = List<CartItem>.from(current);
    final i = items.indexWhere((e) => e.product.id == product.id);
    if (i >= 0) {
      items[i] = items[i].copyWith(quantity: items[i].quantity + quantity);
    } else {
      items.add(CartItem(product: product, quantity: quantity));
    }
    return items;
  }
}
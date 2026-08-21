import 'package:mummymap/data/datasources/shop_local_datasource.dart';
import 'package:mummymap/data/datasources/shop_remote_datasource.dart';
import 'package:mummymap/data/models/shop_product_model.dart';
import 'package:mummymap/domain/repositories/shop_repository.dart';

class ShopRepositoryImpl implements ShopRepository {
  final ShopLocalDataSource _local;
  final ShopRemoteDataSource _remote;
  final String userId;

  ShopRepositoryImpl(this._local, this._remote, this.userId);

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

  bool get _hasUser => userId.isNotEmpty;

  @override
  Future<List<CartItem>> getLocalCart() =>
      _hasUser ? _local.getCart(userId) : Future.value([]);

  @override
  Future<List<CartItem>> getCart() async {
    if (!_hasUser) return [];
    try {
      await flushPendingCartOps();
      final cart = await _remote.getCart();
      await _local.saveCart(userId, cart);
      return cart;
    } catch (_) {
      return _local.getCart(userId);
    }
  }

  @override
  Future<List<CartItem>> addToCart(ShopProduct product, int quantity) async {
    if (!_hasUser) {
      // No user context yet — return optimistic local cart without persisting to shared key
      return [CartItem(product: product, quantity: quantity)];
    }
    try {
      final cart = await _remote.addToCart(product.id, quantity);
      await _local.saveCart(userId, cart);
      return cart;
    } catch (_) {
      final merged = _mergeLocal(await _local.getCart(userId), product, quantity);
      await _local.saveCart(userId, merged);
      await _queueCartOp({'op': 'add', 'productId': product.id, 'quantity': quantity});
      return merged;
    }
  }

  @override
  Future<List<CartItem>> updateCartItem(
      ShopProduct product, int quantity) async {
    if (!_hasUser) return [];
    try {
      final cart = await _remote.updateCartItem(product.id, quantity);
      await _local.saveCart(userId, cart);
      return cart;
    } catch (_) {
      final current = await _local.getCart(userId);
      final updated = <CartItem>[];
      for (final item in current) {
        if (item.product.id == product.id) {
          if (quantity > 0) updated.add(item.copyWith(quantity: quantity));
        } else {
          updated.add(item);
        }
      }
      await _local.saveCart(userId, updated);
      await _queueCartOp({'op': 'update', 'productId': product.id, 'quantity': quantity});
      return updated;
    }
  }

  @override
  Future<List<CartItem>> clearCart() async {
    if (!_hasUser) return const [];
    try {
      await _remote.clearCart();
      await _local.clearPendingCartOps(userId);
    } catch (_) {
      await _queueCartOp({'op': 'clear'});
    }
    await _local.clearCart(userId);
    return const [];
  }

  @override
  Future<String> placeOrder({String? notes}) async {
    final orderId = await _remote.placeOrder(notes: notes);
    if (_hasUser) {
      await _local.clearCart(userId);
      await _local.clearPendingCartOps(userId);
    }
    return orderId;
  }

  @override
  Future<List<String>> getWishlist() =>
      _hasUser ? _local.getWishlist(userId) : Future.value([]);

  @override
  Future<void> saveWishlist(List<String> ids) =>
      _hasUser ? _local.saveWishlist(userId, ids) : Future.value();

  @override
  Future<void> flushPendingCartOps() async {
    if (!_hasUser) return;
    final ops = await _local.getPendingCartOps(userId);
    if (ops.isEmpty) return;

    var index = 0;
    try {
      for (; index < ops.length; index++) {
        final op = ops[index];
        final type = op['op'] as String?;
        final productId = op['productId'] as String?;
        final quantity = (op['quantity'] as num?)?.toInt() ?? 1;
        if (type == 'clear') {
          await _remote.clearCart();
          continue;
        }
        if (productId == null) continue;
        if (type == 'add') {
          await _remote.addToCart(productId, quantity);
        } else if (type == 'update') {
          await _remote.updateCartItem(productId, quantity);
        }
      }
    } catch (_) {
      // Stop and keep the remaining ops for the next sync attempt.
    }

    if (index >= ops.length) {
      await _local.clearPendingCartOps(userId);
    } else {
      await _local.savePendingCartOps(userId, ops.sublist(index));
    }
  }

  Future<void> _queueCartOp(Map<String, dynamic> op) async {
    if (!_hasUser) return;
    final ops = await _local.getPendingCartOps(userId);
    await _local.savePendingCartOps(userId, [...ops, op]);
  }

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
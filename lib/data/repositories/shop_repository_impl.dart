import 'package:mummymap/data/datasources/shop_local_datasource.dart';
import 'package:mummymap/data/datasources/shop_remote_datasource.dart';
import 'package:mummymap/data/models/shop_product_model.dart';
import 'package:mummymap/domain/repositories/shop_repository.dart';

class ShopRepositoryImpl implements ShopRepository {
  final ShopLocalDataSource _local;
  final ShopRemoteDataSource _remote;

  ShopRepositoryImpl(this._local, this._remote);

  @override
  Future<List<ShopProduct>> getProducts() => _remote.getProducts();

  @override
  Future<List<String>> getCategories() => _remote.getCategories();

  @override
  Future<List<CartItem>> getCart() => _local.getCart();

  @override
  Future<void> saveCart(List<CartItem> items) => _local.saveCart(items);

  @override
  Future<List<String>> getWishlist() => _local.getWishlist();

  @override
  Future<void> saveWishlist(List<String> ids) => _local.saveWishlist(ids);

  @override
  Future<void> addToWishlistRemote(String productId) =>
      _remote.addToWishlist(productId);

  @override
  Future<void> removeFromWishlistRemote(String productId) =>
      _remote.removeFromWishlist(productId);

  @override
  Future<void> placeOrder(List<CartItem> items) => _remote.placeOrder(items);

  @override
  Future<void> clearCart() => _local.clearCart();
}
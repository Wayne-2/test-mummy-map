import 'package:mummymap/data/models/shop_product_model.dart';
import 'package:mummymap/domain/repositories/shop_repository.dart';

class GetProductsUseCase {
  final ShopRepository repository;

  GetProductsUseCase(this.repository);

  Future<List<ShopProduct>> call() => repository.getProducts();
}

class GetCategoriesUseCase {
  final ShopRepository repository;

  GetCategoriesUseCase(this.repository);

  Future<List<String>> call() => repository.getCategories();
}

class GetCartUseCase {
  final ShopRepository repository;

  GetCartUseCase(this.repository);

  Future<List<CartItem>> call() => repository.getCart();
}

class SaveCartUseCase {
  final ShopRepository repository;

  SaveCartUseCase(this.repository);

  Future<void> call(List<CartItem> items) => repository.saveCart(items);
}

class GetWishlistUseCase {
  final ShopRepository repository;

  GetWishlistUseCase(this.repository);

  Future<List<String>> call() => repository.getWishlist();
}

class SaveWishlistUseCase {
  final ShopRepository repository;

  SaveWishlistUseCase(this.repository);

  Future<void> call(List<String> ids) => repository.saveWishlist(ids);
}

class ToggleWishlistUseCase {
  final ShopRepository repository;

  ToggleWishlistUseCase(this.repository);

  Future<void> call({
    required String productId,
    required bool isCurrentlyWishlisted,
  }) async {
    if (isCurrentlyWishlisted) {
      await repository.removeFromWishlistRemote(productId);
    } else {
      await repository.addToWishlistRemote(productId);
    }
  }
}

class PlaceOrderUseCase {
  final ShopRepository repository;

  PlaceOrderUseCase(this.repository);

  Future<void> call(List<CartItem> items) => repository.placeOrder(items);
}

class ClearCartUseCase {
  final ShopRepository repository;

  ClearCartUseCase(this.repository);

  Future<void> call() => repository.clearCart();
}
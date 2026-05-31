import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mummymap/data/datasources/shop_local_datasource.dart';
import 'package:mummymap/data/datasources/shop_remote_datasource.dart';
import 'package:mummymap/data/models/shop_product_model.dart';
import 'package:mummymap/data/repositories/shop_repository_impl.dart';
import 'package:mummymap/domain/repositories/shop_repository.dart';

import 'package:mummymap/domain/usecases/shop_usecases.dart';



final shopLocalDataSourceProvider = Provider((_) => ShopLocalDataSource());

final shopRemoteDataSourceProvider = Provider(
  (_) => ShopRemoteDataSourceImpl(),
);

final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  return ShopRepositoryImpl(
    ref.read(shopLocalDataSourceProvider),
    ref.read(shopRemoteDataSourceProvider),
  );
});

final getProductsUseCaseProvider = Provider(
  (ref) => GetProductsUseCase(ref.read(shopRepositoryProvider)),
);

final getCategoriesUseCaseProvider = Provider(
  (ref) => GetCategoriesUseCase(ref.read(shopRepositoryProvider)),
);

final getCartUseCaseProvider = Provider(
  (ref) => GetCartUseCase(ref.read(shopRepositoryProvider)),
);

final saveCartUseCaseProvider = Provider(
  (ref) => SaveCartUseCase(ref.read(shopRepositoryProvider)),
);

final getWishlistUseCaseProvider = Provider(
  (ref) => GetWishlistUseCase(ref.read(shopRepositoryProvider)),
);

final saveWishlistUseCaseProvider = Provider(
  (ref) => SaveWishlistUseCase(ref.read(shopRepositoryProvider)),
);

final toggleWishlistUseCaseProvider = Provider(
  (ref) => ToggleWishlistUseCase(ref.read(shopRepositoryProvider)),
);

final placeOrderUseCaseProvider = Provider(
  (ref) => PlaceOrderUseCase(ref.read(shopRepositoryProvider)),
);

final clearCartUseCaseProvider = Provider(
  (ref) => ClearCartUseCase(ref.read(shopRepositoryProvider)),
);

final shopProvider = StateNotifierProvider<ShopNotifier, ShopState>(
  (ref) => ShopNotifier(
    getProducts: ref.read(getProductsUseCaseProvider),
    getCategories: ref.read(getCategoriesUseCaseProvider),
    getCart: ref.read(getCartUseCaseProvider),
    saveCart: ref.read(saveCartUseCaseProvider),
    getWishlist: ref.read(getWishlistUseCaseProvider),
    saveWishlist: ref.read(saveWishlistUseCaseProvider),
    toggleWishlist: ref.read(toggleWishlistUseCaseProvider),
    placeOrder: ref.read(placeOrderUseCaseProvider),
    clearCart: ref.read(clearCartUseCaseProvider),
  ),
);


class ShopState {
  final List<ShopProduct> products;
  final List<String> categories;
  final List<String> wishlistIds;
  final List<CartItem> cartItems;
  final bool isLoading;
  final String? errorMessage;
  final bool isPlacingOrder;
  final bool orderSuccess;

  const ShopState({
    this.products = const [],
    this.categories = const [],
    this.wishlistIds = const [],
    this.cartItems = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isPlacingOrder = false,
    this.orderSuccess = false,
  });

  bool isWishlisted(String id) => wishlistIds.contains(id);

  int get cartCount =>
      cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get cartTotal => cartItems.fold(
        0,
        (sum, item) => sum + item.product.priceValue * item.quantity,
      );

  List<ShopProduct> get wishlistProducts =>
      products.where((p) => wishlistIds.contains(p.id)).toList();

  ShopState copyWith({
    List<ShopProduct>? products,
    List<String>? categories,
    List<String>? wishlistIds,
    List<CartItem>? cartItems,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool? isPlacingOrder,
    bool? orderSuccess,
  }) {
    return ShopState(
      products: products ?? this.products,
      categories: categories ?? this.categories,
      wishlistIds: wishlistIds ?? this.wishlistIds,
      cartItems: cartItems ?? this.cartItems,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isPlacingOrder: isPlacingOrder ?? this.isPlacingOrder,
      orderSuccess: orderSuccess ?? this.orderSuccess,
    );
  }
}



class ShopNotifier extends StateNotifier<ShopState> {
  final GetProductsUseCase _getProducts;
  final GetCategoriesUseCase _getCategories;
  final GetCartUseCase _getCart;
  final SaveCartUseCase _saveCart;
  final GetWishlistUseCase _getWishlist;
  final SaveWishlistUseCase _saveWishlist;
  final ToggleWishlistUseCase _toggleWishlist;
  final PlaceOrderUseCase _placeOrder;
  final ClearCartUseCase _clearCart;

  ShopNotifier({
    required GetProductsUseCase getProducts,
    required GetCategoriesUseCase getCategories,
    required GetCartUseCase getCart,
    required SaveCartUseCase saveCart,
    required GetWishlistUseCase getWishlist,
    required SaveWishlistUseCase saveWishlist,
    required ToggleWishlistUseCase toggleWishlist,
    required PlaceOrderUseCase placeOrder,
    required ClearCartUseCase clearCart,
  })  : _getProducts = getProducts,
        _getCategories = getCategories,
        _getCart = getCart,
        _saveCart = saveCart,
        _getWishlist = getWishlist,
        _saveWishlist = saveWishlist,
        _toggleWishlist = toggleWishlist,
        _placeOrder = placeOrder,
        _clearCart = clearCart,
        super(const ShopState()) {
    _init();
  }

  Future<void> _init() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await Future.wait([
        _getProducts(),
        _getCategories(),
        _getCart(),
        _getWishlist(),
      ]);
      state = state.copyWith(
        products: results[0] as List<ShopProduct>,
        categories: results[1] as List<String>,
        cartItems: results[2] as List<CartItem>,
        wishlistIds: results[3] as List<String>,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load shop data. Please try again.',
      );
    }
  }

  Future<void> refresh() => _init();

  Future<void> toggleWishlist(String productId) async {
    final isCurrentlyWishlisted = state.isWishlisted(productId);
    final updatedIds = List<String>.from(state.wishlistIds);

    if (isCurrentlyWishlisted) {
      updatedIds.remove(productId);
    } else {
      updatedIds.add(productId);
    }

    state = state.copyWith(wishlistIds: updatedIds);

    try {
      await Future.wait([
        _toggleWishlist(
          productId: productId,
          isCurrentlyWishlisted: isCurrentlyWishlisted,
        ),
        _saveWishlist(updatedIds),
      ]);
    } catch (_) {
      final reverted = List<String>.from(state.wishlistIds);
      if (isCurrentlyWishlisted) {
        reverted.add(productId);
      } else {
        reverted.remove(productId);
      }
      state = state.copyWith(
        wishlistIds: reverted,
        errorMessage: 'Failed to update wishlist.',
      );
    }
  }

  Future<void> addToCart(ShopProduct product) async {
    final items = List<CartItem>.from(state.cartItems);
    final index = items.indexWhere((i) => i.product.id == product.id);

    if (index >= 0) {
      items[index] = items[index].copyWith(quantity: items[index].quantity + 1);
    } else {
      items.add(CartItem(product: product, quantity: 1));
    }

    state = state.copyWith(cartItems: items);
    await _saveCart(items);
  }

  Future<void> removeFromCart(String productId) async {
    final items =
        state.cartItems.where((i) => i.product.id != productId).toList();
    state = state.copyWith(cartItems: items);
    await _saveCart(items);
  }

  Future<void> incrementQuantity(String productId) async {
    final items = state.cartItems.map((i) {
      if (i.product.id != productId) return i;
      return i.copyWith(quantity: i.quantity + 1);
    }).toList();
    state = state.copyWith(cartItems: items);
    await _saveCart(items);
  }

  Future<void> decrementQuantity(String productId) async {
    final items = state.cartItems.map((i) {
      if (i.product.id != productId) return i;
      if (i.quantity <= 1) return i;
      return i.copyWith(quantity: i.quantity - 1);
    }).toList();
    state = state.copyWith(cartItems: items);
    await _saveCart(items);
  }

  Future<bool> checkout() async {
    state = state.copyWith(isPlacingOrder: true, clearError: true);
    try {
      await _placeOrder(state.cartItems);
      await _clearCart();
      state = state.copyWith(
        cartItems: [],
        isPlacingOrder: false,
        orderSuccess: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isPlacingOrder: false,
        orderSuccess: false,
        errorMessage: 'Failed to place order. Please try again.',
      );
      return false;
    }
  }

  Future<void> clearCart() async {
    state = state.copyWith(cartItems: []);
    await _clearCart();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void resetOrderSuccess() {
    state = state.copyWith(orderSuccess: false);
  }
}
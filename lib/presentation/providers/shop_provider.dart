import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mummymap/data/datasources/shop_local_datasource.dart';
import 'package:mummymap/data/datasources/shop_remote_datasource.dart';
import 'package:mummymap/data/models/shop_product_model.dart';
import 'package:mummymap/data/repositories/shop_repository_impl.dart';
import 'package:mummymap/domain/repositories/shop_repository.dart';
import 'package:mummymap/presentation/providers/auth_provider.dart';
import 'package:mummymap/presentation/providers/profile_provider.dart';

final shopLocalDataSourceProvider = Provider((_) => ShopLocalDataSource());

final shopRemoteDataSourceProvider = Provider(
  (ref) => ShopRemoteDataSource(ref.read(dioProvider)),
);

final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  final profile = ref.watch(profileProvider).value;
  final userId = profile?.userId ?? '';
  return ShopRepositoryImpl(
    ref.read(shopLocalDataSourceProvider),
    ref.read(shopRemoteDataSourceProvider),
    userId,
  );
});

final shopProvider = StateNotifierProvider<ShopNotifier, ShopState>((ref) {
  final repo = ref.watch(shopRepositoryProvider);
  final notifier = ShopNotifier(repo);
  // When userId becomes available (profile loads), refresh to load user-scoped Hive data
  ref.listen(shopRepositoryProvider, (prev, next) {
    final prevId = (prev as ShopRepositoryImpl?)?.userId ?? '';
    final nextId = (next as ShopRepositoryImpl).userId;
    if (prevId != nextId && nextId.isNotEmpty) {
      notifier.refreshWith(next);
    }
  });
  return notifier;
});

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
    this.categories = ShopCategories.withAll,
    this.wishlistIds = const [],
    this.cartItems = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isPlacingOrder = false,
    this.orderSuccess = false,
  });

  bool isWishlisted(String id) => wishlistIds.contains(id);

  int get cartCount => cartItems.fold(0, (sum, item) => sum + item.quantity);

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
  ShopRepository _repository;

  ShopNotifier(this._repository) : super(const ShopState()) {
    _init();
  }

  Future<void> refreshWith(ShopRepository newRepo) async {
    _repository = newRepo;
    await _init();
  }

  Future<void> _init() async {
    // 1. Instantly load local data (Cart and Wishlist) from Hive cache
    try {
      final localCart = await _repository.getLocalCart();
      final localWishlist = await _repository.getWishlist();
      state = state.copyWith(
        cartItems: localCart,
        wishlistIds: localWishlist,
        categories: ShopCategories.withAll,
      );
    } catch (_) {}

    // 2. Fetch remote data in the background
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await Future.wait([
        _repository.getProducts(),
        _repository.getCart(), // Sync remote cart
      ]);
      state = state.copyWith(
        products: results[0] as List<ShopProduct>,
        cartItems: results[1] as List<CartItem>,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to sync with server. Showing offline data.',
      );
    }
  }

  Future<void> refresh() => _init();

  Future<void> toggleWishlist(String productId) async {
    final isWishlisted = state.isWishlisted(productId);
    final updated = List<String>.from(state.wishlistIds);
    if (isWishlisted) {
      updated.remove(productId);
    } else {
      updated.add(productId);
    }
    state = state.copyWith(wishlistIds: updated);
    await _repository.saveWishlist(updated);
  }

  Future<void> addToCart(ShopProduct product) async {
    final cart = await _repository.addToCart(product, 1);
    state = state.copyWith(cartItems: cart);
  }

  Future<void> removeFromCart(String productId) async {
    final product = _findProduct(productId);
    if (product == null) return;
    final cart = await _repository.updateCartItem(product, 0);
    state = state.copyWith(cartItems: cart);
  }

  Future<void> incrementQuantity(String productId) async {
    final item = _findCartItem(productId);
    if (item == null) return;
    final cart =
        await _repository.updateCartItem(item.product, item.quantity + 1);
    state = state.copyWith(cartItems: cart);
  }

  Future<void> decrementQuantity(String productId) async {
    final item = _findCartItem(productId);
    if (item == null || item.quantity <= 1) return;
    final cart =
        await _repository.updateCartItem(item.product, item.quantity - 1);
    state = state.copyWith(cartItems: cart);
  }

  Future<bool> checkout({String? notes}) async {
    state = state.copyWith(isPlacingOrder: true, clearError: true);
    try {
      await _repository.placeOrder(notes: notes);
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
    final cart = await _repository.clearCart();
    state = state.copyWith(cartItems: cart);
  }

  void clearError() => state = state.copyWith(clearError: true);
  void resetOrderSuccess() => state = state.copyWith(orderSuccess: false);

  ShopProduct? _findProduct(String id) {
    for (final p in state.products) {
      if (p.id == id) return p;
    }
    for (final i in state.cartItems) {
      if (i.product.id == id) return i.product;
    }
    return null;
  }

  CartItem? _findCartItem(String id) {
    for (final i in state.cartItems) {
      if (i.product.id == id) return i;
    }
    return null;
  }
}
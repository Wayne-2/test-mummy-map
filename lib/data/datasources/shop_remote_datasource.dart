import 'package:dio/dio.dart';
import 'package:mummymap/data/models/shop_product_model.dart';

class ShopRemoteDataSource {
  final Dio dio;

  ShopRemoteDataSource(this.dio);

  Future<List<ShopProduct>> getProducts({
    String? category,
    num? minPrice,
    num? maxPrice,
    int page = 1,
    int limit = 20,
  }) async {
    final query = <String, dynamic>{'page': page, 'limit': limit};
    if (category != null && category != ShopCategories.all) {
      query['category'] = category;
    }
    if (minPrice != null) query['minPrice'] = minPrice;
    if (maxPrice != null) query['maxPrice'] = maxPrice;

    final res = await dio.get('/api/v1/shop/products', queryParameters: query);
    return _extractList(res.data)
        .map((e) => ShopProduct.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ShopProduct> getProductDetail(String id) async {
    final res = await dio.get('/api/v1/shop/products/$id');
    return ShopProduct.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<CartItem>> getCart() async {
    final res = await dio.get('/api/v1/shop/cart');
    return _extractCartItems(res.data);
  }

  Future<List<CartItem>> addToCart(String productId, int quantity) async {
    final res = await dio.post(
      '/api/v1/shop/cart',
      data: {'productId': productId, 'quantity': quantity},
    );
    return _extractCartItems(res.data);
  }

  Future<List<CartItem>> updateCartItem(String productId, int quantity) async {
    final res = await dio.put(
      '/api/v1/shop/cart/$productId',
      data: {'quantity': quantity},
    );
    return _extractCartItems(res.data);
  }

  Future<void> clearCart() async {
    await dio.delete('/api/v1/shop/cart');
  }

  Future<String> placeOrder({String? notes}) async {
    final res = await dio.post(
      '/api/v1/shop/orders',
      data: notes != null && notes.isNotEmpty ? {'notes': notes} : {},
    );
    final data = res.data;
    if (data is Map && data['orderId'] != null) {
      return data['orderId'].toString();
    }
    return '';
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      if (data['data'] is List) return data['data'] as List;
      if (data['products'] is List) return data['products'] as List;
      if (data['items'] is List) return data['items'] as List;
    }
    return const [];
  }

  List<CartItem> _extractCartItems(dynamic data) {
    dynamic itemsRaw;
    if (data is Map) {
      itemsRaw = data['items'] ??
          (data['cart'] is Map ? data['cart']['items'] : null) ??
          (data['data'] is Map ? data['data']['items'] : null) ??
          data['data'];
    } else if (data is List) {
      itemsRaw = data;
    }
    if (itemsRaw is! List) return const [];
    return itemsRaw
        .whereType<Map<String, dynamic>>()
        .map((e) => CartItem.fromJson(e))
        .toList();
  }
}
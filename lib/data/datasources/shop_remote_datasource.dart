import 'package:mummymap/data/models/shop_product_model.dart';

// Replace the base URL and HTTP client with your actual backend setup.
// This file is the only place that needs to change when connecting to a real API.
// Uses the same pattern as the rest of the project — swap the stub returns
// with actual http/dio calls pointing to your endpoints.

abstract class ShopRemoteDataSource {
  Future<List<ShopProduct>> getProducts();
  Future<List<String>> getCategories();
  Future<void> addToWishlist(String productId);
  Future<void> removeFromWishlist(String productId);
  Future<void> placeOrder(List<CartItem> items);
}

class ShopRemoteDataSourceImpl implements ShopRemoteDataSource {
  // final Dio _dio;
  // final String _baseUrl;
  //
  // ShopRemoteDataSourceImpl(this._dio, this._baseUrl);

  @override
  Future<List<ShopProduct>> getProducts() async {
    // TODO: replace with real API call
    // final response = await _dio.get('$_baseUrl/shop/products');
    // final List data = response.data['products'] as List;
    // return data.map((e) => ShopProduct.fromJson(e as Map<String, dynamic>)).toList();
    return kShopProducts;
  }

  @override
  Future<List<String>> getCategories() async {
    // TODO: replace with real API call
    // final response = await _dio.get('$_baseUrl/shop/categories');
    // return List<String>.from(response.data['categories'] as List);
    return kShopCategories;
  }

  @override
  Future<void> addToWishlist(String productId) async {
    // TODO: replace with real API call
    // await _dio.post('$_baseUrl/shop/wishlist', data: {'product_id': productId});
  }

  @override
  Future<void> removeFromWishlist(String productId) async {
    // TODO: replace with real API call
    // await _dio.delete('$_baseUrl/shop/wishlist/$productId');
  }

  @override
  Future<void> placeOrder(List<CartItem> items) async {
    // TODO: replace with real API call
    // final payload = items.map((e) => e.toJson()).toList();
    // await _dio.post('$_baseUrl/shop/orders', data: {'items': payload});
  }
}

// ─── Static seed data (used until backend is connected) ──────────────────────

const kShopCategories = [
  'All',
  'Panties',
  'Stroller',
  'Onesies',
  'Bibs',
  'Furniture',
  'Diapers',
];

const kShopProducts = [
  ShopProduct(
    id: 'p1',
    name: 'White Unisex Baby Onesies',
    category: 'Onesies',
    price: '₦20,000',
    priceValue: 20000,
    images: [
      'assets/shop/onesie_white_1.png',
      'assets/shop/onesie_white_2.png',
    ],
    description:
        'A comfortable, soft 100% cotton white unisex baby onesie. Perfect for everyday wear. Easy snap closures at the bottom for quick diaper changes.',
    rating: 4.5,
    reviewCount: 332,
    tags: ['Baby Product', 'Clothing'],
  ),
  ShopProduct(
    id: 'p2',
    name: 'White Unisex Baby Onesies',
    category: 'Onesies',
    price: '₦20,000',
    priceValue: 20000,
    images: [
      'assets/shop/onesie_red_1.png',
    ],
    description:
        'Soft, breathable cotton onesie in a bold red colorway. Gentle on baby\'s skin, durable enough for daily use.',
    rating: 4.0,
    reviewCount: 210,
    tags: ['Baby Product', 'Clothing'],
  ),
  ShopProduct(
    id: 'p3',
    name: 'Fullset Oak Tree Baby Crib',
    category: 'Furniture',
    price: '₦45,000',
    priceValue: 45000,
    images: [
      'assets/shop/crib_oak_1.png',
      'assets/shop/crib_oak_2.png',
    ],
    description:
        'A popular solid color deep brown oak tree fullset that can be assembled and easily combined with other solid or patterned cushions and baby accessories to make a complete nursery set.',
    rating: 4.5,
    reviewCount: 332,
    tags: ['Baby Product', 'Crib'],
  ),
  ShopProduct(
    id: 'p4',
    name: 'Matte Black Baby Stroller',
    category: 'Stroller',
    price: '₦20,000',
    priceValue: 20000,
    images: [
      'assets/shop/stroller_black_1.png',
    ],
    description:
        'A sleek matte black baby stroller with ergonomic design. Foldable for easy transport, with adjustable handlebar and large storage basket underneath.',
    rating: 4.2,
    reviewCount: 198,
    tags: ['Baby Product', 'Stroller'],
  ),
  ShopProduct(
    id: 'p5',
    name: 'BabyCozy Diapers',
    category: 'Diapers',
    price: '₦8,500',
    priceValue: 8500,
    images: [
      'assets/shop/diapers_cozy_1.png',
    ],
    description:
        'Ultra-soft, leak-proof BabyCozy diapers. Dermatologist tested, free from harmful chemicals. Keeps baby dry and comfortable for up to 12 hours.',
    rating: 4.8,
    reviewCount: 512,
    tags: ['Diapers', 'Essentials'],
  ),
  ShopProduct(
    id: 'p6',
    name: '3in1 Cute Baby Bib',
    category: 'Bibs',
    price: '₦7,000',
    priceValue: 7000,
    images: [
      'assets/shop/bib_cute_1.png',
    ],
    description:
        'A cute 3-in-1 waterproof baby bib set with fun animal prints. Adjustable neck strap, machine washable. Set includes 3 different designs.',
    rating: 4.3,
    reviewCount: 145,
    tags: ['Baby Product', 'Feeding'],
  ),
];
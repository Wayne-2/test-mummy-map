class ShopCategories {
  ShopCategories._();

  static const all = 'ALL';

  static const values = [
    'MATERNITY_CLOTHING',
    'BABY_GEAR',
    'FEEDING',
    'HEALTH_WELLNESS',
    'TOYS',
    'NURSERY',
    'POSTPARTUM_CARE',
    'OTHER',
  ];

  static const withAll = [all, ...values];

  static String display(String raw) {
    if (raw == all) return 'All';
    return raw
        .split('_')
        .map((w) => w.isEmpty
            ? w
            : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }
}

String formatNaira(num value) {
  final whole = value.round().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
  return '\u20A6$whole';
}

class ShopProduct {
  final String id;
  final String name;
  final String category;
  final double priceValue;
  final String description;
  final String? imageUrl;
  final bool inStock;
  final int stockCount;
  final double rating;
  final int reviewCount;
  final List<String> tags;

  const ShopProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.priceValue,
    required this.description,
    this.imageUrl,
    this.inStock = true,
    this.stockCount = 0,
    this.rating = 0,
    this.reviewCount = 0,
    this.tags = const [],
  });

  String get price => formatNaira(priceValue);

  String get categoryDisplay => ShopCategories.display(category);

  List<String> get images => imageUrl != null && imageUrl!.isNotEmpty
      ? [imageUrl!]
      : const [];

  factory ShopProduct.fromJson(Map<String, dynamic> json) {
    final root = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;
    return ShopProduct(
      id: (root['id'] ?? '').toString(),
      name: (root['name'] ?? '') as String,
      category: (root['category'] ?? 'OTHER') as String,
      priceValue: (root['price'] as num?)?.toDouble() ?? 0,
      description: (root['description'] ?? '') as String,
      imageUrl: root['image'] as String?,
      inStock: root['inStock'] as bool? ?? true,
      stockCount: (root['stockCount'] as num?)?.toInt() ?? 0,
      rating: (root['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (root['reviewCount'] as num?)?.toInt() ?? 0,
      tags: root['tags'] is List
          ? List<String>.from(root['tags'] as List)
          : const [],
    );
  }
}

class CartItem {
  final ShopProduct product;
  final int quantity;

  const CartItem({required this.product, required this.quantity});

  CartItem copyWith({int? quantity}) =>
      CartItem(product: product, quantity: quantity ?? this.quantity);

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final qty = (json['quantity'] as num?)?.toInt() ?? 1;
    if (json['product'] is Map<String, dynamic>) {
      return CartItem(
        product: ShopProduct.fromJson(json['product'] as Map<String, dynamic>),
        quantity: qty,
      );
    }
    return CartItem(product: ShopProduct.fromJson(json), quantity: qty);
  }

  Map<String, dynamic> toJson() => {
        'product': {
          'id': product.id,
          'name': product.name,
          'category': product.category,
          'price': product.priceValue,
          'description': product.description,
          'image': product.imageUrl,
          'inStock': product.inStock,
          'stockCount': product.stockCount,
        },
        'quantity': quantity,
      };
}
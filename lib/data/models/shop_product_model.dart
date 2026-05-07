class ShopProduct {
  final String id;
  final String name;
  final String category;
  final String price;
  final double priceValue;
  final List<String> images;
  final String description;
  final double rating;
  final int reviewCount;
  final List<String> tags;

  const ShopProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.priceValue,
    required this.images,
    required this.description,
    required this.rating,
    required this.reviewCount,
    required this.tags,
  });

  factory ShopProduct.fromJson(Map<String, dynamic> json) {
    return ShopProduct(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      price: json['price'] as String,
      priceValue: (json['price_value'] as num).toDouble(),
      images: List<String>.from(json['images'] as List),
      description: json['description'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['review_count'] as int,
      tags: List<String>.from(json['tags'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'price_value': priceValue,
      'images': images,
      'description': description,
      'rating': rating,
      'review_count': reviewCount,
      'tags': tags,
    };
  }
}

class CartItem {
  final ShopProduct product;
  final int quantity;

  const CartItem({required this.product, required this.quantity});

  CartItem copyWith({int? quantity}) =>
      CartItem(product: product, quantity: quantity ?? this.quantity);

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: ShopProduct.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
    };
  }
}
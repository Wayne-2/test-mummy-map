import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mummymap/data/models/shop_product_model.dart';
import 'package:mummymap/presentation/providers/shop_provider.dart';
import 'package:mummymap/presentation/pages/mainnav/shop/product_detail.dart';
import 'package:mummymap/presentation/pages/mainnav/shop/cart_screen.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(shopProvider);
    final wishlistProducts = state.wishlistProducts;
    final cartCount = state.cartCount;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Color(0xFF1A1A1A)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Wishlist',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(Icons.shopping_bag_outlined,
                            color: Color(0xFF1A1A1A), size: 26),
                        if (cartCount > 0)
                          Positioned(
                            top: -4,
                            right: -4,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                color: Color(0xFF3F2868),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '$cartCount',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(Icons.share_outlined,
                        color: Color(0xFF1A1A1A), size: 24),
                  ),
                ],
              ),
            ),
            Expanded(
              child: wishlistProducts.isEmpty
                  ? _EmptyWishlist()
                  : GridView.builder(
                      padding:
                          const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.62,
                      ),
                      itemCount: wishlistProducts.length,
                      itemBuilder: (context, index) => _WishlistCard(
                          product: wishlistProducts[index]),
                    ),
            ),
            if (wishlistProducts.isNotEmpty)
              Padding(
                padding: EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    MediaQuery.of(context).padding.bottom + 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      for (final p in wishlistProducts) {
                        await ref
                            .read(shopProvider.notifier)
                            .addToCart(p);
                      }
                      if (!context.mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CartScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3F2868),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Buy Now',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _WishlistCard extends ConsumerStatefulWidget {
  final ShopProduct product;

  const _WishlistCard({required this.product});

  @override
  ConsumerState<_WishlistCard> createState() => _WishlistCardState();
}

class _WishlistCardState extends ConsumerState<_WishlistCard> {
  int _currentImage = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ProductDetail(product: widget.product)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 160,
                  child: widget.product.images.isEmpty
                      ? Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image_outlined,
                              color: Colors.grey, size: 40),
                        )
                      : PageView.builder(
                          itemCount: widget.product.images.length,
                          onPageChanged: (i) =>
                              setState(() => _currentImage = i),
                          itemBuilder: (context, i) {
                            final img = widget.product.images[i];
                            final isNetwork = img.startsWith('http://') ||
                                img.startsWith('https://');
                            if (isNetwork) {
                              return Image.network(
                                img,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.image_outlined,
                                      color: Colors.grey, size: 40),
                                ),
                              );
                            }
                            return Image.asset(
                              img,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image_outlined,
                                    color: Colors.grey, size: 40),
                              ),
                            );
                          },
                        ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => ref
                      .read(shopProvider.notifier)
                      .toggleWishlist(widget.product.id),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 16,
                    ),
                  ),
                ),
              ),
              if (widget.product.images.length > 1)
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      widget.product.images.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin:
                            const EdgeInsets.symmetric(horizontal: 2),
                        width: _currentImage == i ? 16 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _currentImage == i
                              ? const Color(0xFF3F2868)
                              : Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.product.name,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A1A)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            widget.product.price,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A)),
          ),
        ],
      ),
    );
  }
}

class _EmptyWishlist extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFE8D5F5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.favorite_outline,
                  size: 40, color: Color(0xFF3F2868)),
            ),
            const SizedBox(height: 20),
            const Text(
              'Your wishlist is empty',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap the heart icon on any product to save it here',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
            ),
          ],
        ),
      ),
    );
  }
}
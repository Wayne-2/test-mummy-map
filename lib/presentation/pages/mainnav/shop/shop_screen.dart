import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mummymap/data/models/shop_product_model.dart';
import 'package:mummymap/presentation/providers/shop_provider.dart';
import 'package:mummymap/presentation/pages/mainnav/shop/product_detail.dart';
import 'package:mummymap/presentation/pages/mainnav/shop/wishlist_screen.dart';
import 'package:mummymap/presentation/pages/mainnav/shop/cart_screen.dart';

class ShopScreen extends ConsumerStatefulWidget {
  final VoidCallback? onNotifications;
  final VoidCallback? onProfileTap;

  const ShopScreen({
    super.key,
    this.onNotifications,
    this.onProfileTap,
  });

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
 
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  String _selectedCategory = 'All';
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ShopProduct> _filtered(List<ShopProduct> products) {
    return products.where((p) {
      final matchesCategory =
          _selectedCategory == 'All' || p.category == _selectedCategory;
      final matchesQuery = _query.isEmpty ||
          p.name.toLowerCase().contains(_query.toLowerCase()) ||
          p.category.toLowerCase().contains(_query.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shopProvider);

    if (state.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage!),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () => ref.read(shopProvider.notifier).refresh(),
            ),
          ),
        );
        ref.read(shopProvider.notifier).clearError();
      });
    }

    final filtered = _filtered(state.products);
    final categories =
        state.categories.isEmpty ? const ['All'] : state.categories;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, state),
            _buildTitleRow(context, state),
            _buildSearch(),
            _buildCategories(categories),
            Expanded(
              child: state.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF3F2868),
                      ),
                    )
                  : filtered.isEmpty
                      ? _EmptyState(query: _query)
                      : RefreshIndicator(
                          color: const Color(0xFF3F2868),
                          onRefresh: () =>
                              ref.read(shopProvider.notifier).refresh(),
                          child: GridView.builder(
                            padding:
                                const EdgeInsets.fromLTRB(16, 16, 16, 24),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.62,
                            ),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) =>
                                _ProductCard(product: filtered[index]),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ShopState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          
          GestureDetector(
            onTap: widget.onProfileTap,
            child: const CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xFFE8D5F5),
              child: Icon(Icons.person, color: Color(0xFF3F2868), size: 22),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/logo3.png',
                height: 28,
                width: 28,
                errorBuilder: (_, __, ___) =>
                    const SizedBox(width: 28, height: 28),
              ),
              const SizedBox(width: 6),
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Mummy',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3F2868)),
                    ),
                    TextSpan(
                      text: 'map',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00BCD4)),
                    ),
                  ],
                ),
              ),
            ],
          ),
         
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: Color(0xFF1A1A1A)),
            onPressed: widget.onNotifications,
          ),
        ],
      ),
    );
  }

  Widget _buildTitleRow(BuildContext context, ShopState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          const Text(
            'Shop',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A)),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WishlistScreen()),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.favorite_outline,
                    color: Color(0xFF1A1A1A), size: 26),
                if (state.wishlistIds.isNotEmpty)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${state.wishlistIds.length}',
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
          const SizedBox(width: 16),
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
                if (state.cartCount > 0)
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
                          '${state.cartCount}',
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
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Name, category, location...',
                  hintStyle:
                      TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  icon: Icon(Icons.search,
                      color: Colors.grey.shade400, size: 20),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                Icon(Icons.tune, color: Colors.grey.shade600, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(List<String> categories) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedCategory == cat;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF3F2868)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF3F2868)
                      : Colors.grey.shade300,
                ),
              ),
              child: Text(
                cat,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                  color:
                      isSelected ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}



class _ProductCard extends ConsumerStatefulWidget {
  final ShopProduct product;

  const _ProductCard({required this.product});

  @override
  ConsumerState<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<_ProductCard> {
  int _currentImage = 0;

  @override
  Widget build(BuildContext context) {
    final isWishlisted =
        ref.watch(shopProvider).isWishlisted(widget.product.id);

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
                  child: PageView.builder(
                    itemCount: widget.product.images.length,
                    onPageChanged: (i) =>
                        setState(() => _currentImage = i),
                    itemBuilder: (context, i) => Image.asset(
                      widget.product.images[i],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image_outlined,
                            color: Colors.grey, size: 40),
                      ),
                    ),
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
                    child: Icon(
                      isWishlisted
                          ? Icons.favorite
                          : Icons.favorite_outline,
                      color: isWishlisted
                          ? Colors.red
                          : Colors.grey.shade500,
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

class _EmptyState extends StatelessWidget {
  final String query;

  const _EmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined,
                size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              query.isNotEmpty
                  ? 'No products found for "$query"'
                  : 'No products in this category',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
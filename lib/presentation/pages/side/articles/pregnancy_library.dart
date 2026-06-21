import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mummymap/data/models/article_model.dart';
import 'package:mummymap/presentation/providers/pregnancy_provider.dart';
import 'package:mummymap/presentation/providers/article_provider.dart';
import 'package:mummymap/presentation/pages/side/articles/article_detail.dart';

class PregnancyLibrary extends ConsumerStatefulWidget {
  const PregnancyLibrary({super.key});

  @override
  ConsumerState<PregnancyLibrary> createState() => _PregnancyLibraryState();
}

class _PregnancyLibraryState extends ConsumerState<PregnancyLibrary> {
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    final pregnancy = ref.watch(pregnancyProvider);
    final state = ref.watch(articleProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildCategoryFilter(state),
                    const SizedBox(height: 16),
                    if (pregnancy != null) ...[
                      _buildTrimesterBanner(pregnancy),
                      const SizedBox(height: 20),
                    ],
                    if (state.isLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 60),
                        child: Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFF3F2868)),
                        ),
                      )
                    else if (state.errorMessage != null)
                      _buildError(state.errorMessage!)
                    else if (state.articles.isEmpty)
                      _buildEmpty()
                    else
                      _isGridView
                          ? _buildGridArticles(state.articles)
                          : _buildListArticles(state.articles),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Pregnancy Library',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF1A1A1A)),
            onPressed: () {},
          ),
          GestureDetector(
            onTap: () => setState(() => _isGridView = !_isGridView),
            child: _isGridView
                ? const Icon(Icons.grid_view, color: Color(0xFF3F2868), size: 24)
                : const Icon(Icons.menu, color: Color(0xFF3F2868), size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(ArticleState state) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: state.categories.length,
        itemBuilder: (context, index) {
          final cat = state.categories[index];
          final isSelected = state.selectedCategory == cat;
          return GestureDetector(
            onTap: () =>
                ref.read(articleProvider.notifier).selectCategory(cat),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color:
                    isSelected ? const Color(0xFF3F2868) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF3F2868)
                      : Colors.grey.shade300,
                ),
              ),
              child: Center(
                child: Text(
                  ArticleCategories.display(cat),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color:
                        isSelected ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrimesterBanner(dynamic pregnancy) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFF5EEFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0C8FF)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "You're In Trimester ${pregnancy.trimester}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7B2FBE),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Here's your week-by-week breakdown",
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF3F2868)),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.arrow_forward,
                  color: Color(0xFF3F2868), size: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridArticles(List<Article> articles) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
          childAspectRatio: 0.68,
        ),
        itemCount: articles.length,
        itemBuilder: (context, index) =>
            _GridArticleCard(article: articles[index]),
      ),
    );
  }

  Widget _buildListArticles(List<Article> articles) {
    return Column(
      children: articles.map((a) => _ListArticleCard(article: a)).toList(),
    );
  }

  Widget _buildEmpty() {
    return const Padding(
      padding: EdgeInsets.only(top: 60),
      child: Center(
        child: Text(
          'No articles yet',
          style: TextStyle(fontSize: 15, color: Color(0xFF9E9E9E)),
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Center(
        child: Column(
          children: [
            Text(message,
                style: const TextStyle(
                    fontSize: 14, color: Color(0xFF9E9E9E))),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => ref.read(articleProvider.notifier).load(),
              child: const Text('Retry',
                  style: TextStyle(color: Color(0xFF3F2868))),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArticleThumb extends StatelessWidget {
  final String? url;
  final double height;
  final double? width;

  const _ArticleThumb({required this.url, required this.height, this.width});

  @override
  Widget build(BuildContext context) {
    Widget placeholder() => Container(
          height: height,
          width: width,
          color: Colors.grey.shade200,
          child: const Icon(Icons.image_outlined, color: Colors.grey, size: 32),
        );
    if (url == null || url!.isEmpty) return placeholder();
    return Image.network(
      url!,
      height: height,
      width: width ?? double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => placeholder(),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;

  const _CategoryChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E8FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_offer_outlined,
              size: 12, color: Color(0xFF3F2868)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF3F2868),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _GridArticleCard extends ConsumerWidget {
  final Article article;

  const _GridArticleCard({required this.article});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBookmarked =
        ref.watch(articleProvider).isBookmarked(article.id);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ArticleDetail(article: article)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CategoryChip(label: article.categoryDisplay),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _ArticleThumb(url: article.thumbnail, height: 110),
          ),
          const SizedBox(height: 8),
          Text(
            article.title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (article.excerpt != null) ...[
            const SizedBox(height: 6),
            Text(
              article.excerpt!,
              style: TextStyle(
                  fontSize: 11, color: Colors.grey.shade500, height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const Spacer(),
          Row(
            children: [
              Text(
                article.publishedLabel,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () =>
                    ref.read(articleProvider.notifier).toggleBookmark(article.id),
                child: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                  size: 16,
                  color: isBookmarked
                      ? const Color(0xFF3F2868)
                      : Colors.grey.shade500,
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.share_outlined, size: 14, color: Colors.grey.shade500),
            ],
          ),
        ],
      ),
    );
  }
}

class _ListArticleCard extends ConsumerWidget {
  final Article article;

  const _ListArticleCard({required this.article});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBookmarked =
        ref.watch(articleProvider).isBookmarked(article.id);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ArticleDetail(article: article)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CategoryChip(label: article.categoryDisplay),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (article.excerpt != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          article.excerpt!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child:
                      _ArticleThumb(url: article.thumbnail, height: 80, width: 90),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                GestureDetector(
                  onTap: () => ref
                      .read(articleProvider.notifier)
                      .toggleBookmark(article.id),
                  child: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                    size: 16,
                    color: isBookmarked
                        ? const Color(0xFF3F2868)
                        : Colors.grey.shade500,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.share_outlined,
                    size: 16, color: Colors.grey.shade500),
                const Spacer(),
                Text(
                  article.publishedLabel,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: Colors.grey.shade100),
          ],
        ),
      ),
    );
  }
}
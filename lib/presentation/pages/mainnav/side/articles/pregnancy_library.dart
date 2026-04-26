import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mummymap/presentation/providers/pregnancy_provider.dart';
import 'package:mummymap/presentation/pages/mainnav/side/articles/article_detail.dart';

final _articles = [
  {
    'id': '1',
    'category': 'Nutrition',
    'title': 'Eating for Two: 5 Essential Nutrients Every Pregnant Woman Needs',
    'excerpt':
        'While cravings may be unpredictable, your body is working hard behind the scenes, and fueling it with the right nutrients can make all the difference.',
    'image': 'assets/articles/nutrition_1.png',
    'likes': '12k',
    'shares': '364',
    'comments': '5.3k',
    'author': 'Mummy Map Team',
    'updated': '2w ago',
    'isFeatured': true,
    'week': 'Week 18',
    'body': '''Pregnancy is a beautiful journey and what you eat plays a powerful role in supporting both your health and your baby's development.

While cravings may be unpredictable, your body is working hard behind the scenes, and fueling it with the right nutrients can make all the difference. Here are five essential nutrients every expectant mom should keep an eye on:

1. Folate (Folic Acid)
Folate is crucial in the early stages of pregnancy, helping to prevent neural tube defects and support brain development.
Top sources: Leafy greens, beans, citrus fruits, and fortified cereals.

2. Iron
Your blood volume increases during pregnancy, so iron helps carry oxygen to your baby.
Top sources: Red meat, spinach, lentils, and fortified cereals.

3. Calcium
Essential for your baby's bone and teeth development.
Top sources: Dairy products, fortified plant milks, broccoli, and kale.

4. Omega-3 Fatty Acids
Support your baby's brain and eye development.
Top sources: Salmon, sardines, walnuts, and flaxseeds.

5. Protein
Helps build and repair tissues for both you and your baby.
Top sources: Eggs, poultry, beans, lentils, tofu, and Greek yogurt.

Tip: Don't stress over getting it perfect every day. Focus on variety, color, and balance — and always listen to your body. And of course, check with your doctor before starting any supplements or major diet changes.

Quick Reminder:
Always stay hydrated, eat small frequent meals, and don't skip breakfast your baby (and your energy levels) will thank you!''',
    'tags': ['Nutrition', 'Physical Well-Being'],
  },
  {
    'id': '2',
    'category': 'Mental Health',
    'title': '5 Foods to Help with Morning Sickness',
    'excerpt':
        'While cravings may be unpredictable, your body is working hard behind the scenes.',
    'image': 'assets/articles/mental_health_1.png',
    'likes': '12k',
    'shares': '364',
    'comments': '5.3k',
    'author': 'Mummy Map Team',
    'updated': '1w ago',
    'isFeatured': false,
    'week': 'Week 18',
    'body': 'Full article content goes here...',
    'tags': ['Mental Health'],
  },
  {
    'id': '3',
    'category': 'Exercise',
    'title': '5 Foods to Help with Morning Sickness',
    'excerpt':
        'While cravings may be unpredictable, your body is working hard behind the scenes.',
    'image': 'assets/articles/exercise_1.png',
    'likes': '12k',
    'shares': '364',
    'comments': '5.3k',
    'author': 'Mummy Map Team',
    'updated': '3d ago',
    'isFeatured': false,
    'week': 'Week 18',
    'body': 'Full article content goes here...',
    'tags': ['Exercise'],
  },
  {
    'id': '4',
    'category': 'Trimester',
    'title': 'What to Expect in Your Second Trimester',
    'excerpt':
        'The second trimester is often called the golden period of pregnancy.',
    'image': 'assets/articles/trimester_1.png',
    'likes': '8k',
    'shares': '201',
    'comments': '3.1k',
    'author': 'Mummy Map Team',
    'updated': '5d ago',
    'isFeatured': false,
    'week': 'Week 14',
    'body': 'Full article content goes here...',
    'tags': ['Trimester'],
  },
];

final _categories = [
  'All',
  'Trimester',
  'Nutrition',
  'Exercise',
  'Mental Health',
];

class PregnancyLibrary extends ConsumerStatefulWidget {
  const PregnancyLibrary({super.key});

  @override
  ConsumerState<PregnancyLibrary> createState() => _PregnancyLibraryState();
}

class _PregnancyLibraryState extends ConsumerState<PregnancyLibrary> {
  String _selectedCategory = 'All';
  bool _isGridView = true;
  final _featuredController = PageController();
  int _featuredPage = 0;

  List<Map<String, dynamic>> get _filtered {
    if (_selectedCategory == 'All') return _articles;
    return _articles
        .where((a) => a['category'] == _selectedCategory)
        .toList();
  }

  List<Map<String, dynamic>> get _featured =>
      _articles.where((a) => a['isFeatured'] == true).toList();

  @override
  void dispose() {
    _featuredController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pregnancy = ref.watch(pregnancyProvider);

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
                    _buildCategoryFilter(),
                    const SizedBox(height: 16),
                    if (pregnancy != null) ...[
                      _buildTrimesterBanner(pregnancy),
                      const SizedBox(height: 20),
                    ],
                    if (_featured.isNotEmpty && _selectedCategory == 'All') ...[
                      _buildFeaturedCarousel(),
                      const SizedBox(height: 20),
                    ],
                    _isGridView
                        ? _buildGridArticles()
                        : _buildListArticles(),
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

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
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
                  color: isSelected ? Colors.white : const Color(0xFF1A1A1A),
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
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
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
              child: const Icon(
                Icons.arrow_forward,
                color: Color(0xFF3F2868),
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _featuredController,
            itemCount: _featured.length,
            onPageChanged: (i) => setState(() => _featuredPage = i),
            itemBuilder: (context, index) {
              final article = _featured[index];
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ArticleDetail(article: article),
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.auto_awesome,
                                  color: Color(0xFF3F2868), size: 14),
                              SizedBox(width: 4),
                              Text(
                                'Just for you',
                                style: TextStyle(
                                  color: Color(0xFF3F2868),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            article['week'] as String,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        article['title'] as String,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(Icons.bookmark_outline,
                              size: 18, color: Colors.grey.shade500),
                          const SizedBox(width: 16),
                          Icon(Icons.share_outlined,
                              size: 18, color: Colors.grey.shade500),
                          const SizedBox(width: 16),
                          Icon(Icons.favorite_outline,
                              size: 18, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            article['likes'] as String,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _featured.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _featuredPage == i ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _featuredPage == i
                    ? const Color(0xFF3F2868)
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGridArticles() {
    final articles = _filtered;
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

  Widget _buildListArticles() {
    final articles = _filtered;
    return Column(
      children: articles.map((a) => _ListArticleCard(article: a)).toList(),
    );
  }
}

class _GridArticleCard extends StatelessWidget {
  final Map<String, dynamic> article;

  const _GridArticleCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ArticleDetail(article: article),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                  article['category'] as String,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF3F2868),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              article['image'] as String,
              height: 110,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.image_outlined,
                    color: Colors.grey, size: 32),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            article['title'] as String,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            article['excerpt'] as String,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            children: [
              Icon(Icons.favorite_outline,
                  size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                article['likes'] as String,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
              const Spacer(),
              Icon(Icons.bookmark_outline,
                  size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 10),
              Icon(Icons.share_outlined,
                  size: 14, color: Colors.grey.shade500),
            ],
          ),
        ],
      ),
    );
  }
}

class _ListArticleCard extends StatelessWidget {
  final Map<String, dynamic> article;

  const _ListArticleCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ArticleDetail(article: article),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                    article['category'] as String,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF3F2868),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article['title'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        article['excerpt'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    article['image'] as String,
                    width: 90,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 90,
                      height: 80,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image_outlined,
                          color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.bookmark_outline,
                    size: 16, color: Colors.grey.shade500),
                const SizedBox(width: 16),
                Icon(Icons.share_outlined,
                    size: 16, color: Colors.grey.shade500),
                const SizedBox(width: 16),
                Icon(Icons.favorite_outline,
                    size: 16, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  article['likes'] as String,
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade500),
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
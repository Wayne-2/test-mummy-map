import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mummymap/data/models/article_model.dart';
import 'package:mummymap/presentation/providers/article_provider.dart';

class ArticleDetail extends ConsumerStatefulWidget {
  final Article article;

  const ArticleDetail({super.key, required this.article});

  @override
  ConsumerState<ArticleDetail> createState() => _ArticleDetailState();
}

class _ArticleDetailState extends ConsumerState<ArticleDetail> {
  late Article _article;
  bool _loadingBody = false;
  bool? _helpful;

  @override
  void initState() {
    super.initState();
    _article = widget.article;
    if (_article.body == null || _article.body!.isEmpty) {
      _fetchBody();
    }
  }

  Future<void> _fetchBody() async {
    setState(() => _loadingBody = true);
    try {
      final full = await ref
          .read(articleProvider.notifier)
          .fetchDetail(_article.slug ?? _article.id);
      if (mounted) setState(() => _article = full);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingBody = false);
    }
  }

  void _share() {
    final title = _article.title;
    Share.share('$title\n\nShared from MummyMap');
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isBookmarked =
        ref.watch(articleProvider).isBookmarked(_article.id);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Article',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => ref
                        .read(articleProvider.notifier)
                        .toggleBookmark(_article.id),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: const Color(0xFF3F2868), width: 2),
                      ),
                      child: Icon(
                        isBookmarked
                            ? Icons.bookmark
                            : Icons.bookmark_outline,
                        color: const Color(0xFF3F2868),
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _hero(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _categoryChip(),
                        const SizedBox(height: 14),
                        Text(
                          _article.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _authorRow(),
                        const SizedBox(height: 20),
                        if (_loadingBody)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: CircularProgressIndicator(
                                  color: Color(0xFF3F2868)),
                            ),
                          )
                        else if (_article.body != null &&
                            _article.body!.isNotEmpty)
                          HtmlWidget(
                            _article.body!,
                            textStyle: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF333333),
                              height: 1.7,
                            ),
                          )
                        else if (_article.excerpt != null)
                          Text(
                            _article.excerpt!,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF333333),
                              height: 1.7,
                            ),
                          ),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 16),
                        _helpfulRow(),
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: bottomPadding + 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _BottomAction(
                  icon: isBookmarked
                      ? Icons.bookmark
                      : Icons.bookmark_outline,
                  label: 'Save',
                  color: isBookmarked
                      ? const Color(0xFF3F2868)
                      : Colors.grey.shade700,
                  onTap: () => ref
                      .read(articleProvider.notifier)
                      .toggleBookmark(_article.id),
                ),
                _BottomAction(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  color: Colors.grey.shade700,
                  onTap: _share,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _hero() {
    final url = _article.thumbnail;
    Widget placeholder() => Container(
          height: 220,
          color: Colors.grey.shade200,
          child: const Center(
            child: Icon(Icons.image_outlined, color: Colors.grey, size: 48),
          ),
        );
    if (url == null || url.isEmpty) return placeholder();
    return Image.network(
      url,
      height: 220,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => placeholder(),
    );
  }

  Widget _categoryChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_offer_outlined,
              size: 12, color: Color(0xFF3F2868)),
          const SizedBox(width: 4),
          Text(
            _article.categoryDisplay,
            style: const TextStyle(fontSize: 12, color: Color(0xFF3F2868)),
          ),
        ],
      ),
    );
  }

  Widget _authorRow() {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFF3F2868),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text(
              'MM',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _article.author ?? 'Mummy Map Team',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(width: 4),
        const Icon(Icons.verified, color: Color(0xFF3F2868), size: 14),
        const Spacer(),
        if (_article.publishedLabel.isNotEmpty)
          Text(
            _article.publishedLabel,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
      ],
    );
  }

  Widget _helpfulRow() {
    return Row(
      children: [
        Text(
          'Was this article helpful?',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: () => setState(() => _helpful = true),
          child: Icon(
            Icons.thumb_up_outlined,
            color: _helpful == true
                ? const Color(0xFF3F2868)
                : Colors.grey.shade400,
            size: 22,
          ),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: () => setState(() => _helpful = false),
          child: Icon(
            Icons.thumb_down_outlined,
            color: _helpful == false ? Colors.red : Colors.grey.shade400,
            size: 22,
          ),
        ),
      ],
    );
  }
}

class _BottomAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _BottomAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
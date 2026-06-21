class ArticleCategories {
  ArticleCategories._();

  static const all = 'ALL';

  static const values = [
    'PREGNANCY',
    'NUTRITION',
    'MENTAL_HEALTH',
    'BABY_CARE',
    'FITNESS',
    'BREASTFEEDING',
    'PARENTING',
    'MEDICAL',
    'LIFESTYLE',
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

class Article {
  final String id;
  final String? slug;
  final String title;
  final String category;
  final String? thumbnail;
  final String? excerpt;
  final String? body;
  final String? author;
  final DateTime? publishedAt;
  final bool bookmarked;

  const Article({
    required this.id,
    this.slug,
    required this.title,
    required this.category,
    this.thumbnail,
    this.excerpt,
    this.body,
    this.author,
    this.publishedAt,
    this.bookmarked = false,
  });

  String get categoryDisplay => ArticleCategories.display(category);

  String get publishedLabel {
    if (publishedAt == null) return '';
    final diff = DateTime.now().difference(publishedAt!);
    if (diff.inDays >= 7) return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    return 'Just now';
  }

  factory Article.fromJson(Map<String, dynamic> json) {
    final root = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;

    DateTime? parseDate(dynamic v) =>
        (v is String && v.isNotEmpty) ? DateTime.tryParse(v) : null;

    String? pickString(List<String> keys) {
      for (final k in keys) {
        final v = root[k];
        if (v is String && v.isNotEmpty) return v;
      }
      return null;
    }

    return Article(
      id: (root['id'] ?? root['_id'] ?? '').toString(),
      slug: pickString(['slug']),
      title: pickString(['title', 'name']) ?? '',
      category: pickString(['category']) ?? 'OTHER',
      thumbnail: pickString(['thumbnail', 'image', 'coverImage', 'thumbnailUrl']),
      excerpt: pickString(['excerpt', 'summary', 'description']),
      body: pickString(['body', 'content', 'html', 'bodyHtml']),
      author: pickString(['author', 'authorName']) ??
          (root['author'] is Map ? root['author']['name'] as String? : null),
      publishedAt: parseDate(root['publishedAt'] ?? root['createdAt']),
      bookmarked: root['bookmarked'] as bool? ??
          root['isBookmarked'] as bool? ??
          false,
    );
  }

  Article copyWith({String? body, bool? bookmarked}) {
    return Article(
      id: id,
      slug: slug,
      title: title,
      category: category,
      thumbnail: thumbnail,
      excerpt: excerpt,
      body: body ?? this.body,
      author: author,
      publishedAt: publishedAt,
      bookmarked: bookmarked ?? this.bookmarked,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'title': title,
      'category': category,
      'thumbnail': thumbnail,
      'excerpt': excerpt,
      'body': body,
      'author': author,
      'publishedAt': publishedAt?.toIso8601String(),
      'bookmarked': bookmarked,
    };
  }
}
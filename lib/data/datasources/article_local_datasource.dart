import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mummymap/data/models/article_model.dart';

class ArticleLocalDatasource {
  static const _boxName = 'articles_box';
  static const _articlesKey = 'cached_articles';
  static const _bookmarksKey = 'cached_bookmarks';

  Box<String> get _box => Hive.box<String>(_boxName);

  Future<List<Article>> getArticles(String userId) async {
    final json = _box.get('${_articlesKey}_$userId');
    if (json == null) return [];
    try {
      final decoded = jsonDecode(json) as List;
      return decoded.map((e) => Article.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveArticles(String userId, List<Article> articles) async {
    await _box.put('${_articlesKey}_$userId', jsonEncode(articles.map((e) => e.toJson()).toList()));
  }

  Future<Set<String>> getBookmarkedIds(String userId) async {
    final json = _box.get('${_bookmarksKey}_$userId');
    if (json == null) return {};
    try {
      final decoded = jsonDecode(json) as List;
      return Set<String>.from(decoded);
    } catch (_) {
      return {};
    }
  }

  Future<void> saveBookmarkedIds(String userId, Set<String> ids) async {
    await _box.put('${_bookmarksKey}_$userId', jsonEncode(ids.toList()));
  }
}

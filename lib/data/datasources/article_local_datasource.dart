import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mummymap/data/models/article_model.dart';

class ArticleLocalDatasource {
  static const _boxName = 'articles_box';
  static const _articlesKey = 'cached_articles';
  static const _bookmarksKey = 'cached_bookmarks';

  Box<String> get _box => Hive.box<String>(_boxName);

  Future<List<Article>> getArticles() async {
    final json = _box.get(_articlesKey);
    if (json == null) return [];
    try {
      final decoded = jsonDecode(json) as List;
      return decoded.map((e) => Article.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveArticles(List<Article> articles) async {
    await _box.put(_articlesKey, jsonEncode(articles.map((e) => e.toJson()).toList()));
  }

  Future<Set<String>> getBookmarkedIds() async {
    final json = _box.get(_bookmarksKey);
    if (json == null) return {};
    try {
      final decoded = jsonDecode(json) as List;
      return Set<String>.from(decoded);
    } catch (_) {
      return {};
    }
  }

  Future<void> saveBookmarkedIds(Set<String> ids) async {
    await _box.put(_bookmarksKey, jsonEncode(ids.toList()));
  }
}

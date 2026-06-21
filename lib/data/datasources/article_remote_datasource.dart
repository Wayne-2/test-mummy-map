import 'package:dio/dio.dart';
import 'package:mummymap/data/models/article_model.dart';

class ArticleRemoteDatasource {
  final Dio dio;

  ArticleRemoteDatasource(this.dio);

  Future<List<Article>> getArticles({
    String? category,
    int page = 1,
    int limit = 20,
  }) async {
    final query = <String, dynamic>{'page': page, 'limit': limit};
    if (category != null && category != ArticleCategories.all) {
      query['category'] = category;
    }
    final res = await dio.get('/api/v1/articles', queryParameters: query);
    return _extractList(res.data)
        .map((e) => Article.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Article> getArticleDetail(String idOrSlug) async {
    final res = await dio.get('/api/v1/articles/$idOrSlug');
    return Article.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<Article>> getBookmarks({int page = 1, int limit = 20}) async {
    final res = await dio.get(
      '/api/v1/articles/bookmarks',
      queryParameters: {'page': page, 'limit': limit},
    );
    return _extractList(res.data)
        .map((e) => Article.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<bool> toggleBookmark(String id) async {
    final res = await dio.post('/api/v1/articles/$id/bookmark');
    final data = res.data;
    if (data is Map && data['bookmarked'] is bool) {
      return data['bookmarked'] as bool;
    }
    return false;
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      if (data['data'] is List) return data['data'] as List;
      if (data['articles'] is List) return data['articles'] as List;
      if (data['items'] is List) return data['items'] as List;
      if (data['results'] is List) return data['results'] as List;
    }
    return const [];
  }
}
import 'package:mummymap/data/datasources/article_local_datasource.dart';
import 'package:mummymap/data/datasources/article_remote_datasource.dart';
import 'package:mummymap/data/models/article_model.dart';

class ArticleRepository {
  final ArticleLocalDatasource localDatasource;
  final ArticleRemoteDatasource remoteDatasource;
  final String userId;

  ArticleRepository(this.localDatasource, this.remoteDatasource, this.userId);

  Future<List<Article>> getArticles({String? category, int page = 1}) async {
    try {
      final articles = await remoteDatasource.getArticles(category: category, page: page);
      if (category == null && page == 1) {
        await localDatasource.saveArticles(userId, articles);
      }
      return articles;
    } catch (_) {
      if (category == null && page == 1) {
        return localDatasource.getArticles(userId);
      }
      rethrow;
    }
  }

  Future<List<Article>> getLocalArticles() => localDatasource.getArticles(userId);
  Future<Set<String>> getLocalBookmarks() => localDatasource.getBookmarkedIds(userId);
  Future<void> saveLocalBookmarks(Set<String> ids) => localDatasource.saveBookmarkedIds(userId, ids);

  Future<Article> getArticleDetail(String idOrSlug) {
    return remoteDatasource.getArticleDetail(idOrSlug);
  }

  Future<List<Article>> getBookmarks({int page = 1}) {
    return remoteDatasource.getBookmarks(page: page);
  }

  Future<bool> toggleBookmark(String id) {
    return remoteDatasource.toggleBookmark(id);
  }
}
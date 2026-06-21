import 'package:mummymap/data/datasources/article_local_datasource.dart';
import 'package:mummymap/data/datasources/article_remote_datasource.dart';
import 'package:mummymap/data/models/article_model.dart';

class ArticleRepository {
  final ArticleLocalDatasource localDatasource;
  final ArticleRemoteDatasource remoteDatasource;

  ArticleRepository(this.localDatasource, this.remoteDatasource);

  Future<List<Article>> getArticles({String? category, int page = 1}) async {
    try {
      final articles = await remoteDatasource.getArticles(category: category, page: page);
      if (category == null && page == 1) {
        await localDatasource.saveArticles(articles);
      }
      return articles;
    } catch (_) {
      if (category == null && page == 1) {
        return localDatasource.getArticles();
      }
      rethrow;
    }
  }

  Future<List<Article>> getLocalArticles() => localDatasource.getArticles();
  Future<Set<String>> getLocalBookmarks() => localDatasource.getBookmarkedIds();
  Future<void> saveLocalBookmarks(Set<String> ids) => localDatasource.saveBookmarkedIds(ids);

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
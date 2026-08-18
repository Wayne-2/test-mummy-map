import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mummymap/data/datasources/article_remote_datasource.dart';
import 'package:mummymap/data/models/article_model.dart';
import 'package:mummymap/domain/repositories/article_repository.dart';
import 'package:mummymap/presentation/providers/auth_provider.dart';
import 'package:mummymap/presentation/providers/profile_provider.dart';

import 'package:mummymap/data/datasources/article_local_datasource.dart';

final articleLocalDatasourceProvider = Provider<ArticleLocalDatasource>((ref) {
  return ArticleLocalDatasource();
});

final articleDatasourceProvider = Provider<ArticleRemoteDatasource>((ref) {
  return ArticleRemoteDatasource(ref.read(dioProvider));
});

final articleRepositoryProvider = Provider<ArticleRepository>((ref) {
  final profile = ref.watch(profileProvider).value;
  final userId = profile?.userId ?? '';
  return ArticleRepository(
    ref.read(articleLocalDatasourceProvider),
    ref.read(articleDatasourceProvider),
    userId,
  );
});

class ArticleState {
  final List<Article> articles;
  final List<String> categories;
  final String selectedCategory;
  final Set<String> bookmarkedIds;
  final bool isLoading;
  final String? errorMessage;

  const ArticleState({
    this.articles = const [],
    this.categories = ArticleCategories.withAll,
    this.selectedCategory = ArticleCategories.all,
    this.bookmarkedIds = const {},
    this.isLoading = false,
    this.errorMessage,
  });

  bool isBookmarked(String id) => bookmarkedIds.contains(id);

  ArticleState copyWith({
    List<Article>? articles,
    String? selectedCategory,
    Set<String>? bookmarkedIds,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ArticleState(
      articles: articles ?? this.articles,
      categories: categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      bookmarkedIds: bookmarkedIds ?? this.bookmarkedIds,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class ArticleNotifier extends StateNotifier<ArticleState> {
  final ArticleRepository _repository;

  ArticleNotifier(this._repository) : super(const ArticleState()) {
    load();
  }

  Future<void> load() async {
    // 1. Instantly load local data
    try {
      final localArticles = await _repository.getLocalArticles();
      final localBookmarks = await _repository.getLocalBookmarks();
      state = state.copyWith(
        articles: localArticles,
        bookmarkedIds: localBookmarks,
      );
    } catch (_) {}

    // 2. Fetch remote data in background
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final category = state.selectedCategory == ArticleCategories.all
          ? null
          : state.selectedCategory;
      final articles = await _repository.getArticles(category: category);
      final bookmarked = {
        ...state.bookmarkedIds,
        ...articles.where((a) => a.bookmarked).map((a) => a.id),
      };
      state = state.copyWith(
        articles: articles,
        bookmarkedIds: bookmarked,
        isLoading: false,
      );
      // Ensure bookmarks are locally cached
      await _repository.saveLocalBookmarks(bookmarked);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Showing offline articles.',
      );
    }
  }

  Future<void> selectCategory(String category) async {
    if (category == state.selectedCategory) return;
    state = state.copyWith(selectedCategory: category);
    await load();
  }

  Future<void> toggleBookmark(String id) async {
    final wasBookmarked = state.isBookmarked(id);
    final optimistic = Set<String>.from(state.bookmarkedIds);
    if (wasBookmarked) {
      optimistic.remove(id);
    } else {
      optimistic.add(id);
    }
    state = state.copyWith(bookmarkedIds: optimistic);

    try {
      final nowBookmarked = await _repository.toggleBookmark(id);
      final confirmed = Set<String>.from(state.bookmarkedIds);
      if (nowBookmarked) {
        confirmed.add(id);
      } else {
        confirmed.remove(id);
      }
      state = state.copyWith(bookmarkedIds: confirmed);
      await _repository.saveLocalBookmarks(confirmed);
    } catch (_) {
      final reverted = Set<String>.from(state.bookmarkedIds);
      if (wasBookmarked) {
        reverted.add(id);
      } else {
        reverted.remove(id);
      }
      state = state.copyWith(
        bookmarkedIds: reverted,
        errorMessage: 'Could not update bookmark.',
      );
    }
  }

  Future<Article> fetchDetail(String idOrSlug) {
    return _repository.getArticleDetail(idOrSlug);
  }

  Future<List<Article>> fetchBookmarks() {
    return _repository.getBookmarks();
  }
}

final articleProvider =
    StateNotifierProvider<ArticleNotifier, ArticleState>(
  (ref) => ArticleNotifier(ref.read(articleRepositoryProvider)),
);
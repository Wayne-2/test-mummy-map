import 'package:dio/dio.dart';

class GroupRemoteDatasource {
  final Dio dio;

  GroupRemoteDatasource(this.dio);

  Future<List<Map<String, dynamic>>> getGroups({
    String? search,
    List<String>? tags,
    int page = 1,
    int limit = 20,
  }) async {
    final res = await dio.get(
      '/api/v1/groups',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (tags != null && tags.isNotEmpty) 'tags': tags,
        'page': page,
        'limit': limit,
      },
    );
    return _listFrom(res.data);
  }

  Future<Map<String, dynamic>> createGroup({
    required String name,
    required List<String> tags,
    required bool isPublic,
    String? imageUrl,
  }) async {
    final res = await dio.post(
      '/api/v1/groups',
      data: {
        'name': name,
        'tags': tags,
        'type': isPublic ? 'PUBLIC' : 'PRIVATE',
        if (imageUrl != null && imageUrl.isNotEmpty) 'imageUrl': imageUrl,
      },
    );
    return _mapFrom(res.data);
  }

  Future<void> joinGroup(String groupId) async {
    await dio.post('/api/v1/groups/$groupId/join');
  }

  Future<void> leaveGroup(String groupId) async {
    await dio.post('/api/v1/groups/$groupId/leave');
  }

  Future<List<Map<String, dynamic>>> getGroupPosts(
    String groupId, {
    String sortBy = 'latest',
    int page = 1,
    int limit = 20,
  }) async {
    final res = await dio.get(
      '/api/v1/posts/group/$groupId',
      queryParameters: {
        'sortBy': sortBy,
        'page': page,
        'limit': limit,
      },
    );
    return _listFrom(res.data);
  }

  Future<Map<String, dynamic>> createPost({
    required String groupId,
    required String title,
    required String body,
    List<String> mediaUrls = const [],
  }) async {
    final res = await dio.post(
      '/api/v1/posts',
      data: {
        'groupId': groupId,
        'title': title,
        'body': body,
        if (mediaUrls.isNotEmpty) 'mediaUrls': mediaUrls,
      },
    );
    return _mapFrom(res.data);
  }

  Future<void> deletePost(String postId) async {
    await dio.delete('/api/v1/posts/$postId');
  }

  Future<Map<String, dynamic>> addComment({
    required String postId,
    required String body,
  }) async {
    final res = await dio.post(
      '/api/v1/posts/$postId/comments',
      data: {'body': body},
    );
    return _mapFrom(res.data);
  }

  Future<void> deleteComment(String commentId) async {
    await dio.delete('/api/v1/posts/comments/$commentId');
  }

  Future<void> likePost(String postId) async {
    await dio.post('/api/v1/posts/$postId/like');
  }

  Future<void> unlikePost(String postId) async {
    await dio.delete('/api/v1/posts/$postId/like');
  }

  List<Map<String, dynamic>> _listFrom(dynamic responseData) {
    final unwrapped = _unwrap(responseData);
    if (unwrapped is List) {
      return unwrapped.whereType<Map<String, dynamic>>().toList();
    }
    if (unwrapped is Map<String, dynamic>) {
      final inner = unwrapped['data'] ?? unwrapped['items'];
      if (inner is List) {
        return inner.whereType<Map<String, dynamic>>().toList();
      }
    }
    return const [];
  }

  Map<String, dynamic> _mapFrom(dynamic responseData) {
    final unwrapped = _unwrap(responseData);
    if (unwrapped is Map<String, dynamic>) return unwrapped;
    return const {};
  }

  dynamic _unwrap(dynamic responseData) {
    if (responseData is Map<String, dynamic> &&
        responseData['data'] != null &&
        responseData.containsKey('success')) {
      return responseData['data'];
    }
    return responseData;
  }
}
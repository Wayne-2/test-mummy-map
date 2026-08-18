import 'package:mummymap/data/datasources/group_remote_datasource.dart';
import 'package:mummymap/data/datasources/group_local_datasource.dart';
import 'package:mummymap/data/models/group_model.dart';

class GroupRepository {
  final GroupRemoteDatasource datasource;
  final GroupLocalDatasource localDatasource;
  final String userId;

  GroupRepository(this.datasource, this.localDatasource, this.userId);

  Future<List<CommunityGroup>> getLocalGroups({
    required String currentUserId,
  }) async {
    final raw = await localDatasource.getLocalGroups(userId);
    if (raw == null) return [];
    return raw
        .map((e) => CommunityGroup.fromJson(e, currentUserId: currentUserId))
        .toList();
  }

  Future<List<CommunityGroup>> getGroups({
    required String currentUserId,
    String? search,
    List<String>? tags,
    int page = 1,
    int limit = 20,
  }) async {
    final raw = await datasource.getGroups(
      search: search,
      tags: tags,
      page: page,
      limit: limit,
    );
    if (page == 1 && search == null && tags == null) {
      await localDatasource.saveGroups(userId, raw);
    }
    return raw
        .map((e) => CommunityGroup.fromJson(e, currentUserId: currentUserId))
        .toList();
  }

  Future<CommunityGroup> createGroup({
    required String currentUserId,
    required String name,
    required List<String> tags,
    required bool isPublic,
    String? imageUrl,
  }) async {
    final raw = await datasource.createGroup(
      name: name,
      tags: tags,
      isPublic: isPublic,
      imageUrl: imageUrl,
    );
    return CommunityGroup.fromJson(raw, currentUserId: currentUserId);
  }

  Future<void> joinGroup(String groupId) => datasource.joinGroup(groupId);

  Future<void> leaveGroup(String groupId) => datasource.leaveGroup(groupId);

  Future<List<GroupPost>> getLocalGroupPosts({
    required String groupId,
    required String groupName,
    required int groupColor,
    required String groupInitials,
  }) async {
    final raw = await localDatasource.getLocalGroupPosts(userId, groupId);
    if (raw == null) return [];
    return raw
        .map((e) => GroupPost.fromJson(
              e,
              fallbackGroupId: groupId,
              groupName: groupName,
              groupColor: groupColor,
              groupInitials: groupInitials,
            ))
        .toList();
  }

  Future<List<GroupPost>> getGroupPosts({
    required String groupId,
    required String groupName,
    required int groupColor,
    required String groupInitials,
    String sortBy = 'latest',
    int page = 1,
    int limit = 20,
  }) async {
    final raw = await datasource.getGroupPosts(
      groupId,
      sortBy: sortBy,
      page: page,
      limit: limit,
    );
    if (page == 1 && sortBy == 'latest') {
      await localDatasource.saveGroupPosts(userId, groupId, raw);
    }
    return raw
        .map((e) => GroupPost.fromJson(
              e,
              fallbackGroupId: groupId,
              groupName: groupName,
              groupColor: groupColor,
              groupInitials: groupInitials,
            ))
        .toList();
  }

  Future<GroupPost> createPost({
    required String groupId,
    required String groupName,
    required int groupColor,
    required String groupInitials,
    required String title,
    required String body,
  }) async {
    final raw = await datasource.createPost(
      groupId: groupId,
      title: title,
      body: body,
    );
    return GroupPost.fromJson(
      raw,
      fallbackGroupId: groupId,
      groupName: groupName,
      groupColor: groupColor,
      groupInitials: groupInitials,
    );
  }

  Future<void> deletePost(String postId) => datasource.deletePost(postId);

  Future<PostReply> addComment({
    required String postId,
    required String body,
  }) async {
    final raw = await datasource.addComment(postId: postId, body: body);
    return PostReply.fromJson(raw);
  }

  Future<void> deleteComment(String commentId) {
    return datasource.deleteComment(commentId);
  }

  Future<void> likePost(String postId) => datasource.likePost(postId);

  Future<void> unlikePost(String postId) => datasource.unlikePost(postId);

  Future<void> invalidateGroupsCache() => localDatasource.clearGroups(userId);

  Future<void> invalidateGroupPostsCache(String groupId) =>
      localDatasource.clearGroupPosts(userId, groupId);

  Future<void> saveBookmarks(List<String> bookmarks) => localDatasource.saveBookmarks(userId, bookmarks);

  Future<List<String>> getBookmarks() => localDatasource.getBookmarks(userId);
}

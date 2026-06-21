import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mummymap/data/datasources/group_remote_datasource.dart';
import 'package:mummymap/data/datasources/group_local_datasource.dart';
import 'package:mummymap/data/models/group_model.dart';
import 'package:mummymap/domain/repositories/group_repository.dart';
import 'package:mummymap/presentation/providers/auth_provider.dart';
import 'package:mummymap/presentation/providers/profile_provider.dart';

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  return GroupRepository(
    GroupRemoteDatasource(ref.read(dioProvider)),
    GroupLocalDatasource(),
  );
});

class GroupsState {
  final List<CommunityGroup> groups;
  final List<GroupPost> posts;
  final List<String> globalBookmarks;
  final bool isLoading;
  final bool isSubmitting;
  final int page;
  final bool hasMore;
  final String? errorMessage;

  const GroupsState({
    this.groups = const [],
    this.posts = const [],
    this.globalBookmarks = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.page = 1,
    this.hasMore = true,
    this.errorMessage,
  });

  List<CommunityGroup> get joinedGroups =>
      groups.where((g) => g.joined).toList();

  List<CommunityGroup> get unjoinedGroups =>
      groups.where((g) => !g.joined).toList();

  List<GroupPost> get forYouPosts {
    final joinedIds = joinedGroups.map((g) => g.id).toSet();
    return posts.where((p) => joinedIds.contains(p.groupId)).toList();
  }

  List<GroupPost> postsForGroup(String groupId) =>
      posts.where((p) => p.groupId == groupId).toList();

  bool isBookmarked(String postId) => globalBookmarks.contains(postId);

  GroupsState copyWith({
    List<CommunityGroup>? groups,
    List<GroupPost>? posts,
    List<String>? globalBookmarks,
    bool? isLoading,
    bool? isSubmitting,
    int? page,
    bool? hasMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return GroupsState(
      groups: groups ?? this.groups,
      posts: posts ?? this.posts,
      globalBookmarks: globalBookmarks ?? this.globalBookmarks,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class GroupsNotifier extends StateNotifier<GroupsState> {
  final GroupRepository _repository;
  final String _currentUserId;
  final String _currentUserName;

  GroupsNotifier(
    this._repository, {
    required String currentUserId,
    required String currentUserName,
  })  : _currentUserId = currentUserId,
        _currentUserName = currentUserName,
        super(const GroupsState());

  Future<void> loadGroups() async {
    if (state.groups.isEmpty) {
      state = state.copyWith(isLoading: true, clearError: true);
      try {
        final localGroups = await _repository.getLocalGroups(currentUserId: _currentUserId);
        if (localGroups.isNotEmpty) {
          state = state.copyWith(groups: localGroups, isLoading: false);
        }
      } catch (_) {}
    } else {
      state = state.copyWith(isLoading: true, clearError: true);
    }

    try {
      final remoteGroups = await _repository.getGroups(currentUserId: _currentUserId);
      state = state.copyWith(groups: remoteGroups, isLoading: false);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: state.groups.isEmpty ? 'Failed to load your groups. Please check your connection.' : null,
      );
    }
  }

  Future<bool> createGroup({
    required String name,
    required List<String> tags,
    required bool isPublic,
    String? imageUrl,
  }) async {
    if (state.isSubmitting) return false;
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final group = await _repository.createGroup(
        currentUserId: _currentUserId,
        name: name,
        tags: tags,
        isPublic: isPublic,
        imageUrl: imageUrl,
      );
      final created = group.copyWith(joined: true, isOwner: true);
      state = state.copyWith(
        groups: [created, ...state.groups],
        isSubmitting: false,
      );
      return true;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Could not create the group. The name may be taken.',
      );
      return false;
    }
  }

  Future<void> joinGroup(String groupId) async {
    final previous = state.groups;
    state = state.copyWith(
      groups: state.groups.map((g) {
        if (g.id != groupId) return g;
        final current = int.tryParse(g.members) ?? 0;
        return g.copyWith(joined: true, members: '${current + 1}');
      }).toList(),
    );
    try {
      await _repository.joinGroup(groupId);
    } on DioException catch (e) {
      if (e.response?.statusCode != 400 && e.response?.statusCode != 409) {
        state = state.copyWith(groups: previous);
      }
    } catch (_) {
      state = state.copyWith(groups: previous);
    }
  }

  Future<void> leaveGroup(String groupId) async {
    final previous = state.groups;
    state = state.copyWith(
      groups: state.groups.map((g) {
        if (g.id != groupId) return g;
        final current = int.tryParse(g.members) ?? 1;
        return g.copyWith(
          joined: false,
          members: '${current > 0 ? current - 1 : 0}',
        );
      }).toList(),
    );
    try {
      await _repository.leaveGroup(groupId);
    } catch (_) {
      state = state.copyWith(groups: previous);
    }
  }

  Future<void> loadPostsForGroup(String groupId) async {
    final group = state.groups.where((g) => g.id == groupId).toList();
    if (group.isEmpty) return;
    final g = group.first;
    
    state = state.copyWith(isLoading: true, clearError: true, page: 1, hasMore: true);

    try {
      final localPosts = await _repository.getLocalGroupPosts(
        groupId: groupId,
        groupName: g.name,
        groupColor: g.avatarColor,
        groupInitials: g.initials,
      );
      if (localPosts.isNotEmpty) {
        final others = state.posts.where((p) => p.groupId != groupId).toList();
        state = state.copyWith(posts: [...localPosts, ...others], isLoading: false);
      }
    } catch (_) {}

    try {
      final posts = await _repository.getGroupPosts(
        groupId: groupId,
        groupName: g.name,
        groupColor: g.avatarColor,
        groupInitials: g.initials,
        page: 1,
      );
      final others = state.posts.where((p) => p.groupId != groupId).toList();
      state = state.copyWith(
        posts: [...posts, ...others],
        hasMore: posts.length == 20,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: state.posts.isEmpty ? 'Failed to load posts. Please try again.' : null,
      );
    }
  }

  Future<void> loadMorePostsForGroup(String groupId) async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true, clearError: true);

    final groupMatch = state.groups.where((g) => g.id == groupId).toList();
    if (groupMatch.isEmpty) {
      state = state.copyWith(isLoading: false);
      return;
    }
    final g = groupMatch.first;
    final nextPage = state.page + 1;

    try {
      final newPosts = await _repository.getGroupPosts(
        groupId: groupId,
        groupName: g.name,
        groupColor: g.avatarColor,
        groupInitials: g.initials,
        page: nextPage,
      );
      
      final currentGroupPosts = state.posts.where((p) => p.groupId == groupId).toList();
      final otherPosts = state.posts.where((p) => p.groupId != groupId).toList();
      
      state = state.copyWith(
        posts: [...currentGroupPosts, ...newPosts, ...otherPosts],
        page: nextPage,
        hasMore: newPosts.length == 20,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> addPost({
    required String groupId,
    required String title,
    required String body,
    List<PollOption> pollOptions = const [],
  }) async {
    if (state.isSubmitting) return false;
    final groupMatch = state.groups.where((g) => g.id == groupId).toList();
    if (groupMatch.isEmpty) return false;
    final g = groupMatch.first;

    // Fake poll creation for UI only (if pollOptions is not empty)
    if (pollOptions.isNotEmpty) {
      final localPost = GroupPost(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        groupId: groupId,
        groupInitials: g.initials,
        groupColor: g.avatarColor,
        author: _currentUserName,
        group: g.name,
        createdAt: DateTime.now(),
        title: title,
        body: '',
        likes: 0,
        type: 'poll',
        pollOptions: pollOptions,
      );
      state = state.copyWith(posts: [localPost, ...state.posts]);
      return true;
    }

    state = state.copyWith(isSubmitting: true);
    try {
      final post = await _repository.createPost(
        groupId: groupId,
        groupName: g.name,
        groupColor: g.avatarColor,
        groupInitials: g.initials,
        title: title,
        body: body,
      );
      final withAuthor = post.author == 'Member'
          ? GroupPost(
              id: post.id,
              groupId: post.groupId,
              groupInitials: post.groupInitials,
              groupColor: post.groupColor,
              author: _currentUserName,
              group: post.group,
              createdAt: post.createdAt,
              title: post.title,
              body: post.body,
              likes: post.likes,
              type: post.type,
              likedBy: post.likedBy,
              postReplies: post.postReplies,
            )
          : post;
      state = state.copyWith(
        posts: [withAuthor, ...state.posts],
        isSubmitting: false,
      );
      return true;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Could not publish your post. Please try again.',
      );
      return false;
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      state = state.copyWith(
        posts: state.posts.where((p) => p.id != postId).toList(),
      );
      await _repository.deletePost(postId);
    } catch (_) {
      state = state.copyWith(errorMessage: 'Failed to delete post.');
    }
  }

  Future<void> deleteComment(String postId, String commentId) async {
    try {
      state = state.copyWith(
        posts: state.posts.map((p) {
          if (p.id != postId) return p;
          return p.copyWith(
            postReplies: p.postReplies.where((r) => r.id != commentId).toList(),
          );
        }).toList(),
      );
      await _repository.deleteComment(commentId);
    } catch (_) {
      state = state.copyWith(errorMessage: 'Failed to delete comment.');
    }
  }

  Future<void> toggleLike(String postId) async {
    final target = state.posts.where((p) => p.id == postId).toList();
    if (target.isEmpty) return;
    final post = target.first;
    final alreadyLiked = post.likedBy.contains(_currentUserId);

    state = state.copyWith(
      posts: state.posts.map((p) {
        if (p.id != postId) return p;
        final updatedLikedBy = alreadyLiked
            ? p.likedBy.where((id) => id != _currentUserId).toList()
            : [...p.likedBy, _currentUserId];
        return p.copyWith(
          likes: alreadyLiked ? p.likes - 1 : p.likes + 1,
          likedBy: updatedLikedBy,
        );
      }).toList(),
    );

    try {
      if (alreadyLiked) {
        await _repository.unlikePost(postId);
      } else {
        await _repository.likePost(postId);
      }
    } catch (_) {
      state = state.copyWith(
        posts: state.posts.map((p) {
          if (p.id != postId) return p;
          final revertedLikedBy = alreadyLiked
              ? [...p.likedBy, _currentUserId]
              : p.likedBy.where((id) => id != _currentUserId).toList();
          return p.copyWith(
            likes: alreadyLiked ? p.likes + 1 : p.likes - 1,
            likedBy: revertedLikedBy,
          );
        }).toList(),
      );
    }
  }

  Future<void> addReply(String postId, String body) async {
    if (state.isSubmitting) return;
    final trimmed = body.trim();
    if (trimmed.isEmpty) return;
    
    state = state.copyWith(isSubmitting: true);
    try {
      final reply = await _repository.addComment(postId: postId, body: trimmed);
      final named = reply.author == 'Member'
          ? PostReply(
              id: reply.id,
              author: _currentUserName,
              initials: reply.initials,
              avatarColor: reply.avatarColor,
              createdAt: reply.createdAt,
              body: reply.body,
            )
          : reply;
      state = state.copyWith(
        isSubmitting: false,
        posts: state.posts.map((p) {
          if (p.id != postId) return p;
          return p.copyWith(postReplies: [...p.postReplies, named]);
        }).toList(),
      );
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Could not send your reply. Please try again.',
      );
    }
  }

  void toggleLikeReply(String postId, String replyId) {
    state = state.copyWith(
      posts: state.posts.map((p) {
        if (p.id != postId) return p;
        final updatedReplies = p.postReplies.map((r) {
          if (r.id != replyId) return r;
          final alreadyLiked = r.likedBy.contains(_currentUserId);
          final updatedLikedBy = alreadyLiked
              ? r.likedBy.where((id) => id != _currentUserId).toList()
              : [...r.likedBy, _currentUserId];
          return r.copyWith(likedBy: updatedLikedBy);
        }).toList();
        return p.copyWith(postReplies: updatedReplies);
      }).toList(),
    );
  }

  void toggleBookmark(String postId) {
    final bookmarks = List<String>.from(state.globalBookmarks);
    if (bookmarks.contains(postId)) {
      bookmarks.remove(postId);
    } else {
      bookmarks.add(postId);
    }
    state = state.copyWith(globalBookmarks: bookmarks);
  }

  void voteOnPoll(String postId, int optionIndex) {
    state = state.copyWith(
      posts: state.posts.map((p) {
        if (p.id != postId) return p;
        final alreadyVoted = p.pollOptions.any((o) => o.selected);
        if (alreadyVoted) return p;
        final updatedOptions = p.pollOptions.asMap().entries.map((e) {
          if (e.key == optionIndex) {
            return e.value.copyWith(votes: e.value.votes + 1, selected: true);
          }
          return e.value;
        }).toList();
        return p.copyWith(pollOptions: updatedOptions);
      }).toList(),
    );
  }

  bool isLikedByMe(GroupPost post) => post.likedBy.contains(_currentUserId);

  bool isReplyLikedByMe(PostReply reply) =>
      reply.likedBy.contains(_currentUserId);

  bool isMyPost(GroupPost post) => post.author == _currentUserName;
  
  bool isMyReply(PostReply reply) => reply.author == _currentUserName;

  void clearError() => state = state.copyWith(clearError: true);
}

final groupsProvider =
    StateNotifierProvider<GroupsNotifier, GroupsState>((ref) {
  final profile = ref.watch(profileProvider).value;
  final userId = profile?.userId ?? '';
  final name = [profile?.firstName, profile?.lastName]
      .where((s) => s != null && s.trim().isNotEmpty)
      .join(' ')
      .trim();
  return GroupsNotifier(
    ref.read(groupRepositoryProvider),
    currentUserId: userId,
    currentUserName: name.isNotEmpty ? name : 'You',
  );
});
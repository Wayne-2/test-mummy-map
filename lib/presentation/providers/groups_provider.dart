import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mummymap/data/datasources/group_remote_datasource.dart';
import 'package:mummymap/data/datasources/group_local_datasource.dart';
import 'package:mummymap/data/models/group_model.dart';
import 'package:mummymap/domain/repositories/group_repository.dart';
import 'package:mummymap/presentation/providers/auth_provider.dart';
import 'package:mummymap/presentation/providers/profile_provider.dart';

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  final profile = ref.watch(profileProvider).value;
  final userId = profile?.userId ?? profile?.id ?? '';
  return GroupRepository(
    GroupRemoteDatasource(ref.read(dioProvider)),
    GroupLocalDatasource(),
    userId,
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
  Future<void>? _groupsLoadInFlight;

  GroupsNotifier(
    this._repository, {
    required String currentUserId,
    required String currentUserName,
  })  : _currentUserId = currentUserId,
        _currentUserName = currentUserName,
        super(const GroupsState());

  Future<void> loadGroups() {
    final inFlight = _groupsLoadInFlight;
    if (inFlight != null) return inFlight;
    final load = _loadGroups();
    _groupsLoadInFlight = load;
    return load.whenComplete(() => _groupsLoadInFlight = null);
  }

  Future<void> _loadGroups() async {
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
      final mergedGroups = remoteGroups.map((rg) {
        final localGroupsMatch = state.groups.where((lg) => lg.id == rg.id);
        if (localGroupsMatch.isNotEmpty) {
          final local = localGroupsMatch.first;
          return rg.copyWith(
            joined: rg.joined || local.joined,
            isOwner: rg.isOwner || local.isOwner,
          );
        }
        return rg;
      }).toList();
      state = state.copyWith(groups: mergedGroups, isLoading: false);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: state.groups.isEmpty ? 'Failed to load your groups. Please check your connection.' : null,
      );
    }

    try {
      final bookmarks = await _repository.getBookmarks();
      state = state.copyWith(globalBookmarks: bookmarks);
    } catch (_) {}
  }

  Future<void> loadForYouFeed() async {
    if (state.groups.isEmpty) {
      await loadGroups();
    }
    final joined = state.joinedGroups;
    if (joined.isEmpty) return;
    for (final group in joined) {
      await loadPostsForGroup(group.id);
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
      await _invalidateGroupsCache();
      return true;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Could not create the group. The name may be taken.',
      );
      return false;
    }
  }

  Future<bool> joinGroup(String groupId) async {
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
      await _invalidateGroupsCache();
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        return true;
      }
      state = state.copyWith(groups: previous);
      return false;
    } catch (_) {
      state = state.copyWith(groups: previous);
      return false;
    }
  }

  Future<bool> leaveGroup(String groupId) async {
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
      await _invalidateGroupsCache();
      return true;
    } catch (_) {
      state = state.copyWith(groups: previous);
      return false;
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
      final remotePosts = await _repository.getGroupPosts(
        groupId: groupId,
        groupName: g.name,
        groupColor: g.avatarColor,
        groupInitials: g.initials,
        page: 1,
      );

      final mergedPosts = remotePosts.map((rp) {
        final localMatch = state.posts.where((lp) => lp.id == rp.id).toList();
        if (localMatch.isNotEmpty) {
          final local = localMatch.first;
          final alreadyLikedLocally = local.likedBy.contains(_currentUserId);
          final likedRemotely = rp.likedBy.contains(_currentUserId);

          if (alreadyLikedLocally && !likedRemotely) {
             return rp.copyWith(likedBy: [...rp.likedBy, _currentUserId]);
          }
        }
        return rp;
      }).toList();

      final others = state.posts.where((p) => p.groupId != groupId).toList();
      state = state.copyWith(
        posts: [...mergedPosts, ...others],
        hasMore: mergedPosts.length == 20,
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
      final remoteNewPosts = await _repository.getGroupPosts(
        groupId: groupId,
        groupName: g.name,
        groupColor: g.avatarColor,
        groupInitials: g.initials,
        page: nextPage,
      );

      final newPosts = remoteNewPosts.map((rp) {
        final localMatch = state.posts.where((lp) => lp.id == rp.id).toList();
        if (localMatch.isNotEmpty) {
          final local = localMatch.first;
          final alreadyLikedLocally = local.likedBy.contains(_currentUserId);
          final likedRemotely = rp.likedBy.contains(_currentUserId);

          if (alreadyLikedLocally && !likedRemotely) {
             return rp.copyWith(likedBy: [...rp.likedBy, _currentUserId]);
          }
        }
        return rp;
      }).toList();

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

    // The server does not expose a poll creation contract. Never create a
    // local-only post that would vanish after a refresh.
    if (pollOptions.isNotEmpty) {
      state = state.copyWith(
        errorMessage: 'Polls are not available yet.',
      );
      return false;
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
              authorId: _currentUserId,
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
      await _invalidateGroupPostsCache(groupId);
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
    final previous = state.posts;
    final groupId = _groupIdForPost(postId, previous);
    try {
      state = state.copyWith(
        posts: state.posts.where((p) => p.id != postId).toList(),
      );
      await _repository.deletePost(postId);
      if (groupId != null) {
        await _invalidateGroupPostsCache(groupId);
      }
    } catch (_) {
      state = state.copyWith(
        posts: previous,
        errorMessage: 'Failed to delete post.',
      );
    }
  }

  Future<void> deleteComment(String postId, String commentId) async {
    final previous = state.posts;
    final groupId = _groupIdForPost(postId, previous);
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
      if (groupId != null) {
        await _invalidateGroupPostsCache(groupId);
      }
    } catch (_) {
      state = state.copyWith(
        posts: previous,
        errorMessage: 'Failed to delete comment.',
      );
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
      await _invalidateGroupPostsCache(post.groupId);
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
      final groupId = _groupIdForPost(postId, state.posts);
      if (groupId != null) {
        await _invalidateGroupPostsCache(groupId);
      }
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
              authorId: _currentUserId,
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
      final groupId = _groupIdForPost(postId, state.posts);
      if (groupId != null) {
        await _invalidateGroupPostsCache(groupId);
      }
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Could not send your reply. Please try again.',
      );
    }
  }

  void toggleBookmark(String postId) {
    final bookmarks = List<String>.from(state.globalBookmarks);
    if (bookmarks.contains(postId)) {
      bookmarks.remove(postId);
    } else {
      bookmarks.add(postId);
    }
    state = state.copyWith(globalBookmarks: bookmarks);
    _repository.saveBookmarks(bookmarks);
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

  Future<void> _invalidateGroupsCache() async {
    try {
      await _repository.invalidateGroupsCache();
    } catch (_) {}
  }

  Future<void> _invalidateGroupPostsCache(String groupId) async {
    try {
      await _repository.invalidateGroupPostsCache(groupId);
    } catch (_) {}
  }

  String? _groupIdForPost(String postId, List<GroupPost> posts) {
    for (final post in posts) {
      if (post.id == postId) return post.groupId;
    }
    return null;
  }

  bool isLikedByMe(GroupPost post) => post.likedBy.contains(_currentUserId);

  bool isReplyLikedByMe(PostReply reply) =>
      reply.likedBy.contains(_currentUserId);

  bool isMyPost(GroupPost post) =>
      _currentUserId.isNotEmpty && post.authorId == _currentUserId;
  
  bool isMyReply(PostReply reply) =>
      _currentUserId.isNotEmpty && reply.authorId == _currentUserId;

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

import 'package:flutter_riverpod/flutter_riverpod.dart';

class PollOption {
  final String text;
  final int votes;
  final bool selected;

  const PollOption({
    required this.text,
    required this.votes,
    this.selected = false,
  });

  PollOption copyWith({int? votes, bool? selected}) {
    return PollOption(
      text: text,
      votes: votes ?? this.votes,
      selected: selected ?? this.selected,
    );
  }
}

class PostReply {
  final String id;
  final String author;
  final String initials;
  final int avatarColor;
  final DateTime createdAt;
  final String body;
  final List<String> likedBy;

  const PostReply({
    required this.id,
    required this.author,
    required this.initials,
    required this.avatarColor,
    required this.createdAt,
    required this.body,
    this.likedBy = const [],
  });

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  PostReply copyWith({List<String>? likedBy}) {
    return PostReply(
      id: id,
      author: author,
      initials: initials,
      avatarColor: avatarColor,
      createdAt: createdAt,
      body: body,
      likedBy: likedBy ?? this.likedBy,
    );
  }
}

class GroupPost {
  final String id;
  final String groupId;
  final String groupInitials;
  final int groupColor;
  final String author;
  final String group;
  final DateTime createdAt;
  final String title;
  final String body;
  final int likes;
  final String type;
  final List<PollOption> pollOptions;
  final List<String> likedBy;
  final List<PostReply> postReplies;

  const GroupPost({
    required this.id,
    required this.groupId,
    required this.groupInitials,
    required this.groupColor,
    required this.author,
    required this.group,
    required this.createdAt,
    required this.title,
    required this.body,
    required this.likes,
    required this.type,
    this.pollOptions = const [],
    this.likedBy = const [],
    this.postReplies = const [],
  });

  bool get isLikedByMe => likedBy.contains('me');

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  GroupPost copyWith({
    int? likes,
    List<PollOption>? pollOptions,
    List<String>? likedBy,
    List<PostReply>? postReplies,
  }) {
    return GroupPost(
      id: id,
      groupId: groupId,
      groupInitials: groupInitials,
      groupColor: groupColor,
      author: author,
      group: group,
      createdAt: createdAt,
      title: title,
      body: body,
      likes: likes ?? this.likes,
      type: type,
      pollOptions: pollOptions ?? this.pollOptions,
      likedBy: likedBy ?? this.likedBy,
      postReplies: postReplies ?? this.postReplies,
    );
  }
}

class CommunityGroup {
  final String id;
  final String name;
  final String description;
  final String members;
  final String createdAt;
  final bool isPublic;
  final int avatarColor;
  final bool joined;
  final bool isOwner;
  final List<String> bookmarkedPostIds;

  const CommunityGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.members,
    required this.createdAt,
    required this.isPublic,
    required this.avatarColor,
    this.joined = false,
    this.isOwner = false,
    this.bookmarkedPostIds = const [],
  });

  String get initials => name.length >= 2
      ? name.substring(0, 2).toUpperCase()
      : name.toUpperCase();

  CommunityGroup copyWith({
    bool? joined,
    bool? isOwner,
    String? members,
    List<String>? bookmarkedPostIds,
  }) {
    return CommunityGroup(
      id: id,
      name: name,
      description: description,
      members: members ?? this.members,
      createdAt: createdAt,
      isPublic: isPublic,
      avatarColor: avatarColor,
      joined: joined ?? this.joined,
      isOwner: isOwner ?? this.isOwner,
      bookmarkedPostIds: bookmarkedPostIds ?? this.bookmarkedPostIds,
    );
  }
}

class GroupsState {
  final List<CommunityGroup> groups;
  final List<GroupPost> posts;
  final List<String> globalBookmarks;

  const GroupsState({
    required this.groups,
    required this.posts,
    this.globalBookmarks = const [],
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
  }) {
    return GroupsState(
      groups: groups ?? this.groups,
      posts: posts ?? this.posts,
      globalBookmarks: globalBookmarks ?? this.globalBookmarks,
    );
  }
}

class GroupsNotifier extends StateNotifier<GroupsState> {
  GroupsNotifier() : super(const GroupsState(groups: [], posts: []));

  void createGroup({
    required String name,
    required String description,
    required bool isPublic,
    required int avatarColor,
  }) {
    final group = CommunityGroup(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      members: '1',
      createdAt: 'Just now',
      isPublic: isPublic,
      avatarColor: avatarColor,
      joined: true,
      isOwner: true,
    );
    state = state.copyWith(groups: [...state.groups, group]);
  }

  void joinGroup(String groupId) {
    state = state.copyWith(
      groups: state.groups.map((g) {
        if (g.id != groupId) return g;
        final current = int.tryParse(g.members) ?? 1;
        return g.copyWith(joined: true, members: '${current + 1}');
      }).toList(),
    );
  }

  void leaveGroup(String groupId) {
    state = state.copyWith(
      groups: state.groups
          .map((g) => g.id == groupId ? g.copyWith(joined: false) : g)
          .toList(),
    );
  }

  void addPost(GroupPost post) {
    state = state.copyWith(posts: [post, ...state.posts]);
  }

  void toggleLike(String postId) {
    state = state.copyWith(
      posts: state.posts.map((p) {
        if (p.id != postId) return p;
        final alreadyLiked = p.likedBy.contains('me');
        final updatedLikedBy = alreadyLiked
            ? p.likedBy.where((id) => id != 'me').toList()
            : [...p.likedBy, 'me'];
        return p.copyWith(
          likes: alreadyLiked ? p.likes - 1 : p.likes + 1,
          likedBy: updatedLikedBy,
        );
      }).toList(),
    );
  }

  void toggleLikeReply(String postId, String replyId) {
    state = state.copyWith(
      posts: state.posts.map((p) {
        if (p.id != postId) return p;
        final updatedReplies = p.postReplies.map((r) {
          if (r.id != replyId) return r;
          final alreadyLiked = r.likedBy.contains('me');
          final updatedLikedBy = alreadyLiked
              ? r.likedBy.where((id) => id != 'me').toList()
              : [...r.likedBy, 'me'];
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

  void addReply(String postId, String body) {
    final reply = PostReply(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      author: 'You',
      initials: 'ME',
      avatarColor: 0xFF3F2868,
      createdAt: DateTime.now(),
      body: body,
    );
    state = state.copyWith(
      posts: state.posts.map((p) {
        if (p.id != postId) return p;
        return p.copyWith(postReplies: [...p.postReplies, reply]);
      }).toList(),
    );
  }

  void voteOnPoll(String postId, int optionIndex) {
    state = state.copyWith(
      posts: state.posts.map((p) {
        if (p.id != postId) return p;
        final alreadyVoted = p.pollOptions.any((o) => o.selected);
        if (alreadyVoted) return p;
        final updatedOptions = p.pollOptions.asMap().entries.map((e) {
          if (e.key == optionIndex) {
            return e.value.copyWith(
              votes: e.value.votes + 1,
              selected: true,
            );
          }
          return e.value;
        }).toList();
        return p.copyWith(pollOptions: updatedOptions);
      }).toList(),
    );
  }
}

final groupsProvider =
    StateNotifierProvider<GroupsNotifier, GroupsState>(
  (_) => GroupsNotifier(),
);
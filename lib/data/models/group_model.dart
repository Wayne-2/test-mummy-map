const List<int> _kAvatarPalette = [
  0xFF3F2868,
  0xFFE57373,
  0xFF4FC3F7,
  0xFF81C784,
  0xFFFFB74D,
  0xFFBA68C8,
  0xFF4DD0E1,
  0xFFFF8A65,
];

int _colorFromId(String id) {
  if (id.isEmpty) return _kAvatarPalette.first;
  final hash = id.codeUnits.fold<int>(0, (sum, c) => sum + c);
  return _kAvatarPalette[hash % _kAvatarPalette.length];
}

String _initialsFrom(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return '?';
  final parts = trimmed.split(RegExp(r'\s+'));
  if (parts.length >= 2) {
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
  return trimmed.length >= 2
      ? trimmed.substring(0, 2).toUpperCase()
      : trimmed.toUpperCase();
}

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

  String get timeAgo => _timeAgo(createdAt);

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

  factory PostReply.fromJson(Map<String, dynamic> json) {
    final author = _stringOr(
      json,
      const ['authorName', 'author', 'username', 'userName'],
      'Member',
    );
    final id = _stringOr(json, const ['id', '_id', 'commentId'], '');
    return PostReply(
      id: id,
      author: author,
      initials: _initialsFrom(author),
      avatarColor: _colorFromId(id.isNotEmpty ? id : author),
      createdAt: _dateOr(json, const ['createdAt', 'date', 'created_at']),
      body: _stringOr(json, const ['body', 'text', 'content'], ''),
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

  bool isLikedBy(String userId) => likedBy.contains(userId);

  String get timeAgo => _timeAgo(createdAt);

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

  factory GroupPost.fromJson(
    Map<String, dynamic> json, {
    required String fallbackGroupId,
    required String groupName,
    required int groupColor,
    required String groupInitials,
  }) {
    final id = _stringOr(json, const ['id', '_id', 'postId'], '');
    final author = _stringOr(
      json,
      const ['authorName', 'author', 'username', 'userName'],
      'Member',
    );
    final likedByRaw = json['likedBy'];
    final likedBy = likedByRaw is List
        ? likedByRaw.map((e) => e.toString()).toList()
        : <String>[];
    final likeCount = _intOr(
      json,
      const ['likes', 'likeCount', 'likesCount'],
      likedBy.length,
    );
    final repliesRaw = json['comments'] ?? json['replies'];
    final replies = repliesRaw is List
        ? repliesRaw
            .whereType<Map<String, dynamic>>()
            .map(PostReply.fromJson)
            .toList()
        : <PostReply>[];

    return GroupPost(
      id: id,
      groupId: _stringOr(
          json, const ['groupId', 'group_id'], fallbackGroupId),
      groupInitials: groupInitials,
      groupColor: groupColor,
      author: author,
      group: groupName,
      createdAt: _dateOr(json, const ['createdAt', 'created_at', 'date']),
      title: _stringOr(json, const ['title'], ''),
      body: _stringOr(json, const ['body', 'content'], ''),
      likes: likeCount,
      type: 'text',
      likedBy: likedBy,
      postReplies: replies,
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
  final String? imageUrl;
  final List<String> tags;
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
    this.imageUrl,
    this.tags = const [],
    this.joined = false,
    this.isOwner = false,
    this.bookmarkedPostIds = const [],
  });

  String get initials => _initialsFrom(name);

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
      imageUrl: imageUrl,
      tags: tags,
      joined: joined ?? this.joined,
      isOwner: isOwner ?? this.isOwner,
      bookmarkedPostIds: bookmarkedPostIds ?? this.bookmarkedPostIds,
    );
  }

  factory CommunityGroup.fromJson(
    Map<String, dynamic> json, {
    required String currentUserId,
  }) {
    final id = _stringOr(json, const ['id', '_id', 'groupId'], '');
    final typeRaw =
        _stringOr(json, const ['type', 'visibility'], 'PUBLIC').toUpperCase();
    final tagsRaw = json['tags'];
    final tags = tagsRaw is List
        ? tagsRaw.map((e) => e.toString()).toList()
        : <String>[];
    final ownerId = _stringOr(
      json,
      const ['ownerId', 'createdBy', 'adminId', 'creatorId'],
      '',
    );
    
    final membersRaw = json['members'];
    bool isMemberInList = false;
    int memberCount = 0;
    
    if (membersRaw is List) {
      memberCount = membersRaw.length;
      isMemberInList = membersRaw.any((e) => e.toString() == currentUserId);
    } else {
      memberCount = _intOr(
        json,
        const ['memberCount', 'membersCount', 'members', 'totalMembers'],
        0,
      );
    }

    final isMember = _boolOr(
      json,
      const ['isMember', 'joined', 'hasJoined'],
      isMemberInList,
    );
    final isOwner = ownerId.isNotEmpty && ownerId == currentUserId;

    return CommunityGroup(
      id: id,
      name: _stringOr(json, const ['name', 'title'], 'Group'),
      description:
          _stringOr(json, const ['description', 'about', 'bio'], ''),
      members: memberCount.toString(),
      createdAt: _relativeCreatedAt(json),
      isPublic: typeRaw != 'PRIVATE',
      avatarColor: _colorFromId(id),
      imageUrl:
          _nullableString(json, const ['imageUrl', 'image', 'photoUrl']),
      tags: tags,
      joined: isMember || isOwner,
      isOwner: isOwner,
    );
  }
}

String _stringOr(
    Map<String, dynamic> json, List<String> keys, String fallback) {
  for (final k in keys) {
    final v = json[k];
    if (v is String && v.isNotEmpty) return v;
  }
  return fallback;
}

String? _nullableString(Map<String, dynamic> json, List<String> keys) {
  for (final k in keys) {
    final v = json[k];
    if (v is String && v.isNotEmpty) return v;
  }
  return null;
}

int _intOr(Map<String, dynamic> json, List<String> keys, int fallback) {
  for (final k in keys) {
    final v = json[k];
    if (v is num) return v.toInt();
  }
  return fallback;
}

bool _boolOr(Map<String, dynamic> json, List<String> keys, bool fallback) {
  for (final k in keys) {
    final v = json[k];
    if (v is bool) return v;
  }
  return fallback;
}

DateTime _dateOr(Map<String, dynamic> json, List<String> keys) {
  for (final k in keys) {
    final v = json[k];
    if (v is String && v.isNotEmpty) {
      final parsed = DateTime.tryParse(v);
      if (parsed != null) return parsed;
    }
  }
  return DateTime.now();
}

String _relativeCreatedAt(Map<String, dynamic> json) {
  for (final k in const ['createdAt', 'created_at']) {
    final v = json[k];
    if (v is String && v.isNotEmpty) {
      final parsed = DateTime.tryParse(v);
      if (parsed != null) return _timeAgo(parsed);
    }
  }
  return 'Recently';
}

String _timeAgo(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inSeconds < 60) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}
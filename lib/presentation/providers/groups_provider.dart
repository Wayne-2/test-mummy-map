import 'package:flutter_riverpod/flutter_riverpod.dart';

class GroupPost {
  final String id;
  final String groupId;
  final String groupInitials;
  final int groupColor;
  final String author;
  final String group;
  final String time;
  final String title;
  final String body;
  int likes;
  final int replies;
  final String type;
  final List<PollOption> pollOptions;

  GroupPost({
    required this.id,
    required this.groupId,
    required this.groupInitials,
    required this.groupColor,
    required this.author,
    required this.group,
    required this.time,
    required this.title,
    required this.body,
    required this.likes,
    required this.replies,
    required this.type,
    this.pollOptions = const [],
  });

  GroupPost copyWith({int? likes, List<PollOption>? pollOptions}) {
    return GroupPost(
      id: id,
      groupId: groupId,
      groupInitials: groupInitials,
      groupColor: groupColor,
      author: author,
      group: group,
      time: time,
      title: title,
      body: body,
      likes: likes ?? this.likes,
      replies: replies,
      type: type,
      pollOptions: pollOptions ?? this.pollOptions,
    );
  }
}

class PollOption {
  final String text;
  final int votes;
  final bool selected;

  PollOption({
    required this.text,
    required this.votes,
    this.selected = false,
  });

  int get percent {
    return votes;
  }

  PollOption copyWith({int? votes, bool? selected}) {
    return PollOption(
      text: text,
      votes: votes ?? this.votes,
      selected: selected ?? this.selected,
    );
  }
}

class CommunityGroup {
  final String id;
  final String name;
  final String members;
  final String created;
  final String latestPost;
  final String lastMessage;
  final String time;
  final int unread;
  bool joined;

  CommunityGroup({
    required this.id,
    required this.name,
    required this.members,
    required this.created,
    required this.latestPost,
    required this.lastMessage,
    required this.time,
    required this.unread,
    this.joined = false,
  });

  CommunityGroup copyWith({bool? joined}) {
    return CommunityGroup(
      id: id,
      name: name,
      members: members,
      created: created,
      latestPost: latestPost,
      lastMessage: lastMessage,
      time: time,
      unread: unread,
      joined: joined ?? this.joined,
    );
  }
}

class GroupsState {
  final List<CommunityGroup> groups;
  final List<GroupPost> posts;

  const GroupsState({
    required this.groups,
    required this.posts,
  });

  List<CommunityGroup> get joinedGroups =>
      groups.where((g) => g.joined).toList();

  List<GroupPost> get forYouPosts {
    final joinedIds = joinedGroups.map((g) => g.id).toSet();
    return posts.where((p) => joinedIds.contains(p.groupId)).toList();
  }

  GroupsState copyWith({
    List<CommunityGroup>? groups,
    List<GroupPost>? posts,
  }) {
    return GroupsState(
      groups: groups ?? this.groups,
      posts: posts ?? this.posts,
    );
  }
}

class GroupsNotifier extends StateNotifier<GroupsState> {
  GroupsNotifier()
      : super(GroupsState(
          groups: _initialGroups,
          posts: _initialPosts,
        ));

  void joinGroup(String groupId) {
    state = state.copyWith(
      groups: state.groups
          .map((g) => g.id == groupId ? g.copyWith(joined: true) : g)
          .toList(),
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

  void likePost(String postId) {
    state = state.copyWith(
      posts: state.posts.map((p) {
        if (p.id == postId) return p.copyWith(likes: p.likes + 1);
        return p;
      }).toList(),
    );
  }

  void voteOnPoll(String postId, int optionIndex) {
    state = state.copyWith(
      posts: state.posts.map((p) {
        if (p.id != postId) return p;
        final updatedOptions = p.pollOptions.asMap().entries.map((e) {
          if (e.key == optionIndex) {
            return e.value.copyWith(
              votes: e.value.votes + 10,
              selected: true,
            );
          }
          return e.value.copyWith(selected: false);
        }).toList();
        return p.copyWith(pollOptions: updatedOptions);
      }).toList(),
    );
  }

  static final _initialGroups = [
    CommunityGroup(
      id: '1',
      name: 'Sporty Moms',
      members: '127K',
      created: '12 months',
      latestPost: 'Daily Breast Feeding...',
      lastMessage: 'Daniela: Birth Pills (Good Or Bad)',
      time: '4:35 AM',
      unread: 17,
    ),
    CommunityGroup(
      id: '2',
      name: 'November Mommies 2025',
      members: '23.1K',
      created: '6 months',
      latestPost: 'What trimester are you in?',
      lastMessage: 'Stephanie: Intestinal digestion a major s...',
      time: '4:35 AM',
      unread: 0,
    ),
    CommunityGroup(
      id: '3',
      name: 'Socially Awkward Moms',
      members: '11.9K',
      created: '8 months',
      latestPost: 'Any tips for social anxiety?',
      lastMessage: 'Stephanie: Intestinal digestion a major s...',
      time: '4:35 AM',
      unread: 0,
    ),
    CommunityGroup(
      id: '4',
      name: 'BOY Moms',
      members: '5.6K',
      created: '10 months',
      latestPost: 'Self care routines?',
      lastMessage: 'Daniela: Birth Pills (Good Or Bad)',
      time: '4:35 AM',
      unread: 17,
    ),
  ];

  static final _initialPosts = [
    GroupPost(
      id: '1',
      groupId: '1',
      groupInitials: 'SM',
      groupColor: 0xFFE57373,
      author: 'Joyce',
      group: 'Sporty Moms',
      time: '12 Mins',
      title: 'Daily Breast Feeding',
      body:
          'We\'ve just started a breast feeding exercise for my 4 month old who was showing the signs she was ready for food. It\'s day 4 of giving her some food to try but she\'s seemed not very interested in it.',
      likes: 12,
      replies: 178,
      type: 'text',
    ),
    GroupPost(
      id: '2',
      groupId: '4',
      groupInitials: 'BM',
      groupColor: 0xFF4FC3F7,
      author: 'Sharon',
      group: 'BOY Moms',
      time: '12 Mins',
      title: 'What self-care routine do I start in 2nd Trimester?',
      body: '',
      likes: 12,
      replies: 178,
      type: 'poll',
      pollOptions: [
        PollOption(text: 'Gentle prenatal yoga', votes: 10),
        PollOption(text: 'Daily hydration and balanced meals', votes: 35),
        PollOption(text: 'Regular rest and short naps', votes: 80),
      ],
    ),
  ];
}

final groupsProvider =
    StateNotifierProvider<GroupsNotifier, GroupsState>(
  (_) => GroupsNotifier(),
);
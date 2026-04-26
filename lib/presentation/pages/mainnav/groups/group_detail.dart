import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mummymap/presentation/providers/groups_provider.dart';
import 'package:mummymap/presentation/pages/mainnav/groups/community_rules.dart';
import 'package:mummymap/presentation/pages/mainnav/groups/widgets/post_card.dart';
import 'package:mummymap/presentation/pages/mainnav/groups/create_post.dart';

class GroupDetail extends ConsumerWidget {
  final String groupId;

  const GroupDetail({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(groupsProvider);
    final group = state.groups.firstWhere((g) => g.id == groupId);
    final posts = state.postsForGroup(groupId);

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: group.joined
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF3F2868),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => CreatePost(groupId: groupId)),
              ),
              child: const Icon(Icons.edit, color: Colors.white),
            )
          : null,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _GroupHeader(
              group: group,
              onJoin: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CommunityRules(
                    onAccept: () {
                      ref
                          .read(groupsProvider.notifier)
                          .joinGroup(groupId);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('You joined ${group.name}!'),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ),
              ),
              onOptions: () =>
                  _showGroupOptions(context, ref, group),
            ),
          ),
          if (!group.joined)
            const SliverFillRemaining(
              child: _NotJoinedState(),
            )
          else ...[
            SliverToBoxAdapter(
              child: _TopContributors(),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Feed',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A))),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Text('All Posts',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF1A1A1A))),
                          const SizedBox(width: 4),
                          Icon(Icons.keyboard_arrow_down,
                              size: 16,
                              color: Colors.grey.shade500),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (posts.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.article_outlined,
                          size: 48, color: Color(0xFFBDBDBD)),
                      SizedBox(height: 16),
                      Text('No posts yet',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A))),
                      SizedBox(height: 8),
                      Text('Be the first to post!',
                          style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF9E9E9E))),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Column(
                    children: [
                      PostCard(post: posts[index]),
                      Divider(
                          height: 1,
                          color: Colors.grey.shade100),
                    ],
                  ),
                  childCount: posts.length,
                ),
              ),
          ],
        ],
      ),
    );
  }

  void _showGroupOptions(
      BuildContext context, WidgetRef ref, CommunityGroup group) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share group'),
              onTap: () => Navigator.pop(context),
            ),
            if (group.joined && !group.isOwner)
              ListTile(
                leading: const Icon(Icons.exit_to_app,
                    color: Colors.red),
                title: const Text('Leave group',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  ref
                      .read(groupsProvider.notifier)
                      .leaveGroup(group.id);
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            if (group.isOwner)
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Group settings'),
                onTap: () => Navigator.pop(context),
              ),
            ListTile(
              leading: const Icon(Icons.flag_outlined,
                  color: Colors.red),
              title: const Text('Report group',
                  style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  final CommunityGroup group;
  final VoidCallback onJoin;
  final VoidCallback onOptions;

  const _GroupHeader({
    required this.group,
    required this.onJoin,
    required this.onOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(group.avatarColor),
            Color(group.avatarColor).withOpacity(0.75),
          ],
        ),
      ),
      child: Stack(
        children: [
          // GROUP BACKGROUND IMAGE — replace 'assets/groups/group_bg_placeholder.png'
          // with your actual background image asset per group
          Positioned.fill(
            child: Image.asset(
              'assets/groups/group_bg_placeholder.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox(),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              bottom: 20,
              left: 16,
              right: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Row(
                      children: [
                        Image.asset('assets/logo3.png',
                            height: 22, width: 22),
                        const SizedBox(width: 6),
                        const Text('Mummy Map',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert,
                          color: Colors.white),
                      onPressed: onOptions,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      group.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                    if (group.joined) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.verified,
                          color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      const Text('Member',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12)),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  group.description,
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.5),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                // MEMBER AVATARS ROW
                Row(
                  children: [
                    ...List.generate(
                      4,
                      (i) => Transform.translate(
                        offset: Offset(i * -8.0, 0),
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.white24,
                          child: const Icon(Icons.person,
                              color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('Kehinde & 23+ just joined...',
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.public,
                        color: Colors.white70, size: 14),
                    const SizedBox(width: 4),
                    Text(
                        group.isPublic
                            ? 'Public Group'
                            : 'Private Group',
                        style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12)),
                    const SizedBox(width: 16),
                    const Icon(Icons.group,
                        color: Colors.white70, size: 14),
                    const SizedBox(width: 4),
                    Text('${group.members} Members',
                        style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12)),
                    const SizedBox(width: 16),
                    const Icon(Icons.tag,
                        color: Colors.white70, size: 14),
                    const SizedBox(width: 4),
                    const Text('200 active today',
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 16),
                if (!group.joined)
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: onJoin,
                          child: Container(
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(21),
                            ),
                            child: const Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Text('Join',
                                    style: TextStyle(
                                        color:
                                            Color(0xFF3F2868),
                                        fontWeight:
                                            FontWeight.w600,
                                        fontSize: 15)),
                                SizedBox(width: 6),
                                Icon(Icons.add,
                                    color: Color(0xFF3F2868),
                                    size: 18),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _CircleBtn(
                          icon: Icons.notifications_outlined),
                      const SizedBox(width: 8),
                      _CircleBtn(
                          icon: Icons.keyboard_arrow_down),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: _OutlineBtn(
                          icon: Icons.event,
                          label: 'Event',
                          onTap: () =>
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Events coming soon'),
                              duration: Duration(seconds: 1),
                              behavior:
                                  SnackBarBehavior.floating,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _OutlineBtn(
                          icon: Icons.person_add_outlined,
                          label: 'Invite',
                          onTap: () =>
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Invite coming soon'),
                              duration: Duration(seconds: 1),
                              behavior:
                                  SnackBarBehavior.floating,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _CircleBtn(
                          icon: Icons.notifications_outlined),
                      const SizedBox(width: 8),
                      _CircleBtn(
                          icon: Icons.keyboard_arrow_down),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OutlineBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _OutlineBtn(
      {required this.icon,
      required this.label,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white54),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    color: Colors.white, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;

  const _CircleBtn({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white54),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }
}

class _TopContributors extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        gradient: const LinearGradient(
          colors: [Color(0xFFF3E8FF), Color(0xFFE8D5F5)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.star,
                  color: Color(0xFF3F2868), size: 16),
              SizedBox(width: 6),
              Text('Top Contributors',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3F2868),
                      fontSize: 14)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _ContributorItem(rank: '#1', name: 'Folake'),
              _ContributorItem(rank: '#2', name: 'Sharon'),
              _ContributorItem(rank: '#3', name: 'Karen'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContributorItem extends StatelessWidget {
  final String rank;
  final String name;

  const _ContributorItem(
      {required this.rank, required this.name});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // CONTRIBUTOR AVATAR — replace 'assets/avatars/avatar_placeholder.png'
        // with actual user avatar assets
        CircleAvatar(
          radius: 26,
          backgroundColor: const Color(0xFFE8D5F5),
          child: const Icon(Icons.person,
              color: Color(0xFF3F2868), size: 24),
        ),
        const SizedBox(height: 6),
        Text(rank,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3F2868))),
        Text(name,
            style: const TextStyle(
                fontSize: 12, color: Color(0xFF1A1A1A))),
      ],
    );
  }
}

class _NotJoinedState extends StatelessWidget {
  const _NotJoinedState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Join this community to see posts',
        style: TextStyle(
            fontSize: 14, color: Color(0xFF9E9E9E)),
      ),
    );
  }
}
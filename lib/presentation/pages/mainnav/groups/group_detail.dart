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
    final groupPosts =
        state.posts.where((p) => p.groupId == groupId).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _GroupHeader(
            group: group,
            onJoin: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CommunityRules(
                  onAccept: () {
                    ref.read(groupsProvider.notifier).joinGroup(groupId);
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: group.joined
                ? _GroupFeed(group: group, posts: groupPosts)
                : const _NotJoinedState(),
          ),
        ],
      ),
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
    );
  }
}

class _GroupHeader extends StatelessWidget {
  final CommunityGroup group;
  final VoidCallback onJoin;

  const _GroupHeader({required this.group, required this.onJoin});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3F2868), Color(0xFF6A3A9A)],
        ),
      ),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              Row(
                children: [
                  Image.asset('assets/logo3.png', height: 24, width: 24),
                  const SizedBox(width: 6),
                  const Text('Mummy Map',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 8),
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
                const Icon(Icons.verified, color: Colors.white70, size: 18),
                const SizedBox(width: 4),
                const Text('Member',
                    style:
                        TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'A vibrant space for active moms to connect, share fitness tips, postpartum workout routines, and cheer each other on through every stretch, squat, and stride of motherhood...',
            style: TextStyle(
                color: Colors.white70, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.public, color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              const Text('Public Group',
                  style:
                      TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(width: 16),
              const Icon(Icons.group, color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              Text('${group.members} Members',
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 12)),
              const SizedBox(width: 16),
              const Icon(Icons.tag, color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              const Text('200 active today',
                  style:
                      TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (!group.joined)
                Expanded(
                  child: GestureDetector(
                    onTap: onJoin,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Join',
                              style: TextStyle(
                                  color: Color(0xFF3F2868),
                                  fontWeight: FontWeight.w600)),
                          SizedBox(width: 4),
                          Icon(Icons.add,
                              color: Color(0xFF3F2868), size: 16),
                        ],
                      ),
                    ),
                  ),
                )
              else ...[
                Expanded(
                  child: _HeaderButton(
                      icon: Icons.event,
                      label: 'Event',
                      onTap: () {}),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _HeaderButton(
                      icon: Icons.person_add_outlined,
                      label: 'Invite',
                      onTap: () {}),
                ),
              ],
              const SizedBox(width: 8),
              _IconButton(icon: Icons.notifications_outlined),
              const SizedBox(width: 8),
              _IconButton(icon: Icons.keyboard_arrow_down),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HeaderButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white54),
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

class _IconButton extends StatelessWidget {
  final IconData icon;

  const _IconButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(icon, color: Colors.white, size: 18),
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
        style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
      ),
    );
  }
}

class _GroupFeed extends StatelessWidget {
  final CommunityGroup group;
  final List<GroupPost> posts;

  const _GroupFeed({required this.group, required this.posts});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.star, color: Color(0xFF3F2868), size: 16),
                  SizedBox(width: 6),
                  Text('Top Contributors',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A))),
                ],
              ),
              const SizedBox(height: 12),
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
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Text('All Posts',
                        style: TextStyle(
                            fontSize: 13, color: Color(0xFF1A1A1A))),
                    SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down,
                        size: 16, color: Color(0xFF9E9E9E)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: posts.isEmpty
              ? const Center(
                  child: Text('No posts yet. Be the first to post!',
                      style: TextStyle(
                          fontSize: 14, color: Color(0xFF9E9E9E))),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: posts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      PostCard(post: posts[index]),
                ),
        ),
      ],
    );
  }
}

class _ContributorItem extends StatelessWidget {
  final String rank;
  final String name;

  const _ContributorItem({required this.rank, required this.name});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 24,
          backgroundColor: Color(0xFFE8D5F5),
          child: Icon(Icons.person, color: Color(0xFF3F2868)),
        ),
        const SizedBox(height: 4),
        Text(rank,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3F2868))),
        Text(name,
            style: const TextStyle(
                fontSize: 12, color: Color(0xFF1A1A1A))),
      ],
    );
  }
}
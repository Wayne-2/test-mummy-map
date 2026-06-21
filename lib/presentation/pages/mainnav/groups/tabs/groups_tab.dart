import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mummymap/data/models/group_model.dart';
import 'package:mummymap/presentation/providers/groups_provider.dart';
import 'package:mummymap/presentation/pages/mainnav/groups/create_group.dart';
import 'package:mummymap/presentation/pages/mainnav/groups/group_detail.dart';

class GroupsTab extends ConsumerStatefulWidget {
  const GroupsTab({super.key});

  @override
  ConsumerState<GroupsTab> createState() => _GroupsTabState();
}

class _GroupsTabState extends ConsumerState<GroupsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(groupsProvider.notifier).loadGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(groupsProvider);
    final joinedGroups = state.joinedGroups;
    final unjoinedGroups = state.unjoinedGroups;

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateGroup()),
        ),
        backgroundColor: const Color(0xFF3F2868),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: joinedGroups.isEmpty
          ? _EmptyGroups(
              onCreateGroup: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const CreateGroup()),
              ),
            )
          : ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My Groups',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A)),
                      ),
                    ],
                  ),
                ),
                ...joinedGroups.map((group) => _GroupListItem(
                      group: group,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                GroupDetail(groupId: group.id)),
                      ),
                      onOptions: () => _showGroupOptions(
                          context, ref, group),
                    )),
                if (unjoinedGroups.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
                    child: Text(
                      'Similar Groups',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A)),
                    ),
                  ),
                  SizedBox(
                    height: 140,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16),
                      itemCount: unjoinedGroups.length,
                      itemBuilder: (context, index) {
                        final group = unjoinedGroups[index];
                        return _SimilarGroupCard(
                          group: group,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => GroupDetail(
                                    groupId: group.id)),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 80),
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
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('Mute notifications'),
              onTap: () => Navigator.pop(context),
            ),
            if (!group.isOwner)
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
                },
              ),
            if (group.isOwner)
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Group settings'),
                onTap: () => Navigator.pop(context),
              ),
          ],
        ),
      ),
    );
  }
}

class _GroupListItem extends StatelessWidget {
  final CommunityGroup group;
  final VoidCallback onTap;
  final VoidCallback onOptions;

  const _GroupListItem({
    required this.group,
    required this.onTap,
    required this.onOptions,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 10),
        child: Row(
          children: [
            
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                'assets/mum2.jpg',
                width: 54,
                height: 54,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Color(group.avatarColor),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      group.initials,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            group.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Color(0xFF1A1A1A)),
                          ),
                          if (group.isOwner) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8D5F5),
                                borderRadius:
                                    BorderRadius.circular(8),
                              ),
                              child: const Text('Admin',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF3F2868),
                                      fontWeight:
                                          FontWeight.w600)),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        group.createdAt,
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          group.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onOptions,
              child: Icon(Icons.more_vert,
                  color: Colors.grey.shade400, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class _SimilarGroupCard extends StatelessWidget {
  final CommunityGroup group;
  final VoidCallback onTap;

  const _SimilarGroupCard(
      {required this.group, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(13),
                topRight: Radius.circular(13),
              ),
              child: Image.asset(
                'assets/mum2.jpg',
                height: 70,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 70,
                  color: Color(group.avatarColor),
                  child: Center(
                    child: Text(group.initials,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20)),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(group.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color(0xFF1A1A1A))),
                  const SizedBox(height: 2),
                  Text('${group.members} Members',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyGroups extends StatelessWidget {
  final VoidCallback onCreateGroup;

  const _EmptyGroups({required this.onCreateGroup});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFE8D5F5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.group_outlined,
                  size: 40, color: Color(0xFF3F2868)),
            ),
            const SizedBox(height: 20),
            const Text('No groups yet',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A))),
            const SizedBox(height: 8),
            const Text(
              'Create a group or join existing communities to connect with other mums',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9E9E9E),
                  height: 1.5),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: onCreateGroup,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Create a Group',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F2868),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
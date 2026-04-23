import 'package:flutter/material.dart';
import 'package:mummymap/presentation/pages/mainnav/groups/group_detail.dart';

class GroupsTab extends StatelessWidget {
  const GroupsTab({super.key});

  // Empty for new users
  static const List<Map<String, dynamic>> _myGroups = [];

  @override
  Widget build(BuildContext context) {
    if (_myGroups.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.group_outlined, size: 60, color: Color(0xFFBDBDBD)),
              SizedBox(height: 16),
              Text(
                'No groups yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Join a community to connect with other mums on the same journey',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Groups',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.person_add_outlined,
                    color: Color(0xFF3F2868)),
                onPressed: () {},
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _myGroups.length,
            itemBuilder: (context, index) {
              final group = _myGroups[index];
              return _GroupListItem(
                group: group,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GroupDetail(group: group),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _GroupListItem extends StatelessWidget {
  final Map<String, dynamic> group;
  final VoidCallback onTap;

  const _GroupListItem({required this.group, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        radius: 26,
        backgroundColor: const Color(0xFFE8D5F5),
        child: Text(
          group['name'].toString().substring(0, 2),
          style: const TextStyle(
            color: Color(0xFF3F2868),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        group['name'],
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Color(0xFF1A1A1A),
        ),
      ),
      subtitle: Text(
        group['lastMessage'] ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            group['time'] ?? '',
            style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
          ),
          if ((group['unread'] ?? 0) > 0) ...[
            const SizedBox(height: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF3F2868),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${group['unread']}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
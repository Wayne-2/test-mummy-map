import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mummymap/presentation/providers/groups_provider.dart';
import 'package:mummymap/presentation/pages/mainnav/groups/post_detail.dart';
import 'package:mummymap/presentation/pages/mainnav/groups/create_post.dart';

class PostCard extends ConsumerWidget {
  final GroupPost post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final livePost = ref.watch(groupsProvider).posts.firstWhere(
          (p) => p.id == post.id,
          orElse: () => post,
        );

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PostDetail(post: livePost)),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(livePost.groupColor),
                  child: Text(
                    livePost.groupInitials,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: livePost.author,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            TextSpan(
                              text: ' in ${livePost.group}',
                              style: const TextStyle(
                                  fontSize: 13, color: Color(0xFF9E9E9E)),
                            ),
                          ],
                        ),
                      ),
                      Text(livePost.time,
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF9E9E9E))),
                    ],
                  ),
                ),
                const Icon(Icons.more_horiz, color: Color(0xFF9E9E9E)),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              livePost.title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A)),
            ),
            if (livePost.body.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                livePost.body,
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF555555), height: 1.5),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (livePost.type == 'poll') ...[
              const SizedBox(height: 12),
              _PollWidget(postId: livePost.id),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                GestureDetector(
                  onTap: () =>
                      ref.read(groupsProvider.notifier).likePost(livePost.id),
                  child: const Icon(Icons.favorite_outline,
                      size: 18, color: Color(0xFF9E9E9E)),
                ),
                const SizedBox(width: 4),
                Text('${livePost.likes}',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF9E9E9E))),
                const SizedBox(width: 16),
                const Icon(Icons.chat_bubble_outline,
                    size: 18, color: Color(0xFF9E9E9E)),
                const SizedBox(width: 4),
                Text('${livePost.replies}',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF9E9E9E))),
                const Spacer(),
                const Icon(Icons.share_outlined,
                    size: 18, color: Color(0xFF9E9E9E)),
              ],
            ),
            const Divider(height: 20),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => CreatePost(groupId: livePost.groupId)),
              ),
              child: Row(
                children: const [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: Color(0xFFE8D5F5),
                    child:
                        Icon(Icons.person, color: Color(0xFF3F2868), size: 14),
                  ),
                  SizedBox(width: 10),
                  Text('Add a reply...',
                      style:
                          TextStyle(fontSize: 13, color: Color(0xFFBDBDBD))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PollWidget extends ConsumerWidget {
  final String postId;

  const _PollWidget({required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(groupsProvider).posts;
    final post = posts.firstWhere((p) => p.id == postId);
    final totalVotes =
        post.pollOptions.fold(0, (sum, o) => sum + o.votes);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select one or more',
            style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
        const SizedBox(height: 8),
        ...post.pollOptions.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          final percent = totalVotes == 0
              ? 0
              : (option.votes / totalVotes * 100).round();

          return GestureDetector(
            onTap: () =>
                ref.read(groupsProvider.notifier).voteOnPoll(postId, index),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: option.selected
                      ? const Color(0xFF3F2868)
                      : const Color(0xFFE0E0E0),
                ),
              ),
              child: Stack(
                children: [
                  FractionallySizedBox(
                    widthFactor: percent / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF3F2868),
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          option.text,
                          style: TextStyle(
                            fontSize: 13,
                            color: percent > 20
                                ? Colors.white
                                : const Color(0xFF1A1A1A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          children: [
                            Text('$percent%',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: percent > 20
                                        ? Colors.white
                                        : const Color(0xFF1A1A1A))),
                            const SizedBox(width: 8),
                            Text('${option.votes} votes',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.white70)),
                            if (option.selected) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.check_circle,
                                  color: Colors.white, size: 16),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
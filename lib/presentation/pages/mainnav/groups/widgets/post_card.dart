import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mummymap/data/models/group_model.dart';
import 'package:mummymap/presentation/providers/groups_provider.dart';
import 'package:mummymap/presentation/pages/mainnav/groups/post_detail.dart';
import 'package:share_plus/share_plus.dart';

class PostCard extends ConsumerWidget {
  final GroupPost post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final livePost = ref.watch(groupsProvider).posts.firstWhere(
          (p) => p.id == post.id,
          orElse: () => post,
        );
    final isBookmarked =
        ref.watch(groupsProvider).isBookmarked(livePost.id);
    final isLikedByMe =
        ref.read(groupsProvider.notifier).isLikedByMe(livePost);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PostDetail(post: livePost)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(livePost.groupColor),
                  child: Text(livePost.groupInitials,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
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
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1A1A)),
                            ),
                            TextSpan(
                              text: ' in ${livePost.group}',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(livePost.timeAgo,
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade400)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _showPostOptions(context, ref, livePost),
                  child: Icon(Icons.more_horiz,
                      color: Colors.grey.shade400, size: 22),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              livePost.title,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A)),
            ),
            if (livePost.body.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                livePost.body,
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.5),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (livePost.type == 'poll') ...[
              const SizedBox(height: 12),
              _PollWidget(postId: livePost.id),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                GestureDetector(
                  onTap: () => ref
                      .read(groupsProvider.notifier)
                      .toggleLike(livePost.id),
                  child: Row(
                    children: [
                      Icon(
                        isLikedByMe
                            ? Icons.favorite
                            : Icons.favorite_outline,
                        size: 20,
                        color: isLikedByMe
                            ? Colors.red
                            : Colors.grey.shade500,
                      ),
                      const SizedBox(width: 5),
                      Text('${livePost.likes}',
                          style: TextStyle(
                              fontSize: 13,
                              color: isLikedByMe
                                  ? Colors.red
                                  : Colors.grey.shade500)),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => PostDetail(post: livePost)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.chat_bubble_outline,
                          size: 20, color: Colors.grey.shade500),
                      const SizedBox(width: 5),
                      Text('${livePost.postReplies.length}',
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500)),
                    ],
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => ref
                      .read(groupsProvider.notifier)
                      .toggleBookmark(livePost.id),
                  child: Icon(
                    isBookmarked
                        ? Icons.bookmark
                        : Icons.bookmark_outline,
                    size: 20,
                    color: isBookmarked
                        ? const Color(0xFF3F2868)
                        : Colors.grey.shade500,
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () => Share.share(
                    '${livePost.title}\n\n${livePost.body}'.trim(),
                  ),
                  child: Icon(Icons.share_outlined,
                      size: 20, color: Colors.grey.shade500),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => PostDetail(post: livePost)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 14,
                    backgroundColor: Color(0xFFE8D5F5),
                    child: Icon(Icons.person,
                        color: Color(0xFF3F2868), size: 14),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('Add a reply...',
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade400)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPostOptions(
      BuildContext context, WidgetRef ref, GroupPost post) {
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
              leading: const Icon(Icons.bookmark_outline),
              title: const Text('Save post'),
              onTap: () {
                ref
                    .read(groupsProvider.notifier)
                    .toggleBookmark(post.id);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share post'),
              onTap: () {
                Navigator.pop(context);
                Share.share('${post.title}\n\n${post.body}'.trim());
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag_outlined,
                  color: Colors.red),
              title: const Text('Report post',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reporting is not available yet.')),
                );
              },
            ),
            if (ref.read(groupsProvider.notifier).isMyPost(post))
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Delete post', style: TextStyle(color: Colors.red)),
                onTap: () {
                  ref.read(groupsProvider.notifier).deletePost(post.id);
                  Navigator.pop(context);
                },
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
    final alreadyVoted = post.pollOptions.any((o) => o.selected);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.how_to_vote_outlined,
                size: 14, color: Colors.grey.shade400),
            const SizedBox(width: 4),
            Text(
              alreadyVoted ? 'You voted' : 'Select one or more',
              style: TextStyle(
                  fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...post.pollOptions.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          final percent = totalVotes == 0
              ? 0.0
              : option.votes / totalVotes;

          return GestureDetector(
            onTap: alreadyVoted
                ? null
                : () => ref
                    .read(groupsProvider.notifier)
                    .voteOnPoll(postId, index),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: option.selected
                      ? const Color(0xFF3F2868)
                      : Colors.grey.shade200,
                  width: option.selected ? 1.5 : 1,
                ),
              ),
              child: Stack(
                children: [
                  FractionallySizedBox(
                    widthFactor: percent,
                    child: Container(
                      decoration: BoxDecoration(
                        color: option.selected
                            ? const Color(0xFF3F2868)
                            : const Color(0xFFE8D5F5),
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          option.text,
                          style: TextStyle(
                            fontSize: 13,
                            color: option.selected
                                ? Colors.white
                                : const Color(0xFF1A1A1A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (alreadyVoted)
                          Row(
                            children: [
                              Text(
                                '${(percent * 100).round()}%',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: option.selected
                                        ? Colors.white
                                        : Colors.grey.shade600),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${option.votes} votes',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: option.selected
                                        ? Colors.white70
                                        : Colors.grey.shade400),
                              ),
                              if (option.selected) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.check_circle,
                                    color: Colors.white,
                                    size: 15),
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

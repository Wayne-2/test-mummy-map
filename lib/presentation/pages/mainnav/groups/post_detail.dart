import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mummymap/presentation/providers/groups_provider.dart';
import 'package:mummymap/presentation/pages/mainnav/groups/create_post.dart';

class PostDetail extends ConsumerStatefulWidget {
  final GroupPost post;

  const PostDetail({super.key, required this.post});

  @override
  ConsumerState<PostDetail> createState() => _PostDetailState();
}

class _PostDetailState extends ConsumerState<PostDetail> {
  final _replyController = TextEditingController();

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  void _submitReply() {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;
    ref.read(groupsProvider.notifier).addReply(widget.post.id, text);
    _replyController.clear();
    FocusScope.of(context).unfocus();
  }

  void _showPostOptions(GroupPost post) {
    final isBookmarked =
        ref.read(groupsProvider).isBookmarked(post.id);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
              leading: Icon(isBookmarked
                  ? Icons.bookmark
                  : Icons.bookmark_outline),
              title: Text(
                  isBookmarked ? 'Remove bookmark' : 'Save post'),
              onTap: () {
                ref
                    .read(groupsProvider.notifier)
                    .toggleBookmark(post.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isBookmarked
                        ? 'Bookmark removed'
                        : 'Post bookmarked'),
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy_outlined),
              title: const Text('Copy post text'),
              onTap: () {
                Clipboard.setData(ClipboardData(text: post.title));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Copied to clipboard'),
                    duration: Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.flag_outlined, color: Colors.red),
              title: const Text('Report post',
                  style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(groupsProvider);
    final livePost = state.posts.firstWhere(
      (p) => p.id == widget.post.id,
      orElse: () => widget.post,
    );
    final isBookmarked = state.isBookmarked(livePost.id);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 4, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Color(0xFF1A1A1A)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text('Post',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A))),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.more_horiz,
                        color: Color(0xFF1A1A1A)),
                    onPressed: () => _showPostOptions(livePost),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor:
                              Color(livePost.groupColor),
                          child: Text(livePost.groupInitials,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: livePost.author,
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1A1A1A)),
                                    ),
                                    TextSpan(
                                      text:
                                          ' in ${livePost.group}',
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF9E9E9E)),
                                    ),
                                  ],
                                ),
                              ),
                              Text(livePost.timeAgo,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(livePost.title,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A))),
                    if (livePost.body.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(livePost.body,
                          style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF333333),
                              height: 1.7)),
                    ],
                    const SizedBox(height: 16),
                    const Divider(height: 28),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        _ActionButton(
                          icon: livePost.isLikedByMe
                              ? Icons.favorite
                              : Icons.favorite_outline,
                          label: '${livePost.likes}',
                          color: livePost.isLikedByMe
                              ? Colors.red
                              : Colors.grey.shade600,
                          onTap: () => ref
                              .read(groupsProvider.notifier)
                              .toggleLike(livePost.id),
                        ),
                        _ActionButton(
                          icon: Icons.chat_bubble_outline,
                          label:
                              '${livePost.postReplies.length}',
                          color: Colors.grey.shade600,
                          onTap: () {},
                        ),
                        _ActionButton(
                          icon: isBookmarked
                              ? Icons.bookmark
                              : Icons.bookmark_outline,
                          label: '',
                          color: isBookmarked
                              ? const Color(0xFF3F2868)
                              : Colors.grey.shade600,
                          onTap: () {
                            ref
                                .read(groupsProvider.notifier)
                                .toggleBookmark(livePost.id);
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              SnackBar(
                                content: Text(isBookmarked
                                    ? 'Bookmark removed'
                                    : 'Post bookmarked'),
                                duration:
                                    const Duration(seconds: 1),
                                behavior:
                                    SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                        _ActionButton(
                          icon: Icons.share_outlined,
                          label: '',
                          color: Colors.grey.shade600,
                          onTap: () {
                            Clipboard.setData(ClipboardData(
                                text: livePost.title));
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Copied to clipboard'),
                                duration: Duration(seconds: 1),
                                behavior:
                                    SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const Divider(height: 28),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Replies (${livePost.postReplies.length})',
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A1A)),
                        ),
                        Icon(Icons.keyboard_arrow_down,
                            color: Colors.grey.shade500),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (livePost.postReplies.isEmpty)
                      Center(
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 32),
                          child: Text(
                            'No replies yet. Be the first!',
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade400),
                          ),
                        ),
                      )
                    else
                      ...livePost.postReplies.map(
                        (reply) => _ReplyItem(
                          reply: reply,
                          postId: livePost.id,
                          replyingTo:
                              '@${livePost.author} in ${livePost.group}',
                        ),
                      ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            _buildReplyBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
            top: BorderSide(color: Colors.grey.shade200, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFFE8D5F5),
            child: Icon(Icons.person,
                color: Color(0xFF3F2868), size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _replyController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Add a reply...',
                hintStyle: TextStyle(
                    color: Colors.grey.shade400, fontSize: 14),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _replyController.text.trim().isNotEmpty
                ? _submitReply
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _replyController.text.trim().isNotEmpty
                    ? const Color(0xFF3F2868)
                    : Colors.grey.shade300,
              ),
              child: const Icon(Icons.send,
                  color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 24, color: color),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      fontSize: 14,
                      color: color,
                      fontWeight: FontWeight.w500)),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReplyItem extends ConsumerWidget {
  final PostReply reply;
  final String postId;
  final String replyingTo;

  const _ReplyItem({
    required this.reply,
    required this.postId,
    required this.replyingTo,
  });

  void _showReplyOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
              leading: const Icon(Icons.copy_outlined),
              title: const Text('Copy reply'),
              onTap: () {
                Clipboard.setData(
                    ClipboardData(text: reply.body));
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag_outlined,
                  color: Colors.red),
              title: const Text('Report reply',
                  style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLiked = reply.likedBy.contains('me');

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Color(reply.avatarColor),
            child: Text(reply.initials,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
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
                        Text(reply.author,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Color(0xFF1A1A1A))),
                        const SizedBox(width: 6),
                        Text('• ${reply.timeAgo}',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500)),
                      ],
                    ),
                    GestureDetector(
                      onTap: () =>
                          _showReplyOptions(context, ref),
                      child: Icon(Icons.more_horiz,
                          color: Colors.grey.shade400),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text('Replying to $replyingTo',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF3F2868))),
                const SizedBox(height: 6),
                Text(reply.body,
                    style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF333333),
                        height: 1.6)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => ref
                          .read(groupsProvider.notifier)
                          .toggleLikeReply(postId, reply.id),
                      child: Row(
                        children: [
                          Icon(
                            isLiked
                                ? Icons.favorite
                                : Icons.favorite_outline,
                            size: 16,
                            color: isLiked
                                ? Colors.red
                                : Colors.grey.shade400,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isLiked
                                ? '${reply.likedBy.length}'
                                : 'Like',
                            style: TextStyle(
                                fontSize: 12,
                                color: isLiked
                                    ? Colors.red
                                    : Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.chat_bubble_outline,
                        size: 16, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text('Reply',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500)),
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
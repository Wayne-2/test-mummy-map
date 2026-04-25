import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mummymap/presentation/providers/groups_provider.dart';
//import 'package:mummymap/presentation/pages/mainnav/groups/create_post.dart';

class PostDetail extends ConsumerStatefulWidget {
  final GroupPost post;

  const PostDetail({super.key, required this.post});

  @override
  ConsumerState<PostDetail> createState() => _PostDetailState();
}

class _PostDetailState extends ConsumerState<PostDetail> {
  bool _bookmarked = false;
  bool _liked = false;
  final _replyController = TextEditingController();
  final List<Map<String, String>> _localReplies = [];

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  void _submitReply() {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _localReplies.add({
        'name': 'You',
        'initials': 'ME',
        'time': 'Just now',
        'body': text,
      });
      _replyController.clear();
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final livePost = ref.watch(groupsProvider).posts.firstWhere(
          (p) => p.id == widget.post.id,
          orElse: () => widget.post,
        );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPostHeader(livePost),
                    const SizedBox(height: 16),
                    Text(
                      livePost.title,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A)),
                    ),
                    if (livePost.body.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        livePost.body,
                        style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF333333),
                            height: 1.7),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      '8:12 PM  •  03 Apr 25  •  12.4M Views',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500),
                    ),
                    const Divider(height: 28),
                    _buildActionRow(context, livePost),
                    const Divider(height: 28),
                    _buildRepliesHeader(),
                    const SizedBox(height: 16),
                    if (_localReplies.isEmpty && true)
                      _ReplyItem(
                        initials: 'SH',
                        color: const Color(0xFF4FC3F7),
                        name: 'Sharon',
                        time: '12hrs',
                        replyingTo:
                            '@${livePost.author} in ${livePost.group}',
                        body:
                            'Just reading your post I realized that I also went through the exact same thing when I gave birth to my first child and daughter Adaeze. It was hell trying to get her to be calm. It still remains a challenge but it gets better!',
                      ),
                    ..._localReplies.map(
                      (reply) => Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _ReplyItem(
                          initials: reply['initials']!,
                          color: const Color(0xFF3F2868),
                          name: reply['name']!,
                          time: reply['time']!,
                          replyingTo:
                              '@${livePost.author} in ${livePost.group}',
                          body: reply['body']!,
                        ),
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

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            'Post',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A)),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Color(0xFF1A1A1A)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildPostHeader(GroupPost post) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Color(post.groupColor),
          child: Text(
            post.groupInitials,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: post.author,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A)),
                    ),
                    TextSpan(
                      text: ' in ${post.group}',
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF9E9E9E)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                post.time,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF3F2868), width: 1.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Text('Join',
                    style: TextStyle(
                        color: Color(0xFF3F2868),
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
                SizedBox(width: 4),
                Icon(Icons.add, color: Color(0xFF3F2868), size: 15),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionRow(BuildContext context, GroupPost post) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ActionButton(
          icon: _liked ? Icons.favorite : Icons.favorite_outline,
          label: _liked ? '${post.likes + 1}' : '${post.likes}',
          color: _liked ? Colors.red : Colors.grey.shade600,
          onTap: () {
            setState(() => _liked = !_liked);
            if (_liked) {
              ref.read(groupsProvider.notifier).likePost(post.id);
            }
          },
        ),
        _ActionButton(
          icon: Icons.chat_bubble_outline,
          label: '${post.replies}k',
          color: Colors.grey.shade600,
          onTap: () => FocusScope.of(context)
              .requestFocus(FocusNode()),
        ),
        _ActionButton(
          icon: _bookmarked ? Icons.bookmark : Icons.bookmark_outline,
          label: '6,242',
          color: _bookmarked
              ? const Color(0xFF3F2868)
              : Colors.grey.shade600,
          onTap: () {
            setState(() => _bookmarked = !_bookmarked);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    _bookmarked ? 'Post bookmarked' : 'Bookmark removed'),
                duration: const Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
        _ActionButton(
          icon: Icons.share_outlined,
          label: '10.4k',
          color: Colors.grey.shade600,
          onTap: () {
            Clipboard.setData(ClipboardData(text: post.title));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Link copied to clipboard'),
                duration: Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRepliesHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Most relevant replies',
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A)),
        ),
        Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade500),
      ],
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
            child: Icon(Icons.person, color: Color(0xFF3F2868), size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _replyController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Add a reply...',
                hintStyle:
                    TextStyle(color: Colors.grey.shade400, fontSize: 14),
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
              child: const Icon(Icons.send, color: Colors.white, size: 18),
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
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                  fontSize: 14,
                  color: color,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReplyItem extends StatelessWidget {
  final String initials;
  final Color color;
  final String name;
  final String time;
  final String replyingTo;
  final String body;

  const _ReplyItem({
    required this.initials,
    required this.color,
    required this.name,
    required this.time,
    required this.replyingTo,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color,
            child: Text(initials,
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Color(0xFF1A1A1A))),
                        const SizedBox(width: 6),
                        Text('• $time',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500)),
                      ],
                    ),
                    Icon(Icons.more_horiz, color: Colors.grey.shade400),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Replying to $replyingTo',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF3F2868)),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF333333),
                      height: 1.6),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.favorite_outline,
                        size: 16, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text('Like',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500)),
                    const SizedBox(width: 16),
                    Icon(Icons.chat_bubble_outline,
                        size: 16, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text('Reply',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500)),
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
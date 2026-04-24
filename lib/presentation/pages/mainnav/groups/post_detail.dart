import 'package:flutter/material.dart';
import 'package:mummymap/presentation/pages/mainnav/groups/create_post.dart';

class PostDetail extends StatelessWidget {
  final Map<String, dynamic> post;

  const PostDetail({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _PostDetailAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor:
                              Color(post['groupColor'] ?? 0xFFE8D5F5),
                          child: Text(
                            post['groupInitials'] ?? '??',
                            style: const TextStyle(
                                color: Colors.white,
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
                                      text: post['author'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1A1A1A),
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' in ${post['group']}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF9E9E9E),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                post['time'],
                                style: const TextStyle(
                                    fontSize: 11, color: Color(0xFF9E9E9E)),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFF3F2868)),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Text(
                                'Join',
                                style: TextStyle(
                                  color: Color(0xFF3F2868),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(Icons.add,
                                  color: Color(0xFF3F2868), size: 14),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      post['title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      post['body'] ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF555555),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '8:12 PM  •  03 Apr 25  •  12.4M Views',
                      style: TextStyle(
                          fontSize: 12, color: Color(0xFF9E9E9E)),
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        _StatItem(
                            icon: Icons.favorite_outline,
                            label: '${post['likes']} Likes'),
                        const SizedBox(width: 16),
                        _StatItem(
                            icon: Icons.chat_bubble_outline,
                            label: '${post['replies']}k Replies'),
                        const SizedBox(width: 16),
                        const _StatItem(
                            icon: Icons.bookmark_outline,
                            label: '6,242 Bookmarks'),
                        const SizedBox(width: 16),
                        const _StatItem(
                            icon: Icons.share_outlined,
                            label: '10.4k Shares'),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Most relevant replies',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down,
                            color: Color(0xFF9E9E9E)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _ReplyItem(
                      initials: 'SH',
                      color: const Color(0xFF4FC3F7),
                      name: 'Sharon',
                      time: '12hrs',
                      replyingTo: '@Joyce in Sporty Moms',
                      body:
                          'Just reading your post I realized that I also went through the exact same thing when I gave birth to first child and daughter Adaeze. It was hell trying to get her to be calm. It still remain a...',
                    ),
                  ],
                ),
              ),
            ),
            _ReplyBar(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreatePost()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostDetailAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
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
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF9E9E9E)),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
      ],
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: color,
          child: Text(initials,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
        ),
        const SizedBox(width: 10),
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
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF9E9E9E))),
                    ],
                  ),
                  const Icon(Icons.more_horiz, color: Color(0xFF9E9E9E)),
                ],
              ),
              Text(
                'Replying to $replyingTo',
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF3F2868)),
              ),
              const SizedBox(height: 6),
              Text(
                body,
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF555555), height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReplyBar extends StatelessWidget {
  final VoidCallback onTap;

  const _ReplyBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFFE8D5F5),
              child:
                  Icon(Icons.person, color: Color(0xFF3F2868), size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9F9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: const Text(
                  'Add a reply...',
                  style: TextStyle(
                      fontSize: 13, color: Color(0xFFBDBDBD)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.camera_alt_outlined,
                color: Color(0xFF9E9E9E)),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mummymap/presentation/providers/groups_provider.dart';

class CreatePost extends ConsumerStatefulWidget {
  final String groupId;

  const CreatePost({super.key, required this.groupId});

  @override
  ConsumerState<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends ConsumerState<CreatePost> {
  final _postController = TextEditingController();
  bool _showPoll = false;

  final List<TextEditingController> _pollOptions = [
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  void dispose() {
    _postController.dispose();
    for (final c in _pollOptions) {
      c.dispose();
    }
    super.dispose();
  }

  void _submitPost() {
    final text = _postController.text.trim();
    if (text.isEmpty) return;

    final state = ref.read(groupsProvider);

    final group = state.groups
        .where((g) => g.id == widget.groupId)
        .first;

    final pollOptions = _showPoll
        ? _pollOptions
            .map((c) => c.text.trim())
            .where((t) => t.isNotEmpty)
            .map((t) => PollOption(text: t, votes: 0))
            .toList()
        : <PollOption>[];

    final post = GroupPost(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      groupId: widget.groupId,
      groupInitials: group.initials,
      groupColor: group.avatarColor,
      author: 'You',
      group: group.name,
      createdAt: DateTime.now(),
      title: text,
      body: '',
      likes: 0,
      type: _showPoll && pollOptions.isNotEmpty ? 'poll' : 'text',
      pollOptions: pollOptions,
      likedBy: const [],
      postReplies: const [],
    );

    ref.read(groupsProvider.notifier).addPost(post);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isReady = _postController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close),
                  ),
                  ElevatedButton(
                    onPressed: isReady ? _submitPost : null,
                    child: const Text('Post'),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _postController,
                  maxLines: null,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'Tell us what is happening',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            if (_showPoll)
              Column(
                children: List.generate(_pollOptions.length, (i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: TextField(
                      controller: _pollOptions[i],
                      decoration: InputDecoration(
                        hintText: 'Option ${i + 1}',
                      ),
                    ),
                  );
                }),
              ),

            Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.poll_outlined),
                    onPressed: () {
                      setState(() => _showPoll = !_showPoll);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
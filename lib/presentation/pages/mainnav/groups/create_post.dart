import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mummymap/data/models/group_model.dart';
import 'package:mummymap/presentation/providers/groups_provider.dart';

class CreatePost extends ConsumerStatefulWidget {
  final String groupId;

  const CreatePost({super.key, required this.groupId});

  @override
  ConsumerState<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends ConsumerState<CreatePost> {
  final _titleController = TextEditingController();
  final _postController = TextEditingController();
  final bool _enablePolls = false; // TODO: Enable when backend supports polls
  bool _showPoll = false;
  bool _isSubmitting = false;

  final List<TextEditingController> _pollOptions = [
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _postController.dispose();
    for (final c in _pollOptions) {
      c.dispose();
    }
    super.dispose();
  }

  static const int _maxPollOptions = 12;
  static const int _minPollOptions = 2;

  void _addPollOption() {
    if (_pollOptions.length >= _maxPollOptions) return;
    setState(() => _pollOptions.add(TextEditingController()));
  }

  void _removePollOption(int index) {
    if (_pollOptions.length <= _minPollOptions) return;
    setState(() {
      final removed = _pollOptions.removeAt(index);
      removed.dispose();
    });
  }

  Future<void> _submitPost() async {
    final title = _titleController.text.trim();
    final text = _postController.text.trim();
    if (text.isEmpty || title.isEmpty) return;

    final pollOptions = _showPoll
        ? _pollOptions
            .map((c) => c.text.trim())
            .where((t) => t.isNotEmpty)
            .map((t) => PollOption(text: t, votes: 0))
            .toList()
        : <PollOption>[];

    setState(() => _isSubmitting = true);

    final success = await ref.read(groupsProvider.notifier).addPost(
          groupId: widget.groupId,
          title: title,
          body: text,
          pollOptions: pollOptions,
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not publish your post. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isReady = _titleController.text.trim().isNotEmpty &&
        _postController.text.trim().isNotEmpty &&
        !_isSubmitting;

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
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Post title',
                        border: InputBorder.none,
                      ),
                    ),
                    const Divider(),
                    Expanded(
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
                  ],
                ),
              ),
            ),

            if (_showPoll)
              Column(
                children: [
                  ...List.generate(_pollOptions.length, (i) {
                    final canRemove = _pollOptions.length > _minPollOptions;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _pollOptions[i],
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                hintText: 'Option ${i + 1}',
                              ),
                            ),
                          ),
                          if (canRemove)
                            IconButton(
                              icon: const Icon(Icons.close,
                                  size: 20, color: Color(0xFF9E9E9E)),
                              onPressed: () => _removePollOption(i),
                            ),
                        ],
                      ),
                    );
                  }),
                  if (_pollOptions.length < _maxPollOptions)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: _addPollOption,
                          icon: const Icon(Icons.add,
                              size: 20, color: Color(0xFF3F2868)),
                          label: const Text(
                            'Add option',
                            style: TextStyle(
                                color: Color(0xFF3F2868),
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                ],
              ),

            Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Spacer(),
                  if (_enablePolls)
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
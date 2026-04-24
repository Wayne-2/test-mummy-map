import 'package:flutter/material.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  final _postController = TextEditingController();
  String _audience = 'Everyone';
  bool _showPoll = false;
  final List<TextEditingController> _pollOptions = [
    TextEditingController(),
    TextEditingController(),
  ];
  String _pollLength = '1 day';
  bool _allowMultiple = true;

  @override
  void dispose() {
    _postController.dispose();
    for (final c in _pollOptions) {
      c.dispose();
    }
    super.dispose();
  }

  void _showAudienceSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AudienceSelector(
        selected: _audience,
        onSelected: (val) {
          setState(() => _audience = val);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPostReady = _postController.text.trim().isNotEmpty;

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
                    child: const Icon(Icons.close, color: Color(0xFF1A1A1A)),
                  ),
                  ElevatedButton(
                    onPressed: isPostReady ? () {} : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3F2868),
                      disabledBackgroundColor: const Color(0xFFBDBDBD),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 10),
                    ),
                    child: const Text(
                      'Post',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(0xFFE8D5F5),
                    child: Icon(Icons.person,
                        color: Color(0xFF3F2868), size: 18),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _showAudienceSelector,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: const Color(0xFFE0E0E0)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Text(
                            _audience,
                            style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF1A1A1A)),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_down,
                              size: 16, color: Color(0xFF9E9E9E)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    TextField(
                      controller: _postController,
                      maxLines: null,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'Tell us what is happening',
                        hintStyle: TextStyle(
                            color: Color(0xFFBDBDBD), fontSize: 15),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                          fontSize: 15, color: Color(0xFF1A1A1A)),
                    ),
                    if (_showPoll) _PollCreator(
                      options: _pollOptions,
                      pollLength: _pollLength,
                      allowMultiple: _allowMultiple,
                      onPollLengthChanged: (val) =>
                          setState(() => _pollLength = val),
                      onAllowMultipleChanged: (val) =>
                          setState(() => _allowMultiple = val),
                      onAddOption: () {
                        setState(() => _pollOptions
                            .add(TextEditingController()));
                      },
                      onClose: () =>
                          setState(() => _showPoll = false),
                    ),
                  ],
                ),
              ),
            ),
            _MediaRow(context: context),
            _BottomBar(
              onTap: (action) {
                if (action == 'poll') {
                  setState(() => _showPoll = !_showPoll);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PollCreator extends StatelessWidget {
  final List<TextEditingController> options;
  final String pollLength;
  final bool allowMultiple;
  final ValueChanged<String> onPollLengthChanged;
  final ValueChanged<bool> onAllowMultipleChanged;
  final VoidCallback onAddOption;
  final VoidCallback onClose;

  const _PollCreator({
    required this.options,
    required this.pollLength,
    required this.allowMultiple,
    required this.onPollLengthChanged,
    required this.onAllowMultipleChanged,
    required this.onAddOption,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Poll',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF1A1A1A)),
              ),
              GestureDetector(
                onTap: onClose,
                child: const Icon(Icons.close, color: Color(0xFF9E9E9E)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(options.length, (index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF3F2868)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: options[index],
                      decoration: InputDecoration(
                        hintText: 'Choice ${index + 1}',
                        hintStyle: const TextStyle(
                            color: Color(0xFFBDBDBD), fontSize: 13),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                      ),
                    ),
                  ),
                  if (index == 0)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(Icons.drag_handle,
                          color: Color(0xFF9E9E9E)),
                    ),
                ],
              ),
            );
          }),
          GestureDetector(
            onTap: onAddOption,
            child: const Row(
              children: [
                Icon(Icons.add, color: Color(0xFF3F2868), size: 18),
                SizedBox(width: 4),
                Text(
                  'Add Choice',
                  style: TextStyle(
                      color: Color(0xFF3F2868),
                      fontWeight: FontWeight.w600,
                      fontSize: 13),
                ),
              ],
            ),
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Poll length',
                  style: TextStyle(
                      fontSize: 13, color: Color(0xFF1A1A1A))),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    Text(pollLength,
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF1A1A1A))),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down,
                        size: 16, color: Color(0xFF9E9E9E)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Allow multiple answers',
                  style: TextStyle(
                      fontSize: 13, color: Color(0xFF1A1A1A))),
              Switch(
                value: allowMultiple,
                onChanged: onAllowMultipleChanged,
                activeColor: const Color(0xFF3F2868),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MediaRow extends StatelessWidget {
  final BuildContext context;

  const _MediaRow({required this.context});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          Container(
            width: 64,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: const Icon(Icons.camera_alt_outlined,
                color: Color(0xFF9E9E9E)),
          ),
          ...List.generate(
            5,
            (i) => Container(
              width: 64,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8D5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.image, color: Color(0xFF3F2868)),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final ValueChanged<String> onTap;

  const _BottomBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      child: Row(
        children: [
          const Icon(Icons.public, color: Color(0xFF9E9E9E), size: 18),
          const SizedBox(width: 6),
          const Text('Everyone can reply',
              style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
          const Spacer(),
          _BarIcon(
              icon: Icons.image_outlined,
              onTap: () => onTap('image')),
          const SizedBox(width: 20),
          _BarIcon(icon: Icons.gif, onTap: () => onTap('gif')),
          const SizedBox(width: 20),
          _BarIcon(
              icon: Icons.poll_outlined,
              onTap: () => onTap('poll')),
        ],
      ),
    );
  }
}

class _BarIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _BarIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, color: const Color(0xFF9E9E9E), size: 22),
    );
  }
}

class _AudienceSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const _AudienceSelector(
      {required this.selected, required this.onSelected});

  static const _groups = [
    {'name': 'Sporty Moms', 'members': '124k Members'},
    {'name': 'November Mommies 2025', 'members': '23.1k Members'},
    {'name': 'Socially Awkward Moms', 'members': '11.9k Members'},
    {'name': 'Exclusively Camping Momas', 'members': '690 Members'},
    {'name': 'Boy Moms', 'members': '5.6k Members'},
    {'name': 'GIRLIE MOMMAS', 'members': '5.6k Members'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Choose audience',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            onTap: () => onSelected('Everyone'),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF3F2868),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.public, color: Colors.white),
            ),
            title: const Text('Everyone',
                style: TextStyle(fontWeight: FontWeight.w600)),
            trailing: selected == 'Everyone'
                ? const Icon(Icons.check_circle,
                    color: Colors.green)
                : null,
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'My Groups',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          ..._groups.map(
            (group) => ListTile(
              onTap: () => onSelected(group['name']!),
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFE8D5F5),
                child: Text(
                  group['name']!.substring(0, 2),
                  style: const TextStyle(
                      color: Color(0xFF3F2868),
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                ),
              ),
              title: Text(group['name']!,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 14)),
              subtitle: Text(group['members']!,
                  style: const TextStyle(fontSize: 12)),
              trailing: selected == group['name']
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
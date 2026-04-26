import 'package:flutter/material.dart';

class MoodSelector extends StatefulWidget {
  const MoodSelector({super.key});

  @override
  State<MoodSelector> createState() => _MoodSelectorState();
}

class _MoodSelectorState extends State<MoodSelector> {
  String? _selectedMood;
  bool _submitted = false;

  final List<Map<String, String>> _moods = [
    {'emoji': '🤩', 'label': 'Inspired'},
    {'emoji': '😡', 'label': 'Angry'},
    {'emoji': '😢', 'label': 'Sad'},
    {'emoji': '😊', 'label': 'Happy'},
    {'emoji': '😰', 'label': 'Anxious'},
    {'emoji': '🥳', 'label': 'Excited'},
  ];

  static const Map<String, String> _moodMessages = {
    'Inspired': "We're excited to know that you feeling **inspired** today\ncan you tell us what makes you feel this way?",
    'Angry': "We're sorry to hear you're feeling **angry** today\ncan you tell us what's been bothering you?",
    'Sad': "We're here for you. You're feeling **sad** today\nwould you like to share what's on your mind?",
    'Happy': "Love to see it! You're feeling **happy** today\ncan you tell us what's bringing you joy?",
    'Anxious': "Take a breath. You're feeling **anxious** today\ncan you tell us what's been on your mind?",
    'Excited': "That's wonderful! You're feeling **excited** today\ncan you tell us what you're looking forward to?",
  };

  void _onMoodTapped(Map<String, String> mood) {
    setState(() {
      _selectedMood = mood['label'];
      _submitted = false;
    });
    _showMoodSheet(mood);
  }

  void _showMoodSheet(Map<String, String> mood) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _MoodSheet(
        mood: mood,
        message: _moodMessages[mood['label']!] ?? '',
        onSubmitted: () {
          setState(() => _submitted = true);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'How are you feeling today?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              if (_submitted && _selectedMood != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Logged',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: _moods.map((mood) {
              final isSelected = _selectedMood == mood['label'];
              return GestureDetector(
                onTap: () => _onMoodTapped(mood),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFE8D5F5)
                        : const Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF3F2868)
                          : Colors.transparent,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(mood['emoji']!, style: const TextStyle(fontSize: 28)),
                      const SizedBox(height: 4),
                      Text(
                        mood['label']!,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? const Color(0xFF3F2868)
                              : const Color(0xFF9E9E9E),
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _MoodSheet extends StatefulWidget {
  final Map<String, String> mood;
  final String message;
  final VoidCallback onSubmitted;

  const _MoodSheet({
    required this.mood,
    required this.message,
    required this.onSubmitted,
  });

  @override
  State<_MoodSheet> createState() => _MoodSheetState();
}

class _MoodSheetState extends State<_MoodSheet> {
  final _controller = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canSubmit => _controller.text.trim().isNotEmpty;

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isLoading = false);
    widget.onSubmitted();
    Navigator.pop(context);
  }

  List<TextSpan> _parseMessage(String message) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int lastEnd = 0;

    for (final match in regex.allMatches(message)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: message.substring(lastEnd, match.start),
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF555555),
            height: 1.6,
          ),
        ));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A1A1A),
          height: 1.6,
        ),
      ));
      lastEnd = match.end;
    }

    if (lastEnd < message.length) {
      spans.add(TextSpan(
        text: message.substring(lastEnd),
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF555555),
          height: 1.6,
        ),
      ));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Divider(height: 20),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            child: Column(
              children: [
                Text(
                  'How Are You Feeling Today?',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  widget.mood['emoji']!,
                  style: const TextStyle(fontSize: 64),
                ),
                const SizedBox(height: 16),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(children: _parseMessage(widget.message)),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _controller,
                  maxLines: 5,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1A1A1A),
                    height: 1.6,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Share how you\'re feeling...',
                    hintStyle: const TextStyle(
                      color: Color(0xFFBDBDBD),
                      fontSize: 14,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF3F2868),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: (_canSubmit && !_isLoading) ? _submit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3F2868),
                      disabledBackgroundColor: const Color(0xFFBDBDBD),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Submitting...',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : const Text(
                            'Submit',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
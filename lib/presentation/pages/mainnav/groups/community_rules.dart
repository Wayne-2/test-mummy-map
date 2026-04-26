import 'package:flutter/material.dart';

class CommunityRules extends StatelessWidget {
  final VoidCallback onAccept;

  const CommunityRules({super.key, required this.onAccept});

  static const _rules = [
    {
      'title': 'Keep Posts on topic.',
      'body':
          'This community is all about pregnancy. Every post published on this group must be about self-care, routine exercises, pregnancy-related publications etc... pregnancy in general.',
    },
    {
      'title': 'Be kind and respectful.',
      'body':
          'We\'re all on the same team here, so let\'s have fun, share what we know, and hopefully learn something new. No bullying, harassment, racism, or sexism.',
    },
    {
      'title': 'Promoting of contents',
      'body':
          'Sales oriented posts aren\'t allowed in this community. Do not ask the community to buy, follow, or share any unverified product or service.',
    },
    {
      'title': 'No hate speech or discrimination',
      'body':
          'We want everyone to feel safe and welcome, no matter their age, race, gender, religion or culture. We have zero-tolerance on hate speech.',
    },
    {
      'title': 'Do not spam',
      'body': 'Avoid posting the same stuff over and over again.',
    },
    {
      'title': 'Don\'t advertise other communities',
      'body':
          'Please don\'t advertise external communities here. Do not post WhatsApp, Telegram, or Discord communities in this community.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Color(0xFF1A1A1A)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Community Rules',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF9E9E9E),
                      height: 1.5),
                  children: [
                    TextSpan(
                        text:
                            'Community rules are enforced by community leaders, and are in addition to '),
                    TextSpan(
                      text: 'our Rules.',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A)),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _rules.length,
                separatorBuilder: (_, __) => const Divider(height: 24),
                itemBuilder: (context, index) {
                  final rule = _rules[index];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: const Color(0xFFE0E0E0)),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A1A)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rule['title']!,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A1A)),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              rule['body']!,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF555555),
                                  height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).padding.bottom + 16,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3F2868),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Got It',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:mummymap/presentation/pages/mainnav/groups/group_detail.dart';
import 'package:mummymap/presentation/pages/mainnav/groups/widgets/post_card.dart';

final _suggestedGroups = [
  {
    'id': '1',
    'name': 'Sporty Moms',
    'members': '127K',
    'created': '12 months ago',
    'image': 'assets/groups/sporty_moms.png',
    'latestPost': 'Daily Breast Feeding...',
    'joined': false,
  },
  {
    'id': '2',
    'name': 'November Mommies 2025',
    'members': '23.1K',
    'created': '6 months ago',
    'image': 'assets/groups/november_moms.png',
    'latestPost': 'What trimester are you in?',
    'joined': false,
  },
  {
    'id': '3',
    'name': 'Socially Awkward Moms',
    'members': '11.9K',
    'created': '8 months ago',
    'image': 'assets/groups/socially_awkward.png',
    'latestPost': 'Any tips for social anxiety during pregnancy?',
    'joined': false,
  },
];

final _explorePosts = [
  {
    'groupInitials': 'SM',
    'groupColor': 0xFFE57373,
    'author': 'Joyce',
    'group': 'Sporty Moms',
    'time': '12 Mins',
    'title': 'Daily Breast Feeding',
    'body':
        'We\'ve just started a breast feeding exercise for my 4 month old who was showing the signs she was ready for food. It\'s day 4 o...',
    'likes': 12,
    'replies': 178,
    'type': 'text',
  },
  {
    'groupInitials': 'BM',
    'groupColor': 0xFF4FC3F7,
    'author': 'Sharon',
    'group': 'BOY Moms',
    'time': '12 Mins',
    'title': 'What self-care routine do I start in 2nd Trimester?',
    'body': '',
    'likes': 12,
    'replies': 178,
    'type': 'poll',
    'pollOptions': [
      {'text': 'Gentle prenatal yoga', 'percent': 10, 'votes': 14},
      {'text': 'Daily hydration and balanced meals', 'percent': 35, 'votes': 27},
      {'text': 'Regular rest and short naps', 'percent': 80, 'votes': 78},
    ],
  },
];

class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  final PageController _pageController = PageController(viewportFraction: 0.92);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text(
              'Suggested Groups To Follow',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          SizedBox(
            height: 220,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _suggestedGroups.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (context, index) {
                final group = _suggestedGroups[index];
                return _SuggestedGroupCard(
                  group: group,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GroupDetail(group: group),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _suggestedGroups.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _currentPage == i ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _currentPage == i
                      ? const Color(0xFF3F2868)
                      : const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _explorePosts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) =>
                PostCard(post: _explorePosts[index]),
          ),
        ],
      ),
    );
  }
}

class _SuggestedGroupCard extends StatelessWidget {
  final Map<String, dynamic> group;
  final VoidCallback onTap;

  const _SuggestedGroupCard({required this.group, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF3F2868),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF3F2868),
                      const Color(0xFF6A3A9A),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white24,
                        child: Text(
                          group['name'].toString().substring(0, 2),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group['name'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Created ${group['created']} ago',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    group['latestPost'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.people_outline,
                              color: Colors.white70, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${group['members']}+ Members',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: onTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: const [
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
                      ),
                    ],
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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mummymap/presentation/providers/groups_provider.dart';
import 'package:mummymap/presentation/pages/mainnav/groups/widgets/post_card.dart';

class ForYouTab extends ConsumerWidget {
  final VoidCallback onExplore;

  const ForYouTab({super.key, required this.onExplore});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(groupsProvider).forYouPosts;

    if (posts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8D5F5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.dynamic_feed_outlined,
                    size: 40, color: Color(0xFF3F2868)),
              ),
              const SizedBox(height: 20),
              const Text(
                'Your feed is empty',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A)),
              ),
              const SizedBox(height: 8),
              const Text(
                'Join or create groups to see posts from communities you care about',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF9E9E9E),
                    height: 1.5),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: onExplore,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3F2868),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: const Text('Explore Groups',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: posts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => PostCard(post: posts[index]),
    );
  }
}
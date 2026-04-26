import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mummymap/presentation/pages/mainnav/home/widgets/hero_card.dart';
import 'package:mummymap/presentation/pages/mainnav/home/widgets/trimester_chart.dart';
import 'package:mummymap/presentation/pages/mainnav/home/widgets/fun_facts_card.dart';
import 'package:mummymap/presentation/pages/mainnav/home/widgets/upcoming_appointments.dart';
import 'package:mummymap/presentation/pages/mainnav/home/widgets/mood_selector.dart';
import 'package:mummymap/presentation/pages/mainnav/home/widgets/community_spaces.dart';

class HomeScreen extends ConsumerWidget {
  final VoidCallback? onExploreGroups;
  final VoidCallback? onNotifications;
  final VoidCallback? onProfileTap;

  const HomeScreen({
    super.key,
    this.onExploreGroups,
    this.onNotifications,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _HomeAppBar(
              onNotifications: onNotifications,
              onProfileTap: onProfileTap,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HeroCard(),
                    const SizedBox(height: 24),
                    const TrimesterChart(),
                    const SizedBox(height: 24),
                    const FunFactsCard(),
                    const SizedBox(height: 24),
                    const UpcomingAppointments(),
                    const SizedBox(height: 24),
                    const MoodSelector(),
                    const SizedBox(height: 24),
                    CommunitySpaces(onExploreGroups: onExploreGroups),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeAppBar extends StatelessWidget {
  final VoidCallback? onNotifications;
  final VoidCallback? onProfileTap;

  const _HomeAppBar({this.onNotifications, this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onProfileTap,
            child: const CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xFFE8D5F5),
              child: Icon(Icons.person, color: Color(0xFF3F2868), size: 22),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/logo3.png', height: 28, width: 28),
              const SizedBox(width: 8),
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Mummy',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3F2868),
                      ),
                    ),
                    TextSpan(
                      text: 'map',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00BCD4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: Color(0xFF1A1A1A)),
            onPressed: onNotifications,
          ),
        ],
      ),
    );
  }
}
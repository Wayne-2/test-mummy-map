import 'package:flutter/material.dart';
import 'package:mummymap/presentation/pages/mainnav/track/tabs/meal_plan_tab.dart';
import 'package:mummymap/presentation/pages/mainnav/track/tabs/weight_tracking_tab.dart';
import 'package:mummymap/presentation/pages/mainnav/track/tabs/exercises_tab.dart';

class TrackScreen extends StatefulWidget {
  final VoidCallback? onNotifications;
  final VoidCallback? onProfileTap;

  const TrackScreen({
    super.key,
    this.onNotifications,
    this.onProfileTap,
  });

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _TrackAppBar(
              onNotifications: widget.onNotifications,
              onProfileTap: widget.onProfileTap,
            ),
            TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF3F2868),
              unselectedLabelColor: const Color(0xFF9E9E9E),
              indicatorColor: const Color(0xFF3F2868),
              indicatorWeight: 2,
              labelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(fontSize: 15),
              tabs: const [
                Tab(text: 'Meal Plan'),
                Tab(text: 'Weight Tracking'),
                Tab(text: 'Exercises'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  MealPlanTab(),
                  WeightTrackingTab(),
                  ExercisesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrackAppBar extends StatelessWidget {
  final VoidCallback? onNotifications;
  final VoidCallback? onProfileTap;

  const _TrackAppBar({this.onNotifications, this.onProfileTap});

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
              child:
                  Icon(Icons.person, color: Color(0xFF3F2868), size: 22),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/logo3.png',
                height: 28,
                width: 28,
                errorBuilder: (_, __, ___) =>
                    const SizedBox(width: 28, height: 28),
              ),
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
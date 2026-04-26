import 'package:flutter/material.dart';
import 'package:mummymap/presentation/pages/mainnav/groups/tabs/for_you_tab.dart';
import 'package:mummymap/presentation/pages/mainnav/groups/tabs/explore_tab.dart';
import 'package:mummymap/presentation/pages/mainnav/groups/tabs/groups_tab.dart';

class GroupsScreen extends StatefulWidget {
  final VoidCallback? onNotifications;

  const GroupsScreen({super.key, this.onNotifications});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _goToExplore() => _tabController.animateTo(1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _GroupsAppBar(onNotifications: widget.onNotifications),
            TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF3F2868),
              unselectedLabelColor: const Color(0xFF9E9E9E),
              indicatorColor: const Color(0xFF3F2868),
              indicatorWeight: 2,
              labelStyle: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontSize: 15),
              tabs: const [
                Tab(text: 'For You'),
                Tab(text: 'Explore'),
                Tab(text: 'Groups'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  ForYouTab(onExplore: _goToExplore),
                  const ExploreTab(),
                  const GroupsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupsAppBar extends StatelessWidget {
  final VoidCallback? onNotifications;

  const _GroupsAppBar({this.onNotifications});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFE8D5F5),
            child: const Icon(Icons.person,
                color: Color(0xFF3F2868), size: 22),
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
                          color: Color(0xFF3F2868)),
                    ),
                    TextSpan(
                      text: 'map',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00BCD4)),
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
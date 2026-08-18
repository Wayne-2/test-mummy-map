import 'package:flutter/material.dart';
import 'widgets/calendar_widgets.dart';
import 'tabs/calendar_tab.dart';
import 'tabs/appointments_tab.dart';
import 'tabs/reminders_tab.dart';

class CalendarScreen extends StatefulWidget {
  final VoidCallback? onNotifications;
  final VoidCallback? onProfileTap;

  const CalendarScreen({
    super.key,
    this.onNotifications,
    this.onProfileTap,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
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
            CalendarAppBar(
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
                Tab(text: 'Calendar'),
                Tab(text: 'Appointments'),
                Tab(text: 'Reminders'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  CalendarTab(),
                  AppointmentsTab(),
                  RemindersTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
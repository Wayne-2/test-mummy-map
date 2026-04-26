import 'package:flutter/material.dart';
import 'package:mummymap/presentation/pages/mainnav/home/home_screen.dart';
import 'package:mummymap/presentation/pages/mainnav/groups/groups_screen.dart';
import 'package:mummymap/presentation/pages/mainnav/notifications_screen.dart';
import 'package:mummymap/presentation/pages/mainnav/side/profile_menu.dart';

class MainNav extends StatefulWidget {
  const MainNav({super.key});

  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  int _currentIndex = 0;
  bool _menuOpen = false;
  late final List<Widget> _pages;

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
  }

  void _openMenu() => setState(() => _menuOpen = true);
  void _closeMenu() => setState(() => _menuOpen = false);

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeScreen(
        onExploreGroups: () => setState(() => _currentIndex = 2),
        onNotifications: _openNotifications,
        onProfileTap: _openMenu,
      ),
      const Scaffold(body: Center(child: Text('Track'))),
      GroupsScreen(
        onNotifications: _openNotifications,
        onProfileTap: _openMenu,
      ),
      const Scaffold(body: Center(child: Text('Calendar'))),
      const Scaffold(body: Center(child: Text('Shop'))),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          if (_menuOpen)
            ProfileMenu(onClose: _closeMenu),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF3F2868),
        unselectedItemColor: const Color(0xFFBDBDBD),
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        backgroundColor: Colors.white,
        elevation: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insert_chart_outlined),
            activeIcon: Icon(Icons.insert_chart),
            label: 'Track',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined),
            activeIcon: Icon(Icons.group),
            label: 'Groups',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag),
            label: 'Shop',
          ),
        ],
      ),
    );
  }
}
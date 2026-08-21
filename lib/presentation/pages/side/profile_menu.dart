import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mummymap/presentation/providers/settings_provider.dart';
import 'package:mummymap/presentation/providers/auth_provider.dart';
import 'package:mummymap/presentation/providers/shop_provider.dart';
import 'package:mummymap/presentation/providers/groups_provider.dart';
import 'package:mummymap/presentation/providers/calendar_provider.dart';
import 'package:mummymap/presentation/providers/doctors_provider.dart';
import 'package:mummymap/presentation/providers/profile_provider.dart';
import 'package:mummymap/presentation/pages/side/profile/profile_page.dart';
import 'package:mummymap/presentation/pages/side/articles/pregnancy_library.dart';
import 'package:mummymap/presentation/pages/side/doctors/doctors_screen.dart';
import 'package:mummymap/presentation/pages/side/settings/settings_screen.dart';
import 'package:mummymap/presentation/pages/side/wallet/wallet_screen.dart';

class ProfileMenu extends ConsumerStatefulWidget {
  final VoidCallback onClose;
  final String? activePage;

  const ProfileMenu({
    super.key,
    required this.onClose,
    this.activePage,
  });

  @override
  ConsumerState<ProfileMenu> createState() => _ProfileMenuState();
}

class _ProfileMenuState extends ConsumerState<ProfileMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    await _controller.reverse();
    widget.onClose();
  }

  void _confirmSignOut(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Sign Out',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Are you sure you want to sign out?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE0E0E0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await _logout();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Sign Out',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await _controller.reverse();
    widget.onClose();
    try {
      await ref.read(settingsProvider.notifier).clear();
      await ref.read(authRepositoryProvider).logoutCurrentDevice();
    } catch (_) {}
    if (!mounted) return;
    // Invalidate user-scoped providers to prevent cross-account data leak
    ref.invalidate(shopProvider);
    ref.invalidate(groupsProvider);
    ref.invalidate(calendarProvider);
    ref.invalidate(doctorsProvider);
    ref.invalidate(profileProvider);
    if (!mounted) return;
    context.go('/signin');
  }

  Future<void> _navigate(Widget page) async {
    await _controller.reverse();
    widget.onClose();
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return GestureDetector(
      onTap: _close,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          color: Colors.black.withOpacity(0.4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SlideTransition(
              position: _slideAnimation,
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.78,
                  height: double.infinity,
                  color: Colors.white,
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Main Menu',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _navigate(const ProfilePage()),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  Stack(
                                    children: [
                                      const CircleAvatar(
                                        radius: 24,
                                        backgroundColor: Color(0xFFE8D5F5),
                                        child: Icon(
                                          Icons.person,
                                          color: Color(0xFF3F2868),
                                          size: 26,
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          settings.fullName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                            color: Color(0xFF1A1A1A),
                                          ),
                                        ),
                                        if (settings.email.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            settings.email,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF9E9E9E),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Color(0xFF9E9E9E),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _MenuItem(
                          icon: Icons.menu_book_outlined,
                          label: 'Articles',
                          isActive: widget.activePage == 'articles',
                          onTap: () => _navigate(const PregnancyLibrary()),
                        ),
                        _MenuItem(
                          icon: Icons.medical_services_outlined,
                          label: 'Doctors',
                          isActive: widget.activePage == 'doctors',
                          onTap: () => _navigate(const DoctorsScreen()),
                        ),
                        _MenuItem(
                          icon: Icons.account_balance_wallet_outlined,
                          label: 'Wallet',
                          isActive: widget.activePage == 'wallet',
                          onTap: () => _navigate(const WalletScreen()),
                        ),
                        _MenuItem(
                          icon: Icons.settings_outlined,
                          label: 'Settings',
                          isActive: widget.activePage == 'settings',
                          onTap: () => _navigate(const SettingsScreen()),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                          child: GestureDetector(
                            onTap: () => _confirmSignOut(context),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFEEEE),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.logout,
                                    color: Colors.red,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                const Text(
                                  'Sign Out',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFEDE0FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive
                  ? const Color(0xFF3F2868)
                  : const Color(0xFF555555),
              size: 22,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive
                    ? const Color(0xFF3F2868)
                    : const Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
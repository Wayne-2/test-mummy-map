import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mummymap/presentation/pages/auth/signin.dart';

final _notifPrefsProvider =
    StateNotifierProvider<_NotifPrefsNotifier, _NotifPrefs>(
  (_) => _NotifPrefsNotifier(),
);

class _NotifPrefs {
  final bool pushEnabled;
  final bool appointmentReminders;
  final bool communityActivity;
  final bool weeklyUpdates;
  final bool pregnancyMilestones;

  const _NotifPrefs({
    this.pushEnabled = true,
    this.appointmentReminders = true,
    this.communityActivity = true,
    this.weeklyUpdates = false,
    this.pregnancyMilestones = true,
  });

  _NotifPrefs copyWith({
    bool? pushEnabled,
    bool? appointmentReminders,
    bool? communityActivity,
    bool? weeklyUpdates,
    bool? pregnancyMilestones,
  }) {
    return _NotifPrefs(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      appointmentReminders: appointmentReminders ?? this.appointmentReminders,
      communityActivity: communityActivity ?? this.communityActivity,
      weeklyUpdates: weeklyUpdates ?? this.weeklyUpdates,
      pregnancyMilestones: pregnancyMilestones ?? this.pregnancyMilestones,
    );
  }
}

class _NotifPrefsNotifier extends StateNotifier<_NotifPrefs> {
  _NotifPrefsNotifier() : super(const _NotifPrefs());

  void toggle(String key) {
    switch (key) {
      case 'push':
        state = state.copyWith(pushEnabled: !state.pushEnabled);
      case 'appointments':
        state = state.copyWith(appointmentReminders: !state.appointmentReminders);
      case 'community':
        state = state.copyWith(communityActivity: !state.communityActivity);
      case 'weekly':
        state = state.copyWith(weeklyUpdates: !state.weeklyUpdates);
      case 'milestones':
        state = state.copyWith(pregnancyMilestones: !state.pregnancyMilestones);
    }
  }
}

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _biometricEnabled = false;
  String _selectedLanguage = 'English';
  String _selectedWeightUnit = 'kg';
  String _selectedLengthUnit = 'cm';

  @override
  Widget build(BuildContext context) {
    final notifs = ref.watch(_notifPrefsProvider);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: bottomPadding + 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileCard(context),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Account'),
                    _buildGroup([
                      _Tile(
                        icon: Icons.person_outline,
                        label: 'Edit Profile',
                        onTap: () => _snack(context),
                      ),
                      _Tile(
                        icon: Icons.lock_outline,
                        label: 'Change Password',
                        onTap: () => _snack(context),
                      ),
                      _Tile(
                        icon: Icons.email_outlined,
                        label: 'Change Email',
                        onTap: () => _snack(context),
                      ),
                      _Tile(
                        icon: Icons.phone_outlined,
                        label: 'Phone Number',
                        trailing: const Text(
                          'Not set',
                          style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
                        ),
                        onTap: () => _snack(context),
                      ),
                    ]),
                    const SizedBox(height: 20),
                    _buildSectionHeader('Pregnancy'),
                    _buildGroup([
                      _Tile(
                        icon: Icons.calendar_today_outlined,
                        label: 'Update Due Date',
                        onTap: () => _showUpdateDueDate(context),
                      ),
                      _Tile(
                        icon: Icons.monitor_weight_outlined,
                        label: 'Weight Unit',
                        trailing: _UnitPicker(
                          options: const ['kg', 'lbs'],
                          selected: _selectedWeightUnit,
                          onChanged: (v) => setState(() => _selectedWeightUnit = v),
                        ),
                        onTap: null,
                      ),
                      _Tile(
                        icon: Icons.straighten_outlined,
                        label: 'Length Unit',
                        trailing: _UnitPicker(
                          options: const ['cm', 'in'],
                          selected: _selectedLengthUnit,
                          onChanged: (v) => setState(() => _selectedLengthUnit = v),
                        ),
                        onTap: null,
                      ),
                    ]),
                    const SizedBox(height: 20),
                    _buildSectionHeader('Notifications'),
                    _buildGroup([
                      _Switch(
                        icon: Icons.notifications_outlined,
                        label: 'Push Notifications',
                        subtitle: 'Receive all app notifications',
                        value: notifs.pushEnabled,
                        onChanged: (_) =>
                            ref.read(_notifPrefsProvider.notifier).toggle('push'),
                      ),
                      _Switch(
                        icon: Icons.calendar_today_outlined,
                        label: 'Appointment Reminders',
                        subtitle: 'Get reminded before appointments',
                        value: notifs.appointmentReminders && notifs.pushEnabled,
                        enabled: notifs.pushEnabled,
                        onChanged: (_) =>
                            ref.read(_notifPrefsProvider.notifier).toggle('appointments'),
                      ),
                      _Switch(
                        icon: Icons.group_outlined,
                        label: 'Community Activity',
                        subtitle: 'Likes, replies, and mentions',
                        value: notifs.communityActivity && notifs.pushEnabled,
                        enabled: notifs.pushEnabled,
                        onChanged: (_) =>
                            ref.read(_notifPrefsProvider.notifier).toggle('community'),
                      ),
                      _Switch(
                        icon: Icons.bar_chart_outlined,
                        label: 'Weekly Updates',
                        subtitle: 'Weekly pregnancy progress digest',
                        value: notifs.weeklyUpdates && notifs.pushEnabled,
                        enabled: notifs.pushEnabled,
                        onChanged: (_) =>
                            ref.read(_notifPrefsProvider.notifier).toggle('weekly'),
                      ),
                      _Switch(
                        icon: Icons.child_care_outlined,
                        label: 'Pregnancy Milestones',
                        subtitle: 'Alerts for each new week',
                        value: notifs.pregnancyMilestones && notifs.pushEnabled,
                        enabled: notifs.pushEnabled,
                        onChanged: (_) =>
                            ref.read(_notifPrefsProvider.notifier).toggle('milestones'),
                      ),
                    ]),
                    const SizedBox(height: 20),
                    _buildSectionHeader('Security'),
                    _buildGroup([
                      _Switch(
                        icon: Icons.fingerprint,
                        label: 'Biometric Login',
                        subtitle: 'Use fingerprint or face to sign in',
                        value: _biometricEnabled,
                        onChanged: (v) => setState(() => _biometricEnabled = v),
                      ),
                      _Tile(
                        icon: Icons.shield_outlined,
                        label: 'Privacy Settings',
                        onTap: () => _snack(context),
                      ),
                      _Tile(
                        icon: Icons.devices_outlined,
                        label: 'Manage Devices',
                        onTap: () => _snack(context),
                      ),
                    ]),
                    const SizedBox(height: 20),
                    _buildSectionHeader('Preferences'),
                    _buildGroup([
                      _Tile(
                        icon: Icons.language_outlined,
                        label: 'Language',
                        trailing: GestureDetector(
                          onTap: () => _showLanguagePicker(context),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _selectedLanguage,
                                style: const TextStyle(
                                    fontSize: 13, color: Color(0xFF9E9E9E)),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.chevron_right,
                                  color: Color(0xFF9E9E9E), size: 18),
                            ],
                          ),
                        ),
                        onTap: () => _showLanguagePicker(context),
                      ),
                      _Tile(
                        icon: Icons.color_lens_outlined,
                        label: 'Appearance',
                        trailing: const Text(
                          'Light',
                          style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
                        ),
                        onTap: () => _snack(context),
                      ),
                    ]),
                    const SizedBox(height: 20),
                    _buildSectionHeader('Support'),
                    _buildGroup([
                      _Tile(
                        icon: Icons.help_outline,
                        label: 'Help Center',
                        onTap: () => _snack(context),
                      ),
                      _Tile(
                        icon: Icons.chat_bubble_outline,
                        label: 'Contact Us',
                        onTap: () => _snack(context),
                      ),
                      _Tile(
                        icon: Icons.star_outline,
                        label: 'Rate the App',
                        onTap: () => _snack(context),
                      ),
                      _Tile(
                        icon: Icons.description_outlined,
                        label: 'Terms & Privacy Policy',
                        onTap: () => _snack(context),
                      ),
                    ]),
                    const SizedBox(height: 20),
                    _buildSectionHeader('Data'),
                    _buildGroup([
                      _Tile(
                        icon: Icons.download_outlined,
                        label: 'Export My Data',
                        onTap: () => _snack(context),
                      ),
                      _Tile(
                        icon: Icons.delete_outline,
                        label: 'Delete Account',
                        labelColor: Colors.red,
                        iconColor: Colors.red,
                        onTap: () => _showDeleteAccount(context),
                      ),
                    ]),
                    const SizedBox(height: 24),
                    _buildLogoutButton(context),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        'MummyMap v1.0.0',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            'Settings',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A)),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: Color(0xFFE8D5F5),
                child: Icon(Icons.person, color: Color(0xFF3F2868), size: 28),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _snack(context),
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF3F2868),
                    ),
                    child: const Icon(Icons.camera_alt,
                        color: Colors.white, size: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kelly Kirkland',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A)),
                ),
                const SizedBox(height: 2),
                const Text(
                  'kellykirland@gmail.com',
                  style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8D5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '2nd Trimester  •  Week 20',
                    style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF3F2868),
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _snack(context),
            child: const Icon(Icons.edit_outlined,
                color: Color(0xFF9E9E9E), size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF9E9E9E),
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildGroup(List<Widget> tiles) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < tiles.length; i++) ...[
            tiles[i],
            if (i < tiles.length - 1)
              const Divider(
                  height: 1,
                  indent: 52,
                  endIndent: 16,
                  color: Color(0xFFF5F5F5)),
          ],
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton.icon(
          onPressed: () => _showLogoutConfirm(context),
          icon: const Icon(Icons.logout, color: Colors.red, size: 20),
          label: const Text(
            'Log Out',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600, color: Colors.red),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.red, width: 1.5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30)),
          ),
        ),
      ),
    );
  }

  void _snack(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coming soon'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showUpdateDueDate(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Update Due Date',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A)),
            ),
            const SizedBox(height: 8),
            const Text(
              'This will recalculate your pregnancy progress.',
              style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _snack(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F2868),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
                child: const Text(
                  'Pick New Date',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    const languages = ['English', 'French', 'Yoruba', 'Igbo', 'Hausa', 'Pidgin'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select Language',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A)),
                ),
              ),
            ),
            ...languages.map(
              (lang) => ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                title: Text(lang,
                    style: const TextStyle(
                        fontSize: 15, color: Color(0xFF1A1A1A))),
                trailing: _selectedLanguage == lang
                    ? const Icon(Icons.check_circle, color: Color(0xFF3F2868))
                    : null,
                onTap: () {
                  setState(() => _selectedLanguage = lang);
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.logout, color: Colors.red, size: 28),
            ),
            const SizedBox(height: 16),
            const Text(
              'Log Out',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Are you sure you want to log out of your account?',
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
                          borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF1A1A1A),
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                       Navigator.push(context, MaterialPageRoute(builder: (_) => const SignIn()));
                     
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Log Out',
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccount(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.delete_forever, color: Colors.red, size: 28),
            ),
            const SizedBox(height: 16),
            const Text(
              'Delete Account',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A)),
            ),
            const SizedBox(height: 8),
            const Text(
              'This will permanently delete your account and all your data. This action cannot be undone.',
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
                          borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF1A1A1A),
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _snack(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Delete',
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? labelColor;
  final Color? iconColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _Tile({
    required this.icon,
    required this.label,
    this.labelColor,
    this.iconColor,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: (iconColor ?? const Color(0xFF3F2868)).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18,
                  color: iconColor ?? const Color(0xFF3F2868)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  color: labelColor ?? const Color(0xFF1A1A1A),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailing != null)
              trailing!
            else if (onTap != null)
              const Icon(Icons.chevron_right,
                  color: Color(0xFF9E9E9E), size: 20),
          ],
        ),
      ),
    );
  }
}

class _Switch extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _Switch({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.45,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF3F2868).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: const Color(0xFF3F2868)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF1A1A1A),
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF9E9E9E)),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: enabled ? onChanged : null,
              activeColor: const Color(0xFF3F2868),
              activeTrackColor: const Color(0xFF3F2868).withOpacity(0.3),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: const Color(0xFFE0E0E0),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnitPicker extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onChanged;

  const _UnitPicker({
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options.map((opt) {
          final isSelected = opt == selected;
          return GestureDetector(
            onTap: () => onChanged(opt),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF3F2868) : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                opt,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF9E9E9E),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mummymap/data/models/profile_model.dart';
import 'package:mummymap/presentation/providers/settings_provider.dart';
import 'package:mummymap/presentation/providers/pregnancy_provider.dart';
import 'package:mummymap/presentation/providers/profile_provider.dart';
import 'package:mummymap/presentation/providers/auth_provider.dart';
import 'package:mummymap/presentation/pages/profile_setup/steps/get_to_know_you.dart';
import 'package:mummymap/presentation/pages/auth/signin.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _babyNameController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;

  @override
  void initState() {
    super.initState();
    final s = ref.read(settingsProvider);
    _babyNameController = TextEditingController(text: s.babyName);
    _firstNameController = TextEditingController(text: s.firstName);
    _lastNameController = TextEditingController(text: s.lastName);
    Future.microtask(
      () => ref.read(profileProvider.notifier).loadMyProfile(),
    );
  }

  @override
  void dispose() {
    _babyNameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  ProfileModel? get _profile => ref.read(profileProvider).value;

  Future<void> _patchProfile(ProfileModel updated) async {
    try {
      await ref.read(profileProvider.notifier).updateFields(updated);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save change. Check your connection.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _onFirstChildChanged(String? v) {
    ref.read(settingsProvider.notifier).setFirstChild(v);
    final base = _profile ?? ProfileModel();
    _patchProfile(base.copyWith(
      numberOfChildren: ProfileMappers.firstChildToCount(v),
    ));
  }

  void _onBabyBornChanged(bool v) {
    ref.read(settingsProvider.notifier).setBabyAlreadyBorn(v);
    final base = _profile ?? ProfileModel();
    _patchProfile(base.copyWith(isPregnant: !v));
  }

  void _onBloodGroupChanged(String? display) {
    final base = _profile ?? ProfileModel();
    _patchProfile(base.copyWith(
      bloodType: ProfileMappers.bloodTypeToApi(display),
    ));
  }

  Future<void> _pickDob() async {
    final current = _profile?.dateOfBirth ?? DateTime(1990);
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF3F2868),
            onPrimary: Colors.white,
            onSurface: Color(0xFF1A1A1A),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      final base = _profile ?? ProfileModel();
      await _patchProfile(base.copyWith(dateOfBirth: picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final pregnancy = ref.watch(pregnancyProvider);
    final profile = ref.watch(profileProvider).value;
    final notifier = ref.read(settingsProvider.notifier);

    final bloodDisplay = ProfileMappers.bloodTypeToDisplay(profile?.bloodType);
    final dobText = profile?.dateOfBirth != null
        ? DateFormat('MMM d, yyyy').format(profile!.dateOfBirth!)
        : null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildProfileHeader(settings, profile),
                    const SizedBox(height: 32),
                    _buildSectionLabel('PREGNANCY'),
                    _buildDivider(),
                    _buildRowItem(
                      icon: Icons.calendar_today_outlined,
                      label: 'Due Date',
                      trailing: pregnancy != null
                          ? DateFormat('MMM d, yyyy').format(pregnancy.dueDate)
                          : (profile?.dueDate != null
                              ? DateFormat('MMM d, yyyy')
                                  .format(profile!.dueDate!)
                              : null),
                    ),
                    _buildDivider(),
                    _buildTappableItem(
                      icon: Icons.calculate_outlined,
                      label: 'Due Date Calculator',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GetToKnowYou(
                              onComplete: () => Navigator.pop(context)),
                        ),
                      ),
                    ),
                    _buildDivider(),
                    _buildDropdownItem(
                      icon: Icons.child_care_outlined,
                      label: "Baby's Sex",
                      value: settings.babySex,
                      hint: 'Select',
                      items: const ['Boy', 'Girl', 'Twins', 'Unknown'],
                      onChanged: (v) => notifier.setBabySex(v),
                    ),
                    _buildDivider(),
                    _buildTextFieldItem(
                      icon: Icons.badge_outlined,
                      label: "Baby's Name",
                      controller: _babyNameController,
                      hint: 'Type here...',
                      onSubmitted: (v) => notifier.setBabyName(v),
                    ),
                    _buildDivider(),
                    _buildDropdownItem(
                      icon: Icons.bloodtype_outlined,
                      label: 'Blood Group',
                      value: bloodDisplay,
                      hint: 'Select',
                      items: const [
                        'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
                      ],
                      onChanged: _onBloodGroupChanged,
                    ),
                    _buildDivider(),
                    _buildTappableItem(
                      icon: Icons.cake_outlined,
                      label: 'Date Of Birth',
                      trailing: dobText ?? 'Select',
                      onTap: _pickDob,
                    ),
                    _buildDivider(),
                    _buildDropdownItem(
                      icon: Icons.child_friendly_outlined,
                      label: 'First Child?',
                      value: settings.firstChild,
                      hint: 'Select',
                      items: const ['Yes', 'No'],
                      onChanged: _onFirstChildChanged,
                    ),
                    _buildDivider(),
                    _buildToggleItem(
                      icon: Icons.baby_changing_station_outlined,
                      label: 'Baby Already Born?',
                      value: settings.babyAlreadyBorn,
                      onChanged: _onBabyBornChanged,
                    ),
                    _buildDivider(),
                    const SizedBox(height: 24),
                    _buildSectionLabel('APP SETTINGS'),
                    _buildDivider(),
                    _buildToggleItem(
                      icon: Icons.notifications_outlined,
                      label: 'Reminders',
                      value: settings.reminders,
                      onChanged: (v) => notifier.setReminders(v),
                    ),
                    _buildDivider(),
                    _buildDropdownItem(
                      icon: Icons.straighten_outlined,
                      label: 'Length Units',
                      value: settings.lengthUnit,
                      hint: 'Select',
                      items: const ['Inches (in)', 'Centimeters (cm)'],
                      onChanged: (v) {
                        if (v != null) notifier.setLengthUnit(v);
                      },
                    ),
                    _buildDivider(),
                    _buildDropdownItem(
                      icon: Icons.monitor_weight_outlined,
                      label: 'Weight Units',
                      value: settings.weightUnit,
                      hint: 'Select',
                      items: const ['Pounds (lbs)', 'Kilograms (kg)'],
                      onChanged: (v) {
                        if (v != null) notifier.setWeightUnit(v);
                      },
                    ),
                    _buildDivider(),
                    _buildTappableItem(
                      icon: Icons.swap_horiz_outlined,
                      label: 'Transfer Data',
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Transfer Data coming soon'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      ),
                    ),
                    _buildDivider(),
                    const SizedBox(height: 24),
                    _buildSectionLabel('ACCOUNT DETAILS'),
                    _buildDivider(),
                    _buildTextFieldItem(
                      icon: Icons.edit_outlined,
                      label: 'First Name',
                      controller: _firstNameController,
                      hint: 'First name',
                      onSubmitted: (v) => notifier.setFirstName(v),
                    ),
                    _buildDivider(),
                    _buildTextFieldItem(
                      icon: Icons.edit_outlined,
                      label: 'Last Name',
                      controller: _lastNameController,
                      hint: 'Last name',
                      onSubmitted: (v) => notifier.setLastName(v),
                    ),
                    _buildDivider(),
                    _buildDropdownItem(
                      icon: Icons.cake_outlined,
                      label: 'Age',
                      value: settings.age?.toString(),
                      hint: 'Select',
                      items: List.generate(52, (i) => '${i + 13}'),
                      onChanged: (v) {
                        if (v != null) notifier.setAge(int.tryParse(v));
                      },
                    ),
                    _buildDivider(),
                    _buildDropdownItem(
                      icon: Icons.people_outline,
                      label: 'Relationship',
                      value: settings.relationship,
                      hint: 'Select',
                      items: const ['Mother', 'Father', 'Guardian', 'Partner'],
                      onChanged: (v) {
                        if (v != null) notifier.setRelationship(v);
                      },
                    ),
                    _buildDivider(),
                    const SizedBox(height: 24),
                    _buildSectionLabel('FEEDBACK'),
                    _buildDivider(),
                    _buildTappableItem(
                      icon: Icons.mail_outline,
                      label: 'Send Feedback',
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Send Feedback coming soon'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      ),
                    ),
                    _buildDivider(),
                    _buildTappableItem(
                      icon: Icons.star_outline,
                      label: 'Rate Us On Play Store',
                      onTap: () {},
                    ),
                    _buildDivider(),
                    _buildTappableItem(
                      icon: Icons.star_outline,
                      label: 'Rate Us On App Store',
                      onTap: () {},
                    ),
                    _buildDivider(),
                    const SizedBox(height: 24),
                    _buildSectionLabel('ABOUT'),
                    _buildDivider(),
                    _buildLinkItem(
                      icon: Icons.info_outline,
                      label: 'About Us',
                      onTap: () {},
                    ),
                    _buildDivider(),
                    _buildLinkItem(
                      icon: Icons.description_outlined,
                      label: 'Terms Of Use',
                      onTap: () {},
                    ),
                    _buildDivider(),
                    _buildLinkItem(
                      icon: Icons.shield_outlined,
                      label: 'Privacy Policy',
                      onTap: () {},
                    ),
                    _buildDivider(),
                    const SizedBox(height: 32),
                    _buildSignOutButton(context),
                    const SizedBox(height: 20),
                    _buildFooter(settings, profile),
                    const SizedBox(height: 32),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF0F0F0),
              ),
              child: const Icon(Icons.arrow_back,
                  color: Color(0xFF1A1A1A), size: 22),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/logo3.png',
                  height: 28,
                  width: 28,
                  errorBuilder: (_, __, ___) =>
                      const SizedBox(width: 28, height: 28)),
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
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(SettingsState settings, ProfileModel? profile) {
    final hasImage = (profile?.profileImage ?? '').isNotEmpty;
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE8D5F5),
                  border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
                  image: hasImage
                      ? DecorationImage(
                          image: NetworkImage(profile!.profileImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: hasImage
                    ? null
                    : const Icon(Icons.person,
                        size: 48, color: Color(0xFF3F2868)),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF3F2868),
                  ),
                  child: const Icon(Icons.camera_alt,
                      size: 14, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            settings.fullName,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF9E9E9E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF9E9E9E),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0));
  }

  Widget _buildRowItem({
    required IconData icon,
    required String label,
    String? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF1A1A1A)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 14, color: Color(0xFF1A1A1A))),
          ),
          if (trailing != null)
            Text(trailing,
                style: const TextStyle(
                    fontSize: 14, color: Color(0xFF9E9E9E))),
        ],
      ),
    );
  }

  Widget _buildTappableItem({
    required IconData icon,
    required String label,
    String? trailing,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF1A1A1A)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 14, color: Color(0xFF1A1A1A))),
            ),
            if (trailing != null)
              Text(trailing,
                  style: const TextStyle(
                      fontSize: 14, color: Color(0xFF9E9E9E))),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF1A1A1A)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 14, color: Color(0xFF1A1A1A))),
            ),
            const Icon(Icons.open_in_new, size: 16, color: Color(0xFF9E9E9E)),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF1A1A1A)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 14, color: Color(0xFF1A1A1A))),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFF3F2868),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFE0E0E0),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownItem({
    required IconData icon,
    required String label,
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF1A1A1A)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 14, color: Color(0xFF1A1A1A))),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(hint,
                  style: const TextStyle(
                      fontSize: 14, color: Color(0xFF9E9E9E))),
              icon: const Icon(Icons.keyboard_arrow_down,
                  size: 18, color: Color(0xFF9E9E9E)),
              style: const TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
              items: items
                  .map((item) => DropdownMenuItem(
                        value: item,
                        child: Text(item,
                            style: const TextStyle(
                                fontSize: 14, color: Color(0xFF1A1A1A))),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldItem({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required String hint,
    required ValueChanged<String> onSubmitted,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF1A1A1A)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 14, color: Color(0xFF1A1A1A))),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                    fontSize: 14, color: Color(0xFF9E9E9E)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              onSubmitted: onSubmitted,
              onEditingComplete: () {
                onSubmitted(controller.text);
                FocusScope.of(context).unfocus();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: () => _confirmSignOut(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3F2868),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Sign Out',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(SettingsState settings, ProfileModel? profile) {
    final now = DateTime.now();
    final formatted = '${_monthName(now.month)} ${now.day}, ${now.year}';
    final email = profile?.email ?? settings.email;
    return Column(
      children: [
        Text('Last backup on: $formatted',
            style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
        const SizedBox(height: 4),
        Text(
          email.isNotEmpty ? 'Account: $email' : '',
          style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
        ),
      ],
    );
  }

  String _monthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month];
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
                      await _signOut(context);
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

  Future<void> _signOut(BuildContext context) async {
    try {
      await ref.read(settingsProvider.notifier).clear();
      await ref.read(authRepositoryProvider).logoutCurrentDevice();
    } catch (_) {}
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SignIn()),
      (_) => false,
    );
  }
}
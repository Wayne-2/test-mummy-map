import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mummymap/data/models/profile_model.dart';
import 'package:mummymap/presentation/providers/profile_provider.dart';
import 'package:mummymap/presentation/providers/settings_provider.dart';
import 'package:mummymap/presentation/providers/pregnancy_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(profileProvider.notifier).loadMyProfile(),
    );
  }

  ProfileModel? get _profile => ref.read(profileProvider).value;

  Future<void> _patch(ProfileModel updated) async {
    try {
      await ref.read(profileProvider.notifier).updateFields(updated);
    } catch (_) {
      _toast('Could not save change. Check your connection.', isError: true);
    }
  }

  void _toast(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : const Color(0xFF3F2868),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _changePhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;
    try {
      await ref.read(profileProvider.notifier).changePhoto(picked.path);
      _toast('Photo updated');
    } catch (_) {
      _toast('Could not upload photo.', isError: true);
    }
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
      await _patch((_profile ?? ProfileModel()).copyWith(dateOfBirth: picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider);
    final profile = state.value;
    final settings = ref.watch(settingsProvider);
    final pregnancy = ref.watch(pregnancyProvider);

    final firstChild = profile?.numberOfChildren == 0
        ? 'Yes'
        : (profile?.numberOfChildren != null ? 'No' : null);
    final babyAlreadyBorn = profile?.isPregnant == false;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: state.isLoading && profile == null
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF3F2868)))
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  _header(settings, profile),
                  const SizedBox(height: 24),
                  _statsRow(profile),
                  const SizedBox(height: 24),
                  if (pregnancy != null) _pregnancyCard(pregnancy),
                  const SizedBox(height: 16),
                  _sectionTitle('Details'),
                  _editableTile(
                    icon: Icons.cake_outlined,
                    label: 'Date Of Birth',
                    value: profile?.dateOfBirth != null
                        ? DateFormat('MMM d, yyyy')
                            .format(profile!.dateOfBirth!)
                        : 'Set',
                    onTap: _pickDob,
                  ),
                  _dropdownTile(
                    icon: Icons.bloodtype_outlined,
                    label: 'Blood Group',
                    value:
                        ProfileMappers.bloodTypeToDisplay(profile?.bloodType),
                    items: const [
                      'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
                    ],
                    onChanged: (v) => _patch((_profile ?? ProfileModel())
                        .copyWith(bloodType: ProfileMappers.bloodTypeToApi(v))),
                  ),
                  _dropdownTile(
                    icon: Icons.child_friendly_outlined,
                    label: 'First Child?',
                    value: firstChild,
                    items: const ['Yes', 'No'],
                    onChanged: (v) {
                      _patch((_profile ?? ProfileModel()).copyWith(
                        numberOfChildren:
                            ProfileMappers.firstChildToCount(v),
                      ));
                    },
                  ),
                  _toggleTile(
                    icon: Icons.baby_changing_station_outlined,
                    label: 'Baby Already Born?',
                    value: babyAlreadyBorn,
                    onChanged: (v) {
                      _patch((_profile ?? ProfileModel())
                          .copyWith(isPregnant: !v));
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _header(SettingsState settings, ProfileModel? profile) {
    final hasImage = (profile?.profileImage ?? '').isNotEmpty;
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE8D5F5),
                border: Border.all(color: Colors.white, width: 3),
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
                      size: 56, color: Color(0xFF3F2868)),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _changePhoto,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF3F2868),
                  ),
                  child: const Icon(Icons.camera_alt,
                      size: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          settings.fullName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        if ((profile?.email ?? '').isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            profile!.email!,
            style: const TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
          ),
        ],
      ],
    );
  }

  Widget _statsRow(ProfileModel? profile) {
    Widget stat(String label, int? n) => Column(
          children: [
            Text(
              '${n ?? 0}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF9E9E9E))),
          ],
        );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          stat('Posts', profile?.postsCount),
          stat('Followers', profile?.followersCount),
          stat('Following', profile?.followingCount),
        ],
      ),
    );
  }

  Widget _pregnancyCard(pregnancy) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3F2868),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${pregnancy.trimesterLabel} · Week ${pregnancy.currentWeek}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Due ${DateFormat('MMM d, yyyy').format(pregnancy.dueDate)}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.pregnant_woman, color: Colors.white, size: 40),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          t.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF9E9E9E),
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _editableTile({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF3F2868)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 14, color: Color(0xFF1A1A1A))),
            ),
            Text(value,
                style: const TextStyle(
                    fontSize: 14, color: Color(0xFF9E9E9E))),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 18, color: Color(0xFF9E9E9E)),
          ],
        ),
      ),
    );
  }

  Widget _dropdownTile({
    required IconData icon,
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF3F2868)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 14, color: Color(0xFF1A1A1A))),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: const Text('Select',
                  style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E))),
              icon: const Icon(Icons.keyboard_arrow_down,
                  size: 18, color: Color(0xFF9E9E9E)),
              items: items
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e,
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

  Widget _toggleTile({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF3F2868)),
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
}
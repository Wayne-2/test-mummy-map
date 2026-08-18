import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../data/models/calendar_models.dart';
import '../../../../providers/calendar_provider.dart';
import '../widgets/add_event_sheet.dart';
import '../widgets/calendar_widgets.dart';

class RemindersTab extends ConsumerStatefulWidget {
  const RemindersTab({super.key});

  @override
  ConsumerState<RemindersTab> createState() => _RemindersTabState();
}

class _RemindersTabState extends ConsumerState<RemindersTab> {
  String _filter = 'Today';
  List<ReminderModel> _reminders = [];
  bool _isLoading = true;

  final Map<String, bool> _sectionExpanded = {
    'Morning': true,
    'Afternoon': true,
    'Evening': true,
    'Completed': true,
    'Ongoing': true,
    'Repeating': true,
  };

  Map<String, List<ReminderModel>> get _grouped {
    final state = ref.watch(calendarProvider);
    final reminders = state.reminders;
    if (_filter == 'All') {
      return {
        'Completed':
            reminders.where((r) => r.completed).toList(),
        'Ongoing': reminders
            .where((r) => !r.completed && r.enabled)
            .toList(),
        'Repeating': reminders
            .where((r) => !r.completed && r.repeatDays != null)
            .toList(),
      };
    }
    return {
      'Morning':
          reminders.where((r) => r.timeOfDay == 'Morning').toList(),
      'Afternoon': reminders
          .where((r) => r.timeOfDay == 'Afternoon')
          .toList(),
      'Evening':
          reminders.where((r) => r.timeOfDay == 'Evening').toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(calendarProvider);
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return Stack(
      children: [
        Column(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  FilterChipWidget(
                    label: 'All',
                    selected: _filter == 'All',
                    onTap: () => setState(() => _filter = 'All'),
                  ),
                  const SizedBox(width: 8),
                  FilterChipWidget(
                    label: 'Today',
                    selected: _filter == 'Today',
                    onTap: () => setState(() => _filter = 'Today'),
                  ),
                  const SizedBox(width: 8),
                  FilterChipWidget(
                    label: 'Upcoming',
                    selected: _filter == 'Upcoming',
                    onTap: () =>
                        setState(() => _filter = 'Upcoming'),
                  ),
                  const Spacer(),
                  const Icon(Icons.search,
                      color: Color(0xFF1A1A1A), size: 22),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: state.reminders.isEmpty 
                  ? const Center(
                      child: Text(
                        'No reminders yet.\nTap + Add to create one!', 
                        textAlign: TextAlign.center, 
                        style: TextStyle(color: Color(0xFF9E9E9E)),
                      ),
                    )
                  : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  ..._grouped.entries.map((entry) {
                    final section = entry.key;
                    final items = entry.value;
                    if (items.isEmpty) return const SizedBox();
                    final isExpanded =
                        _sectionExpanded[section] ?? true;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => setState(() =>
                              _sectionExpanded[section] =
                                  !isExpanded),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(
                                    vertical: 12),
                            child: Row(
                              children: [
                                Icon(
                                  _sectionIcon(section),
                                  size: 16,
                                  color: const Color(0xFF555555),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  section,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  isExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: const Color(0xFF9E9E9E),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isExpanded)
                          ...items.map((r) =>
                              ReminderTile(
                                reminder: r,
                                onToggle: (v) {
                                  r.enabled = v;
                                  ref.read(calendarProvider.notifier).updateReminder(r);
                                },
                                onDelete: () {
                                  ref.read(calendarProvider.notifier).deleteReminder(r.id);
                                },
                                onComplete: () {
                                  r.completed = !r.completed;
                                  ref.read(calendarProvider.notifier).updateReminder(r);
                                },
                              )),
                        const SizedBox(height: 4),
                      ],
                    );
                  }),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 24,
          right: 16,
          child: GestureDetector(
            onTap: () async {
              await _showAddSheet(context);
            },
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3F2868),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.add,
                      color: Colors.white, size: 26),
                ),
                const SizedBox(height: 4),
                const Text('Add',
                    style: TextStyle(
                        fontSize: 11, color: Color(0xFF9E9E9E))),
              ],
            ),
          ),
        ),
      ],
    );
  }

  IconData _sectionIcon(String section) {
    switch (section) {
      case 'Morning':
        return Icons.wb_twilight;
      case 'Afternoon':
        return Icons.wb_sunny_outlined;
      case 'Evening':
        return Icons.nights_stay_outlined;
      case 'Completed':
        return Icons.check_circle_outline;
      case 'Ongoing':
        return Icons.loop;
      case 'Repeating':
        return Icons.repeat;
      default:
        return Icons.alarm;
    }
  }

  Future<void> _showAddSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) =>
          const AddEventSheet(initialType: NewEventType.reminder),
    );
  }
}

class ReminderTile extends StatefulWidget {
  final ReminderModel reminder;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;
  final VoidCallback onComplete;

  const ReminderTile({
    super.key,
    required this.reminder,
    required this.onToggle,
    required this.onDelete,
    required this.onComplete,
  });

  @override
  State<ReminderTile> createState() => _ReminderTileState();
}

class _ReminderTileState extends State<ReminderTile> {
  bool _swiped = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.reminder;

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null &&
            details.primaryVelocity! < -200) {
          setState(() => _swiped = true);
        } else if (details.primaryVelocity != null &&
            details.primaryVelocity! > 200) {
          setState(() => _swiped = false);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF0F0F0)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _swiped
              ? Row(
                  children: [
                    Expanded(
                      child: _buildTileContent(r),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _swiped = false),
                      child: Container(
                        width: 56,
                        height: 70,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.edit_outlined,
                            color: Color(0xFF555555)),
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.onDelete,
                      child: Container(
                        width: 56,
                        height: 70,
                        color: Colors.red,
                        child: const Icon(Icons.delete_outline,
                            color: Colors.white),
                      ),
                    ),
                  ],
                )
              : _buildTileContent(r),
        ),
      ),
    );
  }

  Widget _buildTileContent(ReminderModel r) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: widget.onComplete,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: r.completed
                    ? const Color(0xFF3F2868)
                    : Colors.transparent,
                border: Border.all(
                  color: r.completed
                      ? const Color(0xFF3F2868)
                      : const Color(0xFFBDBDBD),
                  width: 1.5,
                ),
              ),
              child: r.completed
                  ? const Icon(Icons.check,
                      color: Colors.white, size: 13)
                  : null,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A1A1A),
                    decoration: r.completed
                        ? TextDecoration.lineThrough
                        : null,
                    decorationColor: const Color(0xFF9E9E9E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  r.repeatDays != null
                      ? '${r.time}  •  ${r.repeatDays}'
                      : r.time,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF9E9E9E)),
                ),
              ],
            ),
          ),
          Switch(
            value: r.enabled,
            onChanged: widget.onToggle,
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

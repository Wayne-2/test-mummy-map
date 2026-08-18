import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mummymap/presentation/providers/doctors_provider.dart';
import '../../../../../data/models/calendar_models.dart';
import '../../../../providers/calendar_provider.dart';
import '../widgets/add_event_sheet.dart';
import '../widgets/agenda_sheet.dart';
import '../widgets/calendar_widgets.dart';

class CalendarTab extends ConsumerStatefulWidget {
  const CalendarTab({super.key});

  @override
  ConsumerState<CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends ConsumerState<CalendarTab> {
  DateTime _focusedMonth = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  bool _fabExpanded = false;

  List<CalendarEvent> get _allEvents {
    final docState = ref.watch(doctorsProvider);
    final calState = ref.watch(calendarProvider);
    
    final allDocApps = [...docState.upcoming, ...docState.history];
    final docEvents = allDocApps.map((app) {
      DateTime parsedDate;
      try {
        parsedDate = DateTime.parse(app.date);
      } catch (e) {
        parsedDate = DateTime.now();
      }
      return CalendarEvent(
        id: 'doc_${app.id}',
        title: 'Appointment with ${app.doctor.name}',
        date: parsedDate,
        type: EventType.appointment,
        color: const Color(0xFF3F2868),
        timeLabel: app.time,
        emoji: '🩺',
      );
    }).toList();
    
    return [...docEvents, ...calState.events];
  }

  List<CalendarEvent> get _todayEvents {
    final t = DateTime.now();
    return _allEvents.where((e) {
      final d = e.date;
      return d.year == t.year && d.month == t.month && d.day == t.day;
    }).toList();
  }

  List<CalendarEvent> _eventsForDay(DateTime day) =>
      _allEvents.where((e) {
        return e.date.year == day.year &&
            e.date.month == day.month &&
            e.date.day == day.day;
      }).toList();

  void _prevMonth() {
    setState(() {
      _focusedMonth =
          DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth =
          DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayEvents = _todayEvents;
    final appointments =
        todayEvents.where((e) => e.type == EventType.appointment).length;
    final groupMeetups =
        todayEvents.where((e) => e.type == EventType.group).length;

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Color(0xFF3F2868), width: 3),
                  ),
                  color: Color(0xFFF9F6FF),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.alarm,
                        size: 16, color: Color(0xFF3F2868)),
                    const SizedBox(width: 8),
                    const Text(
                      'Today',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3F2868)),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${appointments + groupMeetups} Events',
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF555555)),
                    ),
                    if (groupMeetups > 0) ...[
                      const Text('  •  ',
                          style: TextStyle(color: Color(0xFF9E9E9E))),
                      Text(
                        '$groupMeetups Group Meetup',
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF555555)),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Today',
                            style: TextStyle(
                                fontSize: 13, color: Color(0xFF9E9E9E))),
                        Text(
                          _formatHeaderDate(today),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.chevron_left,
                          color: Color(0xFF1A1A1A)),
                      onPressed: _prevMonth,
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right,
                          color: Color(0xFF1A1A1A)),
                      onPressed: _nextMonth,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _buildCalendarGrid(),
              _buildMonthStrip(),
              const SizedBox(height: 16),
              _buildTodayHighlights(todayEvents),
              const SizedBox(height: 100),
            ],
          ),
        ),
        Positioned(
          bottom: 24,
          right: 16,
          child: _buildFab(context),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    final firstDay =
        DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7;
    final today = DateTime.now();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map((d) => Expanded(
                      child: Center(
                        child: Text(d,
                            style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF9E9E9E),
                                fontWeight: FontWeight.w500)),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: startWeekday + daysInMonth,
            itemBuilder: (context, index) {
              if (index < startWeekday) return const SizedBox();
              final day = index - startWeekday + 1;
              final date = DateTime(
                  _focusedMonth.year, _focusedMonth.month, day);
              final isToday = date.year == today.year &&
                  date.month == today.month &&
                  date.day == today.day;
              final isSelected = date.year == _selectedDay.year &&
                  date.month == _selectedDay.month &&
                  date.day == _selectedDay.day;
              final events = _eventsForDay(date);

              return GestureDetector(
                onTap: () => setState(() => _selectedDay = date),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isToday || isSelected
                            ? const Color(0xFF3F2868)
                            : Colors.transparent,
                      ),
                      child: Center(
                        child: Text(
                          '$day',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isToday || isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isToday || isSelected
                                ? Colors.white
                                : const Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                    ),
                    if (events.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: events
                            .take(3)
                            .map((e) => Container(
                                  width: 4,
                                  height: 4,
                                  margin: const EdgeInsets.only(
                                      top: 2, left: 1, right: 1),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: e.color,
                                  ),
                                ))
                            .toList(),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMonthStrip() {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final currentMonthIndex = _focusedMonth.month - 1;

    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: months.length,
        itemBuilder: (context, index) {
          final isSelected = index == currentMonthIndex;
          return GestureDetector(
            onTap: () => setState(() {
              _focusedMonth =
                  DateTime(_focusedMonth.year, index + 1, 1);
            }),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFEDE7F6)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                months[index],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected
                      ? FontWeight.w600
                      : FontWeight.normal,
                  color: isSelected
                      ? const Color(0xFF3F2868)
                      : const Color(0xFF9E9E9E),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTodayHighlights(List<CalendarEvent> events) {
    if (events.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF5EEFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0C8FF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text('⚡', style: TextStyle(fontSize: 16)),
                SizedBox(width: 8),
                Text(
                  "Today's Highlights",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3F2868),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...events.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: e.color,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${e.emoji}  ${e.title} – ${e.timeLabel}',
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF333333)),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _showAgendaSheet(context, events),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3F2868),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'View Agenda',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFab(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_fabExpanded) ...[
          FabOption(
            label: 'Appointment',
            icon: Icons.edit_outlined,
            onTap: () {
              setState(() => _fabExpanded = false);
              _showAddSheet(context, initialType: NewEventType.appointment);
            },
          ),
          const SizedBox(height: 8),
          FabOption(
            label: 'Reminder',
            icon: Icons.notifications_outlined,
            onTap: () {
              setState(() => _fabExpanded = false);
              _showAddSheet(context, initialType: NewEventType.reminder);
            },
          ),
          const SizedBox(height: 8),
          FabOption(
            label: 'Event',
            icon: Icons.calendar_month,
            onTap: () {
              setState(() => _fabExpanded = false);
              _showAddSheet(context, initialType: NewEventType.event);
            },
          ),
          const SizedBox(height: 8),
        ],
        GestureDetector(
          onTap: () => setState(() => _fabExpanded = !_fabExpanded),
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF3F2868),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _fabExpanded ? Icons.close : Icons.add,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(height: 4),
              const Text('Add',
                  style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
            ],
          ),
        ),
      ],
    );
  }

  void _showAgendaSheet(
      BuildContext context, List<CalendarEvent> events) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AgendaSheet(events: events),
    );
  }

  void _showAddSheet(BuildContext context,
      {required NewEventType initialType}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AddEventSheet(initialType: initialType),
    );
  }

  String _formatHeaderDate(DateTime d) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month]} ${d.day}, ${d.year}';
  }
}

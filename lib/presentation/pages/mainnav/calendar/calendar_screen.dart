import 'package:flutter/material.dart';
import 'package:mummymap/data/models/doctor_model.dart';

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
            _CalendarAppBar(
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
                  _CalendarTab(),
                  _AppointmentsTab(),
                  _RemindersTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarAppBar extends StatelessWidget {
  final VoidCallback? onNotifications;
  final VoidCallback? onProfileTap;

  const _CalendarAppBar({this.onNotifications, this.onProfileTap});

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
              child: Icon(Icons.person, color: Color(0xFF3F2868), size: 22),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/logo3.png', height: 28, width: 28,
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
            onPressed: onNotifications,
          ),
        ],
      ),
    );
  }
}

// ─── CALENDAR TAB ─────────────────────────────────────────────────────────────

class _CalendarTab extends StatefulWidget {
  const _CalendarTab();

  @override
  State<_CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<_CalendarTab> {
  DateTime _focusedMonth = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  bool _fabExpanded = false;

  static const _seed = _SeedData();

  List<_CalendarEvent> get _todayEvents =>
      _seed.events.where((e) {
        final d = e.date;
        final t = DateTime.now();
        return d.year == t.year && d.month == t.month && d.day == t.day;
      }).toList();

  List<_CalendarEvent> _eventsForDay(DateTime day) =>
      _seed.events.where((e) {
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
        todayEvents.where((e) => e.type == _EventType.appointment).length;
    final groupMeetups =
        todayEvents.where((e) => e.type == _EventType.group).length;

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
                decoration: BoxDecoration(
                  border: const Border(
                    left: BorderSide(color: Color(0xFF3F2868), width: 3),
                  ),
                  color: const Color(0xFFF9F6FF),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.alarm,
                        size: 16, color: Color(0xFF3F2868)),
                    const SizedBox(width: 8),
                    Text(
                      'Today',
                      style: const TextStyle(
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

  Widget _buildTodayHighlights(List<_CalendarEvent> events) {
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
          _FabOption(
            label: 'Appointment',
            icon: Icons.edit_outlined,
            onTap: () {
              setState(() => _fabExpanded = false);
              _showAddSheet(context, initialType: _NewEventType.appointment);
            },
          ),
          const SizedBox(height: 8),
          _FabOption(
            label: 'Reminder',
            icon: Icons.notifications_outlined,
            onTap: () {
              setState(() => _fabExpanded = false);
              _showAddSheet(context, initialType: _NewEventType.reminder);
            },
          ),
          const SizedBox(height: 8),
          _FabOption(
            label: 'Event',
            icon: Icons.calendar_month,
            onTap: () {
              setState(() => _fabExpanded = false);
              _showAddSheet(context, initialType: _NewEventType.event);
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
      BuildContext context, List<_CalendarEvent> events) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AgendaSheet(events: events),
    );
  }

  void _showAddSheet(BuildContext context,
      {required _NewEventType initialType}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AddEventSheet(initialType: initialType),
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

// ─── APPOINTMENTS TAB ─────────────────────────────────────────────────────────

class _AppointmentsTab extends StatefulWidget {
  const _AppointmentsTab();

  @override
  State<_AppointmentsTab> createState() => _AppointmentsTabState();
}

class _AppointmentsTabState extends State<_AppointmentsTab> {
  String _filter = 'Upcoming';
  int _selectedDayOffset = 0;

  final List<DoctorAppointment> _appointments = kScheduledAppointments;

  List<DateTime> get _days {
    final today = DateTime.now();
    return List.generate(
        7, (i) => DateTime(today.year, today.month, today.day + i));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            const SizedBox(height: 12),
            _buildDayStrip(),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _FilterDropdown(
                    value: _filter,
                    items: const ['Upcoming', 'Past', 'Cancelled'],
                    onChanged: (v) {
                      if (v != null) setState(() => _filter = v);
                    },
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.calendar_month_outlined,
                        size: 18, color: Color(0xFF1A1A1A)),
                  ),
                  const Spacer(),
                  const Icon(Icons.search,
                      color: Color(0xFF1A1A1A), size: 22),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _appointments.isEmpty
                  ? const _EmptyAppointments()
                  : PageView.builder(
                      itemCount: _appointments.length,
                      controller:
                          PageController(viewportFraction: 0.92),
                      itemBuilder: (context, index) =>
                          _AppointmentCard(
                              appointment: _appointments[index]),
                    ),
            ),
          ],
        ),
        Positioned(
          bottom: 24,
          right: 16,
          child: GestureDetector(
            onTap: () => _showAddSheet(context),
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

  Widget _buildDayStrip() {
    final today = DateTime.now();
    final days = _days;
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: days.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = _selectedDayOffset == -1;
            return GestureDetector(
              onTap: () => setState(() => _selectedDayOffset = -1),
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFEDE7F6)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF3F2868)
                        : const Color(0xFFE0E0E0),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Today',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? const Color(0xFF3F2868)
                          : const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
              ),
            );
          }

          final day = days[index - 1];
          final isSelected = _selectedDayOffset == index - 1;
          final hasEvent = kScheduledAppointments.any((a) {
            return true;
          });
          final weekdayIndex = day.weekday - 1;

          return GestureDetector(
            onTap: () =>
                setState(() => _selectedDayOffset = index - 1),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFEDE7F6)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF3F2868)
                      : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '${dayNames[weekdayIndex]} ${day.day}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isSelected
                          ? const Color(0xFF3F2868)
                          : const Color(0xFF1A1A1A),
                    ),
                  ),
                  if (hasEvent && index == 2) ...[
                    const SizedBox(width: 4),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF3F2868),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) =>
          const _AddEventSheet(initialType: _NewEventType.appointment),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final DoctorAppointment appointment;

  const _AppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EEFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0C8FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Monday, April 7, 2025',
            style: const TextStyle(
                fontSize: 12, color: Color(0xFF9E9E9E)),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '${appointment.time}  •  ${appointment.doctor.specialty}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const Spacer(),
              const Icon(Icons.medical_services_outlined,
                  color: Color(0xFF3F2868), size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF3F2868),
                  child: Text(
                    appointment.doctor.name
                        .split(' ')
                        .map((w) => w[0])
                        .take(2)
                        .join(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  appointment.doctor.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.verified,
                    color: Color(0xFF3F2868), size: 14),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _InfoRow(
              icon: Icons.description_outlined,
              text: 'Checkup with ${appointment.doctor.name} to find out scheduled routine...'),
          const SizedBox(height: 8),
          const _InfoRow(
              icon: Icons.alarm, text: '30 mins before'),
          const SizedBox(height: 8),
          const _InfoRow(
              icon: Icons.location_on_outlined, text: 'Google meet'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {},
                child: const Row(
                  children: [
                    Icon(Icons.cancel_outlined,
                        size: 16, color: Color(0xFF9E9E9E)),
                    SizedBox(width: 4),
                    Text('Cancel',
                        style: TextStyle(
                            fontSize: 13, color: Color(0xFF9E9E9E))),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () {},
                child: const Row(
                  children: [
                    Icon(Icons.edit_calendar_outlined,
                        size: 16, color: Color(0xFF3F2868)),
                    SizedBox(width: 4),
                    Text('Reschedule',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3F2868))),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF9E9E9E)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
                fontSize: 13, color: Color(0xFF555555)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _EmptyAppointments extends StatelessWidget {
  const _EmptyAppointments();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFE8D5F5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.calendar_today_outlined,
                  size: 40, color: Color(0xFF3F2868)),
            ),
            const SizedBox(height: 20),
            const Text(
              'No appointments',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap + Add to schedule an appointment with a doctor',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── REMINDERS TAB ────────────────────────────────────────────────────────────

class _RemindersTab extends StatefulWidget {
  const _RemindersTab();

  @override
  State<_RemindersTab> createState() => _RemindersTabState();
}

class _RemindersTabState extends State<_RemindersTab> {
  String _filter = 'Today';

  final List<_Reminder> _reminders = _SeedData.seedReminders();

  final Map<String, bool> _sectionExpanded = {
    'Morning': true,
    'Afternoon': true,
    'Evening': true,
    'Completed': true,
    'Ongoing': true,
    'Repeating': true,
  };

  Map<String, List<_Reminder>> get _grouped {
    if (_filter == 'All') {
      return {
        'Completed':
            _reminders.where((r) => r.completed).toList(),
        'Ongoing': _reminders
            .where((r) => !r.completed && r.enabled)
            .toList(),
        'Repeating': _reminders
            .where((r) => !r.completed && r.repeatDays != null)
            .toList(),
      };
    }
    return {
      'Morning':
          _reminders.where((r) => r.timeOfDay == 'Morning').toList(),
      'Afternoon': _reminders
          .where((r) => r.timeOfDay == 'Afternoon')
          .toList(),
      'Evening':
          _reminders.where((r) => r.timeOfDay == 'Evening').toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    selected: _filter == 'All',
                    onTap: () => setState(() => _filter = 'All'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Today',
                    selected: _filter == 'Today',
                    onTap: () => setState(() => _filter = 'Today'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
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
              child: ListView(
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
                              _ReminderTile(
                                reminder: r,
                                onToggle: (v) => setState(
                                    () => r.enabled = v),
                                onDelete: () => setState(
                                    () => _reminders.remove(r)),
                                onComplete: () => setState(
                                    () => r.completed = !r.completed),
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
            onTap: () => _showAddSheet(context),
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

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) =>
          const _AddEventSheet(initialType: _NewEventType.reminder),
    );
  }
}

class _ReminderTile extends StatefulWidget {
  final _Reminder reminder;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;
  final VoidCallback onComplete;

  const _ReminderTile({
    required this.reminder,
    required this.onToggle,
    required this.onDelete,
    required this.onComplete,
  });

  @override
  State<_ReminderTile> createState() => _ReminderTileState();
}

class _ReminderTileState extends State<_ReminderTile> {
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

  Widget _buildTileContent(_Reminder r) {
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
            activeColor: Colors.white,
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

// ─── ADD EVENT SHEET ──────────────────────────────────────────────────────────

enum _NewEventType { appointment, reminder, event }

class _AddEventSheet extends StatefulWidget {
  final _NewEventType initialType;

  const _AddEventSheet({required this.initialType});

  @override
  State<_AddEventSheet> createState() => _AddEventSheetState();
}

class _AddEventSheetState extends State<_AddEventSheet> {
  late _NewEventType _type;
  final _titleController = TextEditingController();
  bool _allDay = false;
  String _repeat = 'Does not repeat';
  String _notify = '30 mins before';

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  String get _sheetTitle {
    switch (_type) {
      case _NewEventType.appointment:
        return 'Schedule Appointment';
      case _NewEventType.reminder:
        return 'Set Reminder';
      case _NewEventType.event:
        return 'Create Event';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              _sheetTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close,
                            color: Color(0xFF1A1A1A)),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            hintText: 'Add title',
                            hintStyle: TextStyle(
                                color: Color(0xFFBDBDBD),
                                fontSize: 16),
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 16),
                          ),
                          style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF1A1A1A)),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3F2868),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                        child: const Text('Save',
                            style: TextStyle(
                                fontSize: 14, color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _TypeChip(
                        label: 'Appointment',
                        selected:
                            _type == _NewEventType.appointment,
                        onTap: () => setState(
                            () => _type = _NewEventType.appointment),
                      ),
                      const SizedBox(width: 8),
                      _TypeChip(
                        label: 'Reminder',
                        selected: _type == _NewEventType.reminder,
                        onTap: () => setState(
                            () => _type = _NewEventType.reminder),
                      ),
                      const SizedBox(width: 8),
                      _TypeChip(
                        label: 'Event',
                        selected: _type == _NewEventType.event,
                        onTap: () => setState(
                            () => _type = _NewEventType.event),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _SheetRow(
                    icon: Icons.circle,
                    iconColor: const Color(0xFFFFA726),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Group',
                            style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9E9E9E))),
                        Text('Personal',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A1A))),
                      ],
                    ),
                  ),
                  if (_type == _NewEventType.appointment) ...[
                    const SizedBox(height: 16),
                    _SheetRow(
                      icon: Icons.medical_services_outlined,
                      child: const Text(
                        'Select doctor of preference',
                        style: TextStyle(
                            fontSize: 14, color: Color(0xFF9E9E9E)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _SheetRow(
                    icon: Icons.access_time_outlined,
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text('All-day',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF1A1A1A))),
                        ),
                        Switch(
                          value: _allDay,
                          onChanged: (v) =>
                              setState(() => _allDay = v),
                          activeColor: Colors.white,
                          activeTrackColor: const Color(0xFF3F2868),
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor:
                              const Color(0xFFE0E0E0),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 32),
                    child: Column(
                      children: [
                        _DateTimeRow(
                          date: 'Mon, Apr 7, 2025',
                          time: '5:00 PM',
                        ),
                        _DateTimeRow(
                          date: 'Mon, Apr 7, 2025',
                          time: '6:00 PM',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SheetRow(
                    icon: Icons.repeat,
                    child: Text(_repeat,
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFF9E9E9E))),
                  ),
                  const SizedBox(height: 16),
                  _SheetRow(
                    icon: Icons.alarm,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(_notify,
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF1A1A1A))),
                        ),
                        const Icon(Icons.close,
                            size: 16, color: Color(0xFF9E9E9E)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 32, top: 4),
                    child: GestureDetector(
                      onTap: () {},
                      child: const Text('Add notification',
                          style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF3F2868),
                              fontWeight: FontWeight.w500)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SheetRow(
                    icon: Icons.circle,
                    iconColor: const Color(0xFFFFA726),
                    child: const Text('Default color',
                        style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF1A1A1A))),
                  ),
                  const SizedBox(height: 16),
                  _SheetRow(
                    icon: Icons.description_outlined,
                    child: const Text('Add notes',
                        style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF9E9E9E))),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── AGENDA SHEET ─────────────────────────────────────────────────────────────

class _AgendaSheet extends StatelessWidget {
  final List<_CalendarEvent> events;

  const _AgendaSheet({required this.events});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      builder: (context, controller) => Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text(
            "Today's Agenda",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              border: const Border(
                left: BorderSide(color: Color(0xFF3F2868), width: 3),
              ),
              color: const Color(0xFFF9F6FF),
            ),
            child: Row(
              children: [
                const Icon(Icons.alarm,
                    size: 16, color: Color(0xFF3F2868)),
                const SizedBox(width: 8),
                Text(
                  'You have ${events.length} appointments and 1 group event today.',
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF555555)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 60,
                  child: Column(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF3F2868),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _dayName(today.weekday),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w500),
                              ),
                              Text(
                                '${today.day}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          controller: controller,
                          itemCount: 24,
                          itemBuilder: (_, i) => SizedBox(
                            height: 60,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 8, left: 8),
                              child: Text(
                                '${i == 0 ? 12 : i > 12 ? i - 12 : i} ${i < 12 ? 'AM' : 'PM'}',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF9E9E9E)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      ...List.generate(24, (i) => Positioned(
                        top: 36 + i * 60.0,
                        left: 0,
                        right: 16,
                        child: const Divider(
                            height: 1,
                            color: Color(0xFFF0F0F0)),
                      )),
                      ...events.map((e) {
                        final hour = e.date.hour;
                        return Positioned(
                          top: 36 + hour * 60.0 + 8,
                          left: 8,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: e.color.withOpacity(0.9),
                              borderRadius:
                                  BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    e.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (e.type == _EventType.group)
                                  const Icon(Icons.group,
                                      color: Colors.white,
                                      size: 16),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _dayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
}

// ─── SMALL WIDGETS ────────────────────────────────────────────────────────────

class _FabOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _FabOption({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF555555),
                  fontWeight: FontWeight.w500)),
          const SizedBox(width: 10),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E0E0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: const Color(0xFF3F2868), size: 20),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEDE7F6) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? const Color(0xFF3F2868)
                : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight:
                selected ? FontWeight.w600 : FontWeight.normal,
            color: selected
                ? const Color(0xFF3F2868)
                : const Color(0xFF555555),
          ),
        ),
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          icon: const Icon(Icons.keyboard_arrow_down,
              size: 16, color: Color(0xFF1A1A1A)),
          style: const TextStyle(
              fontSize: 13, color: Color(0xFF1A1A1A)),
          items: items
              .map((i) => DropdownMenuItem(
                    value: i,
                    child: Text(i),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEDE7F6) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? const Color(0xFF3F2868)
                : const Color(0xFFE0E0E0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight:
                selected ? FontWeight.w600 : FontWeight.normal,
            color: selected
                ? const Color(0xFF3F2868)
                : const Color(0xFF555555),
          ),
        ),
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Widget child;

  const _SheetRow({
    required this.icon,
    required this.child,
    this.iconColor = const Color(0xFF9E9E9E),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 12),
        Expanded(child: child),
      ],
    );
  }
}

class _DateTimeRow extends StatelessWidget {
  final String date;
  final String time;

  const _DateTimeRow({required this.date, required this.time});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(date,
              style: const TextStyle(
                  fontSize: 14, color: Color(0xFF1A1A1A))),
          const Spacer(),
          Text(time,
              style: const TextStyle(
                  fontSize: 14, color: Color(0xFF1A1A1A))),
        ],
      ),
    );
  }
}

// ─── DATA MODELS ──────────────────────────────────────────────────────────────

enum _EventType { appointment, group, reminder }

class _CalendarEvent {
  final String title;
  final DateTime date;
  final _EventType type;
  final Color color;
  final String timeLabel;
  final String emoji;

  const _CalendarEvent({
    required this.title,
    required this.date,
    required this.type,
    required this.color,
    required this.timeLabel,
    required this.emoji,
  });
}

class _Reminder {
  final String title;
  final String time;
  final String timeOfDay;
  final String? repeatDays;
  bool enabled;
  bool completed;

  _Reminder({
    required this.title,
    required this.time,
    required this.timeOfDay,
    this.repeatDays,
    this.enabled = true,
    this.completed = false,
  });
}

class _SeedData {
  const _SeedData();

  List<_CalendarEvent> get events {
    final now = DateTime.now();
    return [
      _CalendarEvent(
        title: 'Baby Checkup',
        date: DateTime(now.year, now.month, now.day, 11),
        type: _EventType.appointment,
        color: const Color(0xFF3F2868),
        timeLabel: '11:00 AM',
        emoji: '👶',
      ),
      _CalendarEvent(
        title: 'Sporty Moms Walk',
        date: DateTime(now.year, now.month, now.day, 16),
        type: _EventType.group,
        color: const Color(0xFFFFA726),
        timeLabel: '4:00 PM',
        emoji: '🏃',
      ),
      _CalendarEvent(
        title: 'Start solids today',
        date: DateTime(now.year, now.month, now.day, 18),
        type: _EventType.reminder,
        color: const Color(0xFF4FC3F7),
        timeLabel: 'Reminder',
        emoji: '💬',
      ),
      _CalendarEvent(
        title: 'Prenatal Checkup',
        date: DateTime(now.year, now.month, now.day + 3, 10),
        type: _EventType.appointment,
        color: const Color(0xFF3F2868),
        timeLabel: '10:00 AM',
        emoji: '🏥',
      ),
      _CalendarEvent(
        title: 'Meal Plan Group Session',
        date: DateTime(now.year, now.month, now.day, 8, 30),
        type: _EventType.group,
        color: const Color(0xFFFFA726),
        timeLabel: '8:30 AM',
        emoji: '🍽️',
      ),
    ];
  }

  static List<_Reminder> seedReminders() {
    return [
      _Reminder(
        title: 'Prenatal Vitamin',
        time: '8:00 AM',
        timeOfDay: 'Morning',
        enabled: true,
      ),
      _Reminder(
        title: 'Stretch For 10 Mins',
        time: '9:00 AM',
        timeOfDay: 'Morning',
        repeatDays: 'Mon - Fri',
        enabled: true,
      ),
      _Reminder(
        title: 'Drink Water',
        time: '2:00 PM',
        timeOfDay: 'Afternoon',
        enabled: false,
        completed: true,
      ),
      _Reminder(
        title: 'Hydration Break',
        time: '11:32 AM',
        timeOfDay: 'Evening',
        repeatDays: 'Mon - Sun',
        enabled: true,
      ),
      _Reminder(
        title: 'Morning Stretch',
        time: 'Apr 4',
        timeOfDay: 'Morning',
        enabled: false,
        completed: true,
      ),
      _Reminder(
        title: 'Take Meds',
        time: 'Apr 6',
        timeOfDay: 'Morning',
        enabled: false,
        completed: true,
      ),
    ];
  }
}
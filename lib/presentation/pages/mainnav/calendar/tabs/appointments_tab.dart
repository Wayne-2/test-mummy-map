import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:intl/intl.dart';
import 'package:mummymap/data/models/doctor_model.dart';
import 'package:mummymap/presentation/providers/calendar_provider.dart';
import 'package:mummymap/presentation/providers/doctors_provider.dart';
import '../../../../../data/models/calendar_models.dart';
import '../widgets/add_event_sheet.dart';
import '../widgets/calendar_widgets.dart';

class AppointmentsTab extends ConsumerStatefulWidget {
  const AppointmentsTab({super.key});

  @override
  ConsumerState<AppointmentsTab> createState() => _AppointmentsTabState();
}

class _AppointmentsTabState extends ConsumerState<AppointmentsTab> {
  String _filter = 'Upcoming';
  int _selectedDayOffset = 0;

  DateTime _getDate(dynamic item) {
    if (item is DoctorAppointment) {
      try {
        return DateTime.parse(item.date);
      } catch (_) {
        return DateTime.now();
      }
    } else if (item is CalendarEvent) {
      return item.date;
    }
    return DateTime.now();
  }

  List<dynamic> get _appointments {
    final docState = ref.watch(doctorsProvider);
    final calState = ref.watch(calendarProvider);
    
    List<dynamic> items = [];
    
    if (_filter == 'Upcoming') {
      items.addAll(docState.upcoming);
      items.addAll(calState.events.where((e) => e.type == EventType.appointment && e.date.isAfter(DateTime.now())));
    } else if (_filter == 'Past') {
      items.addAll(docState.history);
      items.addAll(calState.events.where((e) => e.type == EventType.appointment && e.date.isBefore(DateTime.now())));
    }
    
    items.sort((a, b) => _getDate(a).compareTo(_getDate(b)));
    return items;
  }

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
                  FilterDropdown(
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
                  ? const EmptyAppointments()
                  : PageView.builder(
                      itemCount: _appointments.length,
                      controller:
                          PageController(viewportFraction: 0.92),
                      itemBuilder: (context, index) {
                        final item = _appointments[index];
                        if (item is DoctorAppointment) {
                          return AppointmentCard(appointment: item);
                        } else if (item is CalendarEvent) {
                          return LocalAppointmentCard(event: item);
                        }
                        return const SizedBox();
                      },
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
          final hasEvent = _appointments.any((a) {
            return true; // Simplified for UI
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
          const AddEventSheet(initialType: NewEventType.appointment),
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final DoctorAppointment appointment;

  const AppointmentCard({super.key, required this.appointment});

  String _getFormattedDate() {
    try {
      final d = DateTime.parse(appointment.date);
      return DateFormat('EEEE, MMMM d, yyyy').format(d);
    } catch (e) {
      return appointment.date;
    }
  }

  void _saveToDevice(BuildContext context) {
    try {
      DateTime parsedDate = DateTime.parse(appointment.date);
      // Try to parse time, or default to 9 AM
      // (Basic parsing, in a real app would use a precise DateFormat if standard)
      DateTime startDate = parsedDate;
      if (appointment.time.isNotEmpty) {
        // e.g. "9:00PM"
        try {
          final timeStr = appointment.time.replaceAll(' ', '');
          final isPM = timeStr.toLowerCase().contains('pm');
          final parts = timeStr.replaceAll(RegExp(r'[a-zA-Z]'), '').split(':');
          int hour = int.parse(parts[0]);
          int minute = parts.length > 1 ? int.parse(parts[1]) : 0;
          if (isPM && hour != 12) hour += 12;
          if (!isPM && hour == 12) hour = 0;
          startDate = DateTime(parsedDate.year, parsedDate.month, parsedDate.day, hour, minute);
        } catch (_) {}
      }

      final event = Event(
        title: 'Appointment with ${appointment.doctor.name}',
        description: 'Scheduled via Mummymap\nCall Type: ${appointment.callType}',
        location: 'Virtual',
        startDate: startDate,
        endDate: startDate.add(const Duration(hours: 1)),
        allDay: false,
      );

      Add2Calendar.addEvent2Cal(event);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not format date to save event: ${e.toString()}')),
      );
    }
  }

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
            _getFormattedDate(),
            style: const TextStyle(
                fontSize: 12, color: Color(0xFF9E9E9E)),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${appointment.time}  •  ${appointment.doctor.specialty}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
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
                        .map((w) => w.isNotEmpty ? w[0] : '')
                        .take(2)
                        .join(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    appointment.doctor.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                const Icon(Icons.verified,
                    color: Color(0xFF3F2868), size: 14),
              ],
            ),
          ),
          const SizedBox(height: 12),
          InfoRow(
              icon: Icons.description_outlined,
              text: 'Checkup with ${appointment.doctor.name} scheduled for ${appointment.callType}.'),
          const SizedBox(height: 8),
          const InfoRow(
              icon: Icons.alarm, text: 'No notifications set'),
          const SizedBox(height: 8),
          InfoRow(
              icon: Icons.location_on_outlined, text: appointment.callType == 'Video' ? 'Google meet' : 'Phone Call'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => _saveToDevice(context),
                child: const Row(
                  children: [
                    Icon(Icons.save_alt,
                        size: 16, color: Color(0xFF3F2868)),
                    SizedBox(width: 4),
                    Text('Save to Device',
                        style: TextStyle(
                            fontSize: 13, color: Color(0xFF3F2868), fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () {},
                child: const Row(
                  children: [
                    Icon(Icons.edit_calendar_outlined,
                        size: 16, color: Color(0xFF1A1A1A)),
                    SizedBox(width: 4),
                    Text('Reschedule',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A))),
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

class LocalAppointmentCard extends StatelessWidget {
  final CalendarEvent event;

  const LocalAppointmentCard({super.key, required this.event});

  String _getFormattedDate() {
    return DateFormat('EEEE, MMMM d, yyyy').format(event.date);
  }

  void _saveToDevice(BuildContext context) {
    try {
      final calEvent = Event(
        title: event.title,
        description: 'Scheduled via Mummymap\nLocally Added',
        location: '',
        startDate: event.date,
        endDate: event.date.add(const Duration(hours: 1)),
        allDay: false,
      );
      Add2Calendar.addEvent2Cal(calEvent);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not format date to save event: ${e.toString()}')),
      );
    }
  }

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
            _getFormattedDate(),
            style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${event.timeLabel}  •  Personal',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
              const Icon(Icons.event_outlined, color: Color(0xFF3F2868), size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFF3F2868),
                  child: Text('PA', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const InfoRow(
              icon: Icons.description_outlined,
              text: 'Custom appointment added locally.'),
          const SizedBox(height: 8),
          const InfoRow(icon: Icons.alarm, text: 'No notifications set'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => _saveToDevice(context),
                child: const Row(
                  children: [
                    Icon(Icons.save_alt, size: 16, color: Color(0xFF3F2868)),
                    SizedBox(width: 4),
                    Text('Save to Device', style: TextStyle(fontSize: 13, color: Color(0xFF3F2868), fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () {},
                child: const Row(
                  children: [
                    Icon(Icons.edit_calendar_outlined, size: 16, color: Color(0xFF1A1A1A)),
                    SizedBox(width: 4),
                    Text('Edit', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
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

class EmptyAppointments extends StatelessWidget {
  const EmptyAppointments({super.key});

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

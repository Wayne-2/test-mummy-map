import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mummymap/data/models/doctor_model.dart';
import 'package:mummymap/presentation/providers/doctors_provider.dart';
import '../../../../../data/models/calendar_models.dart';
import '../../../../providers/calendar_provider.dart';
import '../../calendar/widgets/add_event_sheet.dart';

class UpcomingAppointments extends ConsumerWidget {
  const UpcomingAppointments({super.key});

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docState = ref.watch(doctorsProvider);
    final calState = ref.watch(calendarProvider);
    
    List<dynamic> items = [];
    items.addAll(docState.upcoming);
    items.addAll(calState.events.where((e) => e.type == EventType.appointment && e.date.isAfter(DateTime.now())));
    
    items.sort((a, b) => _getDate(a).compareTo(_getDate(b)));
    
    final appointments = items.take(2).toList(); // Show max 2 on home screen

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Upcoming Appointments',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    builder: (_) => const AddEventSheet(initialType: NewEventType.appointment),
                  );
                },
                child: const Text(
                  '+ Add',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3F2868),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          appointments.isEmpty
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 40, color: Color(0xFFBDBDBD)),
                      const SizedBox(height: 12),
                      const Text(
                        'No appointments yet',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Tap + Add to schedule your first appointment',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF9E9E9E),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 160,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.white,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                              ),
                              builder: (_) => const AddEventSheet(initialType: NewEventType.appointment),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3F2868),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Add Appointment',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: appointments.map((a) {
                    if (a is DoctorAppointment) {
                      return _AppointmentCard(appointment: a);
                    } else if (a is CalendarEvent) {
                      return _LocalAppointmentCard(event: a);
                    }
                    return const SizedBox();
                  }).toList(),
                ),
        ],
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final DoctorAppointment appointment;

  const _AppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    String monthStr = '...';
    String dayStr = '--';
    
    try {
      final d = DateTime.parse(appointment.date);
      monthStr = DateFormat('MMM').format(d);
      dayStr = DateFormat('d').format(d);
    } catch (e) {
      final parts = appointment.date.split(' ');
      if (parts.length >= 2) {
        dayStr = parts[0].replaceAll(RegExp(r'[^0-9]'), '');
        monthStr = parts[1].length > 3 ? parts[1].substring(0, 3) : parts[1];
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF3F2868),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  monthStr,
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                ),
                Text(
                  dayStr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Appointment with ${appointment.doctor.name}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.person_outline,
                        size: 13, color: Color(0xFF9E9E9E)),
                    const SizedBox(width: 4),
                    Text(
                      appointment.doctor.specialty,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF9E9E9E)),
                    ),
                    const Text(' • ',
                        style: TextStyle(color: Color(0xFF9E9E9E))),
                    Text(
                      appointment.time,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF9E9E9E)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LocalAppointmentCard extends StatelessWidget {
  final CalendarEvent event;

  const _LocalAppointmentCard({required this.event});

  @override
  Widget build(BuildContext context) {
    String monthStr = DateFormat('MMM').format(event.date);
    String dayStr = DateFormat('d').format(event.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF3F2868),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  monthStr,
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                ),
                Text(
                  dayStr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.event_outlined,
                        size: 13, color: Color(0xFF9E9E9E)),
                    const SizedBox(width: 4),
                    const Text(
                      'Personal',
                      style: TextStyle(
                          fontSize: 12, color: Color(0xFF9E9E9E)),
                    ),
                    const Text(' • ',
                        style: TextStyle(color: Color(0xFF9E9E9E))),
                    Text(
                      event.timeLabel,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF9E9E9E)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
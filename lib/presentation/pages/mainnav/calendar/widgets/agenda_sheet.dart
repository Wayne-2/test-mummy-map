import 'package:flutter/material.dart';
import '../../../../../data/models/calendar_models.dart';

class AgendaSheet extends StatelessWidget {
  final List<CalendarEvent> events;

  const AgendaSheet({super.key, required this.events});

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
                              color: e.color.withValues(alpha: 0.9),
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
                                if (e.type == EventType.group)
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

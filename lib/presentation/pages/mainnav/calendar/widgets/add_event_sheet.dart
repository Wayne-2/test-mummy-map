import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../data/models/calendar_models.dart';
import '../../../../providers/calendar_provider.dart';
import 'calendar_widgets.dart';

class AddEventSheet extends ConsumerStatefulWidget {
  final NewEventType initialType;

  const AddEventSheet({super.key, required this.initialType});

  @override
  ConsumerState<AddEventSheet> createState() => _AddEventSheetState();
}

class _AddEventSheetState extends ConsumerState<AddEventSheet> {
  late NewEventType _type;
  final _titleController = TextEditingController();
  bool _allDay = false;
  String _repeat = 'Does not repeat';
  String _notify = '30 mins before';

  DateTime _startDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  
  DateTime _endDate = DateTime.now().add(const Duration(hours: 1));
  TimeOfDay _endTime = TimeOfDay.now().replacing(
    hour: (TimeOfDay.now().hour + 1) % 24,
  );

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
      case NewEventType.appointment:
        return 'Schedule Appointment';
      case NewEventType.reminder:
        return 'Set Reminder';
      case NewEventType.event:
        return 'Create Event';
    }
  }

  Future<void> _pickDate(bool isStart) async {
    final initial = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF3F2868),
            colorScheme: const ColorScheme.light(primary: Color(0xFF3F2868)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = picked;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final initial = isStart ? _startTime : _endTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF3F2868),
            colorScheme: const ColorScheme.light(primary: Color(0xFF3F2868)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('EEE, MMM d, yyyy').format(date);
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
                        onPressed: () {
                          final title = _titleController.text.trim();
                          if (title.isEmpty) return;
                          
                          if (_type == NewEventType.reminder) {
                            final reminder = ReminderModel(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              title: title,
                              time: _startTime.format(context),
                              timeOfDay: _startTime.hour < 12 ? 'Morning' : (_startTime.hour < 17 ? 'Afternoon' : 'Evening'),
                              repeatDays: _repeat == 'Does not repeat' ? null : _repeat,
                            );
                            ref.read(calendarProvider.notifier).addReminder(reminder);
                          } else {
                            final event = CalendarEvent(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              title: title,
                              date: _startDate.copyWith(hour: _startTime.hour, minute: _startTime.minute),
                              type: _type == NewEventType.appointment ? EventType.appointment : EventType.event,
                              color: _type == NewEventType.appointment ? const Color(0xFF3F2868) : const Color(0xFFFFA726),
                              timeLabel: _startTime.format(context),
                              emoji: _type == NewEventType.appointment ? '🏥' : '📅',
                            );
                            ref.read(calendarProvider.notifier).addEvent(event);
                          }
                          Navigator.pop(context);
                        },
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
                      TypeChip(
                        label: 'Appointment',
                        selected:
                            _type == NewEventType.appointment,
                        onTap: () => setState(
                            () => _type = NewEventType.appointment),
                      ),
                      const SizedBox(width: 8),
                      TypeChip(
                        label: 'Reminder',
                        selected: _type == NewEventType.reminder,
                        onTap: () => setState(
                            () => _type = NewEventType.reminder),
                      ),
                      const SizedBox(width: 8),
                      TypeChip(
                        label: 'Event',
                        selected: _type == NewEventType.event,
                        onTap: () => setState(
                            () => _type = NewEventType.event),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SheetRow(
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
                  if (_type == NewEventType.appointment) ...[
                    const SizedBox(height: 16),
                    const SheetRow(
                      icon: Icons.medical_services_outlined,
                      child: Text(
                        'Select doctor of preference',
                        style: TextStyle(
                            fontSize: 14, color: Color(0xFF9E9E9E)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SheetRow(
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
                          activeThumbColor: Colors.white,
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
                        DateTimeRow(
                          date: _formatDate(_startDate),
                          time: _startTime.format(context),
                          onDateTap: () => _pickDate(true),
                          onTimeTap: () => _pickTime(true),
                        ),
                        DateTimeRow(
                          date: _formatDate(_endDate),
                          time: _endTime.format(context),
                          onDateTap: () => _pickDate(false),
                          onTimeTap: () => _pickTime(false),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SheetRow(
                    icon: Icons.repeat,
                    child: Text(_repeat,
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFF9E9E9E))),
                  ),
                  const SizedBox(height: 16),
                  SheetRow(
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
                  const SheetRow(
                    icon: Icons.circle,
                    iconColor: Color(0xFFFFA726),
                    child: Text('Default color',
                        style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF1A1A1A))),
                  ),
                  const SizedBox(height: 16),
                  const SheetRow(
                    icon: Icons.description_outlined,
                    child: Text('Add notes',
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

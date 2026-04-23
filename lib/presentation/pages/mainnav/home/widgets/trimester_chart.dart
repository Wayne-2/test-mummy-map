import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mummymap/presentation/providers/pregnancy_provider.dart';

class TrimesterChart extends ConsumerWidget {
  const TrimesterChart({super.key});

  static const _rows = [
    {'trimester': '1', 'month': '1', 'weeks': ['0', '1', '2', '3', '4']},
    {'trimester': '', 'month': '2', 'weeks': ['5', '6', '7', '8']},
    {'trimester': '', 'month': '3', 'weeks': ['9', '10', '11', '12', '13']},
    {'trimester': '2', 'month': '4', 'weeks': ['14', '15', '16', '17']},
    {'trimester': '', 'month': '5', 'weeks': ['18', '19', '20', '21']},
    {'trimester': '', 'month': '6', 'weeks': ['22', '23', '24', '25', '26']},
    {'trimester': '3', 'month': '7', 'weeks': ['27', '28', '29', '30']},
    {'trimester': '', 'month': '8', 'weeks': ['31', '32', '33', '34', '35']},
    {'trimester': '', 'month': '9', 'weeks': ['36', '37', '38', '39', '40']},
  ];

  static Color rowColor(String trimester, String month) {
    final t = trimester.isNotEmpty ? trimester : _getTrimesterForMonth(month);
    if (t == '1') return const Color(0xFFFFF3E0);
    if (t == '2') return const Color(0xFFE8F5E9);
    return const Color(0xFFE3F2FD);
  }

  static String _getTrimesterForMonth(String month) {
    final m = int.parse(month);
    if (m <= 3) return '1';
    if (m <= 6) return '2';
    return '3';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pregnancy = ref.watch(pregnancyProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trimester Chart',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          pregnancy == null ? _EmptyState() : _Chart(
            currentWeek: pregnancy.currentWeek,
            dueDate: pregnancy.dueDate,
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: const Column(
        children: [
          Icon(Icons.calendar_month_outlined, size: 40, color: Color(0xFFBDBDBD)),
          SizedBox(height: 12),
          Text(
            'Add your due date to see your trimester chart',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
          ),
        ],
      ),
    );
  }
}

class _Chart extends StatelessWidget {
  final int currentWeek;
  final DateTime dueDate;

  const _Chart({required this.currentWeek, required this.dueDate});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          ...TrimesterChart._rows.map((row) {
            final weeks = row['weeks'] as List<String>;
            final trimester = row['trimester'] as String;
            final month = row['month'] as String;
            return _buildRow(
              trimester: trimester,
              month: month,
              weeks: weeks,
              color: TrimesterChart.rowColor(trimester, month),
              currentWeek: currentWeek,
            );
          }),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              'Due Date: ${DateFormat('MMM d, yyyy').format(dueDate)}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFF9F9F9),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Center(
              child: Text('Trimester',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9E9E9E))),
            ),
          ),
          Expanded(
            child: Center(
              child: Text('Month',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9E9E9E))),
            ),
          ),
          Expanded(
            flex: 5,
            child: Center(
              child: Text('Week',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9E9E9E))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow({
    required String trimester,
    required String month,
    required List<String> weeks,
    required Color color,
    required int currentWeek,
  }) {
    return Container(
      color: color,
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Text(
                trimester,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(month, style: const TextStyle(fontSize: 12)),
            ),
          ),
          Expanded(
            flex: 5,
            child: Row(
              children: weeks.map((week) {
                final isCurrentWeek = int.tryParse(week) == currentWeek;
                return Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isCurrentWeek
                          ? const Color(0xFF3F2868)
                          : Colors.transparent,
                      borderRadius: isCurrentWeek
                          ? BorderRadius.circular(6)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        week,
                        style: TextStyle(
                          fontSize: 12,
                          color: isCurrentWeek
                              ? Colors.white
                              : const Color(0xFF1A1A1A),
                          fontWeight: isCurrentWeek
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
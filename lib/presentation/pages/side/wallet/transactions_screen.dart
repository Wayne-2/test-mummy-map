import 'package:flutter/material.dart';
import 'package:mummymap/data/models/wallet_model.dart';
import 'package:mummymap/presentation/pages/side/wallet/widget/wallet_widgets.dart';
import 'transaction_detail_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  List<WalletTransaction> get _filtered {
    if (_query.isEmpty) return kWalletTransactions;
    return kWalletTransactions
        .where((tx) =>
            tx.description.toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final grouped = groupByDate(_filtered);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            _buildSearchBar(),
            Expanded(
              child: ListView(
                children: [
                  for (final entry in grouped.entries) ...[
                    SectionLabel(label: entry.key),
                    for (final tx in entry.value)
                      Column(
                        children: [
                          TransactionTile(
                            tx: tx,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    TransactionDetailScreen(tx: tx),
                              ),
                            ),
                          ),
                          const Divider(
                              height: 1, color: Color(0xFFF5F5F5)),
                        ],
                      ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            'Transactions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {},
            child: const Text(
              'Download',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF3F2868),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v),
                style: const TextStyle(
                    fontSize: 14, color: Color(0xFF1A1A1A)),
                decoration: InputDecoration(
                  hintText: 'Name, category, location...',
                  hintStyle: TextStyle(
                      color: Colors.grey.shade400, fontSize: 13),
                  icon: Icon(Icons.search,
                      color: Colors.grey.shade400, size: 20),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _showFilterSheet(context),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.tune,
                  color: Colors.grey.shade600, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _FilterSheet(),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet();

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  String _activeTab = 'Month';

  int _selectedMonth = 10;
  int _selectedYear = 2025;

  String _duration = 'Last 3 months';
  String? _startDate;
  String? _endDate;

  String _status = 'All Status';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
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
          const Text(
            'Filter',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ['Month', 'Timeframe', 'Status'].map((tab) {
                final selected = _activeTab == tab;
                return GestureDetector(
                  onTap: () => setState(() => _activeTab = tab),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF3F2868)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF3F2868)
                            : const Color(0xFFE0E0E0),
                      ),
                    ),
                    child: Text(
                      tab,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: selected
                            ? Colors.white
                            : const Color(0xFF555555),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildTabContent(),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              0,
              16,
              MediaQuery.of(context).padding.bottom + 16,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F2868),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
                child: const Text(
                  'Confirm',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_activeTab) {
      case 'Month':
        return _buildMonthPicker();
      case 'Timeframe':
        return _buildTimeframePicker();
      case 'Status':
        return _buildStatusPicker();
      default:
        return const SizedBox();
    }
  }

  Widget _buildMonthPicker() {
    return SizedBox(
      height: 120,
      child: Row(
        children: [
          Expanded(
            child: _DrumScroller(
              values: List.generate(12, (i) => '${i + 1}'.padLeft(2, '0')),
              selectedIndex: _selectedMonth - 1,
              onChanged: (i) =>
                  setState(() => _selectedMonth = i + 1),
            ),
          ),
          Expanded(
            child: _DrumScroller(
              values: ['2023', '2024', '2025', '2026'],
              selectedIndex:
                  (['2023', '2024', '2025', '2026'].indexOf('$_selectedYear'))
                      .clamp(0, 3),
              onChanged: (i) => setState(
                  () => _selectedYear = int.parse(['2023', '2024', '2025', '2026'][i])),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeframePicker() {
    final durations = ['Last 3 months', 'Last 6 months', 'Custom'];
    final shortLabels = ['Last 3 months', 'Last 6 months', 'Custom'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Duration',
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A)),
        ),
        const SizedBox(height: 10),
        Row(
          children: durations.asMap().entries.map((e) {
            final selected = _duration == e.value;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _duration = e.value;
                  if (_duration == 'Last 3 months') {
                    _startDate = 'Aug, 2025';
                    _endDate = 'Oct, 2025';
                  } else if (_duration == 'Last 6 months') {
                    _startDate = 'May, 2025';
                    _endDate = 'Oct, 2025';
                  } else {
                    _startDate = null;
                    _endDate = null;
                  }
                });
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFFEDE7F6)
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF3F2868)
                        : Colors.transparent,
                  ),
                ),
                child: Text(
                  shortLabels[e.key],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: selected
                        ? const Color(0xFF3F2868)
                        : const Color(0xFF555555),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        const Text(
          'Start Date',
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A)),
        ),
        const SizedBox(height: 8),
        _DatePickerTile(
          value: _startDate ?? 'Select',
          onTap: () => _showDatePicker(context, isStart: true),
        ),
        const SizedBox(height: 12),
        const Text(
          'End Date',
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A)),
        ),
        const SizedBox(height: 8),
        _DatePickerTile(
          value: _endDate ?? 'Select',
          onTap: () => _showDatePicker(context, isStart: false),
        ),
      ],
    );
  }

  Widget _buildStatusPicker() {
    final statuses = [
      'All Status', 'Successful', 'Pending', 'Failed', 'Reversed'
    ];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: statuses.map((s) {
        final selected = _status == s;
        return GestureDetector(
          onTap: () => setState(() => _status = s),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFFEDE7F6)
                  : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected
                    ? const Color(0xFF3F2868)
                    : Colors.transparent,
              ),
            ),
            child: Text(
              s,
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
      }).toList(),
    );
  }

  void _showDatePicker(BuildContext context, {required bool isStart}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _MonthYearPicker(
        title: isStart ? 'Start Date' : 'End Date',
        onConfirm: (month, year) {
          setState(() {
            const months = [
              '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
              'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
            ];
            final value = '${months[month]}, $year';
            if (isStart) {
              _startDate = value;
            } else {
              _endDate = value;
            }
          });
        },
      ),
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  final String value;
  final VoidCallback onTap;

  const _DatePickerTile({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: value == 'Select'
                    ? const Color(0xFFBDBDBD)
                    : const Color(0xFF1A1A1A),
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right,
                color: Color(0xFF9E9E9E), size: 18),
          ],
        ),
      ),
    );
  }
}

class _MonthYearPicker extends StatefulWidget {
  final String title;
  final void Function(int month, int year) onConfirm;

  const _MonthYearPicker({
    required this.title,
    required this.onConfirm,
  });

  @override
  State<_MonthYearPicker> createState() => _MonthYearPickerState();
}

class _MonthYearPickerState extends State<_MonthYearPicker> {
  int _month = DateTime.now().month;
  int _year = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.chevron_left,
                      color: Color(0xFF1A1A1A)),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: Row(
              children: [
                Expanded(
                  child: _DrumScroller(
                    values: List.generate(
                        12, (i) => '${i + 1}'.padLeft(2, '0')),
                    selectedIndex: _month - 1,
                    onChanged: (i) =>
                        setState(() => _month = i + 1),
                  ),
                ),
                Expanded(
                  child: _DrumScroller(
                    values: ['2023', '2024', '2025', '2026'],
                    selectedIndex:
                        (['2023', '2024', '2025', '2026'].indexOf('$_year'))
                            .clamp(0, 3),
                    onChanged: (i) => setState(() =>
                        _year = int.parse(
                            ['2023', '2024', '2025', '2026'][i])),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  widget.onConfirm(_month, _year);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F2868),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
                child: const Text(
                  'Confirm',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrumScroller extends StatefulWidget {
  final List<String> values;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _DrumScroller({
    required this.values,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  State<_DrumScroller> createState() => _DrumScrollerState();
}

class _DrumScrollerState extends State<_DrumScroller> {
  late int _current;
  late FixedExtentScrollController _controller;

  @override
  void initState() {
    super.initState();
    _current = widget.selectedIndex;
    _controller =
        FixedExtentScrollController(initialItem: _current);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListWheelScrollView.useDelegate(
      controller: _controller,
      itemExtent: 40,
      diameterRatio: 1.5,
      perspective: 0.003,
      onSelectedItemChanged: (i) {
        setState(() => _current = i);
        widget.onChanged(i);
      },
      childDelegate: ListWheelChildBuilderDelegate(
        builder: (context, index) {
          if (index < 0 || index >= widget.values.length) {
            return null;
          }
          final isSelected = index == _current;
          return Center(
            child: Text(
              widget.values[index],
              style: TextStyle(
                fontSize: isSelected ? 22 : 16,
                fontWeight: isSelected
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: isSelected
                    ? const Color(0xFF1A1A1A)
                    : const Color(0xFFBDBDBD),
              ),
            ),
          );
        },
        childCount: widget.values.length,
      ),
    );
  }
}
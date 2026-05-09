import 'package:flutter/material.dart';
import 'package:mummymap/data/models/track_models.dart';  

class VendorProfileScreen extends StatefulWidget {
  final Vendor vendor;

  const VendorProfileScreen({super.key, required this.vendor});

  @override
  State<VendorProfileScreen> createState() => _VendorProfileScreenState();
}

class _VendorProfileScreenState extends State<VendorProfileScreen> {
  int _selectedTrimester = 1;
  String _selectedDay = 'Today';
  final Set<String> _selectedMealIds = {};
  int _cartCount = 0;

  final List<String> _days = ['Today', 'Mon 7', 'Tue 8', 'Wed 9', 'Thu 10'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroImage(),
                    _buildVendorInfo(),
                    _buildTrimesterTabs(),
                    _buildDayStrip(),
                    const SizedBox(height: 16),
                    _buildMealList(),
                    const SizedBox(height: 32),
                  ],
                ),
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
            'Profile',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const Spacer(),
          Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.shopping_basket_outlined,
                  color: Color(0xFF1A1A1A), size: 24),
              if (_cartCount > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$_cartCount',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _selectedMealIds.isEmpty
                ? null
                : () => _showOrderMealPlanSheet(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3F2868),
              disabledBackgroundColor: Colors.grey.shade300,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
            ),
            child: const Text(
              'Schedule',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildHeroImage() {
    return Image.asset(
      widget.vendor.imagePath,
      width: double.infinity,
      height: 200,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        height: 200,
        color: Colors.grey.shade300,
        child: const Icon(Icons.store, size: 60, color: Colors.grey),
      ),
    );
  }

  Widget _buildVendorInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.vendor.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const Spacer(),
              _StarRow(rating: widget.vendor.rating),
            ],
          ),
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            text: widget.vendor.days,
          ),
          const SizedBox(height: 4),
          _InfoRow(
            icon: Icons.access_time,
            text:
                'Opens ${widget.vendor.openTime}  •  Closes ${widget.vendor.closeTime}',
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 14, color: Color(0xFF9E9E9E)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.vendor.address,
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF555555)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.open_in_new,
                  size: 14, color: Color(0xFF9E9E9E)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrimesterTabs() {
    final tabs = [
      '1\u02e2\u1d57 Trimester',
      '2\u207f\u1d48 Trimester',
      '3\u02b3\u1d48 Trimester',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: tabs.asMap().entries.map((e) {
          final index = e.key + 1;
          final label = e.value;
          final selected = _selectedTrimester == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedTrimester = index),
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Column(
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: selected
                          ? const Color(0xFF3F2868)
                          : const Color(0xFF9E9E9E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (selected)
                    Container(
                      height: 2,
                      width: 40,
                      color: const Color(0xFF3F2868),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDayStrip() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: _days.length,
        itemBuilder: (context, index) {
          final day = _days[index];
          final selected = _selectedDay == day;
          return GestureDetector(
            onTap: () => setState(() => _selectedDay = day),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFEDE7F6)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF3F2868)
                      : const Color(0xFFE0E0E0),
                ),
              ),
              child: Text(
                day,
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
        },
      ),
    );
  }

  Widget _buildMealList() {
    return Column(
      children: kMeals.map((meal) {
        final isSelected = _selectedMealIds.contains(meal.id);
        return _VendorMealItem(
          meal: meal,
          isSelected: isSelected,
          onToggle: () {
            setState(() {
              if (isSelected) {
                _selectedMealIds.remove(meal.id);
                _cartCount = (_cartCount - 1).clamp(0, 99);
              } else {
                _selectedMealIds.add(meal.id);
                _cartCount++;
              }
            });
          },
        );
      }).toList(),
    );
  }

  void _showOrderMealPlanSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _OrderMealPlanSheet(
        vendor: widget.vendor,
        onSchedule: (trimesterIndex) {
          Navigator.pop(context);
          _showSchedulingLoader(context, trimesterIndex);
        },
      ),
    );
  }

  void _showSchedulingLoader(BuildContext context, int trimesterIndex) {
    final suffixes = ['1st', '2nd', '3rd'];
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ScheduledAlert(
        vendorName: widget.vendor.name,
        trimesterLabel: suffixes[trimesterIndex - 1],
        onCancel: () => Navigator.pop(context),
      ),
    );
  }
}

class _VendorMealItem extends StatelessWidget {
  final MealItem meal;
  final bool isSelected;
  final VoidCallback onToggle;

  const _VendorMealItem({
    required this.meal,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              meal.imagePath,
              width: 90,
              height: 90,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 90,
                height: 90,
                color: Colors.grey.shade200,
                child: const Icon(Icons.restaurant, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE7F6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    meal.mealTime,
                    style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF3F2868),
                        fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  meal.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  meal.price,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? const Color(0xFF3F2868)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF3F2868)
                      : const Color(0xFFBDBDBD),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check,
                      color: Colors.white, size: 14)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderMealPlanSheet extends StatefulWidget {
  final Vendor vendor;
  final ValueChanged<int> onSchedule;

  const _OrderMealPlanSheet({
    required this.vendor,
    required this.onSchedule,
  });

  @override
  State<_OrderMealPlanSheet> createState() => _OrderMealPlanSheetState();
}

class _OrderMealPlanSheetState extends State<_OrderMealPlanSheet> {
  int _selectedTrimester = 1;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Order Meal Plan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 20),
          _TrimesterPlanOption(
            label: '1\u02e2\u1d57 Trimester Plan',
            price: widget.vendor.priceLabel,
            selected: _selectedTrimester == 1,
            onTap: () => setState(() => _selectedTrimester = 1),
          ),
          const SizedBox(height: 10),
          _TrimesterPlanOption(
            label: '2\u207f\u1d48 Trimester Plan',
            price: widget.vendor.priceLabel,
            selected: _selectedTrimester == 2,
            onTap: () => setState(() => _selectedTrimester = 2),
          ),
          const SizedBox(height: 10),
          _TrimesterPlanOption(
            label: '3\u02b3\u1d48 Trimester Plan',
            price: widget.vendor.priceLabel,
            selected: _selectedTrimester == 3,
            onTap: () => setState(() => _selectedTrimester = 3),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      setState(() => _isLoading = true);
                      await Future.delayed(const Duration(seconds: 2));
                      if (!mounted) return;
                      widget.onSchedule(_selectedTrimester);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isLoading
                    ? Colors.grey.shade400
                    : const Color(0xFF3F2868),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                elevation: 0,
              ),
              child: Text(
                _isLoading ? 'Scheduling order...' : 'Schedule Order',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrimesterPlanOption extends StatelessWidget {
  final String label;
  final String price;
  final bool selected;
  final VoidCallback onTap;

  const _TrimesterPlanOption({
    required this.label,
    required this.price,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? const Color(0xFF3F2868)
                : const Color(0xFFE0E0E0),
            width: selected ? 1.5 : 1,
          ),
          color: selected
              ? const Color(0xFFF5EEFF)
              : Colors.white,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEDE7F6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                label,
                style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF3F2868),
                    fontWeight: FontWeight.w500),
              ),
            ),
            const Spacer(),
            Text(
              '$price / week',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduledAlert extends StatelessWidget {
  final String vendorName;
  final String trimesterLabel;
  final VoidCallback onCancel;

  const _ScheduledAlert({
    required this.vendorName,
    required this.trimesterLabel,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Alert',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close,
                      color: Color(0xFF9E9E9E), size: 20),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: Container(
                width: 160,
                height: 140,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.phone_android,
                    size: 60, color: Color(0xFF3F2868)),
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Meal Plan Order Scheduled!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                'You have been automatically scheduled weekly meal plan for your ${trimesterLabel} Trimester from\n$vendorName',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF555555),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onCancel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F2868),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
                child: const Text(
                  'Cancel Order',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  final double rating;

  const _StarRow({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < rating.floor()) {
          return const Icon(Icons.star,
              color: Color(0xFFFFC107), size: 14);
        } else if (i < rating) {
          return const Icon(Icons.star_half,
              color: Color(0xFFFFC107), size: 14);
        }
        return const Icon(Icons.star_outline,
            color: Color(0xFFFFC107), size: 14);
      }),
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
      children: [
        Icon(icon, size: 14, color: const Color(0xFF9E9E9E)),
        const SizedBox(width: 6),
        Text(text,
            style: const TextStyle(
                fontSize: 13, color: Color(0xFF555555))),
      ],
    );
  }
}
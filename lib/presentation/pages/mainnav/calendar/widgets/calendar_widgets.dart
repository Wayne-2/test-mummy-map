import 'package:flutter/material.dart';

class CalendarAppBar extends StatelessWidget {
  final VoidCallback? onNotifications;
  final VoidCallback? onProfileTap;

  const CalendarAppBar({super.key, this.onNotifications, this.onProfileTap});

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

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const InfoRow({super.key, required this.icon, required this.text});

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

class FilterChipWidget extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const FilterChipWidget({
    super.key,
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

class FilterDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const FilterDropdown({
    super.key,
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

class TypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const TypeChip({
    super.key,
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

class SheetRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Widget child;

  const SheetRow({
    super.key,
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

class DateTimeRow extends StatelessWidget {
  final String date;
  final String time;
  final VoidCallback? onDateTap;
  final VoidCallback? onTimeTap;

  const DateTimeRow({
    super.key, 
    required this.date, 
    required this.time,
    this.onDateTap,
    this.onTimeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          GestureDetector(
            onTap: onDateTap,
            child: Text(date,
                style: const TextStyle(
                    fontSize: 14, color: Color(0xFF1A1A1A))),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onTimeTap,
            child: Text(time,
                style: const TextStyle(
                    fontSize: 14, color: Color(0xFF1A1A1A))),
          ),
        ],
      ),
    );
  }
}

class FabOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const FabOption({
    super.key,
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
                  color: Colors.black.withValues(alpha: 0.06),
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

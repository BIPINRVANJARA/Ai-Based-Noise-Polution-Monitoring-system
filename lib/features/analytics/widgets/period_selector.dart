import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PeriodSelector extends StatelessWidget {
  final List<String> periods;
  final int selectedIndex;
  final Function(int) onChanged;

  const PeriodSelector({
    super.key,
    required this.periods,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(periods.length, (index) {
          final isSelected = index == selectedIndex;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFA3E635) : const Color(0xFF1E1E2C),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  periods[index],
                  style: GoogleFonts.jetBrainsMono(
                    color: isSelected ? const Color(0xFF1E1E2C) : Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

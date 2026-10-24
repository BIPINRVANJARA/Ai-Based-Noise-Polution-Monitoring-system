import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 16),
      height: 66,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C).withOpacity(0.96),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFA3E635).withOpacity(0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
        child: Row(
          children: [
            _buildNavItem(0, Icons.dashboard_rounded, 'Home'),
            _buildNavItem(1, Icons.map_rounded, 'Map'),
            _buildNavItem(2, Icons.insights_rounded, 'Analytics'),
            _buildNavItem(3, Icons.notifications_rounded, 'Alerts', badgeCount: 3),
            _buildNavItem(4, Icons.settings_rounded, 'Settings'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, {int badgeCount = 0}) {
    final isSelected = currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFA3E635).withOpacity(0.18) : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: isSelected
                ? Border.all(color: const Color(0xFFA3E635).withOpacity(0.4), width: 1)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: isSelected ? const Color(0xFFA3E635) : const Color(0xFF9CA3AF),
                  ),
                  if (badgeCount > 0 && !isSelected)
                    Positioned(
                      right: -3,
                      top: -3,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    color: isSelected ? const Color(0xFFA3E635) : const Color(0xFF9CA3AF),
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

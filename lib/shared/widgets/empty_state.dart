import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const EmptyState({super.key, required this.icon, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: const Color(0xFFA3E635)),
          const SizedBox(height: 16),
          Text(title, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF111827))),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(subtitle!, style: GoogleFonts.inter(color: const Color(0xFF9CA3AF))),
          ]
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DeviceCard extends StatelessWidget {
  final String id;
  final String name;
  final bool isOnline;
  final int batteryLevel;
  final String lastSeen;
  final String area;
  final VoidCallback onTap;

  const DeviceCard({
    super.key,
    required this.id,
    required this.name,
    required this.isOnline,
    required this.batteryLevel,
    required this.lastSeen,
    required this.area,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E1E2C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: Color(0xFF2A2A3C))),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isOnline ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(name, style: GoogleFonts.jetBrainsMono(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(batteryLevel > 20 ? Icons.battery_full : Icons.battery_alert, color: batteryLevel > 20 ? Colors.white : Colors.red, size: 16),
                      const SizedBox(width: 4),
                      Text('$batteryLevel%', style: GoogleFonts.inter(color: Colors.white, fontSize: 12)),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 8),
              Text(id, style: GoogleFonts.jetBrainsMono(color: const Color(0xFF9CA3AF), fontSize: 12)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Last seen: $lastSeen', style: GoogleFonts.inter(color: const Color(0xFF9CA3AF), fontSize: 12)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFF2A2A3C), borderRadius: BorderRadius.circular(8)),
                    child: Text(area, style: GoogleFonts.inter(color: const Color(0xFFA3E635), fontSize: 10, fontWeight: FontWeight.bold)),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

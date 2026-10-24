import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AlertCard extends StatelessWidget {
  final String id;
  final String source;
  final int db;
  final String location;
  final String time;
  final bool isActive;
  final VoidCallback onTap;

  const AlertCard({
    super.key,
    required this.id,
    required this.source,
    required this.db,
    required this.location,
    required this.time,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color severityColor = db > 90 ? Colors.red : (db > 75 ? Colors.orange : Colors.green);

    return Card(
      color: const Color(0xFF1E1E2C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFF2A2A3C)),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: const Color(0xFFA3E635).withOpacity(0.2),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 8, color: severityColor),
              Expanded(
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
                              const Icon(Icons.warning, color: Color(0xFF9CA3AF), size: 16),
                              const SizedBox(width: 8),
                              Text(
                                source,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            time,
                            style: GoogleFonts.jetBrainsMono(
                              color: const Color(0xFF9CA3AF),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$db dB',
                                style: GoogleFonts.inter(
                                  color: severityColor,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                location,
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF9CA3AF),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isActive ? Colors.red.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              isActive ? 'Active' : 'Resolved',
                              style: GoogleFonts.jetBrainsMono(
                                color: isActive ? Colors.red : Colors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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

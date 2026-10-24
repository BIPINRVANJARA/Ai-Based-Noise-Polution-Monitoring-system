import 'package:flutter/material.dart';
import 'package:noiseguard/shared/widgets/glass_card.dart';
import 'package:google_fonts/google_fonts.dart';

class AiPredictionCard extends StatelessWidget {
  final String sourceName;
  final double confidence;
  final IconData icon;

  const AiPredictionCard({
    Key? key,
    required this.sourceName,
    required this.confidence,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              icon,
              size: 100,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A3C),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: const Color(0xFFA3E635), size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sourceName,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: confidence,
                              backgroundColor: const Color(0xFF2A2A3C),
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFA3E635)),
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${(confidence * 100).toInt()}%',
                          style: GoogleFonts.jetBrainsMono(
                            color: const Color(0xFFA3E635),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

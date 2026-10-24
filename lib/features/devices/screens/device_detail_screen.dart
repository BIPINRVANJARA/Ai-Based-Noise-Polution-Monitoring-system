import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class DeviceDetailScreen extends StatelessWidget {
  final String id;
  const DeviceDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Device Details',
          style: GoogleFonts.inter(color: const Color(0xFF111827), fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'City Center Hub',
                style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF111827)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
                child: Text('Online', style: GoogleFonts.jetBrainsMono(color: Colors.green, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          Text(id, style: GoogleFonts.jetBrainsMono(color: const Color(0xFF9CA3AF))),
          const SizedBox(height: 24),
          _buildInfoCard(Icons.battery_full, 'Battery', '85%'),
          const SizedBox(height: 12),
          _buildInfoCard(Icons.system_update, 'Firmware', 'v2.1.4 (Up to date)'),
          const SizedBox(height: 12),
          _buildInfoCard(Icons.wifi, 'Connectivity', 'WiFi (Strong)'),
          const SizedBox(height: 12),
          _buildInfoCard(Icons.location_on, 'Location', 'Commercial Zone\nLat: 40.71, Lng: -74.01'),
          const SizedBox(height: 24),
          ExpansionTile(
            title: Text('Configure Threshold', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Slider(
                      value: 70,
                      min: 30,
                      max: 120,
                      activeColor: const Color(0xFFA3E635),
                      onChanged: (val) {},
                    ),
                    Text('70 dB (Commercial)', style: GoogleFonts.jetBrainsMono(color: const Color(0xFF111827))),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 24),
          Text('Activity Timeline', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...List.generate(5, (index) => ListTile(
                leading: const Icon(Icons.history, color: Color(0xFF9CA3AF)),
                title: Text('Reading: ${60 + index} dB', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                subtitle: Text('${index * 5} mins ago', style: GoogleFonts.jetBrainsMono(color: const Color(0xFF9CA3AF), fontSize: 12)),
              ))
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFA3E635)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.jetBrainsMono(color: const Color(0xFF9CA3AF), fontSize: 12)),
              Text(value, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }
}

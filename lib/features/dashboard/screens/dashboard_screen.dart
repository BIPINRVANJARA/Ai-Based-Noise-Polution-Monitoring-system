import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noiseguard/features/dashboard/widgets/db_gauge.dart';
import 'package:noiseguard/features/dashboard/widgets/ai_prediction_card.dart';
import 'package:noiseguard/features/dashboard/widgets/device_status_card.dart';
import 'package:noiseguard/shared/widgets/status_dot.dart';
import 'package:noiseguard/shared/widgets/shimmer_loading.dart';
import 'package:noiseguard/providers/noise_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  IconData _getSourceIcon(String source) {
    switch (source.toLowerCase()) {
      case 'traffic':
        return Icons.directions_car_rounded;
      case 'horn':
        return Icons.campaign_rounded;
      case 'construction':
        return Icons.construction_rounded;
      case 'factory':
        return Icons.factory_rounded;
      case 'crowd':
        return Icons.groups_rounded;
      case 'dj':
      case 'dj/music':
        return Icons.music_note_rounded;
      case 'siren':
        return Icons.warning_amber_rounded;
      case 'aircraft':
        return Icons.flight_takeoff_rounded;
      case 'train':
        return Icons.train_rounded;
      default:
        return Icons.graphic_eq_rounded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noiseAsync = ref.watch(currentNoiseProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 100.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFA3E635).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.shield_rounded, color: Color(0xFFA3E635), size: 20),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'NoiseGuard',
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '● REAL ESP32 FIRESTORE STREAM',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          color: const Color(0xFFA3E635),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E2C),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF2A2A3C)),
                    ),
                    child: const Icon(Icons.person_rounded, color: Color(0xFFA3E635), size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Live Status Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2C),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2A2A3C)),
                ),
                child: Row(
                  children: [
                    const StatusDot(color: Color(0xFFA3E635)),
                    const SizedBox(width: 8),
                    Text(
                      'Live Acoustic Sampling',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'NG-ESP32-001',
                      style: GoogleFonts.jetBrainsMono(
                        color: const Color(0xFF9CA3AF),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Decibel Gauge Centerpiece
              Center(
                child: noiseAsync.when(
                  data: (record) => DbGauge(currentDb: record.noiseLevel),
                  loading: () => const ShimmerLoading(width: 260, height: 260, borderRadius: 130),
                  error: (err, _) => const DbGauge(currentDb: 0.0),
                ),
              ),
              const SizedBox(height: 20),
              
              // Metric Cards Row
              Builder(
                builder: (context) {
                  final stats = ref.watch(noiseStatsProvider);
                  return Row(
                    children: [
                      Expanded(child: _buildMetricCard('MIN', '${stats['min']!.toStringAsFixed(1)} dB', const Color(0xFFA3E635))),
                      const SizedBox(width: 10),
                      Expanded(child: _buildMetricCard('AVG', '${stats['avg']!.toStringAsFixed(1)} dB', const Color(0xFFFF9F0A))),
                      const SizedBox(width: 10),
                      Expanded(child: _buildMetricCard('MAX', '${stats['max']!.toStringAsFixed(1)} dB', const Color(0xFFEF4444))),
                    ],
                  );
                },
              ),
              const SizedBox(height: 18),
              
              // AI Sound Classification Card
              noiseAsync.when(
                data: (record) => AiPredictionCard(
                  sourceName: record.source,
                  confidence: record.confidence,
                  icon: _getSourceIcon(record.source),
                ),
                loading: () => const ShimmerLoading(width: double.infinity, height: 90, borderRadius: 24),
                error: (_, __) => const AiPredictionCard(
                  sourceName: 'ESP32 Standby',
                  confidence: 0.0,
                  icon: Icons.wifi_off_rounded,
                ),
              ),
              const SizedBox(height: 18),
              
              // Device Status Card
              noiseAsync.when(
                data: (record) => DeviceStatusCard(
                  batteryLevel: 98,
                  isConnected: record.noiseLevel > 0,
                  location: record.address ?? 'SG Highway, Ahmedabad',
                  lastSync: record.timestamp,
                ),
                loading: () => const ShimmerLoading(width: double.infinity, height: 100, borderRadius: 24),
                error: (_, __) => DeviceStatusCard(
                  batteryLevel: 0,
                  isConnected: false,
                  location: 'SG Highway, Ahmedabad',
                  lastSync: DateTime.now(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2A2A3C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 3,
            width: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.jetBrainsMono(
              color: const Color(0xFF9CA3AF),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

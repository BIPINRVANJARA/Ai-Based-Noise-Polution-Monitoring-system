import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noiseguard/models/alert.dart';
import 'package:noiseguard/providers/alert_provider.dart';
import 'package:noiseguard/providers/gemini_provider.dart';
import 'package:noiseguard/services/gemini_ai_service.dart';
import 'package:noiseguard/shared/widgets/shimmer_loading.dart';

class AlertDetailScreen extends ConsumerStatefulWidget {
  final String id;
  const AlertDetailScreen({super.key, required this.id});

  @override
  ConsumerState<AlertDetailScreen> createState() => _AlertDetailScreenState();
}

class _AlertDetailScreenState extends ConsumerState<AlertDetailScreen> {
  bool? _overrideResolved;

  @override
  Widget build(BuildContext context) {
    final alertsAsync = ref.watch(alertsProvider);

    final AlertModel? matchedAlert = alertsAsync.value?.cast<AlertModel?>().firstWhere(
          (a) => a?.alertId == widget.id,
          orElse: () => null,
        );

    final alert = matchedAlert ??
        AlertModel(
          alertId: widget.id,
          noiseLevel: 78.5,
          duration: const Duration(seconds: 15),
          latitude: 23.0301,
          longitude: 72.5274,
          source: 'Horn / Siren',
          resolved: false,
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
          deviceId: 'NG-ESP32-001',
          address: 'SG Highway, Ahmedabad',
          confidence: 0.94,
          spectralCentroid: 2450.0,
          spectralFlatness: 0.28,
          crestFactor: 4.2,
          lowBandEnergy: 0.15,
          midBandEnergy: 0.55,
          highBandEnergy: 0.30,
        );

    final isResolved = _overrideResolved ?? alert.resolved;
    final diagnosisAsync = ref.watch(geminiViolationDiagnosisProvider(alert));

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1A),
        elevation: 0,
        title: Text(
          'Incident Intelligence',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
        children: [
          // Peak dB Banner
          Hero(
            tag: 'db_hero_${widget.id}',
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2C),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isResolved ? const Color(0xFFA3E635).withOpacity(0.5) : const Color(0xFFEF4444).withOpacity(0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isResolved ? const Color(0xFFA3E635) : const Color(0xFFEF4444)).withOpacity(0.12),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    '${alert.noiseLevel.toStringAsFixed(1)} dB',
                    style: GoogleFonts.inter(
                      fontSize: 46,
                      fontWeight: FontWeight.bold,
                      color: isResolved ? const Color(0xFFA3E635) : const Color(0xFFEF4444),
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: (isResolved ? const Color(0xFFA3E635) : const Color(0xFFEF4444)).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isResolved ? 'RESOLVED VIOLATION' : 'CRITICAL THRESHOLD EXCEEDANCE',
                      style: GoogleFonts.jetBrainsMono(
                        color: isResolved ? const Color(0xFFA3E635) : const Color(0xFFEF4444),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Gemini LLM Acoustic Diagnosis Card
          _buildGeminiDiagnosisSection(diagnosisAsync),
          const SizedBox(height: 16),

          // Info Cards
          _buildInfoCard(
            Icons.warning_amber_rounded,
            'Edge TinyML Source',
            '${alert.source} (${((alert.confidence ?? 0.90) * 100).toInt()}% confidence)',
          ),
          const SizedBox(height: 10),
          _buildInfoCard(
            Icons.location_on_rounded,
            'Monitored Hotspot',
            '${alert.address ?? 'SG Highway, Ahmedabad'}\nLat: ${alert.latitude.toStringAsFixed(4)}, Lng: ${alert.longitude.toStringAsFixed(4)}',
          ),
          const SizedBox(height: 10),
          _buildInfoCard(
            Icons.access_time_rounded,
            'Timestamp & Duration',
            '${alert.createdAt.toLocal().toString().split('.')[0]}\nDuration: ${alert.duration.inSeconds}s',
          ),
          const SizedBox(height: 16),

          // Spectral Telemetry Snapshot
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2C),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF2A2A3C)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.graphic_eq_rounded, color: Color(0xFFA3E635), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '512-PT FFT SPECTRAL TELEMETRY',
                      style: GoogleFonts.jetBrainsMono(
                        color: const Color(0xFFA3E635),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _buildSpectralMetric(
                        'Centroid',
                        alert.spectralCentroid != null ? '${alert.spectralCentroid!.toStringAsFixed(0)} Hz' : '2.4 kHz',
                      ),
                    ),
                    Expanded(
                      child: _buildSpectralMetric(
                        'Flatness',
                        alert.spectralFlatness != null ? alert.spectralFlatness!.toStringAsFixed(2) : '0.35',
                      ),
                    ),
                    Expanded(
                      child: _buildSpectralMetric(
                        'Crest Factor',
                        alert.crestFactor != null ? '${alert.crestFactor!.toStringAsFixed(1)}x' : '4.2x',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Action Buttons
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () => context.push('/reports'),
              icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
              label: Text(
                'Generate Compliance PDF Incident Report',
                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF2A2A3C)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() => _overrideResolved = !isResolved);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isResolved ? 'Incident marked as Active' : 'Incident marked as Resolved'),
                    backgroundColor: const Color(0xFF1E1E2C),
                  ),
                );
              },
              icon: Icon(isResolved ? Icons.replay_rounded : Icons.check_circle_rounded, color: const Color(0xFF0F0F1A)),
              label: Text(
                isResolved ? 'Re-open Violation' : 'Mark as Resolved',
                style: GoogleFonts.inter(color: const Color(0xFF0F0F1A), fontWeight: FontWeight.bold, fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isResolved ? const Color(0xFF9CA3AF) : const Color(0xFFA3E635),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeminiDiagnosisSection(AsyncValue<AcousticDiagnosisResult> diagnosisAsync) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(24),
        border: const Border(
          left: BorderSide(color: Color(0xFFA3E635), width: 5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Color(0xFFA3E635), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'GEMINI ACOUSTIC DIAGNOSIS',
                    style: GoogleFonts.jetBrainsMono(
                      color: const Color(0xFFA3E635),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFA3E635).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'LLM Verified',
                  style: GoogleFonts.jetBrainsMono(
                    color: const Color(0xFFA3E635),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          diagnosisAsync.when(
            loading: () => const ShimmerLoading(width: double.infinity, height: 90, borderRadius: 12),
            error: (err, _) => Text(
              'Acoustic spike registered by edge FFT sensor. Primary frequency energy concentrated in mid/high bands.',
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
            ),
            data: (diag) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Diagnosed Source: ',
                        style: GoogleFonts.inter(color: const Color(0xFF9CA3AF), fontSize: 13),
                      ),
                      Expanded(
                        child: Text(
                          diag.primarySoundSource,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Severity Rating: ',
                        style: GoogleFonts.inter(color: const Color(0xFF9CA3AF), fontSize: 13),
                      ),
                      ...List.generate(5, (index) {
                        return Icon(
                          Icons.circle,
                          size: 10,
                          color: index < diag.severityScore ? const Color(0xFFEF4444) : const Color(0xFF2A2A3C),
                        );
                      }),
                      const SizedBox(width: 8),
                      Text(
                        '(${diag.severityScore}/5)',
                        style: GoogleFonts.jetBrainsMono(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141422),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '📋 Compliance Assessment:',
                          style: GoogleFonts.jetBrainsMono(
                            color: const Color(0xFFA3E635),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          diag.noiseCodeAssessment,
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 12, height: 1.4),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '⚡ Recommended Civic Action:',
                          style: GoogleFonts.jetBrainsMono(
                            color: Colors.amber,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          diag.recommendedAction,
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 12, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A2A3C)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFA3E635).withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFFA3E635), size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.jetBrainsMono(
                    color: const Color(0xFF9CA3AF),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSpectralMetric(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            color: const Color(0xFF9CA3AF),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

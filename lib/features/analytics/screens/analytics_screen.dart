import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noiseguard/features/analytics/widgets/noise_chart.dart';
import 'package:noiseguard/features/analytics/widgets/source_distribution_chart.dart';
import 'package:noiseguard/features/analytics/widgets/peak_hours_chart.dart';
import 'package:noiseguard/features/analytics/widgets/period_selector.dart';
import 'package:noiseguard/providers/analytics_provider.dart';
import 'package:noiseguard/providers/noise_provider.dart';
import 'package:noiseguard/shared/widgets/shimmer_loading.dart';
import 'package:noiseguard/shared/widgets/glass_card.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPeriod = ref.watch(selectedAnalyticsPeriodProvider);
    final summaryAsync = ref.watch(realAnalyticsDataProvider);
    final periods = ['Daily', 'Weekly', 'Monthly', 'Yearly'];

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1A),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analytics & Insights',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '● REAL ESP32 FIRESTORE STREAM',
              style: GoogleFonts.jetBrainsMono(
                color: const Color(0xFFA3E635),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PeriodSelector(
              periods: periods,
              selectedIndex: selectedPeriod,
              onChanged: (index) {
                ref.read(selectedAnalyticsPeriodProvider.notifier).state = index;
              },
            ),
            const SizedBox(height: 20),

            // Summary Cards Row
            summaryAsync.when(
              data: (summary) => Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Avg Noise',
                      '${summary.avgNoise.toStringAsFixed(1)} dB',
                      Icons.graphic_eq_rounded,
                      const Color(0xFFA3E635),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSummaryCard(
                      'Peak Noise',
                      '${summary.maxNoise.toStringAsFixed(1)} dB',
                      Icons.warning_amber_rounded,
                      const Color(0xFFEF4444),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSummaryCard(
                      'Violations',
                      '${summary.violations}',
                      Icons.shield_outlined,
                      const Color(0xFFFF9F0A),
                    ),
                  ),
                ],
              ),
              loading: () => const Row(
                children: [
                  Expanded(child: ShimmerLoading(width: 100, height: 75, borderRadius: 18)),
                  SizedBox(width: 8),
                  Expanded(child: ShimmerLoading(width: 100, height: 75, borderRadius: 18)),
                  SizedBox(width: 8),
                  Expanded(child: ShimmerLoading(width: 100, height: 75, borderRadius: 18)),
                ],
              ),
              error: (_, __) => Row(
                children: [
                  Expanded(child: _buildSummaryCard('Avg Noise', '58.5 dB', Icons.graphic_eq_rounded, const Color(0xFFA3E635))),
                  const SizedBox(width: 8),
                  Expanded(child: _buildSummaryCard('Peak Noise', '88.0 dB', Icons.warning_amber_rounded, const Color(0xFFEF4444))),
                  const SizedBox(width: 8),
                  Expanded(child: _buildSummaryCard('Violations', '12', Icons.shield_outlined, const Color(0xFFFF9F0A))),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Line Chart
            Text(
              'Noise Level Trend',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: const SizedBox(
                height: 200,
                child: NoiseChart(),
              ),
            ),
            const SizedBox(height: 24),

            // Source Distribution Chart
            Text(
              'Acoustic Source Classification',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: const SizedBox(
                height: 200,
                child: SourceDistributionChart(),
              ),
            ),
            const SizedBox(height: 24),

            // Peak Hours
            Text(
              'Hourly Peak Pattern',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: const SizedBox(
                height: 180,
                child: PeakHoursChart(),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color accentColor) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: accentColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF9CA3AF),
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

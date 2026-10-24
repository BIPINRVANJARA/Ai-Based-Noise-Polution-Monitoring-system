import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:noiseguard/providers/gemini_provider.dart';
import 'package:noiseguard/services/gemini_ai_service.dart';
import 'package:noiseguard/shared/widgets/shimmer_loading.dart';
import 'package:share_plus/share_plus.dart';

class AiSummaryScreen extends ConsumerWidget {
  const AiSummaryScreen({super.key});

  Color _getSourceColor(String source) {
    switch (source.toLowerCase()) {
      case 'traffic':
        return const Color(0xFF3B82F6);
      case 'horn':
        return const Color(0xFFEF4444);
      case 'construction':
        return const Color(0xFFF97316);
      case 'siren':
        return const Color(0xFFF43F5E);
      case 'crowd':
      case 'crowd / speech':
        return const Color(0xFF06B6D4);
      case 'music / dj':
      case 'dj':
        return const Color(0xFFEC4899);
      case 'quiet ambient':
      case 'ambient':
      case 'ambient noise':
        return const Color(0xFFA3E635);
      default:
        return const Color(0xFF8B5CF6);
    }
  }

  IconData _getSourceIcon(String source) {
    switch (source.toLowerCase()) {
      case 'traffic':
        return Icons.directions_car_rounded;
      case 'horn':
        return Icons.campaign_rounded;
      case 'construction':
        return Icons.construction_rounded;
      case 'siren':
        return Icons.warning_amber_rounded;
      case 'crowd':
      case 'crowd / speech':
        return Icons.groups_rounded;
      case 'music / dj':
      case 'dj':
        return Icons.music_note_rounded;
      case 'quiet ambient':
      case 'ambient':
        return Icons.eco_rounded;
      default:
        return Icons.graphic_eq_rounded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightsAsync = ref.watch(geminiDailyInsightsProvider);
    final formattedToday = DateFormat('EEEE, MMM d').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFA3E635).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome, color: Color(0xFF65A30D), size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              'Gemini AI Insights',
              style: GoogleFonts.inter(
                color: const Color(0xFF111827),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Regenerate Insights',
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF111827)),
            onPressed: () {
              ref.invalidate(geminiDailyInsightsProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFFA3E635),
        onRefresh: () async {
          ref.invalidate(geminiDailyInsightsProvider);
          await ref.read(geminiDailyInsightsProvider.future);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF6B7280)),
                      const SizedBox(width: 6),
                      Text(
                        formattedToday,
                        style: GoogleFonts.jetBrainsMono(
                          color: const Color(0xFF111827),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E2C),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.bolt_rounded, size: 14, color: Color(0xFFA3E635)),
                        const SizedBox(width: 4),
                        Text(
                          'Gemini 1.5 Flash',
                          style: GoogleFonts.jetBrainsMono(
                            color: const Color(0xFFA3E635),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Dynamic Insights Content
              insightsAsync.when(
                loading: () => _buildLoadingSkeleton(),
                error: (err, stack) => _buildErrorState(ref, err.toString()),
                data: (insights) => _buildInsightsContent(context, insights),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsightsContent(BuildContext context, GeminiDailyInsights insights) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Executive Briefing Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2C),
            borderRadius: BorderRadius.circular(24),
            border: const Border(
              left: BorderSide(color: Color(0xFFA3E635), width: 5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.psychology_rounded, color: Color(0xFFA3E635), size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'EXECUTIVE ACOUSTIC BRIEFING',
                    style: GoogleFonts.jetBrainsMono(
                      color: const Color(0xFFA3E635),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                insights.executiveBriefing,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.55,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Key Metrics Row
        Row(
          children: [
            Expanded(
              child: _buildMetric(
                'Avg dB',
                insights.avgDb.toStringAsFixed(1),
                Icons.graphic_eq_rounded,
                const Color(0xFFA3E635),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetric(
                'Max dB',
                insights.maxDb.toStringAsFixed(1),
                Icons.warning_amber_rounded,
                Colors.redAccent,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetric(
                'Violations',
                '${insights.violationCount}',
                Icons.gavel_rounded,
                Colors.amber,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Source Breakdown Section
        Text(
          'Detected Acoustic Sources',
          style: GoogleFonts.inter(
            color: const Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (insights.sourceBreakdownPercentages.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2C),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'No classified acoustic events registered yet today.',
              style: GoogleFonts.inter(color: Colors.white70),
            ),
          )
        else
          ...insights.sourceBreakdownPercentages.entries.map((entry) {
            final count = insights.sourceCounts[entry.key] ?? 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: _buildSourceItem(
                entry.key,
                count,
                entry.value,
                _getSourceColor(entry.key),
                _getSourceIcon(entry.key),
              ),
            );
          }),

        const SizedBox(height: 20),

        // Civic Mitigation Recommendations
        Text(
          'Gemini Policy & Mitigation Action Plan',
          style: GoogleFonts.inter(
            color: const Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...insights.civicRecommendations.asMap().entries.map((entry) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA3E635).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${entry.key + 1}',
                    style: GoogleFonts.jetBrainsMono(
                      color: const Color(0xFF4D7C0F),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    entry.value,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF1F2937),
                      fontSize: 14,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 24),

        // Share Action Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              final shareText = '''
🛡️ NoiseGuard Gemini Daily Acoustic Intelligence
📍 SG Highway, Ahmedabad
📅 ${DateFormat('yyyy-MM-dd').format(DateTime.now())}

📊 Summary:
${insights.executiveBriefing}

📈 Metrics:
• Average SPL: ${insights.avgDb.toStringAsFixed(1)} dB
• Peak Sound Level: ${insights.maxDb.toStringAsFixed(1)} dB
• Registered Violations: ${insights.violationCount}

🏛️ Mitigation Plan:
${insights.civicRecommendations.map((r) => '• $r').join('\n')}
''';
              Share.share(shareText);
            },
            icon: const Icon(Icons.share_rounded, color: Color(0xFF1E1E2C)),
            label: Text(
              'Share Intelligence Summary',
              style: GoogleFonts.inter(
                color: const Color(0xFF1E1E2C),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA3E635),
              foregroundColor: const Color(0xFF1E1E2C),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetric(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              color: const Color(0xFF9CA3AF),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceItem(String name, int count, double percentage, Color color, IconData icon) {
    final clampedPerc = percentage.clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${(clampedPerc * 100).toStringAsFixed(0)}% ($count)',
                      style: GoogleFonts.jetBrainsMono(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: clampedPerc,
                  backgroundColor: const Color(0xFF2A2A3C),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  borderRadius: BorderRadius.circular(4),
                  minHeight: 6,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Column(
      children: const [
        ShimmerLoading(width: double.infinity, height: 160, borderRadius: 24),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: ShimmerLoading(width: double.infinity, height: 85, borderRadius: 16)),
            SizedBox(width: 8),
            Expanded(child: ShimmerLoading(width: double.infinity, height: 85, borderRadius: 16)),
            SizedBox(width: 8),
            Expanded(child: ShimmerLoading(width: double.infinity, height: 85, borderRadius: 16)),
          ],
        ),
        SizedBox(height: 24),
        ShimmerLoading(width: double.infinity, height: 60, borderRadius: 16),
        SizedBox(height: 10),
        ShimmerLoading(width: double.infinity, height: 60, borderRadius: 16),
        SizedBox(height: 10),
        ShimmerLoading(width: double.infinity, height: 60, borderRadius: 16),
      ],
    );
  }

  Widget _buildErrorState(WidgetRef ref, String error) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded, color: Colors.amber, size: 48),
          const SizedBox(height: 12),
          Text(
            'Unable to Generate AI Insights',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: Colors.white60,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.invalidate(geminiDailyInsightsProvider),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFA3E635)),
            child: Text(
              'Retry',
              style: GoogleFonts.inter(color: const Color(0xFF1E1E2C), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

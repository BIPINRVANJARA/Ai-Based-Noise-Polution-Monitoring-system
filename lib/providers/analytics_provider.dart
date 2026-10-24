import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noiseguard/models/daily_summary.dart';
import 'package:noiseguard/providers/noise_provider.dart';

final selectedAnalyticsPeriodProvider = StateProvider<int>((ref) => 0); // 0: Daily, 1: Weekly, 2: Monthly, 3: Yearly

final realAnalyticsDataProvider = FutureProvider<DailySummary>((ref) async {
  final periodIndex = ref.watch(selectedAnalyticsPeriodProvider);
  
  int days = 1;
  if (periodIndex == 1) days = 7;
  if (periodIndex == 2) days = 30;
  if (periodIndex == 3) days = 365;

  final records = await ref.watch(noiseHistoryProvider(days).future);
  if (records.isEmpty) {
    return DailySummary(
      date: DateTime.now(),
      avgNoise: 0.0,
      maxNoise: 0.0,
      minNoise: 0.0,
      totalReadings: 0,
      violations: 0,
      peakHour: 'N/A',
      sourceDistribution: {'Awaiting Data': 1},
      aiSummary: 'Awaiting real telemetry samples streamed from your ESP32 hardware...',
    );
  }

  double sum = 0;
  double maxDb = 0;
  double minDb = 200;
  int violations = 0;
  final Map<String, int> distribution = {};

  for (final r in records) {
    sum += r.noiseLevel;
    if (r.noiseLevel > maxDb) maxDb = r.noiseLevel;
    if (r.noiseLevel < minDb) minDb = r.noiseLevel;
    if (r.violation) violations++;

    distribution[r.source] = (distribution[r.source] ?? 0) + 1;
  }

  final avg = sum / records.length;
  final topEntry = distribution.isNotEmpty 
      ? distribution.entries.reduce((a, b) => a.value > b.value ? a : b)
      : const MapEntry('Traffic', 1);

  final summaryText = 'Analyzed ${records.length} real ESP32 telemetry records. '
      'Average noise level was ${avg.toStringAsFixed(1)} dB with peak at ${maxDb.toStringAsFixed(1)} dB. '
      'Top detected source was ${topEntry.key} (${topEntry.value} occurrences). '
      'Total of $violations violations recorded.';

  return DailySummary(
    date: DateTime.now(),
    avgNoise: avg,
    maxNoise: maxDb,
    minNoise: minDb == 200 ? 0.0 : minDb,
    totalReadings: records.length,
    violations: violations,
    peakHour: '6:00 PM - 7:00 PM',
    sourceDistribution: distribution,
    aiSummary: summaryText,
  );
});

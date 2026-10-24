import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noiseguard/models/alert.dart';
import 'package:noiseguard/providers/alert_provider.dart';
import 'package:noiseguard/providers/noise_provider.dart';
import 'package:noiseguard/services/gemini_ai_service.dart';

final geminiServiceProvider = Provider<GeminiAiService>((ref) {
  return GeminiAiService();
});

/// Generates live Gemini daily acoustic summary based on real Firestore records and alerts
final geminiDailyInsightsProvider = FutureProvider.autoDispose<GeminiDailyInsights>((ref) async {
  final gemini = ref.watch(geminiServiceProvider);
  final recordsAsync = ref.watch(firestoreNoiseStreamProvider);
  final alertsAsync = ref.watch(alertsProvider);

  final records = recordsAsync.value ?? [];
  final alerts = alertsAsync.value ?? [];

  return gemini.generateDailyInsights(
    records: records,
    alerts: alerts,
    locationName: 'SG Highway, Ahmedabad',
  );
});

/// Diagnoses a specific violation incident using Gemini LLM and spectral features
final geminiViolationDiagnosisProvider =
    FutureProvider.family.autoDispose<AcousticDiagnosisResult, AlertModel>((ref, alert) async {
  final gemini = ref.watch(geminiServiceProvider);
  return gemini.diagnoseViolation(alert: alert);
});

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:noiseguard/core/constants/app_constants.dart';
import 'package:noiseguard/models/alert.dart';
import 'package:noiseguard/models/noise_record.dart';

/// Structured acoustic violation diagnosis returned by Gemini LLM
class AcousticDiagnosisResult {
  final String primarySoundSource;
  final int severityScore; // 1 to 5
  final String noiseCodeAssessment;
  final String recommendedAction;
  final String explanation;

  AcousticDiagnosisResult({
    required this.primarySoundSource,
    required this.severityScore,
    required this.noiseCodeAssessment,
    required this.recommendedAction,
    required this.explanation,
  });

  factory AcousticDiagnosisResult.fallback(AlertModel alert) {
    int severity = 3;
    if (alert.noiseLevel >= 85) {
      severity = 5;
    } else if (alert.noiseLevel >= 75) {
      severity = 4;
    } else if (alert.noiseLevel >= 65) {
      severity = 3;
    } else {
      severity = 2;
    }

    return AcousticDiagnosisResult(
      primarySoundSource: '${alert.source} Acoustic Event',
      severityScore: severity,
      noiseCodeAssessment: alert.noiseLevel > 65.0
          ? 'CPCB Standard Violation (+${(alert.noiseLevel - 65.0).toStringAsFixed(1)} dB above Commercial Day Limit)'
          : 'Elevated Ambient Sound Exceedance',
      recommendedAction: alert.noiseLevel >= 75.0
          ? 'Dispatch civic environmental patrol & issue warning citation to source.'
          : 'Log incident in municipal compliance registry and monitor trend.',
      explanation:
          'Peak SPL reached ${alert.noiseLevel.toStringAsFixed(1)} dB with characteristic ${alert.source.toLowerCase()} spectral signature.',
    );
  }
}

/// Structured daily intelligence summary returned by Gemini LLM
class GeminiDailyInsights {
  final String executiveBriefing;
  final double avgDb;
  final double maxDb;
  final int violationCount;
  final String peakHour;
  final Map<String, double> sourceBreakdownPercentages; // e.g. {'Traffic': 0.65, 'Construction': 0.25}
  final Map<String, int> sourceCounts;
  final List<String> civicRecommendations;
  final DateTime generatedAt;

  GeminiDailyInsights({
    required this.executiveBriefing,
    required this.avgDb,
    required this.maxDb,
    required this.violationCount,
    required this.peakHour,
    required this.sourceBreakdownPercentages,
    required this.sourceCounts,
    required this.civicRecommendations,
    required this.generatedAt,
  });

  factory GeminiDailyInsights.fromComputed({
    required List<NoiseRecord> records,
    required List<AlertModel> alerts,
    required String locationName,
  }) {
    if (records.isEmpty) {
      return GeminiDailyInsights(
        executiveBriefing:
            'Acoustic sensors at $locationName have recorded insufficient baseline telemetry today. Ambient levels remain nominal.',
        avgDb: 48.0,
        maxDb: 54.0,
        violationCount: alerts.length,
        peakHour: 'N/A',
        sourceBreakdownPercentages: {'Ambient': 1.0},
        sourceCounts: {'Ambient': 1},
        civicRecommendations: [
          'Maintain continuous I2S edge sampling along the primary corridor.',
          'Verify micro-sensor telemetry calibration at regular daily intervals.'
        ],
        generatedAt: DateTime.now(),
      );
    }

    double totalDb = 0;
    double maxDb = 0;
    final Map<String, int> counts = {};
    final Map<int, int> hourHistogram = {};

    for (final r in records) {
      totalDb += r.noiseLevel;
      if (r.noiseLevel > maxDb) maxDb = r.noiseLevel;
      counts[r.source] = (counts[r.source] ?? 0) + 1;
      hourHistogram[r.timestamp.hour] = (hourHistogram[r.timestamp.hour] ?? 0) + 1;
    }

    final double avgDb = totalDb / records.length;
    final int totalCount = records.length;
    final Map<String, double> percentages = {};
    counts.forEach((k, v) {
      percentages[k] = v / totalCount;
    });

    int peakH = 18;
    int maxHourCount = 0;
    hourHistogram.forEach((hour, count) {
      if (count > maxHourCount) {
        maxHourCount = count;
        peakH = hour;
      }
    });
    final String peakHourStr = '${peakH % 12 == 0 ? 12 : peakH % 12}:00 ${peakH >= 12 ? 'PM' : 'AM'}';

    final topSource = counts.entries.isNotEmpty
        ? (counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).first.key
        : 'Traffic';

    return GeminiDailyInsights(
      executiveBriefing:
          'Highest recorded noise reached ${maxDb.toStringAsFixed(1)} dB at $locationName around $peakHourStr. $topSource was the dominant acoustic contributor with an average daily baseline of ${avgDb.toStringAsFixed(1)} dB across ${alerts.length} violation events.',
      avgDb: avgDb,
      maxDb: maxDb,
      violationCount: alerts.length,
      peakHour: peakHourStr,
      sourceBreakdownPercentages: percentages,
      sourceCounts: counts,
      civicRecommendations: [
        'Implement automated traffic speed-calming and acoustic signage during peak evening hours ($peakHourStr).',
        'Enforce municipal CPCB commercial zone limits (65 dB daytime) targeting persistent $topSource emissions.'
      ],
      generatedAt: DateTime.now(),
    );
  }
}

class GeminiAiService {
  static final GeminiAiService _instance = GeminiAiService._internal();
  factory GeminiAiService() => _instance;
  GeminiAiService._internal();

  GenerativeModel? _model;

  GenerativeModel _getModel() {
    _model ??= GenerativeModel(
      model: AppConstants.geminiModel,
      apiKey: AppConstants.geminiApiKey,
      generationConfig: GenerationConfig(
        temperature: 0.2,
        maxOutputTokens: 1024,
      ),
    );
    return _model!;
  }

  /// Feature 1: Diagnose an acoustic violation event based on edge DSP spectral data
  Future<AcousticDiagnosisResult> diagnoseViolation({
    required AlertModel alert,
    Map<String, dynamic>? spectralData,
  }) async {
    final double db = alert.noiseLevel;
    final String detectedClass = alert.source;
    final double? sc = alert.spectralCentroid ?? spectralData?['spectralCentroid'];
    final double? sf = alert.spectralFlatness ?? spectralData?['spectralFlatness'];
    final double? cf = alert.crestFactor ?? spectralData?['crestFactor'];
    final double? lowE = alert.lowBandEnergy ?? spectralData?['lowBandEnergy'];
    final double? midE = alert.midBandEnergy ?? spectralData?['midBandEnergy'];
    final double? highE = alert.highBandEnergy ?? spectralData?['highBandEnergy'];

    final prompt = '''
You are an expert environmental acoustic engineer and municipal noise compliance officer.
Analyze this IoT noise violation telemetry captured by an ESP32 sensor at ${alert.address ?? 'Urban Corridor'}:

- Peak Decibel Level: ${db.toStringAsFixed(1)} dB SPL
- On-Device Detected Category: $detectedClass
- Spectral Centroid: ${sc != null ? '${sc.toStringAsFixed(0)} Hz' : 'N/A'}
- Spectral Flatness: ${sf != null ? sf.toStringAsFixed(2) : 'N/A'} (0=pure tone like horn, 1=white noise)
- Crest Factor: ${cf != null ? cf.toStringAsFixed(1) : 'N/A'} (Peak-to-RMS ratio, >4 indicates impulsive impacts)
- Sub-Band Energies: Low (62-500Hz)=${lowE != null ? '${(lowE * 100).toStringAsFixed(0)}%' : 'N/A'}, Mid (500-3000Hz)=${midE != null ? '${(midE * 100).toStringAsFixed(0)}%' : 'N/A'}, High (>3000Hz)=${highE != null ? '${(highE * 100).toStringAsFixed(0)}%' : 'N/A'}

Acoustic Reference Guidelines:
- Human Voice / Speech: Mid-band energy is dominant (500-3000 Hz), centroid between 600-2500 Hz, moderate flatness.
- Vehicle Horn / Honk: Low flatness (<0.18, highly tonal), centroid between 400-1300 Hz.
- Emergency Siren: High ZCR, high centroid (>1400 Hz), elevated high-band energy.
- Heavy Traffic / Engine: Dominant low-frequency rumble (<500 Hz, lowBand > 50%), low centroid (<600 Hz).
- Construction / Impact: High crest factor (>4), broadband flat spectrum.
- Loud Music / DJ: Strong bass + mid frequencies, harmonic spectrum, SPL > 70 dB.

Respond strictly with a valid JSON object matching this schema:
{
  "primarySoundSource": "Specific physical sound source (e.g., Human Shouting / Amplified Speech, High-Tone Vehicle Horn, Heavy Commercial Diesel Truck, Pneumatic Breaker, Loudspeaker PA)",
  "severityScore": 1 to 5 integer (1=minor exceedance, 5=hazardous/emergency),
  "noiseCodeAssessment": "1 clear sentence assessing CPCB/Municipal environmental noise code violation",
  "recommendedAction": "1 actionable enforcement or mitigation step",
  "explanation": "1-2 sentence spectral acoustic analysis explaining why this sound was identified"
}
''';

    try {
      final model = _getModel();
      final response = await model.generateContent([Content.text(prompt)]);
      final text = response.text;
      if (text != null && text.isNotEmpty) {
        final cleanJson = _extractJson(text);
        final data = jsonDecode(cleanJson) as Map<String, dynamic>;
        return AcousticDiagnosisResult(
          primarySoundSource: data['primarySoundSource'] ?? detectedClass,
          severityScore: (data['severityScore'] as num?)?.toInt() ?? 3,
          noiseCodeAssessment: data['noiseCodeAssessment'] ?? 'Noise Limit Exceedance',
          recommendedAction: data['recommendedAction'] ?? 'Deploy municipal inspection team.',
          explanation: data['explanation'] ?? 'Acoustic spike registered by edge FFT sensor.',
        );
      }
    } catch (e) {
      debugPrint('Gemini diagnoseViolation error (using fallback): $e');
    }

    return AcousticDiagnosisResult.fallback(alert);
  }

  /// Feature 2: Generate comprehensive daily executive briefing & policy recommendations
  Future<GeminiDailyInsights> generateDailyInsights({
    required List<NoiseRecord> records,
    required List<AlertModel> alerts,
    required String locationName,
  }) async {
    final fallback = GeminiDailyInsights.fromComputed(
      records: records,
      alerts: alerts,
      locationName: locationName,
    );

    if (records.isEmpty) {
      return fallback;
    }

    final topSources = fallback.sourceCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final sourcesSummary = topSources.take(4).map((e) => '${e.key}: ${e.value} readings').join(', ');

    final prompt = '''
You are the AI Chief Acoustic Analyst for NoiseGuard Urban Intelligence.
Review today's noise sensor telemetry for $locationName:

- Total Audio Readings: ${records.length}
- Average Decibels: ${fallback.avgDb.toStringAsFixed(1)} dB SPL
- Peak Decibel Level: ${fallback.maxDb.toStringAsFixed(1)} dB SPL
- Total Violation Incidents: ${alerts.length}
- Peak Noise Time Window: Around ${fallback.peakHour}
- Acoustic Categories Detected: $sourcesSummary

Generate a high-level executive report in strictly valid JSON:
{
  "executiveBriefing": "2 sentences summarizing today's key noise patterns, peak decibels, and main source.",
  "civicRecommendations": [
    "Specific engineering/civic recommendation 1 (e.g. speed calming, noise barriers)",
    "Specific municipal policy recommendation 2 (e.g. night enforcement, acoustic camera)"
  ]
}
''';

    try {
      final model = _getModel();
      final response = await model.generateContent([Content.text(prompt)]);
      final text = response.text;
      if (text != null && text.isNotEmpty) {
        final cleanJson = _extractJson(text);
        final data = jsonDecode(cleanJson) as Map<String, dynamic>;
        final briefing = data['executiveBriefing'] as String?;
        final recsList = (data['civicRecommendations'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList();

        return GeminiDailyInsights(
          executiveBriefing: briefing ?? fallback.executiveBriefing,
          avgDb: fallback.avgDb,
          maxDb: fallback.maxDb,
          violationCount: fallback.violationCount,
          peakHour: fallback.peakHour,
          sourceBreakdownPercentages: fallback.sourceBreakdownPercentages,
          sourceCounts: fallback.sourceCounts,
          civicRecommendations: recsList != null && recsList.isNotEmpty
              ? recsList
              : fallback.civicRecommendations,
          generatedAt: DateTime.now(),
        );
      }
    } catch (e) {
      debugPrint('Gemini generateDailyInsights error (using fallback): $e');
    }

    return fallback;
  }

  static String _extractJson(String rawText) {
    String text = rawText.trim();
    if (text.startsWith('```json')) {
      text = text.substring(7);
    } else if (text.startsWith('```')) {
      text = text.substring(3);
    }
    if (text.endsWith('```')) {
      text = text.substring(0, text.length - 3);
    }
    return text.trim();
  }
}

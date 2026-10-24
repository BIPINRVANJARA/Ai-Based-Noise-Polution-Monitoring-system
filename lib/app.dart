import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noiseguard/core/router/app_router.dart';
import 'package:noiseguard/providers/noise_provider.dart';
import 'package:noiseguard/providers/settings_provider.dart';
import 'package:noiseguard/services/notification_service.dart';

class NoiseGuardApp extends ConsumerWidget {
  const NoiseGuardApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);
    final currentCustomThreshold = ref.watch(thresholdProvider);

    // Global real-time violation listener: triggers alert notification when threshold is exceeded
    ref.listen(currentNoiseProvider, (previous, next) {
      if (!notificationsEnabled) return;

      next.whenData((record) {
        final effectiveThreshold = record.threshold > 0 ? record.threshold : currentCustomThreshold;
        if (record.noiseLevel > effectiveThreshold || record.violation) {
          NotificationService().showNoiseAlert(
            noiseLevel: record.noiseLevel,
            threshold: effectiveThreshold,
            source: record.source,
            address: record.address ?? 'SG Highway, Ahmedabad',
          );
        }
      });
    });

    return MaterialApp.router(
      title: 'NoiseGuard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFA3E635)),
        textTheme: GoogleFonts.interTextTheme(),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noiseguard/features/devices/widgets/device_card.dart';
import 'package:noiseguard/providers/device_provider.dart';
import 'package:noiseguard/shared/widgets/shimmer_loading.dart';
import 'package:noiseguard/shared/widgets/empty_state.dart';

class DevicesScreen extends ConsumerWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devicesAsync = ref.watch(devicesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1A),
        elevation: 0,
        title: Text(
          'Hardware Devices',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: devicesAsync.when(
        data: (devices) {
          if (devices.isEmpty) {
            return const EmptyState(
              icon: Icons.memory_rounded,
              title: 'No Hardware Devices Registered',
              subtitle: 'Provision your ESP32 board to register it in Cloud Firestore',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              return DeviceCard(
                id: device.deviceId,
                name: device.name,
                isOnline: device.status == 'online',
                batteryLevel: device.batteryLevel.toInt(),
                lastSeen: device.lastSeen.toString().split('.').first,
                area: device.assignedArea ?? 'Residential',
                onTap: () => context.push('/device/${device.deviceId}'),
              );
            },
          );
        },
        loading: () => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 2,
          itemBuilder: (_, __) => const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: ShimmerLoading(width: double.infinity, height: 90, borderRadius: 20),
          ),
        ),
        error: (_, __) => const EmptyState(
          icon: Icons.memory_rounded,
          title: 'No Hardware Devices Registered',
          subtitle: 'Provision your ESP32 board to register it in Cloud Firestore',
        ),
      ),
    );
  }
}

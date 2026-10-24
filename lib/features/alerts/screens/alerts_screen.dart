import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noiseguard/features/alerts/widgets/alert_card.dart';
import 'package:noiseguard/shared/widgets/empty_state.dart';
import 'package:noiseguard/shared/widgets/shimmer_loading.dart';
import 'package:noiseguard/providers/alert_provider.dart';

final selectedAlertFilterProvider = StateProvider<int>((ref) => 0); // 0: All, 1: Active, 2: Resolved

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(selectedAlertFilterProvider);
    final alertsAsync = ref.watch(alertsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1A),
        elevation: 0,
        title: Text(
          'Noise Violation Alerts',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 16),
                  const SizedBox(width: 4),
                  Consumer(
                    builder: (context, ref, child) {
                      final activeCount = ref.watch(unresolvedAlertCountProvider);
                      return Text(
                        '$activeCount Active',
                        style: GoogleFonts.jetBrainsMono(
                          color: const Color(0xFFEF4444),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(54),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
            child: Row(
              children: [
                _buildFilterChip('All', 0, selectedFilter, ref),
                const SizedBox(width: 8),
                _buildFilterChip('Active', 1, selectedFilter, ref),
                const SizedBox(width: 8),
                _buildFilterChip('Resolved', 2, selectedFilter, ref),
              ],
            ),
          ),
        ),
      ),
      body: alertsAsync.when(
        data: (alerts) {
          final filteredAlerts = alerts.where((a) {
            if (selectedFilter == 1) return !a.resolved;
            if (selectedFilter == 2) return a.resolved;
            return true;
          }).toList();

          if (filteredAlerts.isEmpty) {
            return const EmptyState(
              icon: Icons.shield_rounded,
              title: 'All Clear',
              subtitle: 'No real noise violations registered in Cloud Firestore',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            itemCount: filteredAlerts.length,
            itemBuilder: (context, index) {
              final alert = filteredAlerts[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: AlertCard(
                  id: alert.alertId,
                  source: alert.source,
                  db: alert.noiseLevel.toInt(),
                  location: alert.address ?? 'SG Highway, Ahmedabad',
                  time: alert.createdAt.toString().split('.').first,
                  isActive: !alert.resolved,
                  onTap: () => context.push('/alert/${alert.alertId}'),
                ),
              );
            },
          );
        },
        loading: () => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 3,
          itemBuilder: (_, __) => const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: ShimmerLoading(width: double.infinity, height: 90, borderRadius: 20),
          ),
        ),
        error: (_, __) => const EmptyState(
          icon: Icons.shield_rounded,
          title: 'All Clear',
          subtitle: 'No real noise violations registered in Cloud Firestore',
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int index, int selectedIndex, WidgetRef ref) {
    final isSelected = index == selectedIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(selectedAlertFilterProvider.notifier).state = index;
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFA3E635) : const Color(0xFF1E1E2C),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? const Color(0xFFA3E635) : const Color(0xFF2A2A3C),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: isSelected ? const Color(0xFF0F0F1A) : const Color(0xFF9CA3AF),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

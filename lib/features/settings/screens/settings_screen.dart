import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:noiseguard/providers/settings_provider.dart';
import 'package:noiseguard/core/constants/noise_thresholds.dart';
import 'package:noiseguard/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  double _customThreshold = 65.0;
  bool _alertSound = true;
  bool _vibration = true;

  User? get _safeCurrentUser {
    try {
      return FirebaseAuth.instance.currentUser;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final areaType = ref.watch(selectedAreaTypeProvider);
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);
    final user = _safeCurrentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1A),
        elevation: 0,
        title: Text(
          'Settings & Controls',
          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: [
          // Profile Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2C),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF2A2A3C)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: const Color(0xFFA3E635).withOpacity(0.2),
                  child: const Icon(Icons.person_rounded, color: Color(0xFFA3E635), size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? 'NoiseGuard Operator',
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.email ?? 'operator@noiseguard.io',
                        style: GoogleFonts.inter(color: const Color(0xFF9CA3AF), fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFA3E635).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          user != null ? 'AUTHENTICATED' : 'ADMINISTRATOR',
                          style: GoogleFonts.jetBrainsMono(
                            color: const Color(0xFFA3E635),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _buildSectionHeader('NOISE MONITORING & THRESHOLDS'),
          
          // Area Type Selector
          ListTile(
            title: Text('Assigned Area Type', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)),
            subtitle: Text('Sets legal decibel limit for violations', style: GoogleFonts.inter(color: const Color(0xFF9CA3AF), fontSize: 12)),
            trailing: DropdownButton<AreaType>(
              value: areaType,
              dropdownColor: const Color(0xFF1E1E2C),
              style: GoogleFonts.jetBrainsMono(color: const Color(0xFFA3E635), fontWeight: FontWeight.bold),
              underline: const SizedBox(),
              items: AreaType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  ref.read(selectedAreaTypeProvider.notifier).state = val;
                }
              },
            ),
          ),
          
          // Custom Threshold Slider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Custom Alarm Threshold', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)),
                    Text(
                      '${_customThreshold.toStringAsFixed(0)} dB',
                      style: GoogleFonts.jetBrainsMono(color: const Color(0xFFA3E635), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Slider(
                  value: _customThreshold,
                  min: 40.0,
                  max: 100.0,
                  divisions: 60,
                  activeColor: const Color(0xFFA3E635),
                  inactiveColor: const Color(0xFF2A2A3C),
                  onChanged: (val) {
                    setState(() => _customThreshold = val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _buildSectionHeader('NOTIFICATIONS & ALERTS'),
          SwitchListTile(
            title: Text('Push Notifications', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)),
            subtitle: Text('Receive violation notifications in background', style: GoogleFonts.inter(color: const Color(0xFF9CA3AF), fontSize: 12)),
            value: notificationsEnabled,
            activeTrackColor: const Color(0xFFA3E635),
            onChanged: (val) {
              ref.read(notificationsEnabledProvider.notifier).state = val;
            },
          ),
          SwitchListTile(
            title: Text('Alert Sound', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)),
            value: _alertSound,
            activeTrackColor: const Color(0xFFA3E635),
            onChanged: (val) => setState(() => _alertSound = val),
          ),
          SwitchListTile(
            title: Text('Vibration', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)),
            value: _vibration,
            activeTrackColor: const Color(0xFFA3E635),
            onChanged: (val) => setState(() => _vibration = val),
          ),
          const SizedBox(height: 20),

          _buildSectionHeader('HARDWARE DATA STREAM'),
          ListTile(
            leading: const Icon(Icons.sensors_rounded, color: Color(0xFFA3E635)),
            title: Text('Data Source', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)),
            subtitle: Text('Cloud Firestore (noise_records stream)', style: GoogleFonts.inter(color: const Color(0xFFA3E635), fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            title: Text('Version', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)),
            trailing: Text('3.0 Production', style: GoogleFonts.jetBrainsMono(color: const Color(0xFF9CA3AF), fontSize: 12)),
          ),
          const SizedBox(height: 20),

          _buildSectionHeader('ACCOUNT SESSION'),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.red),
            title: Text('Sign Out', style: GoogleFonts.inter(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () async {
              try {
                await AuthService().signOut();
              } catch (_) {}
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('is_guest_logged_in');
              if (mounted) {
                context.go('/login');
              }
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 16),
      child: Text(
        title,
        style: GoogleFonts.jetBrainsMono(color: const Color(0xFFA3E635), fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }
}

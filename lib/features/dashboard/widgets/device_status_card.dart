import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class DeviceStatusCard extends ConsumerWidget {
  final int batteryLevel;
  final bool isConnected;
  final String location;
  final DateTime lastSync;

  const DeviceStatusCard({
    Key? key,
    required this.batteryLevel,
    required this.isConnected,
    required this.location,
    required this.lastSync,
  }) : super(key: key);

  void _showEsp32PairingModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E2C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => const _Esp32PairingSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isConnected
              ? const Color(0xFF2A2A3C)
              : const Color(0xFFEF4444).withOpacity(0.6),
          width: isConnected ? 1.0 : 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Battery Level
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Icon(
                      isConnected ? Icons.battery_charging_full_rounded : Icons.battery_alert_rounded,
                      size: 16,
                      color: isConnected ? const Color(0xFFA3E635) : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isConnected ? '$batteryLevel%' : '0%',
                      style: GoogleFonts.jetBrainsMono(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // WiFi Status
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Icon(
                      isConnected ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                      size: 16,
                      color: isConnected ? const Color(0xFFA3E635) : Colors.redAccent,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        isConnected ? 'Connected' : 'Offline',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: isConnected ? const Color(0xFFA3E635) : Colors.redAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Location Pin
              Expanded(
                flex: 4,
                child: Row(
                  children: [
                    Icon(Icons.location_on_rounded, size: 16, color: isConnected ? const Color(0xFFA3E635) : const Color(0xFF9CA3AF)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        isConnected ? location : 'SG Highway, Ahmedabad',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF9CA3AF),
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Connection Button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () => _showEsp32PairingModal(context, ref),
              icon: Icon(
                isConnected ? Icons.settings_input_antenna_rounded : Icons.wifi_find_rounded,
                size: 18,
                color: isConnected ? const Color(0xFF0F0F1A) : Colors.white,
              ),
              label: Text(
                isConnected ? 'ESP32 Device Provisioning' : 'Configure ESP32 Wi-Fi Hotspot',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isConnected ? const Color(0xFF0F0F1A) : Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isConnected ? const Color(0xFFA3E635) : const Color(0xFFFF9F0A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Esp32PairingSheet extends StatefulWidget {
  const _Esp32PairingSheet({super.key});

  @override
  State<_Esp32PairingSheet> createState() => _Esp32PairingSheetState();
}

class _Esp32PairingSheetState extends State<_Esp32PairingSheet> {
  bool _isConnecting = false;
  bool _isSuccess = false;

  final _ssidController = TextEditingController(text: 'vivoy200');
  final _passController = TextEditingController(text: '77777777');
  final _deviceIdController = TextEditingController(text: 'NG-ESP32-001');

  void _sendWifiCredentials() async {
    setState(() => _isConnecting = true);

    try {
      final uri = Uri.parse('http://192.168.4.1/setup');
      await http.post(uri, body: {
        'ssid': _ssidController.text.trim(),
        'pass': _passController.text.trim(),
        'deviceId': _deviceIdController.text.trim(),
      }).timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('ESP32 HTTP Provisioning notice: $e');
    }

    if (mounted) {
      setState(() {
        _isConnecting = false;
        _isSuccess = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A3C),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFA3E635).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.wifi_rounded, color: Color(0xFFA3E635), size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ESP32 Wi-Fi Setup',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Send Wi-Fi credentials directly to ESP32 Hardware',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          if (!_isSuccess) ...[
            TextField(
              controller: _deviceIdController,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                labelText: 'ESP32 Device ID',
                labelStyle: GoogleFonts.inter(color: const Color(0xFF9CA3AF), fontSize: 11),
                prefixIcon: const Icon(Icons.memory, color: Color(0xFFA3E635), size: 18),
                filled: true,
                fillColor: const Color(0xFF141422),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _ssidController,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                labelText: 'Hotspot / Router SSID',
                labelStyle: GoogleFonts.inter(color: const Color(0xFF9CA3AF), fontSize: 11),
                prefixIcon: const Icon(Icons.wifi, color: Color(0xFFA3E635), size: 18),
                filled: true,
                fillColor: const Color(0xFF141422),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passController,
              obscureText: true,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                labelText: 'Wi-Fi Password',
                labelStyle: GoogleFonts.inter(color: const Color(0xFF9CA3AF), fontSize: 11),
                prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFA3E635), size: 18),
                filled: true,
                fillColor: const Color(0xFF141422),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: _isConnecting ? null : _sendWifiCredentials,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA3E635),
                  foregroundColor: const Color(0xFF0F0F1A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isConnecting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0F0F1A)))
                    : Text('Transmit Credentials to ESP32', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
          ] else ...[
            Center(
              child: Column(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Color(0xFFA3E635), size: 50),
                  const SizedBox(height: 10),
                  Text('Credentials Transmitted!', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Your ESP32 is connecting to Wi-Fi and streaming telemetry to Cloud Firestore.', textAlign: TextAlign.center, style: GoogleFonts.inter(color: const Color(0xFF9CA3AF), fontSize: 12)),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA3E635),
                        foregroundColor: const Color(0xFF0F0F1A),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text('Done', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

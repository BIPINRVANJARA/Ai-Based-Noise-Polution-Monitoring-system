import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedPeriod = 'All Dates';
  String _selectedDevice = 'All Devices';
  String _selectedArea = 'All Areas';
  bool _isGenerating = false;

  final List<String> _periods = ['Today', 'This Week', 'This Month', 'All Dates'];
  final List<String> _devices = ['All Devices', 'NG-ESP32-001 (SG Highway)', 'NG-ESP32-002 (Maninagar)'];
  final List<String> _areas = ['All Areas', 'Residential', 'Commercial', 'Hospital/Silence', 'Industrial'];

  void _generatePdfReport() async {
    setState(() => _isGenerating = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isGenerating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF Report generated for $_selectedDevice ($_selectedPeriod)'),
          backgroundColor: const Color(0xFF1E1E2C),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1A),
        elevation: 0,
        title: Text(
          'Acoustic Reports',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: [
          // Filter Form Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2C),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF2A2A3C)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Generate Compliance Report',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // Date Range Dropdown
                _buildDropdown('Date Filter', _selectedPeriod, _periods, (val) {
                  if (val != null) setState(() => _selectedPeriod = val);
                }),
                const SizedBox(height: 12),

                // Device Dropdown
                _buildDropdown('Target Device', _selectedDevice, _devices, (val) {
                  if (val != null) setState(() => _selectedDevice = val);
                }),
                const SizedBox(height: 12),

                // Area Type Dropdown
                _buildDropdown('Area Zone', _selectedArea, _areas, (val) {
                  if (val != null) setState(() => _selectedArea = val);
                }),
                const SizedBox(height: 20),

                // Generate Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isGenerating ? null : _generatePdfReport,
                    icon: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFF0F0F1A)),
                    label: _isGenerating
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0F0F1A)))
                        : Text(
                            'Generate Official PDF Report',
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0F0F1A)),
                          ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA3E635),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Recent Generated Reports List
          Text(
            'Recent Downloaded Reports',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),

          _buildReportTile('Weekly Noise Compliance Summary', 'Jul 21 - Jul 28, 2026', '2.4 MB PDF'),
          const SizedBox(height: 10),
          _buildReportTile('Monthly Acoustic Violation Audit', 'June 2026', '5.1 MB PDF'),
          const SizedBox(height: 10),
          _buildReportTile('SG Highway Incident Report', 'Jul 15, 2026', '1.2 MB PDF'),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF141422),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2A3C)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF1E1E2C),
          style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
          icon: const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFFA3E635)),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item, style: GoogleFonts.inter(color: Colors.white)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildReportTile(String title, String date, String size) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2A2A3C)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.picture_as_pdf_rounded, color: Colors.redAccent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  '$date • $size',
                  style: GoogleFonts.jetBrainsMono(color: const Color(0xFF9CA3AF), fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded, color: Color(0xFFA3E635)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Downloading $title...'),
                  backgroundColor: const Color(0xFF1E1E2C),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

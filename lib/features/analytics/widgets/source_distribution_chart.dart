import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

class SourceDistributionChart extends StatefulWidget {
  const SourceDistributionChart({super.key});

  @override
  State<SourceDistributionChart> createState() => _SourceDistributionChartState();
}

class _SourceDistributionChartState extends State<SourceDistributionChart> {
  int touchedIndex = -1;

  final Map<String, Color> sourceColors = {
    'Traffic': const Color(0xFF3B82F6),
    'Horn': const Color(0xFFEF4444),
    'Construction': const Color(0xFFF97316),
    'Factory': const Color(0xFF8B5CF6),
    'Crowd': const Color(0xFF06B6D4),
    'DJ': const Color(0xFFEC4899),
  };

  final Map<String, double> sourceValues = {
    'Traffic': 40,
    'Horn': 25,
    'Construction': 15,
    'Factory': 10,
    'Crowd': 5,
    'DJ': 5,
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: _showingSections(),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '100%',
                    style: GoogleFonts.jetBrainsMono(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Total',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF9CA3AF),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: sourceValues.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final key = sourceValues.keys.elementAt(index);
              final value = sourceValues[key]!;
              final color = sourceColors[key]!;
              return Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      key,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    '${value.toInt()}%',
                    style: GoogleFonts.jetBrainsMono(
                      color: const Color(0xFF9CA3AF),
                      fontSize: 12,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _showingSections() {
    return List.generate(sourceValues.length, (i) {
      final isTouched = i == touchedIndex;
      final radius = isTouched ? 30.0 : 20.0;
      final key = sourceValues.keys.elementAt(i);
      final value = sourceValues[key]!;
      final color = sourceColors[key]!;

      return PieChartSectionData(
        color: color,
        value: value,
        title: '',
        radius: radius,
      );
    });
  }
}

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

class PeakHoursChart extends StatelessWidget {
  const PeakHoursChart({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock values for 24 hours
    final values = [
      40.0, 38.0, 35.0, 35.0, 40.0, 50.0, 65.0, 80.0, 
      85.0, 75.0, 70.0, 72.0, 75.0, 78.0, 80.0, 82.0,
      88.0, 95.0, 90.0, 85.0, 75.0, 65.0, 55.0, 45.0,
    ];

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        minY: 0,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value % 6 != 0) return const SizedBox.shrink();
                String text;
                if (value == 0) text = '12a';
                else if (value == 6) text = '6a';
                else if (value == 12) text = '12p';
                else if (value == 18) text = '6p';
                else text = '';
                
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    text,
                    style: GoogleFonts.jetBrainsMono(
                      color: const Color(0xFF9CA3AF),
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(
          24,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: values[index],
                width: 6,
                gradient: LinearGradient(
                  colors: [
                    values[index] > 85 ? Colors.redAccent : const Color(0xFFA3E635),
                    values[index] > 85 ? Colors.red : Colors.teal,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                borderRadius: BorderRadius.circular(4),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: 100,
                  color: const Color(0xFF2A2A3C),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

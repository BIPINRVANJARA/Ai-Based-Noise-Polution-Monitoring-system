import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

class NoiseChart extends StatelessWidget {
  const NoiseChart({super.key});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineTouchData: const LineTouchData(enabled: false), // Disable touch capture so page scrolling is 100% smooth
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 30,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: const Color(0xFF2A2A3C),
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 26,
              interval: 4,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    '${value.toInt()}h',
                    style: GoogleFonts.jetBrainsMono(
                      color: const Color(0xFF9CA3AF),
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 30,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: GoogleFonts.jetBrainsMono(
                    color: const Color(0xFF9CA3AF),
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 24,
        minY: 30,
        maxY: 120,
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: 85,
              color: Colors.redAccent.withOpacity(0.6),
              strokeWidth: 1.5,
              dashArray: [5, 5],
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topRight,
                padding: const EdgeInsets.only(right: 5, bottom: 4),
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  color: Colors.redAccent,
                ),
                labelResolver: (line) => 'Threshold',
              ),
            ),
          ],
        ),
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 45), FlSpot(4, 55), FlSpot(8, 85),
              FlSpot(12, 70), FlSpot(16, 95), FlSpot(20, 65), FlSpot(24, 40),
            ],
            isCurved: true,
            gradient: const LinearGradient(
              colors: [Color(0xFFA3E635), Colors.tealAccent],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFA3E635).withOpacity(0.3),
                  Colors.tealAccent.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

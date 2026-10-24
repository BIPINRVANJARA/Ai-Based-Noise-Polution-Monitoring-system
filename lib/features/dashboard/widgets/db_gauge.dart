import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class DbGauge extends StatefulWidget {
  final double currentDb;
  final double maxDb;

  const DbGauge({
    Key? key,
    required this.currentDb,
    this.maxDb = 120.0,
  }) : super(key: key);

  @override
  State<DbGauge> createState() => _DbGaugeState();
}

class _DbGaugeState extends State<DbGauge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _oldDb = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: widget.currentDb, end: widget.currentDb).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _oldDb = widget.currentDb;
  }

  @override
  void didUpdateWidget(covariant DbGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.currentDb - widget.currentDb).abs() > 0.01) {
      _oldDb = oldWidget.currentDb;
      _animation = Tween<double>(begin: _oldDb, end: widget.currentDb).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getCategory(double db) {
    if (db < 55) return 'Quiet';
    if (db < 75) return 'Moderate';
    if (db < 85) return 'Loud';
    return 'Dangerous';
  }

  Color _getColor(double db) {
    if (db < 55) return const Color(0xFFA3E635);
    if (db < 75) return Colors.amber;
    if (db < 85) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final current = _animation.value;
        final color = _getColor(current);
        
        return Container(
          width: 280,
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(280, 280),
                painter: _GaugePainter(
                  value: current,
                  maxValue: widget.maxDb,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    current.toStringAsFixed(1),
                    style: GoogleFonts.inter(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    'dB',
                    style: GoogleFonts.jetBrainsMono(
                      color: const Color(0xFFA3E635),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getCategory(current),
                    style: GoogleFonts.inter(
                      color: const Color(0xFF9CA3AF),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double value;
  final double maxValue;

  _GaugePainter({required this.value, required this.maxValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - 20;
    
    final startAngle = 135 * (math.pi / 180);
    final sweepAngle = 270 * (math.pi / 180);

    // Background arc
    final bgPaint = Paint()
      ..color = const Color(0xFF1E1E2C)
      ..strokeWidth = 15
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
      
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    // Value arc
    final valueAngle = (value / maxValue).clamp(0.0, 1.0) * sweepAngle;
    
    final gradient = SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + sweepAngle,
      colors: const [
        Color(0xFFA3E635), // Green
        Colors.amber,
        Colors.orange,
        Colors.red,
      ],
      stops: const [0.0, 0.45, 0.62, 0.7],
    );

    final valuePaint = Paint()
      ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = 15
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (valueAngle > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        valueAngle,
        false,
        valuePaint,
      );
    }

    // Tick marks
    final tickPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i <= maxValue; i += 10) {
      final angle = startAngle + (i / maxValue) * sweepAngle;
      final innerRadius = radius - 25;
      final outerRadius = radius - 15;
      
      final p1 = Offset(
        center.dx + innerRadius * math.cos(angle),
        center.dy + innerRadius * math.sin(angle),
      );
      final p2 = Offset(
        center.dx + outerRadius * math.cos(angle),
        center.dy + outerRadius * math.sin(angle),
      );
      
      canvas.drawLine(p1, p2, tickPaint);
      
      // Labels
      if (i == 30 || i == 50 || i == 70 || i == 90 || i == 110) {
        final textSpan = TextSpan(
          text: i.toString(),
          style: GoogleFonts.jetBrainsMono(
            color: Colors.white.withOpacity(0.7),
            fontSize: 10,
          ),
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        
        final labelRadius = radius - 40;
        final labelOffset = Offset(
          center.dx + labelRadius * math.cos(angle) - textPainter.width / 2,
          center.dy + labelRadius * math.sin(angle) - textPainter.height / 2,
        );
        
        textPainter.paint(canvas, labelOffset);
      }
    }

    // Glow at current value endpoint
    if (valueAngle > 0) {
      final endAngle = startAngle + valueAngle;
      final endPoint = Offset(
        center.dx + radius * math.cos(endAngle),
        center.dy + radius * math.sin(endAngle),
      );
      
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [Colors.white.withOpacity(0.8), Colors.transparent],
        ).createShader(Rect.fromCircle(center: endPoint, radius: 10));
        
      canvas.drawCircle(endPoint, 10, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.value != value;
  }
}

import 'package:flutter/material.dart';

class GradientBackgroundWidget extends StatelessWidget {
  final Widget child;

  const GradientBackgroundWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1B365D).withAlpha(230),
                  const Color(0xFF0F2A47),
                  const Color(0xFF121212),
                ]
              : [
                  const Color(0xFFFFFFFF),
                  const Color(0xFFF8FBFF),
                  const Color(0xFFE8F4F8),
                ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: CustomPaint(
        painter: GeometricPatternPainter(isDark: isDark),
        child: child,
      ),
    );
  }
}

class GeometricPatternPainter extends CustomPainter {
  final bool isDark;

  GeometricPatternPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark
          ? const Color(0xFF4A90A4).withAlpha(26)
          : const Color(0xFF1B365D).withAlpha(13))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw subtle geometric patterns
    _drawFinancialPatterns(canvas, size, paint);
  }

  void _drawFinancialPatterns(Canvas canvas, Size size, Paint paint) {
    // Draw trending lines pattern
    final path = Path();

    // Top-left trend lines
    for (int i = 0; i < 5; i++) {
      final startX = size.width * 0.1 + (i * 40.0);
      final startY = size.height * 0.15 + (i * 20.0);

      path.moveTo(startX, startY);
      path.lineTo(startX + 60, startY - 30);
      path.lineTo(startX + 120, startY - 10);
      path.lineTo(startX + 180, startY - 40);
    }

    // Bottom-right geometric shapes
    for (int i = 0; i < 4; i++) {
      final centerX = size.width * 0.7 + (i * 30.0);
      final centerY = size.height * 0.7 + (i * 25.0);

      final rect = Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: 20.0,
        height: 20.0,
      );

      path.addRect(rect);

      // Add circles
      path.addOval(Rect.fromCenter(
        center: Offset(centerX + 40, centerY + 40),
        width: 15.0,
        height: 15.0,
      ));
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

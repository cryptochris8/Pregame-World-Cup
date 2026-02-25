import 'package:flutter/material.dart';

import '../../../../config/app_theme.dart';

/// A programmatic gold trophy cup character avatar for Copa, the chatbot.
///
/// Uses [CustomPainter] to draw a stylized trophy with eyes and a smile.
/// Can be swapped for an SVG/PNG asset later.
class CopaAvatar extends StatelessWidget {
  /// Logical size of the avatar (width and height).
  final double size;

  const CopaAvatar({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CopaTrophyPainter(),
      ),
    );
  }
}

class _CopaTrophyPainter extends CustomPainter {
  // Trophy gold colors
  static const Color _gold = AppTheme.accentGold; // #FBBF24
  static const Color _darkGold = Color(0xFFD4991A);
  static const Color _lightGold = Color(0xFFFDE68A);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final goldPaint = Paint()
      ..color = _gold
      ..style = PaintingStyle.fill;
    final darkPaint = Paint()
      ..color = _darkGold
      ..style = PaintingStyle.fill;
    final lightPaint = Paint()
      ..color = _lightGold
      ..style = PaintingStyle.fill;
    final eyePaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;
    final smilePaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.045
      ..strokeCap = StrokeCap.round;

    // Cup body (rounded U-shape)
    final cupPath = Path()
      ..moveTo(w * 0.2, h * 0.15)
      ..lineTo(w * 0.15, h * 0.55)
      ..quadraticBezierTo(w * 0.15, h * 0.7, w * 0.35, h * 0.7)
      ..lineTo(w * 0.65, h * 0.7)
      ..quadraticBezierTo(w * 0.85, h * 0.7, w * 0.85, h * 0.55)
      ..lineTo(w * 0.8, h * 0.15)
      ..close();
    canvas.drawPath(cupPath, goldPaint);

    // Rim highlight at top
    final rimRect = RRect.fromLTRBR(
      w * 0.17,
      h * 0.12,
      w * 0.83,
      h * 0.22,
      Radius.circular(w * 0.04),
    );
    canvas.drawRRect(rimRect, darkPaint);

    // Inner rim highlight
    final innerRim = RRect.fromLTRBR(
      w * 0.22,
      h * 0.14,
      w * 0.78,
      h * 0.20,
      Radius.circular(w * 0.03),
    );
    canvas.drawRRect(innerRim, lightPaint);

    // Left handle
    final leftHandle = Path()
      ..moveTo(w * 0.18, h * 0.25)
      ..quadraticBezierTo(w * 0.02, h * 0.25, w * 0.04, h * 0.42)
      ..quadraticBezierTo(w * 0.06, h * 0.55, w * 0.18, h * 0.52);
    canvas.drawPath(
      leftHandle,
      darkPaint
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.055,
    );
    darkPaint.style = PaintingStyle.fill;

    // Right handle
    final rightHandle = Path()
      ..moveTo(w * 0.82, h * 0.25)
      ..quadraticBezierTo(w * 0.98, h * 0.25, w * 0.96, h * 0.42)
      ..quadraticBezierTo(w * 0.94, h * 0.55, w * 0.82, h * 0.52);
    canvas.drawPath(
      rightHandle,
      darkPaint
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.055,
    );
    darkPaint.style = PaintingStyle.fill;

    // Stem
    final stemRect = Rect.fromLTWH(w * 0.42, h * 0.70, w * 0.16, h * 0.12);
    canvas.drawRect(stemRect, darkPaint);

    // Base pedestal
    final baseRect = RRect.fromLTRBR(
      w * 0.28,
      h * 0.80,
      w * 0.72,
      h * 0.90,
      Radius.circular(w * 0.03),
    );
    canvas.drawRRect(baseRect, darkPaint);

    // Base highlight
    final baseHighlight = RRect.fromLTRBR(
      w * 0.33,
      h * 0.81,
      w * 0.67,
      h * 0.86,
      Radius.circular(w * 0.02),
    );
    canvas.drawRRect(baseHighlight, goldPaint);

    // Left eye
    canvas.drawCircle(Offset(w * 0.38, h * 0.38), w * 0.055, eyePaint);

    // Right eye
    canvas.drawCircle(Offset(w * 0.62, h * 0.38), w * 0.055, eyePaint);

    // Smile arc
    final smileRect = Rect.fromCenter(
      center: Offset(w * 0.50, h * 0.50),
      width: w * 0.22,
      height: w * 0.16,
    );
    canvas.drawArc(smileRect, 0.2, 2.7, false, smilePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

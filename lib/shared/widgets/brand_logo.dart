import 'dart:math' as math;

import 'package:flutter/material.dart';

/// MealBridge wordmark: a small arch-bridge glyph followed by the two-tone
/// "meal" (dark green) + "bridge" (light green) text. Drawn with widgets
/// (CustomPaint + RichText) rather than an image asset so it stays sharp at
/// any [size] and can be reused for the app bar, onboarding, splash, etc.
class BrandLogo extends StatelessWidget {
  final double size;

  static const Color darkGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFF81C784);

  const BrandLogo({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size * 1.5,
          height: size * 0.95,
          child: CustomPaint(painter: _BridgePainter()),
        ),
        SizedBox(width: size * 0.25),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: size,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              height: 1,
            ),
            children: const [
              TextSpan(text: 'meal', style: TextStyle(color: darkGreen)),
              TextSpan(text: 'bridge', style: TextStyle(color: lightGreen)),
            ],
          ),
        ),
      ],
    );
  }
}

class _BridgePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const strokeColor = BrandLogo.darkGreen;
    final deckY = size.height * 0.7;

    final deckPaint = Paint()
      ..color = strokeColor
      ..strokeWidth = size.height * 0.13
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.02, deckY),
      Offset(size.width * 0.98, deckY),
      deckPaint,
    );

    final archPaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.height * 0.11
      ..strokeCap = StrokeCap.round;
    final archRect = Rect.fromCenter(
      center: Offset(size.width * 0.5, deckY),
      width: size.width * 0.86,
      height: size.height * 0.95,
    );
    canvas.drawArc(archRect, math.pi, math.pi, false, archPaint);

    final pierPaint = Paint()
      ..color = strokeColor
      ..strokeWidth = size.height * 0.1
      ..strokeCap = StrokeCap.round;
    for (final fx in [0.27, 0.73]) {
      canvas.drawLine(
        Offset(size.width * fx, deckY),
        Offset(size.width * fx, size.height * 0.98),
        pierPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BridgePainter oldDelegate) => false;
}

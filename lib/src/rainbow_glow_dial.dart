import 'package:flutter/material.dart';

/// A static glowing tube for the first rainbow glow dial checkpoint.
class RainbowGlowDial extends StatelessWidget {
  /// Creates a static glowing tube.
  const RainbowGlowDial({super.key});

  static const _width = 300.0;
  static const _tubeWidth = 75.0;

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: _width,
      height: _tubeWidth,
      child: CustomPaint(
        painter: _RainbowGlowTubePainter(),
      ),
    );
  }
}

class _RainbowGlowTubePainter extends CustomPainter {
  const _RainbowGlowTubePainter();

  static const double _tubeWidth = RainbowGlowDial._tubeWidth;
  static const _innerGlowColor = Color(0xFF3E7FE9);
  static const _rimColor = Color(0xFFAAC6FE);

  @override
  void paint(Canvas canvas, Size size) {
    final tubeRect = Offset.zero & size;
    const radius = Radius.circular(_tubeWidth / 2);
    final tube = RRect.fromRectAndRadius(tubeRect, radius);
    final tubePath = Path()..addRRect(tube);

    _paintInnerGlow(canvas, tubePath);
    _paintRim(canvas, tube);
  }

  void _paintInnerGlow(Canvas canvas, Path tubePath) {
    const strokeWidth = _tubeWidth * 0.33;
    final innerGlowPaint = Paint()
      ..color = _innerGlowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, strokeWidth / 2);

    canvas
      ..save()
      ..clipPath(tubePath)
      ..drawPath(tubePath, innerGlowPaint)
      ..restore();
  }

  void _paintRim(Canvas canvas, RRect tubeRRect) {
    final rimPaint = Paint()
      ..color = _rimColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawRRect(tubeRRect, rimPaint);
  }

  @override
  bool shouldRepaint(_RainbowGlowTubePainter oldDelegate) => false;
}

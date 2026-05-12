import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A static glowing arc tube for the rainbow glow dial.
class RainbowGlowDial extends StatelessWidget {
  /// Creates a static glowing arc tube.
  const RainbowGlowDial({
    super.key,
    this.size,
    this.padding = const EdgeInsets.all(24),
  });

  static const _defaultSize = 300.0;
  static const _tubeWidth = 35.0;

  /// The preferred square side length for the dial.
  ///
  /// Parent constraints can still shrink or expand the rendered size.
  final double? size;

  /// Empty space between the widget bounds and the painted arc.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = _resolveSide(constraints);

        return SizedBox.square(
          dimension: side,
          child: Padding(
            padding: padding,
            child: const CustomPaint(
              painter: _RainbowGlowTubePainter(),
            ),
          ),
        );
      },
    );
  }

  double _resolveSide(BoxConstraints constraints) {
    final preferredSide = size ?? _defaultSize;
    final maxSide = math.min(constraints.maxWidth, constraints.maxHeight);
    final minSide = math.max(constraints.minWidth, constraints.minHeight);
    final constrainedSide = maxSide.isFinite
        ? math.min(preferredSide, maxSide)
        : preferredSide;
    return math.max(minSide, constrainedSide);
  }
}

class _RainbowGlowTubePainter extends CustomPainter {
  const _RainbowGlowTubePainter();

  static const double _tubeWidth = RainbowGlowDial._tubeWidth;
  static const double _startAngle = 0.75 * math.pi;
  static const double _sweepAngle = 1.5 * math.pi;
  static const double _rimStrokeWidth = 1;
  static const _innerGlowColor = Color(0xFF3E7FE9);
  static const _rimColor = Color(0xFFAAC6FE);

  @override
  void paint(Canvas canvas, Size size) {
    final tubePath = _buildTubePath(size);

    _paintInnerGlow(canvas, tubePath);
    _paintRim(canvas, tubePath);
  }

  Path _buildTubePath(Size size) {
    const capRadius = _tubeWidth / 2;
    const endAngle = _startAngle + _sweepAngle;
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = (size.shortestSide - _rimStrokeWidth) / 2;
    final innerRadius = outerRadius - _tubeWidth;
    final centerlineRadius = innerRadius + capRadius;
    final outerRect = Rect.fromCircle(center: center, radius: outerRadius);
    final innerRect = Rect.fromCircle(center: center, radius: innerRadius);
    final endCapRect = Rect.fromCircle(
      center: _pointOnCircle(center, centerlineRadius, endAngle),
      radius: capRadius,
    );
    final startCapRect = Rect.fromCircle(
      center: _pointOnCircle(center, centerlineRadius, _startAngle),
      radius: capRadius,
    );
    final outerStart = _pointOnCircle(center, outerRadius, _startAngle);

    return Path()
      ..moveTo(outerStart.dx, outerStart.dy)
      ..arcTo(outerRect, _startAngle, _sweepAngle, false)
      ..arcTo(endCapRect, endAngle, math.pi, false)
      ..arcTo(innerRect, endAngle, -_sweepAngle, false)
      ..arcTo(startCapRect, _startAngle + math.pi, math.pi, false)
      ..close();
  }

  Offset _pointOnCircle(Offset center, double radius, double angle) {
    return Offset(
      center.dx + math.cos(angle) * radius,
      center.dy + math.sin(angle) * radius,
    );
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

  void _paintRim(Canvas canvas, Path tubePath) {
    final rimPaint = Paint()
      ..color = _rimColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _rimStrokeWidth;

    canvas.drawPath(tubePath, rimPaint);
  }

  @override
  bool shouldRepaint(_RainbowGlowTubePainter oldDelegate) => false;
}

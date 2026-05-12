import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A static glowing arc tube for the rainbow glow dial.
class RainbowGlowDial extends StatelessWidget {
  /// Creates a static glowing arc tube.
  const RainbowGlowDial({
    super.key,
    this.size,
    this.padding = const EdgeInsets.all(24),
    this.initialValue = 0,
    this.min = 0,
    this.max = 1,
    this.label,
    this.unit,
  }) : assert(min <= max, 'min must be less than or equal to max');

  static const _defaultSize = 300.0;
  static const _tubeWidth = 35.0;

  /// The preferred square side length for the dial.
  ///
  /// Parent constraints can still shrink or expand the rendered size.
  final double? size;

  /// Empty space between the widget bounds and the painted arc.
  final EdgeInsetsGeometry padding;

  /// The initial value displayed as progress along the arc.
  final double initialValue;

  /// The minimum value for the dial range.
  final double min;

  /// The maximum value for the dial range.
  final double max;

  /// Optional label displayed below the value.
  final String? label;

  /// Optional unit appended directly after the value.
  final String? unit;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = _resolveSide(constraints);

        return SizedBox.square(
          dimension: side,
          child: Padding(
            padding: padding,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _RainbowGlowTubePainter(progress: _progress),
                  ),
                ),
                _DialContent(
                  value: _formattedValue,
                  label: label,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  double get _clampedValue => initialValue.clamp(min, max);

  double get _progress {
    if (min == max) {
      return 0;
    }

    final progress = (_clampedValue - min) / (max - min);
    return progress.clamp(0.0, 1.0);
  }

  String get _formattedValue {
    final value = _formatNumber(_clampedValue);
    return unit == null ? value : '$value$unit';
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.round().toString();
    }

    return value.toString().replaceFirst(RegExp(r'\.?0+$'), '');
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

class _DialContent extends StatelessWidget {
  const _DialContent({
    required this.value,
    required this.label,
  });

  final String value;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final label = this.label;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: textTheme.displayMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (label != null) ...[
            const SizedBox(height: 12),
            _LabelPill(label: label),
          ],
        ],
      ),
    );
  }
}

class _LabelPill extends StatelessWidget {
  const _LabelPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      color: Colors.white,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xCCFFFFFF),
            Color(0x33FFFFFF),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(23),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black,
                Color(0xFF2B2B2B),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            child: Text(label, style: labelStyle),
          ),
        ),
      ),
    );
  }
}

class _RainbowGlowTubePainter extends CustomPainter {
  const _RainbowGlowTubePainter({required this.progress});

  static const double _tubeWidth = RainbowGlowDial._tubeWidth;
  static const double _startAngle = 0.75 * math.pi;
  static const double _sweepAngle = 1.5 * math.pi;
  static const double _rimStrokeWidth = 1;
  static const _innerGlowColor = Color(0xFF3E7FE9);
  static const _rimColor = Color(0xFFAAC6FE);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) {
      return;
    }

    final activeSweep = _sweepAngle * progress;
    final tubePath = _buildTubePath(size, activeSweep);

    _paintInnerGlow(canvas, tubePath);
    _paintRim(canvas, tubePath);
  }

  Path _buildTubePath(Size size, double activeSweep) {
    const capRadius = _tubeWidth / 2;
    final endAngle = _startAngle + activeSweep;
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
      ..arcTo(outerRect, _startAngle, activeSweep, false)
      ..arcTo(endCapRect, endAngle, math.pi, false)
      ..arcTo(innerRect, endAngle, -activeSweep, false)
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
  bool shouldRepaint(_RainbowGlowTubePainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

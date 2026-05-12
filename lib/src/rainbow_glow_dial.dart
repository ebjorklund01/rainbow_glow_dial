import 'dart:math' as math;

import 'package:flutter/material.dart';

const double _dialStartAngle = 0.75 * math.pi;
const double _dialSweepAngle = 1.5 * math.pi;
const double _twoPi = math.pi * 2;

/// A static glowing arc tube for the rainbow glow dial.
class RainbowGlowDial extends StatefulWidget {
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
    this.step,
    this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
  }) : assert(min <= max, 'min must be less than or equal to max'),
       assert(step == null || step > 0, 'step must be greater than zero');

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

  /// Optional display and callback increment.
  ///
  /// The internal progress remains smooth and is not snapped.
  final double? step;

  /// Called when the dial value changes.
  final ValueChanged<double>? onChanged;

  /// Called when a tap or drag interaction starts.
  final ValueChanged<double>? onChangeStart;

  /// Called when a tap or drag interaction ends or is canceled.
  final ValueChanged<double>? onChangeEnd;

  @override
  State<RainbowGlowDial> createState() => _RainbowGlowDialState();
}

class _RainbowGlowDialState extends State<RainbowGlowDial> {
  late double _progress;
  var _isInteracting = false;

  @override
  void initState() {
    super.initState();
    _progress = _valueToProgress(widget.initialValue);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = widget._resolveSide(constraints);

        return SizedBox.square(
          dimension: side,
          child: Padding(
            padding: widget.padding,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final paintSize = constraints.biggest;

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (details) {
                    _handleInteractionStart(details.localPosition, paintSize);
                  },
                  onTapUp: (_) => _handleInteractionEnd(),
                  onTapCancel: _handleInteractionEnd,
                  onPanStart: (details) {
                    _handleInteractionStart(details.localPosition, paintSize);
                  },
                  onPanUpdate: (details) {
                    _handleInteractionUpdate(details.localPosition, paintSize);
                  },
                  onPanEnd: (_) => _handleInteractionEnd(),
                  onPanCancel: _handleInteractionEnd,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _RainbowGlowTubePainter(
                            progress: _progress,
                          ),
                        ),
                      ),
                      _DialContent(
                        value: _formattedValue,
                        label: widget.label,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  double get _displayValue => _steppedValue(_progressToValue(_progress));

  String get _formattedValue {
    final formatted = _formatNumber(_displayValue);
    return widget.unit == null ? formatted : '$formatted${widget.unit}';
  }

  double get _range => widget.max - widget.min;

  double _clampValue(double value) => value.clamp(widget.min, widget.max);

  double _valueToProgress(double value) {
    if (_range == 0) return 0;
    return ((value - widget.min) / _range).clamp(0.0, 1.0);
  }

  double _progressToValue(double progress) => widget.min + _range * progress;

  double _steppedValue(double value) {
    final step = widget.step;
    if (step == null) return _clampValue(value);

    final stepCount = ((value - widget.min) / step).round();
    final stepped = widget.min + stepCount * step;
    final precision = math.max(
      _decimalPlaces(step),
      _decimalPlaces(widget.min),
    );
    return _clampValue(_roundToPrecision(stepped, precision));
  }

  String _formatNumber(double value) =>
      value.toString().replaceFirst(RegExp(r'\.?0+$'), '');

  static double _roundToPrecision(double value, int decimals) {
    if (decimals <= 0) return value.roundToDouble();
    final factor = math.pow(10, decimals);
    return (value * factor).roundToDouble() / factor;
  }

  static int _decimalPlaces(double value) {
    if (!value.isFinite || value == value.roundToDouble()) return 0;
    final string = value.toString();
    final eIndex = string.indexOf('e');
    final mantissa = eIndex == -1 ? string : string.substring(0, eIndex);
    final exponent = eIndex == -1 ? 0 : int.parse(string.substring(eIndex + 1));
    final dotIndex = mantissa.indexOf('.');
    final mantissaDecimals = dotIndex == -1
        ? 0
        : mantissa.length - dotIndex - 1;
    return math.max(0, mantissaDecimals - exponent);
  }

  void _handleInteractionStart(Offset localPosition, Size size) {
    if (_isInteracting) {
      _handleInteractionUpdate(localPosition, size);
      return;
    }

    _isInteracting = true;
    _setProgressFromPosition(localPosition, size);
    widget.onChangeStart?.call(_displayValue);
    widget.onChanged?.call(_displayValue);
  }

  void _handleInteractionUpdate(Offset localPosition, Size size) {
    _setProgressFromPosition(localPosition, size);
    widget.onChanged?.call(_displayValue);
  }

  void _handleInteractionEnd() {
    if (!_isInteracting) {
      return;
    }

    _isInteracting = false;
    widget.onChangeEnd?.call(_displayValue);
  }

  void _setProgressFromPosition(Offset localPosition, Size size) {
    setState(() {
      _progress = _progressForPosition(localPosition, size);
    });
  }

  double _progressForPosition(Offset localPosition, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final pointerOffset = localPosition - center;
    final angle = _normalizeAngle(
      math.atan2(pointerOffset.dy, pointerOffset.dx),
    );
    final delta = _normalizeAngle(angle - _dialStartAngle);

    if (delta <= _dialSweepAngle) {
      return (delta / _dialSweepAngle).clamp(0.0, 1.0);
    }

    final distanceToStart = _twoPi - delta;
    final distanceToEnd = delta - _dialSweepAngle;
    return distanceToStart <= distanceToEnd ? 0 : 1;
  }

  double _normalizeAngle(double angle) {
    final normalized = angle % _twoPi;
    return normalized < 0 ? normalized + _twoPi : normalized;
  }
}

extension on RainbowGlowDial {
  double _resolveSide(BoxConstraints constraints) {
    final preferredSide = size ?? RainbowGlowDial._defaultSize;
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
  static const double _rimStrokeWidth = 1;
  static const _innerGlowColor = Color(0xFF3E7FE9);
  static const _rimColor = Color(0xFFAAC6FE);
  static const _thumbPalette = <Color>[
    Color(0xFF3E7FE9),
    Color(0xFF2ECC71),
    Color(0xFFFFD84D),
    Color(0xFFFF8A2A),
    Color(0xFFE92929),
  ];

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final activeSweep = _dialSweepAngle * clampedProgress;
    final thumbColor = _colorForProgress(clampedProgress);
    final thumbCenter = _thumbCenter(size, activeSweep);

    _paintOuterThumbGlow(canvas, thumbCenter, thumbColor);

    if (activeSweep > 0) {
      final tubePath = _buildTubePath(size, activeSweep);

      _paintInnerGlow(canvas, tubePath);
      _paintClippedThumbGlow(canvas, tubePath, thumbCenter, thumbColor);
      _paintRim(canvas, tubePath);
    }

    _paintThumb(canvas, thumbCenter, thumbColor);
  }

  Path _buildTubePath(Size size, double activeSweep) {
    const capRadius = _tubeWidth / 2;
    final endAngle = _dialStartAngle + activeSweep;
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
      center: _pointOnCircle(center, centerlineRadius, _dialStartAngle),
      radius: capRadius,
    );
    final outerStart = _pointOnCircle(center, outerRadius, _dialStartAngle);

    return Path()
      ..moveTo(outerStart.dx, outerStart.dy)
      ..arcTo(outerRect, _dialStartAngle, activeSweep, false)
      ..arcTo(endCapRect, endAngle, math.pi, false)
      ..arcTo(innerRect, endAngle, -activeSweep, false)
      ..arcTo(startCapRect, _dialStartAngle + math.pi, math.pi, false)
      ..close();
  }

  Offset _pointOnCircle(Offset center, double radius, double angle) {
    return Offset(
      center.dx + math.cos(angle) * radius,
      center.dy + math.sin(angle) * radius,
    );
  }

  Offset _thumbCenter(Size size, double activeSweep) {
    const capRadius = _tubeWidth / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = (size.shortestSide - _rimStrokeWidth) / 2;
    final innerRadius = outerRadius - _tubeWidth;
    final centerlineRadius = innerRadius + capRadius;

    return _pointOnCircle(
      center,
      centerlineRadius,
      _dialStartAngle + activeSweep,
    );
  }

  Color _colorForProgress(double progress) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final scaledProgress = clampedProgress * (_thumbPalette.length - 1);
    final lowerIndex = scaledProgress.floor();
    final upperIndex = math.min(lowerIndex + 1, _thumbPalette.length - 1);
    final localProgress = scaledProgress - lowerIndex;
    final lowerColor = _thumbPalette[lowerIndex];
    final upperColor = _thumbPalette[upperIndex];

    return Color.lerp(lowerColor, upperColor, localProgress) ?? upperColor;
  }

  void _paintOuterThumbGlow(
    Canvas canvas,
    Offset thumbCenter,
    Color thumbColor,
  ) {
    final outerThumbGlowPaint = Paint()
      ..color = thumbColor.withValues(alpha: 0.28)
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        _tubeWidth * 0.45,
      );

    canvas.drawCircle(thumbCenter, _tubeWidth * 1.5, outerThumbGlowPaint);
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

  void _paintClippedThumbGlow(
    Canvas canvas,
    Path tubePath,
    Offset thumbCenter,
    Color thumbColor,
  ) {
    final clippedThumbGlowPaint = Paint()
      ..color = thumbColor.withValues(alpha: 0.75)
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        _tubeWidth * 0.75,
      );

    canvas
      ..save()
      ..clipPath(tubePath)
      ..drawCircle(thumbCenter, _tubeWidth * 2, clippedThumbGlowPaint)
      ..restore();
  }

  void _paintRim(Canvas canvas, Path tubePath) {
    final rimPaint = Paint()
      ..color = _rimColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _rimStrokeWidth;

    canvas.drawPath(tubePath, rimPaint);
  }

  void _paintThumb(Canvas canvas, Offset thumbCenter, Color thumbColor) {
    final outerThumbPaint = Paint()..color = Colors.white;
    final innerThumbPaint = Paint()..color = thumbColor;

    canvas
      ..drawCircle(thumbCenter, _tubeWidth * 0.72, outerThumbPaint)
      ..drawCircle(thumbCenter, _tubeWidth * 0.5, innerThumbPaint);
  }

  @override
  bool shouldRepaint(_RainbowGlowTubePainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

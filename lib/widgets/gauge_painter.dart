// --- Custom Gauge Painter ---
import 'package:flutter/material.dart';
import 'dart:math';

class GaugePainter extends CustomPainter {
  final double value;
  final double minValue;
  final double maxValue;
  final int gaugeIndex;
  final double startAngle; // In degrees
  final double sweepAngle; // In degrees

  // Style constants
  final Color faceColor = Colors.white.withAlpha((0.9 * 255).round());
  final Color tickColor = Colors.black;
  final Color labelColor = Colors.black;
  final Color needleColor = Colors.black;
  final Color knobColor = Colors.grey[600]!;
  final Color unitColor = Colors.black.withAlpha((0.8 * 255).round());
  final Color zoneLabelColor = Colors.white;
  final Color zoneBgColor = Colors.black.withAlpha((0.6 * 255).round());

  GaugePainter({
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.gaugeIndex,
    required this.startAngle,
    required this.sweepAngle,
  });

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180.0;
  }

  double _valueToAngleRad(double val, double minVal, double maxVal,
      double startDeg, double sweepDeg) {
    final double valueRatio =
        ((val - minVal) / (maxVal - minVal)).clamp(0.0, 1.0);
    final double currentAngleDeg = startDeg + valueRatio * sweepDeg;
    return _degreesToRadians(currentAngleDeg);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final Offset center = Offset(centerX, centerY);
    final double radius = max(0.0, min(centerX, centerY) * 0.95);

    if (radius <= 0) return;

    // --- 1. Draw Gauge Face ---
    final facePaint = Paint()
      ..color = faceColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, facePaint);

    // --- 2. Draw Ticks and Labels ---
    final majorTickLength = radius * 0.12;
    final minorTickLength = radius * 0.06;
    final labelRadius = radius * 0.75;

    final majorTickPaint = Paint()
      ..color = tickColor
      ..strokeWidth = max(1.0, radius * 0.01)
      ..style = PaintingStyle.stroke;

    final minorTickPaint = Paint()
      ..color = tickColor
      ..strokeWidth = max(0.5, radius * 0.005)
      ..style = PaintingStyle.stroke;

    final labelStyle = TextStyle(
      color: labelColor,
      fontSize: max(6.0, radius * 0.09),
      fontWeight: FontWeight.bold,
    );

    const double majorInterval = 200;
    const double minorInterval = 50;
    final double estimatedMaxLabelWidth = radius * 0.3;

    for (double currentVal = minValue;
        currentVal <= maxValue;
        currentVal += minorInterval) {
      final angleRad = _valueToAngleRad(
          currentVal, minValue, maxValue, startAngle, sweepAngle);
      final isMajorTick = (currentVal % majorInterval == 0);

      final tickLength = isMajorTick ? majorTickLength : minorTickLength;
      final tickPaint = isMajorTick ? majorTickPaint : minorTickPaint;
      final double effectiveRadius = radius;
      final double innerTickRadius = max(0.0, effectiveRadius - tickLength);

      final innerTickPoint = Offset(
        centerX + innerTickRadius * cos(angleRad),
        centerY + innerTickRadius * sin(angleRad),
      );
      final outerTickPoint = Offset(
        centerX + effectiveRadius * cos(angleRad),
        centerY + effectiveRadius * sin(angleRad),
      );
      canvas.drawLine(innerTickPoint, outerTickPoint, tickPaint);

      if (isMajorTick) {
        final textPainter = TextPainter(
          text:
              TextSpan(text: currentVal.toInt().toString(), style: labelStyle),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout(maxWidth: estimatedMaxLabelWidth);

        final double effectiveLabelRadius = max(0.0, labelRadius);
        final labelX = centerX +
            effectiveLabelRadius * cos(angleRad) -
            textPainter.width / 2;
        final labelY = centerY +
            effectiveLabelRadius * sin(angleRad) -
            textPainter.height / 2;

        textPainter.paint(canvas, Offset(labelX, labelY));
      }
    }

    // --- 3. Draw Needle ---
    final needlePaint = Paint()
      ..color = needleColor
      ..style = PaintingStyle.fill;

    final needleAngleRad =
        _valueToAngleRad(value, minValue, maxValue, startAngle, sweepAngle);
    final needleLength = radius * 0.75;
    final needleEndWidth = max(1.5, radius * 0.045);
    final tailLength = radius * 0.15;
    final tailWidth = max(10.5, radius * 0.045);

    final effectiveNeedleLength = max(0.0, needleLength);
    final effectiveTailLength = max(0.0, tailLength);

    final needleTipX = centerX + effectiveNeedleLength * cos(needleAngleRad);
    final needleTipY = centerY + effectiveNeedleLength * sin(needleAngleRad);

    final needlePath = Path();
    needlePath.moveTo(needleTipX, needleTipY);
    needlePath.lineTo(centerX - needleEndWidth / 2 * sin(needleAngleRad),
        centerY + needleEndWidth / 2 * cos(needleAngleRad));
    needlePath.lineTo(
        centerX -
            tailWidth / 2 * sin(needleAngleRad) -
            effectiveTailLength * cos(needleAngleRad),
        centerY +
            tailWidth / 2 * cos(needleAngleRad) -
            effectiveTailLength * sin(needleAngleRad));
    needlePath.lineTo(
        centerX +
            tailWidth / 2 * sin(needleAngleRad) -
            effectiveTailLength * cos(needleAngleRad),
        centerY -
            tailWidth / 2 * cos(needleAngleRad) -
            effectiveTailLength * sin(needleAngleRad));
    needlePath.lineTo(centerX + needleEndWidth / 2 * sin(needleAngleRad),
        centerY - needleEndWidth / 2 * cos(needleAngleRad));
    needlePath.close();

    canvas.drawPath(needlePath, needlePaint);

    // --- 4. Draw Knob ---
    final knobRadius = max(1.0, radius * 0.08);
    final knobPaint = Paint()..color = knobColor;
    final knobBorderPaint = Paint()
      ..color = Colors.black54
      ..strokeWidth = max(0.5, radius * 0.01)
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, knobRadius, knobPaint);
    canvas.drawCircle(center, knobRadius, knobBorderPaint);

    // --- 5. Draw Annotations ---
    final unitStyle = TextStyle(
      fontSize: max(6.0, radius * 0.1),
      fontWeight: FontWeight.bold,
      color: unitColor,
    );
    final unitTextPainter = TextPainter(
      text: TextSpan(text: 'kPa', style: unitStyle),
      textDirection: TextDirection.ltr,
    );
    unitTextPainter.layout();
    final unitX = centerX - unitTextPainter.width / 2;
    final unitY = centerY + radius * 0.4;
    unitTextPainter.paint(canvas, Offset(unitX, unitY));

    final zoneLabelStyle = TextStyle(
      fontSize: max(6.0, radius * 0.09),
      fontWeight: FontWeight.bold,
      color: zoneLabelColor,
    );
    final zoneTextPainter = TextPainter(
      text: TextSpan(text: 'Zone $gaugeIndex', style: zoneLabelStyle),
      textDirection: TextDirection.ltr,
    );
    zoneTextPainter.layout();

    final zoneBgPaint = Paint()..color = zoneBgColor;
    final double bgHPadding = max(1.0, radius * 0.04);
    final double bgVPadding = max(1.0, radius * 0.02);
    final Rect zoneBgRect = Rect.fromCenter(
      center: Offset(centerX, centerY - radius * 0.5),
      width: zoneTextPainter.width + 2 * bgHPadding,
      height: zoneTextPainter.height + 2 * bgVPadding,
    );
    final RRect zoneBgRRect = RRect.fromRectAndRadius(
        zoneBgRect, Radius.circular(max(1.0, radius * 0.03)));
    canvas.drawRRect(zoneBgRRect, zoneBgPaint);

    final zoneTextX = zoneBgRect.center.dx - zoneTextPainter.width / 2;
    final zoneTextY = zoneBgRect.center.dy - zoneTextPainter.height / 2;
    zoneTextPainter.paint(canvas, Offset(zoneTextX, zoneTextY));
  }

  @override
  bool shouldRepaint(covariant GaugePainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.gaugeIndex != gaugeIndex;
  }
}

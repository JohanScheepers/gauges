// --- Gauge Card Widget ---
import 'package:flutter/material.dart';
import 'dart:math';

import 'gauge_painter.dart';


class GaugeCard extends StatefulWidget {
  final double targetValue;
  final int gaugeIndex;

  const GaugeCard({
    super.key,
    required this.targetValue,
    required this.gaugeIndex,
  });

  @override
  GaugeCardState createState() => GaugeCardState();
}

class GaugeCardState extends State<GaugeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _currentValue = 0.0;

  final double minValue = 0.0;
  final double maxValue = 1800.0;
  final double startAngle = -225;
  final double sweepAngle = 270;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.targetValue;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 750),
      vsync: this, // TickerProviderStateMixin provides 'this'
    );

    _animation = Tween<double>(begin: _currentValue, end: _currentValue)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut))
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
  }

  @override
  void didUpdateWidget(GaugeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetValue != widget.targetValue) {
      _animateToValue(widget.targetValue);
    }
  }

  void _animateToValue(double newValue) {
    double beginValue = _animation.value;
    _animation = Tween<double>(begin: beginValue, end: newValue)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward(from: 0.0);
    _currentValue = newValue;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = min(constraints.maxWidth, constraints.maxHeight);

        if (size <= 0) {
          return const SizedBox.shrink();
        }

        return Center(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.grey[300]!,
                  Colors.grey[400]!,
                  Colors.grey[600]!,
                  Colors.grey[700]!,
                ],
                stops: const [0.85, 0.9, 0.95, 1.0],
                center: const Alignment(0.0, 0.0),
                radius: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.2 * 255).round()),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(1, 2),
                ),
              ],
            ),
            padding: EdgeInsets.all(size * 0.03),
            child: CustomPaint(
              size: Size(size, size),
              painter: GaugePainter(
                value: _animation.value,
                minValue: minValue,
                maxValue: maxValue,
                gaugeIndex: widget.gaugeIndex,
                startAngle: startAngle,
                sweepAngle: sweepAngle,
              ),
            ),
          ),
        );
      },
    );
  }
}

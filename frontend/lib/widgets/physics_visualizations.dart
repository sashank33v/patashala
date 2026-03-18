import 'dart:math';
import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import 'neon_ui.dart';

class ProjectileVisualizer extends StatefulWidget {
  const ProjectileVisualizer({super.key});

  @override
  State<ProjectileVisualizer> createState() => _ProjectileVisualizerState();
}

class _ProjectileVisualizerState extends State<ProjectileVisualizer>
    with SingleTickerProviderStateMixin {
  double angle = 42;
  double speed = 19;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = AdaptiveColors.text(context);
    final range = speed * speed * sin(2 * angle * pi / 180) / 9.8;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassCard(
          child: SizedBox(
            height: 280,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => CustomPaint(
                painter: _ProjectilePainter(
                  angle: angle,
                  speed: speed,
                  progress: _controller.value,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _labelRow('Angle', angle.toStringAsFixed(1), textColor),
        Slider(
          value: angle,
          min: 20,
          max: 85,
          divisions: 13,
          onChanged: (value) => setState(() => angle = value),
        ),
        _labelRow('Speed', speed.toStringAsFixed(1), textColor),
        Slider(value: speed, min: 10, max: 32, onChanged: (value) => setState(() => speed = value)),
        const SizedBox(height: 6),
        Text('Range ≈ ${range.toStringAsFixed(1)} m',
            style: TextStyle(color: NeonPalette.cyan, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _labelRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: color)),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _ProjectilePainter extends CustomPainter {
  final double angle;
  final double speed;
  final double progress;

  _ProjectilePainter({required this.angle, required this.speed, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final base = Offset(0, size.height * 0.9);
    final g = 9.8;
    final rad = angle * pi / 180;
    final totalTime = 2 * speed * sin(rad) / g;
    final path = Path();
    for (double t = 0; t <= totalTime; t += 0.03) {
      final x = speed * cos(rad) * t;
      final y = speed * sin(rad) * t - 0.5 * g * t * t;
      final px = base.dx + x / (speed * totalTime) * size.width;
      final py = base.dy - y / (speed * sin(rad)) * size.height * 0.8;
      if (t == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..shader = const LinearGradient(colors: [NeonPalette.cyan, NeonPalette.purple])
          .createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(path, paint);
    final animProgress = progress * totalTime;
    final x = speed * cos(rad) * animProgress;
    final y = speed * sin(rad) * animProgress - 0.5 * g * animProgress * animProgress;
    final px = base.dx + x / (speed * totalTime) * size.width;
    final py = base.dy - y / (speed * sin(rad)) * size.height * 0.8;
    canvas.drawCircle(Offset(px, py), 8, Paint()..color = NeonPalette.pink);
    canvas.drawShadow(path, Colors.black, 6, false);
  }

  @override
  bool shouldRepaint(covariant _ProjectilePainter oldDelegate) {
    return oldDelegate.angle != angle ||
        oldDelegate.speed != speed ||
        oldDelegate.progress != progress;
  }
}

class ElectricFieldVisualizer extends StatefulWidget {
  const ElectricFieldVisualizer({super.key});

  @override
  State<ElectricFieldVisualizer> createState() => _ElectricFieldVisualizerState();
}

class _ElectricFieldVisualizerState extends State<ElectricFieldVisualizer> {
  Offset positive = const Offset(0.3, 0.5);
  Offset negative = const Offset(0.7, 0.5);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassCard(
          child: SizedBox(
            height: 260,
            child: LayoutBuilder(
              builder: (context, constraints) => GestureDetector(
                onPanUpdate: (event) {
                  final local = Offset(event.localPosition.dx / constraints.maxWidth,
                      event.localPosition.dy / constraints.maxHeight);
                  setState(() {
                    if ((positive - local).distance < (negative - local).distance) {
                      positive = local;
                    } else {
                      negative = local;
                    }
                  });
                },
                child: CustomPaint(
                  painter: _ElectricFieldPainter(positive, negative),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text('Drag charges to see field lines reshape.'),
        const SizedBox(height: 4),
        Text('Field strength grows near the red positive charge.', style: TextStyle(color: AdaptiveColors.text(context))),
      ],
    );
  }
}

class _ElectricFieldPainter extends CustomPainter {
  final Offset positive;
  final Offset negative;

  _ElectricFieldPainter(this.positive, this.negative);

  @override
  void paint(Canvas canvas, Size size) {
    final steps = 24;
    for (int i = 0; i < steps; i++) {
      final angle = i / steps * pi * 2;
      final radius = lerpDouble(20, min(size.width, size.height) * 0.45, i / steps)!;
      final point = Offset(size.width / 2 + cos(angle) * radius, size.height / 2 + sin(angle) * radius);
      final field = _fieldAt(point, size);
      final dir = field.direction;
      final arrowEnd = point + Offset(cos(dir), sin(dir)) * 18;
      canvas.drawLine(point, arrowEnd, Paint()..color = Colors.white24..strokeWidth = 1.4);
      canvas.drawCircle(point, 1.7, Paint()..color = Colors.white70);
    }
    _drawCharge(canvas, size, positive, Colors.redAccent);
    _drawCharge(canvas, size, negative, Colors.blueAccent);
  }

  Offset _fieldAt(Offset p, Size size) {
    final pos = Offset(positive.dx * size.width, positive.dy * size.height);
    final neg = Offset(negative.dx * size.width, negative.dy * size.height);
    final field = (p - pos) / max(0.001, (p - pos).distanceSquared) -
        (p - neg) / max(0.001, (p - neg).distanceSquared);
    return field;
  }

  void _drawCharge(Canvas canvas, Size size, Offset normalized, Color color) {
    final center = Offset(normalized.dx * size.width, normalized.dy * size.height);
    canvas.drawCircle(center, 14, Paint()..color = color.withOpacity(0.3));
    canvas.drawCircle(center, 7, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _ElectricFieldPainter oldDelegate) {
    return oldDelegate.positive != positive || oldDelegate.negative != negative;
  }
}

class MagneticFieldVisualizer extends StatefulWidget {
  const MagneticFieldVisualizer({super.key});

  @override
  State<MagneticFieldVisualizer> createState() =>
      _MagneticFieldVisualizerState();
}

class _MagneticFieldVisualizerState extends State<MagneticFieldVisualizer> {
  double current = 0.8;

  @override
  Widget build(BuildContext context) {
    final textColor = AdaptiveColors.text(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Magnetic Loop',
                  style:
                      TextStyle(color: textColor, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              SizedBox(
                height: 240,
                child: CustomPaint(
                  painter: _MagneticFieldPainter(current),
                  child: const SizedBox.expand(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text('Current intensity: ${current.toStringAsFixed(2)} A',
            style: TextStyle(color: textColor)),
        Slider(
          value: current,
          min: 0.3,
          max: 1.6,
          onChanged: (v) => setState(() => current = v),
        ),
      ],
    );
  }
}

class _MagneticFieldPainter extends CustomPainter {
  final double current;

  _MagneticFieldPainter(this.current);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 + current
      ..shader = const LinearGradient(colors: [
        Colors.blueAccent,
        NeonPalette.cyan,
        NeonPalette.purple
      ]).createShader(Rect.fromCircle(center: center, radius: size.width / 2));

    for (double radius = size.width * 0.35;
        radius > size.width * 0.05;
        radius -= size.width * 0.08) {
      canvas.drawOval(
          Rect.fromCircle(center: center, radius: radius), paint..strokeWidth = 1.5 + current);
    }

    final field = Paint()
      ..strokeWidth = 1.4
      ..color = Colors.white.withOpacity(0.7);
    final arrows = 10;
    for (int i = 0; i < arrows; i++) {
      final angle = i / arrows * pi * 2;
      final start =
          Offset(center.dx + cos(angle) * size.width * 0.3, center.dy + sin(angle) * size.height * 0.3);
      final end =
          Offset(center.dx + cos(angle) * size.width * 0.45, center.dy + sin(angle) * size.height * 0.45);
      canvas.drawLine(start, end, field);
      final arrow = Path()
        ..moveTo(end.dx, end.dy)
        ..lineTo(end.dx - cos(angle) * 6 - sin(angle) * 3, end.dy - sin(angle) * 6 + cos(angle) * 3)
        ..lineTo(end.dx - cos(angle) * 6 + sin(angle) * 3, end.dy - sin(angle) * 6 - cos(angle) * 3)
        ..close();
      canvas.drawPath(arrow, field);
    }
  }

  @override
  bool shouldRepaint(covariant _MagneticFieldPainter oldDelegate) {
    return oldDelegate.current != current;
  }
}

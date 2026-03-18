import 'dart:math';
import 'package:flutter/material.dart';
import 'neon_ui.dart';

class ProjectileVisualizer extends StatefulWidget {
  const ProjectileVisualizer({super.key});

  @override
  State<ProjectileVisualizer> createState() => _ProjectileVisualizerState();
}

class _ProjectileVisualizerState extends State<ProjectileVisualizer> {
  double angle = 45;
  double speed = 18;

  @override
  Widget build(BuildContext context) {
    final textColor = AdaptiveColors.text(context);
    final pathLength = speed * speed * sin(2 * angle * pi / 180) / 9.8;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassCard(
          child: SizedBox(
            height: 260,
            child: CustomPaint(
              painter: _ProjectilePainter(angle: angle, speed: speed),
              child: const SizedBox.expand(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text('Angle: ${angle.toStringAsFixed(1)}°',
            style: TextStyle(color: textColor)),
        Slider(
          value: angle,
          min: 10,
          max: 80,
          divisions: 14,
          onChanged: (v) => setState(() => angle = v),
        ),
        Text('Speed: ${speed.toStringAsFixed(1)} m/s',
            style: TextStyle(color: textColor)),
        Slider(
            value: speed,
            min: 8,
            max: 28,
            onChanged: (v) => setState(() => speed = v)),
        const SizedBox(height: 6),
        Text('Range ≈ ${pathLength.toStringAsFixed(1)} m',
            style: TextStyle(
                color: NeonPalette.cyan, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _ProjectilePainter extends CustomPainter {
  final double angle;
  final double speed;

  _ProjectilePainter({required this.angle, required this.speed});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.1, size.height);
    final path = Path();
    final rad = angle * pi / 180;
    final g = 9.8;
    for (double t = 0; t <= 2 * speed * sin(rad) / g; t += 0.01) {
      final x = speed * cos(rad) * t;
      final y = speed * sin(rad) * t - 0.5 * g * t * t;
      final px = center.dx + x / (speed * speed / g) * (size.width * 0.8);
      final py = center.dy - y / (speed * sin(rad)) * size.height * 0.8;
      if (t == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    final paint = Paint()
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..shader =
          const LinearGradient(colors: [NeonPalette.cyan, NeonPalette.purple])
              .createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(path, paint);
    canvas.drawCircle(
        path.getBounds().bottomRight, 6, Paint()..color = NeonPalette.cyan);
  }

  @override
  bool shouldRepaint(covariant _ProjectilePainter oldDelegate) {
    return oldDelegate.angle != angle || oldDelegate.speed != speed;
  }
}

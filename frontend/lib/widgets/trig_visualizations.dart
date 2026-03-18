import 'dart:math';

import 'package:flutter/material.dart';

import 'neon_ui.dart';

class TrigVisualizationHub extends StatefulWidget {
  final String topicId;

  const TrigVisualizationHub({super.key, required this.topicId});

  @override
  State<TrigVisualizationHub> createState() => _TrigVisualizationHubState();
}

class _TrigVisualizationHubState extends State<TrigVisualizationHub> {
  @override
  Widget build(BuildContext context) {
    switch (widget.topicId) {
      case 'trig-sine-cosine':
        return const SineWaveVisualizer();
      case 'trig-angle-rotation':
        return const UnitCircleVisualizer();
      case 'trig-shadow-length':
        return const ShadowHeightVisualizer();
      case 'trig-right-triangle':
        return const RightTriangleExplorer();
      case 'trig-tangent-function':
        return const TangentVisualizer();
      case 'trig-wave-interference':
        return const InterferenceVisualizer();
      default:
        return const SineWaveVisualizer();
    }
  }
}

class SineWaveVisualizer extends StatefulWidget {
  const SineWaveVisualizer({super.key});

  @override
  State<SineWaveVisualizer> createState() => _SineWaveVisualizerState();
}

class _SineWaveVisualizerState extends State<SineWaveVisualizer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double amplitude = 1;
  double frequency = 1;
  double phase = 0;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final waveColor = Color.lerp(
        NeonPalette.cyan, Colors.redAccent, (amplitude - 0.5) / 2.5)!;
    return RepaintBoundary(
      child: Column(
        children: [
          SizedBox(
            height: 280,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Row(
                  children: [
                    Expanded(
                      child: CustomPaint(
                        painter: _UnitCircleLinkPainter(
                          angle: _controller.value * pi * 2,
                          color: waveColor,
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: CustomPaint(
                        painter: _SinePainter(
                          time: _controller.value,
                          amplitude: amplitude,
                          frequency: frequency,
                          phase: phase,
                          color: waveColor,
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          _label('Amplitude', amplitude),
          Slider(
              value: amplitude,
              min: 0.5,
              max: 3,
              onChanged: (v) => setState(() => amplitude = v)),
          _label('Frequency', frequency),
          Slider(
              value: frequency,
              min: 0.5,
              max: 4,
              onChanged: (v) => setState(() => frequency = v)),
          _label('Phase Shift', phase),
          Slider(
              value: phase,
              min: -pi,
              max: pi,
              onChanged: (v) => setState(() => phase = v)),
        ],
      ),
    );
  }

  Widget _label(String name, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(name, style: const TextStyle(color: NeonPalette.text)),
        Text(value.toStringAsFixed(2),
            style: const TextStyle(color: NeonPalette.cyan)),
      ],
    );
  }
}

class UnitCircleVisualizer extends StatefulWidget {
  const UnitCircleVisualizer({super.key});

  @override
  State<UnitCircleVisualizer> createState() => _UnitCircleVisualizerState();
}

class _UnitCircleVisualizerState extends State<UnitCircleVisualizer>
    with SingleTickerProviderStateMixin {
  double angle = 45;
  bool radians = false;
  bool autoRotate = false;
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 10))
          ..addListener(() {
            if (!autoRotate) return;
            setState(() {
              angle = (_rotationController.value * 360) % 360;
            });
          });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        children: [
          GestureDetector(
            onPanUpdate: (d) {
              setState(() {
                angle = (angle + d.delta.dx * 0.6).clamp(0, 360);
                const snaps = [
                  0,
                  30,
                  45,
                  60,
                  90,
                  120,
                  135,
                  150,
                  180,
                  210,
                  225,
                  240,
                  270,
                  300,
                  315,
                  330,
                  360
                ];
                final nearest = snaps.reduce(
                    (a, b) => (a - angle).abs() < (b - angle).abs() ? a : b);
                if ((nearest - angle).abs() < 3) angle = nearest.toDouble();
              });
            },
            child: SizedBox(
              height: 300,
              child: CustomPaint(
                painter: _UnitCircle3DPainter(angleDeg: angle),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _valueCard('sin', sin(angle * pi / 180)),
              _valueCard('cos', cos(angle * pi / 180)),
              _valueCard('tan', tan(angle * pi / 180)),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () =>
                    setState(() => angle = (angle - 15) < 0 ? 360 : angle - 15),
                icon: const Icon(Icons.remove),
                label: const Text('-15°'),
              ),
              OutlinedButton.icon(
                onPressed: () =>
                    setState(() => angle = (angle + 15) > 360 ? 0 : angle + 15),
                icon: const Icon(Icons.add),
                label: const Text('+15°'),
              ),
              FilledButton.icon(
                onPressed: () {
                  setState(() => autoRotate = !autoRotate);
                  if (autoRotate) {
                    _rotationController.repeat();
                  } else {
                    _rotationController.stop();
                  }
                },
                icon: Icon(autoRotate ? Icons.pause : Icons.play_arrow),
                label: Text(autoRotate ? 'Pause' : 'Play'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      radians
                          ? 'Angle: ${(angle * pi / 180).toStringAsFixed(3)} rad'
                          : 'Angle: ${angle.toStringAsFixed(1)}°',
                      style: const TextStyle(
                          color: NeonPalette.text, fontWeight: FontWeight.w700),
                    ),
                    Slider(
                      value: angle,
                      min: 0,
                      max: 360,
                      divisions: 72,
                      onChanged: (v) => setState(() => angle = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => setState(() => angle = 45),
                icon: const Icon(Icons.restart_alt),
                label: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SwitchListTile.adaptive(
            activeColor: NeonPalette.pink,
            value: radians,
            title: const Text('Radians mode',
                style: TextStyle(color: NeonPalette.text)),
            onChanged: (v) => setState(() => radians = v),
            subtitle: Text(
              radians
                  ? '${(angle * pi / 180).toStringAsFixed(3)} rad'
                  : '${angle.toStringAsFixed(1)}°',
              style: const TextStyle(color: NeonPalette.subtext),
            ),
          ),
        ],
      ),
    );
  }

  Widget _valueCard(String title, double value) {
    final safe =
        value.isInfinite || value.isNaN ? '∞' : value.toStringAsFixed(3);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: GlassCard(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Text(title, style: const TextStyle(color: NeonPalette.subtext)),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: value.isFinite ? value : 0),
                duration: const Duration(milliseconds: 300),
                builder: (context, v, _) => Text(
                  value.isFinite ? v.toStringAsFixed(3) : safe,
                  style: const TextStyle(
                      color: NeonPalette.cyan, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ShadowHeightVisualizer extends StatefulWidget {
  const ShadowHeightVisualizer({super.key});

  @override
  State<ShadowHeightVisualizer> createState() => _ShadowHeightVisualizerState();
}

class _ShadowHeightVisualizerState extends State<ShadowHeightVisualizer> {
  double angle = 40;
  double height = 6;
  bool night = false;

  @override
  Widget build(BuildContext context) {
    final shadow = height / tan(angle * pi / 180);
    return RepaintBoundary(
      child: Column(
        children: [
          SizedBox(
            height: 280,
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 2,
              child: CustomPaint(
                painter: _ShadowScenePainter(
                    angle: angle, height: height, night: night),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          SwitchListTile(
            value: night,
            activeColor: NeonPalette.pink,
            title: const Text('Day / Sunset',
                style: TextStyle(color: NeonPalette.text)),
            onChanged: (v) => setState(() => night = v),
          ),
          _slider('Sun Angle', angle, 10, 80, (v) => setState(() => angle = v)),
          _slider('Building Height', height, 2, 12,
              (v) => setState(() => height = v)),
          Text(
            'shadow = height / tan(θ) => ${shadow.toStringAsFixed(2)} m',
            style: const TextStyle(color: NeonPalette.cyan),
          ),
        ],
      ),
    );
  }

  Widget _slider(String label, double v, double min, double max,
      ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${v.toStringAsFixed(1)}',
            style: const TextStyle(color: NeonPalette.text)),
        Slider(value: v, min: min, max: max, onChanged: onChanged),
      ],
    );
  }
}

class RightTriangleExplorer extends StatefulWidget {
  const RightTriangleExplorer({super.key});

  @override
  State<RightTriangleExplorer> createState() => _RightTriangleExplorerState();
}

class _RightTriangleExplorerState extends State<RightTriangleExplorer> {
  Offset a = const Offset(60, 230);
  Offset b = const Offset(280, 230);
  Offset c = const Offset(280, 80);
  int dragging = -1;
  bool proofMode = false;

  @override
  Widget build(BuildContext context) {
    final ab = (b - a).distance;
    final bc = (c - b).distance;
    final ca = (a - c).distance;
    final lhs = ab * ab + bc * bc;
    final rhs = ca * ca;
    return RepaintBoundary(
      child: Column(
        children: [
          GestureDetector(
            onPanStart: (d) {
              final p = d.localPosition;
              final pts = [a, b, c];
              for (int i = 0; i < pts.length; i++) {
                if ((pts[i] - p).distance < 24) dragging = i;
              }
            },
            onPanUpdate: (d) {
              setState(() {
                if (dragging == 0) a = d.localPosition;
                if (dragging == 1) b = d.localPosition;
                if (dragging == 2) c = d.localPosition;
              });
            },
            onPanEnd: (_) => dragging = -1,
            child: SizedBox(
              height: 300,
              child: CustomPaint(
                painter: _TriangleExplorerPainter(
                    a: a, b: b, c: c, proofMode: proofMode),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                  child: Text('Opposite: ${bc.toStringAsFixed(1)}',
                      style: const TextStyle(color: Colors.redAccent))),
              Expanded(
                  child: Text('Adjacent: ${ab.toStringAsFixed(1)}',
                      style: const TextStyle(color: Colors.greenAccent))),
              Expanded(
                  child: Text('Hypotenuse: ${ca.toStringAsFixed(1)}',
                      style: const TextStyle(color: NeonPalette.purple))),
            ],
          ),
          const SizedBox(height: 6),
          Text(
              'a² + b² = c²  |  ${lhs.toStringAsFixed(1)} ≈ ${rhs.toStringAsFixed(1)}',
              style: const TextStyle(color: NeonPalette.cyan)),
          SwitchListTile(
            value: proofMode,
            title: const Text('Proof Mode (squares)',
                style: TextStyle(color: NeonPalette.text)),
            onChanged: (v) => setState(() => proofMode = v),
          ),
        ],
      ),
    );
  }
}

class TangentVisualizer extends StatefulWidget {
  const TangentVisualizer({super.key});

  @override
  State<TangentVisualizer> createState() => _TangentVisualizerState();
}

class _TangentVisualizerState extends State<TangentVisualizer> {
  double angle = 30;
  double zoom = 1;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        children: [
          SizedBox(
            height: 280,
            child: CustomPaint(
              painter: _TangentPainter(angle: angle, zoom: zoom),
              child: const SizedBox.expand(),
            ),
          ),
          Slider(
              value: angle,
              min: 1,
              max: 179,
              onChanged: (v) => setState(() => angle = v)),
          Slider(
              value: zoom,
              min: 0.6,
              max: 2.5,
              onChanged: (v) => setState(() => zoom = v)),
          Text(
              'tan(θ) = ${tan(angle * pi / 180).isFinite ? tan(angle * pi / 180).toStringAsFixed(3) : '∞'}',
              style: const TextStyle(color: NeonPalette.pink)),
        ],
      ),
    );
  }
}

class InterferenceVisualizer extends StatefulWidget {
  const InterferenceVisualizer({super.key});

  @override
  State<InterferenceVisualizer> createState() => _InterferenceVisualizerState();
}

class _InterferenceVisualizerState extends State<InterferenceVisualizer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double a1 = 1;
  double f1 = 1;
  double a2 = 1;
  double f2 = 1.5;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        children: [
          SizedBox(
            height: 260,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _InterferencePainter(
                      time: _controller.value, a1: a1, f1: f1, a2: a2, f2: f2),
                  child: const SizedBox.expand(),
                );
              },
            ),
          ),
          _range('Wave A amplitude', a1, (v) => setState(() => a1 = v)),
          _range('Wave A frequency', f1, (v) => setState(() => f1 = v),
              min: 0.5, max: 4),
          _range('Wave B amplitude', a2, (v) => setState(() => a2 = v)),
          _range('Wave B frequency', f2, (v) => setState(() => f2 = v),
              min: 0.5, max: 4),
        ],
      ),
    );
  }

  Widget _range(String label, double value, ValueChanged<double> onChanged,
      {double min = 0.5, double max = 3}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.toStringAsFixed(2)}',
            style: const TextStyle(color: NeonPalette.text)),
        Slider(value: value, min: min, max: max, onChanged: onChanged),
      ],
    );
  }
}

class _SinePainter extends CustomPainter {
  final double time;
  final double amplitude;
  final double frequency;
  final double phase;
  final Color color;

  _SinePainter(
      {required this.time,
      required this.amplitude,
      required this.frequency,
      required this.phase,
      required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final axis = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1;
    canvas.drawLine(
        Offset(0, size.height / 2), Offset(size.width, size.height / 2), axis);
    final p = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    final path = Path();
    for (double x = 0; x <= size.width; x++) {
      final t = x / size.width * pi * 2;
      final y = size.height / 2 -
          sin((t * frequency) + phase) * amplitude * (size.height * 0.28);
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, p);
    final mx = (time * size.width);
    final mt = mx / size.width * pi * 2;
    final my = size.height / 2 -
        sin((mt * frequency) + phase) * amplitude * (size.height * 0.28);
    canvas.drawCircle(
        Offset(mx, my), 7, Paint()..color = color.withOpacity(0.7));
    canvas.drawCircle(Offset(mx, my), 4, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _SinePainter oldDelegate) => true;
}

class _UnitCircleLinkPainter extends CustomPainter {
  final double angle;
  final Color color;

  _UnitCircleLinkPainter({required this.angle, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = min(size.width, size.height) * 0.32;
    canvas.drawCircle(
        center,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.white30);
    final point =
        Offset(center.dx + cos(angle) * r, center.dy - sin(angle) * r);
    canvas.drawLine(
        center,
        point,
        Paint()
          ..color = color
          ..strokeWidth = 2.5);
    canvas.drawCircle(point, 6, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _UnitCircleLinkPainter oldDelegate) => true;
}

class _UnitCircle3DPainter extends CustomPainter {
  final double angleDeg;

  _UnitCircle3DPainter({required this.angleDeg});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width * 0.5, size.height * 0.52);
    final r = min(size.width, size.height) * 0.34;
    final a = angleDeg * pi / 180;

    final circle = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    final oval = Rect.fromCenter(center: c, width: r * 2, height: r * 1.55);
    canvas.drawOval(oval, circle);

    for (int i = 0; i < 4; i++) {
      final sx = i.isEven ? 1 : -1;
      final sy = i < 2 ? -1 : 1;
      final rect = Rect.fromLTWH(c.dx + sx * 36, c.dy + sy * 28, 52, 38);
      canvas.drawRect(
          rect,
          Paint()
            ..color =
                (sx * sy > 0 ? Colors.green : Colors.red).withOpacity(0.12));
    }

    final px = c.dx + cos(a) * r;
    final py = c.dy - sin(a) * r * 0.78;
    final trail = Path()..moveTo(c.dx + r, c.dy);
    for (double t = 0; t < a; t += 0.04) {
      trail.lineTo(c.dx + cos(t) * r, c.dy - sin(t) * r * 0.78);
    }
    canvas.drawPath(
        trail,
        Paint()
          ..color = NeonPalette.pink.withOpacity(0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);

    canvas.drawLine(
        c,
        Offset(px, py),
        Paint()
          ..color = NeonPalette.cyan
          ..strokeWidth = 2.6);
    canvas.drawCircle(Offset(px, py), 7, Paint()..color = Colors.white);
    canvas.drawLine(Offset(px, py), Offset(px, c.dy),
        Paint()..color = Colors.redAccent.withOpacity(0.8));
    canvas.drawLine(c, Offset(px, c.dy),
        Paint()..color = Colors.greenAccent.withOpacity(0.8));
  }

  @override
  bool shouldRepaint(covariant _UnitCircle3DPainter oldDelegate) =>
      oldDelegate.angleDeg != angleDeg;
}

class _ShadowScenePainter extends CustomPainter {
  final double angle;
  final double height;
  final bool night;

  _ShadowScenePainter(
      {required this.angle, required this.height, required this.night});

  @override
  void paint(Canvas canvas, Size size) {
    final sky = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: night
            ? [const Color(0xFF1F2937), const Color(0xFF7C2D12)]
            : [const Color(0xFF0EA5E9), const Color(0xFF93C5FD)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), sky);
    canvas.drawRect(
        Rect.fromLTWH(0, size.height * 0.72, size.width, size.height * 0.28),
        Paint()..color = const Color(0xFF1E293B));

    final buildingX = size.width * 0.2;
    final buildingH = height / 12 * size.height * 0.45;
    final baseY = size.height * 0.72;
    canvas.drawRect(Rect.fromLTWH(buildingX, baseY - buildingH, 42, buildingH),
        Paint()..color = const Color(0xFF334155));

    const sunR = 20.0;
    final sunX = size.width * 0.8 - cos(angle * pi / 180) * 120;
    final sunY = size.height * 0.2 + sin(angle * pi / 180) * 45;
    final sun = Offset(sunX, sunY);
    canvas.drawCircle(sun, sunR, Paint()..color = const Color(0xFFFDE047));

    final top = Offset(buildingX + 21, baseY - buildingH);
    final shadowLen = height / tan(angle * pi / 180) * 10;
    final end = Offset(top.dx + shadowLen, baseY);

    final dash = Paint()
      ..color = Colors.yellow.withOpacity(0.7)
      ..strokeWidth = 2;
    for (double t = 0; t < 1; t += 0.08) {
      final p1 = Offset.lerp(sun, top, t)!;
      final p2 = Offset.lerp(sun, top, t + 0.04)!;
      canvas.drawLine(p1, p2, dash);
    }

    final shadow = Path()
      ..moveTo(buildingX + 42, baseY)
      ..lineTo(end.dx, end.dy)
      ..lineTo(end.dx + 18, end.dy)
      ..lineTo(buildingX + 42, baseY)
      ..close();
    canvas.drawPath(shadow, Paint()..color = Colors.black.withOpacity(0.35));

    canvas.drawCircle(Offset(buildingX + 70, baseY - 28), 10,
        Paint()..color = const Color(0xFFF472B6));
    canvas.drawRect(Rect.fromLTWH(buildingX + 66, baseY - 18, 8, 20),
        Paint()..color = const Color(0xFFF472B6));

    canvas.drawRect(Rect.fromLTWH(buildingX + 150, baseY - 70, 12, 70),
        Paint()..color = const Color(0xFF14532D));
    canvas.drawCircle(Offset(buildingX + 156, baseY - 84), 18,
        Paint()..color = const Color(0xFF22C55E));
  }

  @override
  bool shouldRepaint(covariant _ShadowScenePainter oldDelegate) => true;
}

class _TriangleExplorerPainter extends CustomPainter {
  final Offset a;
  final Offset b;
  final Offset c;
  final bool proofMode;

  _TriangleExplorerPainter(
      {required this.a,
      required this.b,
      required this.c,
      required this.proofMode});

  @override
  void paint(Canvas canvas, Size size) {
    if (proofMode) {
      final ab = (b - a).distance;
      final bc = (c - b).distance;
      final ca = (a - c).distance;
      canvas.drawRect(Rect.fromLTWH(a.dx, a.dy - ab, ab, ab),
          Paint()..color = Colors.green.withOpacity(0.12));
      canvas.drawRect(Rect.fromLTWH(b.dx, b.dy - bc, bc, bc),
          Paint()..color = Colors.red.withOpacity(0.12));
      canvas.drawRect(Rect.fromLTWH(c.dx, c.dy - ca, ca, ca),
          Paint()..color = NeonPalette.purple.withOpacity(0.12));
    }

    canvas.drawLine(
        a,
        b,
        Paint()
          ..color = Colors.greenAccent
          ..strokeWidth = 3);
    canvas.drawLine(
        b,
        c,
        Paint()
          ..color = Colors.redAccent
          ..strokeWidth = 3);
    canvas.drawLine(
        c,
        a,
        Paint()
          ..color = NeonPalette.purple
          ..strokeWidth = 3);

    for (final p in [a, b, c]) {
      canvas.drawCircle(p, 9, Paint()..color = Colors.white);
      canvas.drawCircle(p, 5, Paint()..color = NeonPalette.cyan);
    }
  }

  @override
  bool shouldRepaint(covariant _TriangleExplorerPainter oldDelegate) => true;
}

class _TangentPainter extends CustomPainter {
  final double angle;
  final double zoom;

  _TangentPainter({required this.angle, required this.zoom});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.2, size.height * 0.5);
    const r = 62.0;
    canvas.drawCircle(
        center,
        r,
        Paint()
          ..color = Colors.white24
          ..style = PaintingStyle.stroke);
    final rad = angle * pi / 180;
    final point = Offset(center.dx + cos(rad) * r, center.dy - sin(rad) * r);
    canvas.drawLine(
        center,
        point,
        Paint()
          ..color = NeonPalette.cyan
          ..strokeWidth = 2.5);

    final tx = center.dx + r;
    canvas.drawLine(
        Offset(tx, center.dy - 100),
        Offset(tx, center.dy + 100),
        Paint()
          ..color = NeonPalette.pink
          ..strokeWidth = 2);
    final tanLen = tan(rad) * r;
    if (tanLen.isFinite) {
      canvas.drawLine(
          Offset(tx, center.dy),
          Offset(tx, center.dy - tanLen.clamp(-130, 130)),
          Paint()
            ..color = Colors.yellow
            ..strokeWidth = 3);
    }

    final rect = Rect.fromLTWH(
        size.width * 0.42, 24, size.width * 0.55, size.height - 48);
    final axis = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1;
    canvas.drawLine(Offset(rect.left, rect.center.dy),
        Offset(rect.right, rect.center.dy), axis);
    canvas.drawLine(
        Offset(rect.left, rect.top), Offset(rect.left, rect.bottom), axis);

    final p = Paint()
      ..color = NeonPalette.cyan
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path();
    bool started = false;
    for (double x = -pi; x <= pi; x += 0.02) {
      final y = tan(x);
      if (y.abs() > 5) {
        started = false;
        continue;
      }
      final px = rect.left + (x + pi) / (2 * pi) * rect.width;
      final py = rect.center.dy - y * (22 * zoom);
      if (!started) {
        path.moveTo(px, py);
        started = true;
      } else {
        path.lineTo(px, py);
      }
    }
    canvas.drawPath(path, p);

    for (final a in [-pi / 2, pi / 2]) {
      final x = rect.left + (a + pi) / (2 * pi) * rect.width;
      canvas.drawLine(
          Offset(x, rect.top),
          Offset(x, rect.bottom),
          Paint()
            ..color = Colors.redAccent.withOpacity(0.7)
            ..strokeWidth = 1.3);
      canvas.drawCircle(
          Offset(x, rect.center.dy), 4, Paint()..color = Colors.redAccent);
    }
  }

  @override
  bool shouldRepaint(covariant _TangentPainter oldDelegate) => true;
}

class _InterferencePainter extends CustomPainter {
  final double time;
  final double a1;
  final double f1;
  final double a2;
  final double f2;

  _InterferencePainter(
      {required this.time,
      required this.a1,
      required this.f1,
      required this.a2,
      required this.f2});

  @override
  void paint(Canvas canvas, Size size) {
    final cY = size.height * 0.5;
    canvas.drawLine(
        Offset(0, cY), Offset(size.width, cY), Paint()..color = Colors.white24);

    _drawWave(
        canvas, size, cY, a1, f1, time, NeonPalette.cyan.withOpacity(0.7));
    _drawWave(canvas, size, cY, a2, f2, time + 0.25,
        NeonPalette.pink.withOpacity(0.7));
    _drawWave(canvas, size, cY, 1, 1, time, Colors.amber, combine: true);
  }

  void _drawWave(Canvas canvas, Size size, double cY, double amp, double freq,
      double t, Color color,
      {bool combine = false}) {
    final p = Paint()
      ..color = color
      ..strokeWidth = combine ? 3 : 1.7
      ..style = PaintingStyle.stroke;
    final path = Path();
    for (double x = 0; x <= size.width; x++) {
      final k = x / size.width * pi * 8;
      final y = combine
          ? cY -
              (sin(k * f1 + t * pi * 2) * a1 +
                      sin(k * f2 + (t + 0.25) * pi * 2) * a2) *
                  22
          : cY - sin(k * freq + t * pi * 2) * amp * 22;
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      if (combine && x % 24 == 0) {
        canvas.drawCircle(
            Offset(x, y), 2.5, Paint()..color = Colors.white.withOpacity(0.65));
      }
    }
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant _InterferencePainter oldDelegate) => true;
}

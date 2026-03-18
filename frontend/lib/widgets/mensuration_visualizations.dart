import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'neon_ui.dart';

class MensurationVisualizationHub extends StatefulWidget {
  final String topicId;

  const MensurationVisualizationHub({super.key, required this.topicId});

  @override
  State<MensurationVisualizationHub> createState() =>
      _MensurationVisualizationHubState();
}

class _MensurationVisualizationHubState
    extends State<MensurationVisualizationHub> {
  @override
  Widget build(BuildContext context) {
    switch (widget.topicId) {
      case 'mens-rectangle-area':
        return const RectangleAreaInteractive();
      case 'mens-square-area':
        return const SquareAreaInteractive();
      case 'mens-perimeter':
        return const PerimeterInteractive();
      case 'mens-grid-area':
        return const GridMethodInteractive();
      default:
        return const RectangleAreaInteractive();
    }
  }
}

class RectangleAreaInteractive extends StatefulWidget {
  const RectangleAreaInteractive({super.key});

  @override
  State<RectangleAreaInteractive> createState() =>
      _RectangleAreaInteractiveState();
}

class _RectangleAreaInteractiveState extends State<RectangleAreaInteractive>
    with SingleTickerProviderStateMixin {
  double length = 6;
  double width = 4;
  late final AnimationController _rulerAnim;

  @override
  void initState() {
    super.initState();
    _rulerAnim =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();
  }

  @override
  void dispose() {
    _rulerAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final area = length * width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HintSteps(
          title: 'Area Explorer',
          steps: [
            'Drag the glowing corner handle to resize the rectangle.',
            'Watch animated rulers show length and width.',
            'Area updates live: length x width.',
          ],
        ),
        const SizedBox(height: 8),
        _Stage(
          child: AnimatedBuilder(
            animation: _rulerAnim,
            builder: (context, _) {
              return LayoutBuilder(
                builder: (context, c) {
                  return GestureDetector(
                    onPanUpdate: (d) {
                      final next = _rectUnitsFromPoint(
                        d.localPosition,
                        Size(c.maxWidth, c.maxHeight),
                      );
                      setState(() {
                        length = next.$1;
                        width = next.$2;
                      });
                    },
                    child: CustomPaint(
                      painter: _RectGamePainter(
                        length: length,
                        width: width,
                        phase: _rulerAnim.value,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  );
                },
              );
            },
          ),
        ),
        _slider('Length', length, 1, 12, (v) => setState(() => length = v)),
        _slider('Width', width, 1, 12, (v) => setState(() => width = v)),
        Center(
          child: Text(
            'Area = ${length.toStringAsFixed(0)} x ${width.toStringAsFixed(0)} = ${area.toStringAsFixed(0)} sq units',
            style: const TextStyle(
                color: NeonPalette.cyan,
                fontWeight: FontWeight.w800,
                fontSize: 17),
          ),
        ),
      ],
    );
  }

  (double, double) _rectUnitsFromPoint(Offset p, Size size) {
    const pad = 40.0;
    final areaW = (size.width - pad * 2).clamp(100.0, 900.0);
    final areaH = (size.height - pad * 2).clamp(100.0, 900.0);
    final unitX = areaW / 12;
    final unitY = areaH / 12;
    final l = ((p.dx - pad) / unitX).clamp(1.0, 12.0);
    final w = ((size.height - pad - p.dy) / unitY).clamp(1.0, 12.0);
    return (l, w);
  }

  Widget _slider(
      String t, double v, double min, double max, ValueChanged<double> on) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$t: ${v.toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.w700)),
        Slider(
            value: v,
            min: min,
            max: max,
            divisions: (max - min).toInt(),
            onChanged: on),
      ],
    );
  }
}

class SquareAreaInteractive extends StatefulWidget {
  const SquareAreaInteractive({super.key});

  @override
  State<SquareAreaInteractive> createState() => _SquareAreaInteractiveState();
}

class _SquareAreaInteractiveState extends State<SquareAreaInteractive> {
  double side = 5;

  @override
  Widget build(BuildContext context) {
    final area = side * side;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HintSteps(
          title: 'Square Builder',
          steps: [
            'Drag or slide to change side length.',
            'All sides remain equal in a square.',
            'Area = side x side.',
          ],
        ),
        const SizedBox(height: 8),
        _Stage(
          child: GestureDetector(
            onPanUpdate: (d) {
              setState(() {
                side = (side + d.delta.dx / 25).clamp(1.0, 12.0);
              });
            },
            child: CustomPaint(
              painter: _RectGamePainter(
                length: side,
                width: side,
                phase: 0.0,
                fillColor: NeonPalette.pink.withOpacity(0.25),
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
        _slider('Side', side, (v) => setState(() => side = v)),
        Center(
          child: Text(
            'Square Area = ${side.toStringAsFixed(0)}² = ${area.toStringAsFixed(0)} sq units',
            style: const TextStyle(
                color: NeonPalette.pink,
                fontWeight: FontWeight.w800,
                fontSize: 17),
          ),
        ),
      ],
    );
  }

  Widget _slider(String t, double v, ValueChanged<double> on) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$t: ${v.toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.w700)),
        Slider(value: v, min: 1, max: 12, divisions: 11, onChanged: on),
      ],
    );
  }
}

class PerimeterInteractive extends StatefulWidget {
  const PerimeterInteractive({super.key});

  @override
  State<PerimeterInteractive> createState() => _PerimeterInteractiveState();
}

class _PerimeterInteractiveState extends State<PerimeterInteractive>
    with SingleTickerProviderStateMixin {
  String shape = 'rectangle';
  double a = 7;
  double b = 4;
  late final AnimationController _edgeAnim;

  @override
  void initState() {
    super.initState();
    _edgeAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat();
  }

  @override
  void dispose() {
    _edgeAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSquare = shape == 'square';
    final width = isSquare ? a : b;
    final perimeter = isSquare ? (4 * a) : (2 * (a + width));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HintSteps(
          title: 'Perimeter Game',
          steps: [
            'Drag the glowing vertex to change the shape size.',
            'Follow the animated border path and count all sides.',
            'Perimeter is the total boundary length.',
          ],
        ),
        const SizedBox(height: 8),
        Center(
          child: DropdownButton<String>(
            value: shape,
            items: const [
              DropdownMenuItem(value: 'rectangle', child: Text('Rectangle')),
              DropdownMenuItem(value: 'square', child: Text('Square')),
            ],
            onChanged: (v) => setState(() => shape = v ?? 'rectangle'),
          ),
        ),
        _Stage(
          child: AnimatedBuilder(
            animation: _edgeAnim,
            builder: (context, _) {
              return LayoutBuilder(
                builder: (context, c) {
                  return GestureDetector(
                    onPanUpdate: (d) {
                      final next = _rectUnitsFromPoint(
                        d.localPosition,
                        Size(c.maxWidth, c.maxHeight),
                        lockSquare: isSquare,
                      );
                      setState(() {
                        a = next.$1;
                        b = next.$2;
                      });
                    },
                    child: CustomPaint(
                      painter: _PerimeterGamePainter(
                        length: a,
                        width: width,
                        isSquare: isSquare,
                        phase: _edgeAnim.value,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  );
                },
              );
            },
          ),
        ),
        _slider('Length / Side', a, (v) => setState(() => a = v)),
        if (!isSquare) _slider('Width', b, (v) => setState(() => b = v)),
        Center(
          child: Text(
            isSquare
                ? 'Perimeter = 4 x ${a.toStringAsFixed(0)} = ${perimeter.toStringAsFixed(0)} units'
                : 'Perimeter = 2 x (${a.toStringAsFixed(0)} + ${width.toStringAsFixed(0)}) = ${perimeter.toStringAsFixed(0)} units',
            style: const TextStyle(
                color: NeonPalette.cyan,
                fontWeight: FontWeight.w800,
                fontSize: 17),
          ),
        ),
      ],
    );
  }

  (double, double) _rectUnitsFromPoint(Offset p, Size size,
      {required bool lockSquare}) {
    const pad = 40.0;
    final areaW = (size.width - pad * 2).clamp(100.0, 900.0);
    final areaH = (size.height - pad * 2).clamp(100.0, 900.0);
    final unitX = areaW / 12;
    final unitY = areaH / 12;
    final l = ((p.dx - pad) / unitX).clamp(1.0, 12.0);
    final w = ((size.height - pad - p.dy) / unitY).clamp(1.0, 12.0);
    if (lockSquare) {
      return (l, l);
    }
    return (l, w);
  }

  Widget _slider(String t, double v, ValueChanged<double> on) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$t: ${v.toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.w700)),
        Slider(value: v, min: 1, max: 12, divisions: 11, onChanged: on),
      ],
    );
  }
}

class GridMethodInteractive extends StatefulWidget {
  const GridMethodInteractive({super.key});

  @override
  State<GridMethodInteractive> createState() => _GridMethodInteractiveState();
}

class _GridMethodInteractiveState extends State<GridMethodInteractive> {
  int cols = 8;
  int rows = 6;
  final Map<String, int> _cellState = {};

  @override
  Widget build(BuildContext context) {
    final full = _cellState.values.where((v) => v == 1).length;
    final half = _cellState.values.where((v) => v == 2).length;
    final area = full + (half * 0.5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HintSteps(
          title: 'Grid Area Challenge',
          steps: [
            'Tap a cell: empty -> full -> half -> empty.',
            'Count full cells and half cells separately.',
            'Area = full + half/2.',
          ],
        ),
        const SizedBox(height: 8),
        _Stage(
          child: LayoutBuilder(
            builder: (context, c) {
              return GestureDetector(
                onTapDown: (d) {
                  final key = _keyFromTap(
                      d.localPosition, Size(c.maxWidth, c.maxHeight));
                  if (key == null) return;
                  setState(() {
                    final current = _cellState[key] ?? 0;
                    final next = (current + 1) % 3;
                    if (next == 0) {
                      _cellState.remove(key);
                    } else {
                      _cellState[key] = next;
                    }
                  });
                },
                child: CustomPaint(
                  painter: _GridTapPainter(
                      cols: cols, rows: rows, cellState: _cellState),
                  child: const SizedBox.expand(),
                ),
              );
            },
          ),
        ),
        _slider('Columns', cols.toDouble(), 4, 12, (v) {
          setState(() {
            cols = v.round();
            _cellState.clear();
          });
        }),
        _slider('Rows', rows.toDouble(), 4, 10, (v) {
          setState(() {
            rows = v.round();
            _cellState.clear();
          });
        }),
        Wrap(
          spacing: 12,
          children: [
            _legend(NeonPalette.cyan, 'Full: $full'),
            _legend(NeonPalette.pink, 'Half: $half'),
            _legend(Colors.white, 'Area: ${area.toStringAsFixed(1)}'),
          ],
        ),
      ],
    );
  }

  String? _keyFromTap(Offset p, Size size) {
    const pad = 26.0;
    final gridW = size.width - (pad * 2);
    final gridH = size.height - (pad * 2);
    if (p.dx < pad || p.dy < pad || p.dx > pad + gridW || p.dy > pad + gridH) {
      return null;
    }
    final cellW = gridW / cols;
    final cellH = gridH / rows;
    final c = ((p.dx - pad) / cellW).floor().clamp(0, cols - 1);
    final r = ((p.dy - pad) / cellH).floor().clamp(0, rows - 1);
    return '$c:$r';
  }

  Widget _legend(Color color, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.7)),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }

  Widget _slider(
      String t, double v, double min, double max, ValueChanged<double> on) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$t: ${v.toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.w700)),
        Slider(
            value: v,
            min: min,
            max: max,
            divisions: (max - min).toInt(),
            onChanged: on),
      ],
    );
  }
}

class _HintSteps extends StatelessWidget {
  final String title;
  final List<String> steps;

  const _HintSteps({required this.title, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          for (int i = 0; i < steps.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('${i + 1}. ${steps[i]}',
                  style: const TextStyle(color: NeonPalette.subtext)),
            ),
        ],
      ),
    );
  }
}

class _Stage extends StatelessWidget {
  final Widget child;

  const _Stage({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 340,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.02)
          ],
        ),
      ),
      child: child,
    );
  }
}

class _RectGamePainter extends CustomPainter {
  final double length;
  final double width;
  final double phase;
  final Color fillColor;

  _RectGamePainter({
    required this.length,
    required this.width,
    required this.phase,
    this.fillColor = const Color(0x3306B6D4),
  });

  @override
  void paint(Canvas canvas, Size size) {
    const pad = 40.0;
    final plotW = size.width - pad * 2;
    final plotH = size.height - pad * 2;
    final unit = math.min(plotW / 12, plotH / 12);

    final wPx = length * unit;
    final hPx = width * unit;
    final left = pad;
    final bottom = size.height - pad;
    final top = bottom - hPx;
    final rect = Rect.fromLTWH(left, top, wPx, hPx);

    final bgGrid = Paint()
      ..color = Colors.white.withOpacity(0.07)
      ..style = PaintingStyle.stroke;
    for (double x = pad; x <= size.width - pad; x += unit) {
      canvas.drawLine(Offset(x, pad), Offset(x, size.height - pad), bgGrid);
    }
    for (double y = pad; y <= size.height - pad; y += unit) {
      canvas.drawLine(Offset(pad, y), Offset(size.width - pad, y), bgGrid);
    }

    canvas.drawRect(rect, Paint()..color = fillColor);
    canvas.drawRect(
      rect,
      Paint()
        ..color = NeonPalette.cyan
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    final handle = Offset(rect.right, rect.top);
    canvas.drawCircle(
        handle, 11, Paint()..color = NeonPalette.purple.withOpacity(0.28));
    canvas.drawCircle(handle, 7, Paint()..color = NeonPalette.purple);

    _drawArrow(canvas, Offset(left, top - 18), Offset(rect.right, top - 18),
        NeonPalette.cyan, phase);
    _drawArrow(canvas, Offset(left - 18, top), Offset(left - 18, bottom),
        NeonPalette.pink, phase);

    final tp = TextPainter(textDirection: TextDirection.ltr);
    tp.text = TextSpan(
      text: 'L=${length.toStringAsFixed(0)}',
      style:
          const TextStyle(color: NeonPalette.cyan, fontWeight: FontWeight.w800),
    );
    tp.layout();
    tp.paint(canvas, Offset((left + rect.right) / 2 - tp.width / 2, top - 36));

    tp.text = TextSpan(
      text: 'W=${width.toStringAsFixed(0)}',
      style:
          const TextStyle(color: NeonPalette.pink, fontWeight: FontWeight.w800),
    );
    tp.layout();
    tp.paint(canvas,
        Offset(left - tp.width - 24, (top + bottom) / 2 - tp.height / 2));
  }

  void _drawArrow(
      Canvas canvas, Offset a, Offset b, Color color, double phase) {
    final p = Paint()
      ..color = color.withOpacity(0.8 + 0.2 * math.sin(phase * math.pi * 2))
      ..strokeWidth = 2.5;
    canvas.drawLine(a, b, p);
    final dir = (b - a);
    final n = dir.distance == 0 ? const Offset(1, 0) : dir / dir.distance;
    final left = Offset(-n.dy, n.dx);
    const s = 7.0;
    canvas.drawLine(a, a + n * s + left * s * 0.6, p);
    canvas.drawLine(a, a + n * s - left * s * 0.6, p);
    canvas.drawLine(b, b - n * s + left * s * 0.6, p);
    canvas.drawLine(b, b - n * s - left * s * 0.6, p);
  }

  @override
  bool shouldRepaint(covariant _RectGamePainter oldDelegate) {
    return oldDelegate.length != length ||
        oldDelegate.width != width ||
        oldDelegate.phase != phase ||
        oldDelegate.fillColor != fillColor;
  }
}

class _PerimeterGamePainter extends CustomPainter {
  final double length;
  final double width;
  final bool isSquare;
  final double phase;

  _PerimeterGamePainter({
    required this.length,
    required this.width,
    required this.isSquare,
    required this.phase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const pad = 40.0;
    final plotW = size.width - pad * 2;
    final plotH = size.height - pad * 2;
    final unit = math.min(plotW / 12, plotH / 12);

    final wPx = length * unit;
    final hPx = width * unit;
    final left = pad;
    final bottom = size.height - pad;
    final top = bottom - hPx;
    final rect = Rect.fromLTWH(left, top, wPx, hPx);

    final fill = Paint()..color = NeonPalette.purple.withOpacity(0.2);
    final border = Paint()
      ..color = NeonPalette.cyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawRect(rect, fill);
    canvas.drawRect(rect, border);

    final t = phase;
    final pulseX = rect.left + (rect.width * t);
    canvas.drawCircle(
        Offset(pulseX, rect.top), 5, Paint()..color = NeonPalette.cyan);

    for (final p in [
      rect.topLeft,
      rect.topRight,
      rect.bottomRight,
      rect.bottomLeft
    ]) {
      canvas.drawCircle(p, 6, Paint()..color = NeonPalette.pink);
    }
    canvas.drawCircle(rect.topRight, 10,
        Paint()..color = NeonPalette.purple.withOpacity(0.3));

    final tp = TextPainter(textDirection: TextDirection.ltr);
    tp.text = TextSpan(
      text: isSquare
          ? 'Drag top-right vertex | Side=${length.toStringAsFixed(0)}'
          : 'Drag top-right vertex | L=${length.toStringAsFixed(0)} W=${width.toStringAsFixed(0)}',
      style: const TextStyle(
          color: NeonPalette.subtext,
          fontSize: 13,
          fontWeight: FontWeight.w700),
    );
    tp.layout(maxWidth: size.width - 16);
    tp.paint(canvas, const Offset(10, 8));
  }

  @override
  bool shouldRepaint(covariant _PerimeterGamePainter oldDelegate) {
    return oldDelegate.length != length ||
        oldDelegate.width != width ||
        oldDelegate.isSquare != isSquare ||
        oldDelegate.phase != phase;
  }
}

class _GridTapPainter extends CustomPainter {
  final int cols;
  final int rows;
  final Map<String, int> cellState;

  _GridTapPainter(
      {required this.cols, required this.rows, required this.cellState});

  @override
  void paint(Canvas canvas, Size size) {
    const pad = 26.0;
    final grid =
        Rect.fromLTWH(pad, pad, size.width - pad * 2, size.height - pad * 2);

    final cellW = grid.width / cols;
    final cellH = grid.height / rows;

    final border = Paint()
      ..color = Colors.white.withOpacity(0.28)
      ..style = PaintingStyle.stroke;

    for (int c = 0; c <= cols; c++) {
      final x = grid.left + c * cellW;
      canvas.drawLine(Offset(x, grid.top), Offset(x, grid.bottom), border);
    }
    for (int r = 0; r <= rows; r++) {
      final y = grid.top + r * cellH;
      canvas.drawLine(Offset(grid.left, y), Offset(grid.right, y), border);
    }

    for (final e in cellState.entries) {
      final parts = e.key.split(':');
      if (parts.length != 2) continue;
      final c = int.tryParse(parts[0]) ?? 0;
      final r = int.tryParse(parts[1]) ?? 0;
      final rect = Rect.fromLTWH(
          grid.left + c * cellW, grid.top + r * cellH, cellW, cellH);
      if (e.value == 1) {
        canvas.drawRect(rect.deflate(1),
            Paint()..color = NeonPalette.cyan.withOpacity(0.5));
      }
      if (e.value == 2) {
        final tri = Path()
          ..moveTo(rect.left, rect.bottom)
          ..lineTo(rect.right, rect.bottom)
          ..lineTo(rect.right, rect.top)
          ..close();
        canvas.drawPath(
            tri, Paint()..color = NeonPalette.pink.withOpacity(0.55));
      }
    }

    canvas.drawRect(
      grid,
      Paint()
        ..color = NeonPalette.cyan
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _GridTapPainter oldDelegate) {
    return oldDelegate.cols != cols ||
        oldDelegate.rows != rows ||
        oldDelegate.cellState != cellState;
  }
}

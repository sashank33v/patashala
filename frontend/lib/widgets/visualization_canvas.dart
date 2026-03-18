import 'dart:math' as math;

import 'package:flutter/material.dart';

class VisualizationCanvas extends StatelessWidget {
  final String topicId;
  final Map<String, dynamic> viz;

  const VisualizationCanvas({
    super.key,
    required this.topicId,
    required this.viz,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE0F2FE), Color(0xFFF8FAFC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: CustomPaint(
        painter: _VizPainter(topicId: topicId, viz: viz),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _VizPainter extends CustomPainter {
  final String topicId;
  final Map<String, dynamic> viz;

  _VizPainter({required this.topicId, required this.viz});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2563EB)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    if (topicId.startsWith('trig')) {
      _drawTrig(canvas, size, paint);
      return;
    }
    _drawMensuration(canvas, size, paint);
  }

  void _drawTrig(Canvas canvas, Size size, Paint paint) {
    final simulation = viz['simulation'] as Map<String, dynamic>? ?? {};
    final width = size.width;
    final height = size.height;
    final baseY = height - 40;
    const leftX = 30.0;

    if (topicId == 'trig-right-triangle' || topicId == 'trig-shadow-length') {
      final adjacent = (simulation['adjacent'] ?? simulation['shadow_length'] ?? 8).toDouble();
      final opposite = (simulation['opposite'] ?? simulation['object_height'] ?? 4).toDouble();
      final xScale = (width - 70) / math.max(adjacent, 1);
      final yScale = (height - 80) / math.max(opposite, 1);
      final rightX = leftX + adjacent * xScale;
      final topY = baseY - opposite * yScale;

      final path = Path()
        ..moveTo(leftX, baseY)
        ..lineTo(rightX, baseY)
        ..lineTo(rightX, topY)
        ..close();

      canvas.drawPath(path, paint);
      canvas.drawCircle(Offset(rightX, topY), 6, Paint()..color = const Color(0xFFDC2626));
      return;
    }

    final angle = (simulation['angle'] ?? 45).toDouble();
    final center = Offset(width / 2, height / 2);
    final radius = math.min(width, height) * 0.32;
    final theta = angle * math.pi / 180;
    final end = Offset(center.dx + radius * math.cos(theta), center.dy - radius * math.sin(theta));

    canvas.drawCircle(center, radius, Paint()..color = const Color(0xFF94A3B8)..style = PaintingStyle.stroke);
    canvas.drawLine(center, Offset(center.dx + radius, center.dy), paint..color = const Color(0xFF0F766E));
    canvas.drawLine(center, end, paint..color = const Color(0xFF1D4ED8));
    canvas.drawCircle(end, 6, Paint()..color = const Color(0xFFF97316));
  }

  void _drawMensuration(Canvas canvas, Size size, Paint paint) {
    final simulation = viz['simulation'] as Map<String, dynamic>? ?? {};
    final gridColor = Paint()
      ..color = const Color(0xFF93C5FD)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final length =
        (simulation['length'] ?? simulation['side'] ?? 6).toDouble().clamp(1, 12).toDouble();
    final widthValue =
        (simulation['width'] ?? simulation['side'] ?? 4).toDouble().clamp(1, 12).toDouble();

    const padding = 24.0;
    final usableW = size.width - padding * 2;
    final usableH = size.height - padding * 2;
    final cellSize = math.min(usableW / length, usableH / widthValue);

    final rect = Rect.fromLTWH(
      padding,
      padding,
      cellSize * length,
      cellSize * widthValue,
    );

    for (int i = 0; i <= length; i++) {
      final x = rect.left + (i * cellSize);
      canvas.drawLine(Offset(x, rect.top), Offset(x, rect.bottom), gridColor);
    }
    for (int i = 0; i <= widthValue; i++) {
      final y = rect.top + (i * cellSize);
      canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), gridColor);
    }

    canvas.drawRect(rect, paint..color = const Color(0xFF0F766E));
  }

  @override
  bool shouldRepaint(covariant _VizPainter oldDelegate) {
    return oldDelegate.viz != viz || oldDelegate.topicId != topicId;
  }
}

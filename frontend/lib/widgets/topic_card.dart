import 'dart:math';

import 'package:flutter/material.dart';

import 'neon_ui.dart';

class TopicCard extends StatelessWidget {
  final Map<String, dynamic> topic;
  final int index;
  final VoidCallback onTap;

  const TopicCard({super.key, required this.topic, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final subtextColor = AdaptiveColors.subtext(context);
    final gradients = [
      [const Color(0xFF7C3AED), const Color(0xFF06B6D4)],
      [const Color(0xFFEC4899), const Color(0xFF7C3AED)],
      [const Color(0xFF06B6D4), const Color(0xFF0EA5E9)],
      [const Color(0xFF9333EA), const Color(0xFFEC4899)],
    ];
    final g = gradients[index % gradients.length];

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 280 + index * 80),
      builder: (context, value, child) => Transform.translate(
        offset: Offset(0, 18 * (1 - value)),
        child: Opacity(opacity: value, child: child),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GlassCard(
          onTap: onTap,
          child: Row(
            children: [
              Container(
                width: 92,
                height: 76,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(colors: g),
                ),
                child: CustomPaint(
                  painter: _TopicPreviewPainter(seed: index),
                  child: const SizedBox.expand(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(topic['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(topic['description'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: subtextColor, fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _badge(context, topic['difficulty']?.toString() ?? 'Beginner'),
                        const SizedBox(width: 8),
                        Text(topic['duration']?.toString() ?? '${8 + (index % 5)} min', style: TextStyle(color: AdaptiveColors.isDark(context) ? NeonPalette.cyan : const Color(0xFF0E7490), fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: subtextColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(BuildContext context, String text) {
    final textColor = AdaptiveColors.text(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).brightness == Brightness.dark ? Colors.white12 : const Color(0x22111827),
      ),
      child: Text(text, style: TextStyle(fontSize: 11, color: textColor)),
    );
  }
}

class _TopicPreviewPainter extends CustomPainter {
  final int seed;

  _TopicPreviewPainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white70..style = PaintingStyle.stroke..strokeWidth = 1.8;
    final path = Path();
    for (double x = 0; x <= size.width; x++) {
      final y = size.height / 2 + sin((x / size.width * pi * (2 + (seed % 3)))) * 14;
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, p);
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.4), 4, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _TopicPreviewPainter oldDelegate) => oldDelegate.seed != seed;
}

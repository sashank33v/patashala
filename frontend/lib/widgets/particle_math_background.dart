import 'dart:math';

import 'package:flutter/material.dart';

class ParticleMathBackground extends StatefulWidget {
  final Widget child;

  const ParticleMathBackground({super.key, required this.child});

  @override
  State<ParticleMathBackground> createState() => _ParticleMathBackgroundState();
}

class _ParticleMathBackgroundState extends State<ParticleMathBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final _symbols = const ['sin', 'cos', 'tan', 'π', 'θ'];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 16))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _MathParticlesPainter(progress: _controller.value, symbols: _symbols),
          child: widget.child,
        );
      },
    );
  }
}

class _MathParticlesPainter extends CustomPainter {
  final double progress;
  final List<String> symbols;

  _MathParticlesPainter({required this.progress, required this.symbols});

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(42);
    for (int i = 0; i < 26; i++) {
      final seedX = rand.nextDouble();
      final seedY = rand.nextDouble();
      final y = (seedY * size.height + (progress * 90) + i * 7) % size.height;
      final x = (seedX * size.width + sin((progress + i) * pi * 2) * 20);
      final t = TextPainter(
        text: TextSpan(
          text: symbols[i % symbols.length],
          style: TextStyle(
            color: Colors.white.withOpacity(0.04 + (i % 4) * 0.03),
            fontSize: 12 + (i % 3) * 5,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      t.paint(canvas, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(covariant _MathParticlesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

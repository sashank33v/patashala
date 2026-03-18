import 'package:flutter/material.dart';

class FunBackground extends StatelessWidget {
  final Widget child;

  const FunBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE0F7FA), Color(0xFFFFF8E1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -30,
            child: _blob(const Color(0xFFBAE6FD), 140),
          ),
          Positioned(
            left: -20,
            bottom: 40,
            child: _blob(const Color(0xFFFDE68A), 120),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }

  Widget _blob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.55),
        borderRadius: BorderRadius.circular(size / 2),
      ),
    );
  }
}

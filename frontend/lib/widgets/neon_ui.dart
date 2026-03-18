import 'dart:ui';

import 'package:flutter/material.dart';

class NeonPalette {
  static const bg = Color(0xFF0A0E1A);
  static const panel = Color(0xFF111827);
  static const purple = Color(0xFF7C3AED);
  static const cyan = Color(0xFF06B6D4);
  static const pink = Color(0xFFEC4899);
  static const text = Color(0xFFE5E7EB);
  static const subtext = Color(0xFF94A3B8);
}

class MeshBackground extends StatelessWidget {
  final Widget child;

  const MeshBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF090D18), Color(0xFF10192B), Color(0xFF110F22)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(top: -120, left: -60, child: _orb(260, NeonPalette.purple.withOpacity(0.25))),
          Positioned(top: 180, right: -80, child: _orb(240, NeonPalette.cyan.withOpacity(0.22))),
          Positioned(bottom: -100, left: 120, child: _orb(280, NeonPalette.pink.withOpacity(0.20))),
          Positioned.fill(child: child),
        ],
      ),
    );
  }

  Widget _orb(double size, Color color) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
            gradient: LinearGradient(
              colors: [Colors.white.withOpacity(0.13), Colors.white.withOpacity(0.04)],
            ),
          ),
          padding: padding,
          child: child,
        ),
      ),
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: content,
      ),
    );
  }
}

class NeonButton extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;

  const NeonButton({super.key, required this.onTap, required this.child});

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(colors: [NeonPalette.purple, NeonPalette.cyan]),
            boxShadow: [
              BoxShadow(color: NeonPalette.purple.withOpacity(0.45), blurRadius: 16, spreadRadius: 1),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: DefaultTextStyle(
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

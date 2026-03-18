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

class AdaptiveColors {
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color text(BuildContext context) =>
      isDark(context) ? NeonPalette.text : const Color(0xFF111827);

  static Color subtext(BuildContext context) =>
      isDark(context) ? NeonPalette.subtext : Colors.black;
}

class MeshBackground extends StatelessWidget {
  final Widget child;

  const MeshBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF090D18), Color(0xFF10192B), Color(0xFF110F22)]
              : const [Color(0xFFFFEFF6), Color(0xFFFFE4F1), Color(0xFFFFF1F8)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
              top: -120,
              left: -60,
              child: _orb(
                  260, NeonPalette.purple.withOpacity(isDark ? 0.25 : 0.15))),
          Positioned(
              top: 180,
              right: -80,
              child: _orb(
                  240, NeonPalette.cyan.withOpacity(isDark ? 0.22 : 0.14))),
          Positioned(
              bottom: -100,
              left: 120,
              child: _orb(
                  280, NeonPalette.pink.withOpacity(isDark ? 0.20 : 0.12))),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final content = ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.15)
                    : const Color(0x330F172A)),
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      Colors.white.withOpacity(0.13),
                      Colors.white.withOpacity(0.04)
                    ]
                  : [
                      const Color(0xFFFFF2F8).withOpacity(0.94),
                      const Color(0xFFFFE8F3).withOpacity(0.88)
                    ],
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
            gradient: const LinearGradient(
                colors: [NeonPalette.purple, NeonPalette.cyan]),
            boxShadow: [
              BoxShadow(
                  color: NeonPalette.purple.withOpacity(0.45),
                  blurRadius: 16,
                  spreadRadius: 1),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: DefaultTextStyle(
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'neon_ui.dart';

class MobileShell extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final int navIndex;
  final ValueChanged<int>? onNavTap;

  const MobileShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.navIndex = 0,
    this.onNavTap,
  });

  @override
  Widget build(BuildContext context) {
    return MeshBackground(
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390, minWidth: 320),
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF020B22).withOpacity(0.95),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white10),
                boxShadow: [
                  BoxShadow(color: NeonPalette.purple.withOpacity(0.18), blurRadius: 24, spreadRadius: 1),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                      gradient: LinearGradient(
                        colors: [Colors.white.withOpacity(0.04), Colors.transparent],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_back, size: 18, color: NeonPalette.subtext),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                              Text(subtitle, style: const TextStyle(color: NeonPalette.subtext, fontSize: 12.5)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: child)),
                  _BottomNav(index: navIndex, onTap: onNavTap),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int>? onTap;

  const _BottomNav({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_outlined, 'Home'),
      (Icons.menu, 'Topics'),
      (Icons.diamond_outlined, 'Simulate'),
      (Icons.adjust, 'Progress'),
    ];
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 6, 10, 10),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
        color: Colors.white.withOpacity(0.02),
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final active = i == index;
          return Expanded(
            child: GestureDetector(
              onTap: onTap == null ? null : () => onTap!(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: active ? Colors.white10 : Colors.transparent,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(items[i].$1, size: 16, color: active ? Colors.white : NeonPalette.subtext),
                    const SizedBox(height: 2),
                    Text(items[i].$2, style: TextStyle(fontSize: 10.5, color: active ? Colors.white : NeonPalette.subtext)),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

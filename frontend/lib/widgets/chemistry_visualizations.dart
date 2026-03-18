import 'package:flutter/material.dart';
import 'neon_ui.dart';

class ReactionVisualizer extends StatefulWidget {
  const ReactionVisualizer({super.key});

  @override
  State<ReactionVisualizer> createState() => _ReactionVisualizerState();
}

class _ReactionVisualizerState extends State<ReactionVisualizer> {
  double progress = 0.45;
  double temperature = 23;

  @override
  Widget build(BuildContext context) {
    final textColor = AdaptiveColors.text(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                      child: Text('Reaction progress',
                          style: TextStyle(
                              color: textColor, fontWeight: FontWeight.w700))),
                  Text('${(progress * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(color: NeonPalette.cyan)),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 22,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white10,
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [NeonPalette.purple, NeonPalette.cyan],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text('Reaction rate vs temperature',
            style: TextStyle(color: textColor)),
        Slider(
          value: temperature,
          min: 10,
          max: 60,
          divisions: 10,
          label: '${temperature.toStringAsFixed(1)}°C',
          onChanged: (v) => setState(() => temperature = v),
        ),
        const SizedBox(height: 4),
        GlassCard(
          child: Column(
            children: [
              Text('Temperature: ${temperature.toStringAsFixed(1)}°C',
                  style: TextStyle(color: textColor)),
              const SizedBox(height: 8),
              Text(
                  'Activation energy impact: ${(temperature / 60).toStringAsFixed(2)}',
                  style: const TextStyle(color: NeonPalette.pink)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text('Adjust progress', style: TextStyle(color: textColor)),
        Slider(
          value: progress,
          min: 0,
          max: 1,
          onChanged: (v) => setState(() => progress = v),
        ),
      ],
    );
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'neon_ui.dart';

class ReactionKineticsVisualizer extends StatefulWidget {
  const ReactionKineticsVisualizer({super.key});

  @override
  State<ReactionKineticsVisualizer> createState() => _ReactionKineticsVisualizerState();
}

class _ReactionKineticsVisualizerState extends State<ReactionKineticsVisualizer>
    with SingleTickerProviderStateMixin {
  double concentration = 0.5;
  double temperature = 25;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get rate => (0.2 + concentration * temperature / 150) * 0.8;

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
                      child: Text('Reaction kinetics',
                          style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w700))),
                  Text('${(rate * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(color: NeonPalette.cyan)),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 160,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) => CustomPaint(
                    painter: _ReactionPainter(progress: _controller.value, rate: rate),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _inputControl('Concentration', concentration.toStringAsFixed(2), () {}),
        Slider(value: concentration, min: 0.1, max: 1.0, onChanged: (v) => setState(() => concentration = v)),
        _inputControl('Temperature (°C)', temperature.toStringAsFixed(1), () {}),
        Slider(value: temperature, min: 10, max: 60, onChanged: (v) => setState(() => temperature = v)),
      ],
    );
  }

  Widget _inputControl(String label, String value, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: AdaptiveColors.text(context))),
        Text(value, style: TextStyle(color: AdaptiveColors.text(context), fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _ReactionPainter extends CustomPainter {
  final double progress;
  final double rate;

  _ReactionPainter({required this.progress, required this.rate});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        colors: [NeonPalette.purple.withOpacity(0.2), NeonPalette.cyan.withOpacity(0.7)],
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    final rect = Rect.fromLTWH(0, size.height * (1 - rate), size.width, size.height * rate);
    canvas.drawRect(rect, paint);
    final bubbles = rate * 6;
    for (int i = 0; i < bubbles; i++) {
      final x = (i + progress) % 1 * size.width;
      final y = size.height - (rate * size.height) * (i + 1) / bubbles;
      canvas.drawCircle(Offset(x, y), 6, Paint()..color = Colors.white.withOpacity(0.6));
    }
  }

  @override
  bool shouldRepaint(covariant _ReactionPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.rate != rate;
  }
}

class EquilibriumVisualizer extends StatefulWidget {
  const EquilibriumVisualizer({super.key});

  @override
  State<EquilibriumVisualizer> createState() => _EquilibriumVisualizerState();
}

class _EquilibriumVisualizerState extends State<EquilibriumVisualizer> {
  double stress = 0.5;

  @override
  Widget build(BuildContext context) {
    final textColor = AdaptiveColors.text(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassCard(
          child: Row(
            children: [
              Expanded(child: Text('Equilibrium vessel', style: TextStyle(color: textColor, fontWeight: FontWeight.w700))),
              Text('${(stress * 100).toStringAsFixed(0)}% stress', style: const TextStyle(color: NeonPalette.pink)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: CustomPaint(
            painter: _EquilibriumPainter(stress: stress),
            child: const SizedBox.expand(),
          ),
        ),
        const SizedBox(height: 10),
        Text('Apply stress to volume or temperature sliders:', style: TextStyle(color: textColor)),
        Slider(value: stress, min: 0, max: 1, onChanged: (v) => setState(() => stress = v)),
      ],
    );
  }
}

class MolarityLabVisualizer extends StatefulWidget {
  const MolarityLabVisualizer({super.key});

  @override
  State<MolarityLabVisualizer> createState() => _MolarityLabVisualizerState();
}

class _MolarityLabVisualizerState extends State<MolarityLabVisualizer> {
  double molarity = 0.7;
  double volume = 250;

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
              Text('Molarity Lab', style: TextStyle(color: textColor, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: CustomPaint(
                  painter: _MolarityPainter(molarity: molarity),
                  child: const SizedBox.expand(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text('Concentration: ${molarity.toStringAsFixed(2)} mol/L', style: TextStyle(color: textColor)),
        Slider(value: molarity, min: 0.1, max: 1.2, onChanged: (v) => setState(() => molarity = v)),
        Text('Volume: ${volume.toStringAsFixed(0)} mL', style: TextStyle(color: textColor)),
        Slider(value: volume, min: 100, max: 500, onChanged: (v) => setState(() => volume = v)),
      ],
    );
  }
}

class _MolarityPainter extends CustomPainter {
  final double molarity;

  _MolarityPainter({required this.molarity});

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()..shader = LinearGradient(colors: [NeonPalette.cyan.withOpacity(0.1), NeonPalette.purple.withOpacity(0.2)]).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), background);
    final particles = (molarity * 60).toInt();
    final rnd = Random(0);
    for (int i = 0; i < particles; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = size.height * (0.2 + rnd.nextDouble() * 0.6);
      canvas.drawCircle(Offset(x, y), 5 + molarity * 3, Paint()..color = NeonPalette.pink.withOpacity(0.8));
    }
    canvas.drawLine(Offset(0, size.height * 0.9), Offset(size.width, size.height * 0.9), Paint()..color = Colors.white.withOpacity(0.4));
    canvas.drawLine(Offset(size.width * 0.3, size.height * 0.9), Offset(size.width * 0.3, size.height * 0.8), Paint()..color = Colors.white.withOpacity(0.4));
    canvas.drawLine(Offset(size.width * 0.7, size.height * 0.9), Offset(size.width * 0.7, size.height * 0.8), Paint()..color = Colors.white.withOpacity(0.4));
  }

  @override
  bool shouldRepaint(covariant _MolarityPainter oldDelegate) {
    return oldDelegate.molarity != molarity;
  }
}

class SpectroscopyVisualizer extends StatefulWidget {
  const SpectroscopyVisualizer({super.key});

  @override
  State<SpectroscopyVisualizer> createState() =>
      _SpectroscopyVisualizerState();
}

class _SpectroscopyVisualizerState extends State<SpectroscopyVisualizer> {
  double wavelength = 540;
  double intensity = 0.7;

  @override
  Widget build(BuildContext context) {
    final textColor = AdaptiveColors.text(context);
    final bandColor = HSVColor.fromAHSV(
            1, (wavelength - 380) / 400 * 260, 0.9, 0.95)
        .toColor();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Spectroscopy Curve',
                  style:
                      TextStyle(color: textColor, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              SizedBox(
                height: 220,
                child: CustomPaint(
                  painter: _SpectrumPainter(
                    wavelength: wavelength,
                    intensity: intensity,
                    baseColor: bandColor,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text('Wavelength: ${wavelength.toStringAsFixed(0)} nm',
            style: TextStyle(color: textColor)),
        Slider(
          value: wavelength,
          min: 380,
          max: 780,
          divisions: 40,
          onChanged: (v) => setState(() => wavelength = v),
        ),
        Text('Intensity: ${(intensity * 100).toInt()}%',
            style: TextStyle(color: textColor)),
        Slider(
          value: intensity,
          min: 0.1,
          max: 1.0,
          onChanged: (v) => setState(() => intensity = v),
        ),
      ],
    );
  }
}

class _SpectrumPainter extends CustomPainter {
  final double wavelength;
  final double intensity;
  final Color baseColor;

  _SpectrumPainter({
    required this.wavelength,
    required this.intensity,
    required this.baseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final bg = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF0B1222),
          const Color(0xFF111B36),
          const Color(0xFF0B1222),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);
    canvas.drawRect(rect, bg);

    final bandWidth = size.width * (intensity * 0.25 + 0.1);
    final center = size.width / 2;
    final bandX = center +
        (wavelength - 550) / 400 * (size.width - bandWidth) -
        (bandWidth / 2);

    final band = Paint()
      ..shader = LinearGradient(
        colors: [
          baseColor.withOpacity(0),
          baseColor.withOpacity(0.7),
          baseColor.withOpacity(1.0),
          baseColor.withOpacity(0.7),
          baseColor.withOpacity(0),
        ],
      ).createShader(Rect.fromLTWH(bandX, 0, bandWidth, size.height));

    canvas.drawRect(
        Rect.fromLTWH(bandX, 0, bandWidth, size.height), band);

    final dots = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 7; i++) {
      final x = bandX + bandWidth * i / 6;
      final y = size.height * 0.15 +
          (i.isEven ? size.height * 0.2 : size.height * 0.35);
      canvas.drawCircle(Offset(x, y), 6 * intensity, dots);
    }
  }

  @override
  bool shouldRepaint(covariant _SpectrumPainter oldDelegate) {
    return oldDelegate.wavelength != wavelength ||
        oldDelegate.intensity != intensity ||
        oldDelegate.baseColor != baseColor;
  }
}

class _EquilibriumPainter extends CustomPainter {
  final double stress;

  _EquilibriumPainter({required this.stress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.08);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width / 2 - 4, size.height), paint);
    canvas.drawRect(Rect.fromLTWH(size.width / 2 + 4, 0, size.width / 2 - 4, size.height), paint);
    final gradient = Paint()
      ..shader = LinearGradient(colors: [NeonPalette.cyan, NeonPalette.purple]).createShader(Rect.fromLTWH(0, size.height * (1 - stress), size.width / 2 - 4, size.height * stress));
    canvas.drawRect(Rect.fromLTWH(0, size.height * (1 - stress), size.width / 2 - 4, size.height * stress), gradient);
    canvas.drawRect(Rect.fromLTWH(size.width / 2 + 4, size.height * stress * 0.2, size.width / 2 - 4, size.height * (0.7 - stress * 0.2)), gradient);
  }

  @override
  bool shouldRepaint(covariant _EquilibriumPainter oldDelegate) {
    return oldDelegate.stress != stress;
  }
}

import 'package:flutter/material.dart';

import '../api_service.dart';
import '../widgets/neon_ui.dart';
import '../widgets/visualization_canvas.dart';
import 'quiz_screen.dart';

class SimulationScreen extends StatefulWidget {
  final int userId;
  final Map<String, dynamic> topic;

  const SimulationScreen({super.key, required this.userId, required this.topic});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  final Map<String, dynamic> _params = {};
  Map<String, dynamic>? _payload;
  List<Map<String, dynamic>> _presets = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPresets();
    _loadData();
  }

  Future<void> _loadPresets() async {
    try {
      final data = await ApiService.fetchPresets(widget.topic['id']);
      if (!mounted) return;
      setState(() => _presets = data);
    } catch (_) {}
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final data = await ApiService.fetchVisualization(widget.topic['id'], params: _params);
    if (!mounted) return;
    setState(() {
      _payload = data;
      _loading = false;
      final controls = (data['visualization']['controls'] as List<dynamic>);
      for (final control in controls) {
        final id = control['id'] as String;
        _params.putIfAbsent(id, () => control['value']);
      }
    });
  }

  Future<void> _updateParam(String id, dynamic value) async {
    _params[id] = value;
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simulation Lab')),
      body: MeshBackground(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _payload == null
                ? const Center(child: Text('No simulation data'))
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        GlassCard(
                          child: SizedBox(
                            height: 220,
                            child: VisualizationCanvas(
                              topicId: widget.topic['id'],
                              viz: _payload!['visualization'] as Map<String, dynamic>,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: ListView(
                            children: [
                              if (_presets.isNotEmpty) ...[
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _presets.map((preset) {
                                    final label = (preset['label'] ?? 'Preset').toString();
                                    final params = Map<String, dynamic>.from((preset['params'] as Map?) ?? {});
                                    return ActionChip(
                                      avatar: const Icon(Icons.flash_on, size: 16),
                                      label: Text(label),
                                      onPressed: () async {
                                        _params
                                          ..clear()
                                          ..addAll(params);
                                        await _loadData();
                                      },
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 10),
                              ],
                              ..._buildControls(_payload!['visualization']['controls'] as List<dynamic>),
                              GlassCard(
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: (_payload!['visualization']['simulation'] as Map<String, dynamic>)
                                      .entries
                                      .map((e) => Chip(label: Text('${e.key}: ${e.value}')))
                                      .toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: NeonButton(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => QuizScreen(userId: widget.userId, topic: widget.topic)),
                            ),
                            child: const Center(child: Text('Start Mini Quiz')),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  List<Widget> _buildControls(List<dynamic> controls) {
    final widgets = <Widget>[];
    for (final control in controls) {
      final id = control['id'] as String;
      final type = control['type'] as String;
      if (type == 'slider') {
        final min = (control['min'] as num).toDouble();
        final max = (control['max'] as num).toDouble();
        final rawValue = (_params[id] ?? control['value']) as num;
        final value = rawValue.toDouble();

        widgets.add(
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${id.replaceAll('_', ' ')}: ${value.toStringAsFixed(1)}'),
                Slider(value: value.clamp(min, max), min: min, max: max, divisions: (max - min).toInt(), onChanged: (newValue) => _updateParam(id, newValue)),
              ],
            ),
          ),
        );
        widgets.add(const SizedBox(height: 8));
      }
      if (type == 'choice') {
        final options = (control['options'] as List<dynamic>).cast<String>();
        final current = (_params[id] ?? control['value']).toString();
        widgets.add(
          GlassCard(
            child: DropdownButton<String>(
              isExpanded: true,
              value: current,
              items: options.map((opt) => DropdownMenuItem<String>(value: opt, child: Text(opt))).toList(),
              onChanged: (value) {
                if (value != null) _updateParam(id, value);
              },
            ),
          ),
        );
        widgets.add(const SizedBox(height: 8));
      }
    }
    return widgets;
  }
}

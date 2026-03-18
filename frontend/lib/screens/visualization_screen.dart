import 'package:flutter/material.dart';

import '../api_service.dart';
import '../widgets/mensuration_visualizations.dart';
import '../widgets/neon_ui.dart';
import '../widgets/trig_visualizations.dart';
import 'quiz_screen.dart';

class VisualizationScreen extends StatefulWidget {
  final int userId;
  final Map<String, dynamic> topic;

  const VisualizationScreen({super.key, required this.userId, required this.topic});

  @override
  State<VisualizationScreen> createState() => _VisualizationScreenState();
}

class _VisualizationScreenState extends State<VisualizationScreen> {
  bool completed = false;

  @override
  Widget build(BuildContext context) {
    final id = widget.topic['id'].toString();
    final isMens = id.startsWith('mens-');

    return Scaffold(
      appBar: AppBar(title: Text(widget.topic['title']?.toString() ?? 'Visualization')),
      body: MeshBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.topic['title']?.toString() ?? '', style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Text(widget.topic['description']?.toString() ?? 'Interactive explorer', style: const TextStyle(color: NeonPalette.subtext)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                GlassCard(
                  child: isMens
                      ? MensurationVisualizationHub(topicId: id)
                      : TrigVisualizationHub(topicId: id),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: NeonButton(
                        onTap: () async {
                          if (!id.contains('tangent') && !id.contains('interference')) {
                            await ApiService.postProgress(userId: widget.userId, topic: id, completed: true);
                          }
                          if (!mounted) return;
                          setState(() => completed = true);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(completed ? Icons.check_circle : Icons.flag, size: 18),
                            const SizedBox(width: 8),
                            Text(completed ? 'Completed' : 'Mark Complete'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: NeonButton(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => QuizScreen(userId: widget.userId, topic: widget.topic)),
                        ),
                        child: const Center(child: Text('Mini Quiz')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

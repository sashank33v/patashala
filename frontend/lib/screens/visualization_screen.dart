import 'package:flutter/material.dart';

import '../api_service.dart';
import '../services/app_strings.dart';
import '../widgets/mensuration_visualizations.dart';
import '../widgets/neon_ui.dart';
import '../widgets/trig_visualizations.dart';
import 'quiz_screen.dart';

class VisualizationScreen extends StatefulWidget {
  final int userId;
  final Map<String, dynamic> topic;

  const VisualizationScreen(
      {super.key, required this.userId, required this.topic});

  @override
  State<VisualizationScreen> createState() => _VisualizationScreenState();
}

class _VisualizationScreenState extends State<VisualizationScreen> {
  bool completed = false;

  @override
  Widget build(BuildContext context) {
    final id = widget.topic['id'].toString();
    final isMens = id.startsWith('mens-');
    final notes = _notesForTopic(id);
    final subtextColor = AdaptiveColors.subtext(context);

    return Scaffold(
      appBar: AppBar(
          title: Text(widget.topic['title']?.toString() ?? 'Visualization')),
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
                      Text(widget.topic['title']?.toString() ?? '',
                          style: const TextStyle(
                              fontSize: 23, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Text(
                          widget.topic['description']?.toString() ??
                              'Interactive explorer',
                          style: TextStyle(color: subtextColor)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth > 980;
                    final viBoard = GlassCard(
                      child: isMens
                          ? MensurationVisualizationHub(topicId: id)
                          : TrigVisualizationHub(topicId: id),
                    );
                    final noteBoard = GlassCard(
                      child: _NotesPanel(
                          topicTitle:
                              widget.topic['title']?.toString() ?? 'Topic',
                          notes: notes),
                    );

                    if (!wide) {
                      return Column(
                        children: [
                          viBoard,
                          const SizedBox(height: 10),
                          noteBoard,
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: viBoard),
                        const SizedBox(width: 12),
                        Expanded(flex: 2, child: noteBoard),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: NeonButton(
                        onTap: () async {
                          if (!id.contains('tangent') &&
                              !id.contains('interference')) {
                            await ApiService.postProgress(
                                userId: widget.userId,
                                topic: id,
                                completed: true);
                          }
                          if (!mounted) return;
                          setState(() => completed = true);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(completed ? Icons.check_circle : Icons.flag,
                                size: 18),
                            const SizedBox(width: 8),
                            Text(completed
                                ? AppStrings.t('completed')
                                : AppStrings.t('mark_complete')),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: NeonButton(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => QuizScreen(
                                  userId: widget.userId, topic: widget.topic)),
                        ),
                        child: Center(child: Text(AppStrings.t('mini_quiz'))),
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

  List<String> _notesForTopic(String topicId) {
    switch (topicId) {
      case 'trig-right-triangle':
        return [
          'A right triangle has one 90° angle.',
          'Opposite side is across the selected angle.',
          'Adjacent side is next to the selected angle.',
          'Hypotenuse is the longest side.',
        ];
      case 'trig-sine-cosine':
        return [
          'Sine tells vertical movement on the circle.',
          'Cosine tells horizontal movement on the circle.',
          'As angle changes, graph values change smoothly.',
        ];
      case 'trig-angle-rotation':
        return [
          'Move angle with slider/buttons/play to rotate the arm.',
          'Watch how sin/cos/tan values update in real time.',
          'Quadrants change the sign (+/-) of values.',
        ];
      case 'trig-shadow-length':
        return [
          'Larger sun angle usually gives shorter shadow.',
          'Lower sun angle gives longer shadow.',
          'Formula relation: shadow = height / tan(θ).',
        ];
      case 'mens-rectangle-area':
        return [
          'Rectangle area = length × width.',
          'Drag handle or sliders to resize shape.',
          'Grid helps count square units visually.',
        ];
      case 'mens-square-area':
        return [
          'Square has all sides equal.',
          'Area = side × side.',
          'Changing one side updates all edges.',
        ];
      case 'mens-perimeter':
        return [
          'Perimeter means total outer boundary.',
          'Rectangle: 2 × (length + width).',
          'Square: 4 × side.',
        ];
      case 'mens-grid-area':
        return [
          'Tap cells to mark full and half squares.',
          'Area = full squares + half squares / 2.',
          'Use this method for irregular boundaries too.',
        ];
      default:
        return [
          'Use controls to change values.',
          'Observe how the visual changes.',
          'Try quiz after understanding the pattern.',
        ];
    }
  }
}

class _NotesPanel extends StatelessWidget {
  final String topicTitle;
  final List<String> notes;

  const _NotesPanel({required this.topicTitle, required this.notes});

  @override
  Widget build(BuildContext context) {
    final titleColor = AdaptiveColors.text(context);
    final subtextColor = AdaptiveColors.subtext(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.t('reading_notes'),
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w900, color: titleColor)),
        const SizedBox(height: 6),
        Text(topicTitle,
            style: TextStyle(color: subtextColor, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        ...notes.asMap().entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white10
                            : const Color(0x220F172A),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Text('${e.key + 1}',
                          style: TextStyle(
                              fontSize: 12,
                              color: titleColor,
                              fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(e.value,
                            style:
                                TextStyle(color: subtextColor, height: 1.35))),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}

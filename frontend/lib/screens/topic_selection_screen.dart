import 'package:flutter/material.dart';

import '../api_service.dart';
import '../widgets/neon_ui.dart';
import '../widgets/topic_card.dart';
import 'visualization_screen.dart';

class TopicSelectionScreen extends StatefulWidget {
  final int userId;
  final String? recommendedTopic;

  const TopicSelectionScreen({super.key, required this.userId, this.recommendedTopic});

  @override
  State<TopicSelectionScreen> createState() => _TopicSelectionScreenState();
}

class _TopicSelectionScreenState extends State<TopicSelectionScreen> {
  late Future<List<Map<String, dynamic>>> _topics;
  String filter = 'All';

  @override
  void initState() {
    super.initState();
    _topics = ApiService.fetchTopics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Topic')),
      body: MeshBackground(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _topics,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }

            final all = [...snapshot.data!];
            all.addAll([
              {'id': 'trig-tangent-function', 'title': 'Tangent Function', 'description': 'Asymptotes and undefined points', 'subject': 'Trigonometry', 'difficulty': 'Intermediate', 'duration': '10 min'},
              {'id': 'trig-wave-interference', 'title': 'Wave Interference', 'description': 'Constructive vs destructive waves', 'subject': 'Trigonometry', 'difficulty': 'Advanced', 'duration': '12 min'},
            ]);

            final filtered = filter == 'All' ? all : all.where((t) => t['subject'] == filter).toList();

            return Column(
              children: [
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      _filterChip('All'),
                      const SizedBox(width: 8),
                      _filterChip('Trigonometry'),
                      const SizedBox(width: 8),
                      _filterChip('Mensuration'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) => TopicCard(
                      topic: filtered[i],
                      index: i,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => VisualizationScreen(userId: widget.userId, topic: filtered[i])),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _filterChip(String label) {
    final active = filter == label;
    return ChoiceChip(
      label: Text(label),
      selected: active,
      selectedColor: NeonPalette.purple.withOpacity(0.35),
      backgroundColor: Colors.white10,
      onSelected: (_) => setState(() => filter = label),
    );
  }
}

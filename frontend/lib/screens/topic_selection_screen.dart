import 'package:flutter/material.dart';

import '../api_service.dart';
import '../services/app_strings.dart';
import '../widgets/neon_ui.dart';
import '../widgets/topic_card.dart';
import 'visualization_screen.dart';

class TopicSelectionScreen extends StatefulWidget {
  final int userId;
  final String? recommendedTopic;

  const TopicSelectionScreen(
      {super.key, required this.userId, this.recommendedTopic});

  @override
  State<TopicSelectionScreen> createState() => _TopicSelectionScreenState();
}

class _TopicSelectionScreenState extends State<TopicSelectionScreen> {
  late Future<List<Map<String, dynamic>>> _topics;
  String filter = 'All';
  String? selectedSubject;

  @override
  void initState() {
    super.initState();
    _topics = ApiService.fetchTopics();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = AdaptiveColors.text(context);
    final subtextColor = AdaptiveColors.subtext(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(selectedSubject == null
            ? AppStrings.t('choose_subject')
            : AppStrings.t('choose_topic_subject')
                .replaceFirst('{subject}', selectedSubject!)),
      ),
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
              {
                'id': 'trig-tangent-function',
                'title': 'Tangent Function',
                'description': 'Asymptotes and undefined points',
                'subject': 'Trigonometry',
                'difficulty': 'Intermediate',
                'duration': '10 min'
              },
              {
                'id': 'trig-wave-interference',
                'title': 'Wave Interference',
                'description': 'Constructive vs destructive waves',
                'subject': 'Trigonometry',
                'difficulty': 'Advanced',
                'duration': '12 min'
              },
            ]);

            final filtered = filter == 'All'
                ? all
                : all.where((t) => t['subject'] == filter).toList();

            if (selectedSubject == null) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.t('select_subject'),
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: textColor)),
                        const SizedBox(height: 6),
                        Text(AppStrings.t('subject_pick_desc'),
                            style: TextStyle(color: subtextColor)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _subjectCard(
                    title: AppStrings.t('subject_maths'),
                    subtitle: AppStrings.t('maths_subtitle'),
                    gradient: const [NeonPalette.purple, NeonPalette.cyan],
                    icon: Icons.calculate_rounded,
                    onTap: () => setState(() => selectedSubject = 'Maths'),
                  ),
                  const SizedBox(height: 10),
                  _subjectCard(
                    title: AppStrings.t('subject_chemistry'),
                    subtitle: AppStrings.t('chem_subtitle'),
                    gradient: const [Color(0xFF0EA5E9), Color(0xFF22C55E)],
                    icon: Icons.science_rounded,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppStrings.t('chem_coming'))),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _subjectCard(
                    title: AppStrings.t('subject_physics'),
                    subtitle: AppStrings.t('physics_subtitle'),
                    gradient: const [Color(0xFFF97316), Color(0xFFEC4899)],
                    icon: Icons.bolt_rounded,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppStrings.t('physics_coming'))),
                      );
                    },
                  ),
                ],
              );
            }

            if (selectedSubject != 'Maths') {
              return Center(
                child: Text(AppStrings.t('select_maths_hint'),
                    style: TextStyle(color: textColor)),
              );
            }

            return Column(
              children: [
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => setState(() {
                          selectedSubject = null;
                          filter = 'All';
                        }),
                        icon: const Icon(Icons.arrow_back, size: 16),
                        label: Text(AppStrings.t('subjects')),
                      ),
                      const SizedBox(width: 8),
                      _filterChip('All', AppStrings.t('filter_all')),
                      const SizedBox(width: 8),
                      _filterChip(
                          'Trigonometry', AppStrings.t('filter_trigonometry')),
                      const SizedBox(width: 8),
                      _filterChip(
                          'Mensuration', AppStrings.t('filter_mensuration')),
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
                        MaterialPageRoute(
                            builder: (_) => VisualizationScreen(
                                userId: widget.userId, topic: filtered[i])),
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

  Widget _filterChip(String value, String label) {
    final active = filter == value;
    return ChoiceChip(
      label: Text(label),
      selected: active,
      selectedColor: NeonPalette.purple.withOpacity(0.35),
      backgroundColor: Colors.white10,
      onSelected: (_) => setState(() => filter = value),
    );
  }

  Widget _subjectCard({
    required String title,
    required String subtitle,
    required List<Color> gradient,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(colors: gradient),
          boxShadow: [
            BoxShadow(color: gradient.first.withOpacity(0.30), blurRadius: 16)
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.black.withOpacity(0.18),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}

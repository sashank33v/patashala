import 'package:flutter/material.dart';

import '../api_service.dart';
import '../widgets/neon_ui.dart';
import '../widgets/topic_card.dart';
import 'visualization_screen.dart';

class TopicSelectionScreen extends StatefulWidget {
  final int userId;
  final String? recommendedTopic;
  final String? initialSubject;

  const TopicSelectionScreen({
    super.key,
    required this.userId,
    this.recommendedTopic,
    this.initialSubject,
  });

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
    selectedSubject = widget.initialSubject;
  }

  @override
  Widget build(BuildContext context) {
    final textColor = AdaptiveColors.text(context);
    final subtextColor = AdaptiveColors.subtext(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(selectedSubject == null
            ? 'Choose Subject'
            : 'Choose Topic - $selectedSubject'),
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

            final chemTopics = [
              {
                'id': 'chem-reaction-kinetics',
                'title': 'Reaction Kinetics',
                'description':
                    'Adjust concentration + temperature to match a titration curve.',
                'subject': 'Chemistry',
                'difficulty': 'Beginner',
                'duration': '8 min'
              },
              {
                'id': 'chem-equilibrium',
                'title': 'Chemical Equilibrium',
                'description':
                    'Stress with pressure/temperature and watch Le Chatelier respond.',
                'subject': 'Chemistry',
                'difficulty': 'Intermediate',
                'duration': '10 min'
              },
              {
                'id': 'chem-molarity-lab',
                'title': 'Molarity Lab Setup',
                'description':
                    'Prep solutions and track how concentration affects conductivity.',
                'subject': 'Chemistry',
                'difficulty': 'Intermediate',
                'duration': '11 min'
              },
              {
                'id': 'chem-spectroscopy',
                'title': 'Spectroscopy Curve',
                'description':
                    'Slide wavelengths and observe how colors form emission bands.',
                'subject': 'Chemistry',
                'difficulty': 'Intermediate',
                'duration': '10 min'
              },
            ];

            final physTopics = [
              {
                'id': 'phy-projectile-motion',
                'title': 'Projectile Motion',
                'description':
                    'Model how launch angle, gravity and drag affect a real shot.',
                'subject': 'Physics',
                'difficulty': 'Beginner',
                'duration': '9 min'
              },
              {
                'id': 'phy-wave-motion',
                'title': 'Wave Motion',
                'description': 'Simulate pulses along a rope or water surface.',
                'subject': 'Physics',
                'difficulty': 'Intermediate',
                'duration': '10 min'
              },
              {
                'id': 'phy-electric-field',
                'title': 'Electric Field Mapping',
                'description':
                    'Drag charges and watch field lines visualize the force.',
                'subject': 'Physics',
                'difficulty': 'Intermediate',
                'duration': '12 min'
              },
              {
                'id': 'phy-magnetism',
                'title': 'Magnetic Field Lab',
                'description':
                    'Position magnets and sliders to feel how loops distort.',
                'subject': 'Physics',
                'difficulty': 'Intermediate',
                'duration': '10 min'
              },
            ];

            final mathTopics = all
                .where((t) =>
                    (t['subject'] as String).contains('Trig') ||
                    (t['subject'] as String).contains('Mens'))
                .toList();
            final mathFiltered = filter == 'All'
                ? mathTopics
                : mathTopics
                    .where((t) => t['subject'] == filter)
                    .toList();

            if (selectedSubject == null) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Select a Subject',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: textColor)),
                        const SizedBox(height: 6),
                        Text(
                            'Pick a subject to explore interactive visual learning.',
                            style: TextStyle(color: subtextColor)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _subjectCard(
                    title: 'Maths',
                    subtitle: 'Trigonometry + Mensuration',
                    gradient: const [NeonPalette.purple, NeonPalette.cyan],
                    icon: Icons.calculate_rounded,
                    onTap: () => setState(() => selectedSubject = 'Maths'),
                  ),
                  const SizedBox(height: 10),
                  _subjectCard(
                    title: 'Chemistry',
                    subtitle: 'Reaction kinetics + ionic visuals',
                    gradient: const [Color(0xFF0EA5E9), Color(0xFF22C55E)],
                    icon: Icons.science_rounded,
                    onTap: () => setState(() => selectedSubject = 'Chemistry'),
                  ),
                  const SizedBox(height: 10),
                  _subjectCard(
                    title: 'Physics',
                    subtitle: 'Mechanics + field explorations',
                    gradient: const [Color(0xFFF97316), Color(0xFFEC4899)],
                    icon: Icons.bolt_rounded,
                    onTap: () => setState(() => selectedSubject = 'Physics'),
                  ),
                ],
              );
            }

            final subjectTopics = selectedSubject == 'Chemistry'
                ? chemTopics
                : selectedSubject == 'Physics'
                    ? physTopics
                    : mathFiltered;

            if (subjectTopics.isEmpty) {
              return Center(
                child: Text('No topics available for $selectedSubject yet.',
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
                        label: const Text('Subjects'),
                      ),
                      if (selectedSubject == 'Maths') ...[
                        const SizedBox(width: 8),
                        _filterChip('All', 'All'),
                        const SizedBox(width: 8),
                        _filterChip('Trigonometry', 'Trigonometry'),
                        const SizedBox(width: 8),
                        _filterChip('Mensuration', 'Mensuration'),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: subjectTopics.length,
                    itemBuilder: (context, i) => TopicCard(
                      topic: subjectTopics[i],
                      index: i,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => VisualizationScreen(
                                userId: widget.userId,
                                topic: subjectTopics[i])),
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

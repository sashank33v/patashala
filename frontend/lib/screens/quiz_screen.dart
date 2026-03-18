import 'package:flutter/material.dart';

import '../api_service.dart';
import '../data/quiz_bank.dart';
import '../widgets/neon_ui.dart';
import 'progress_dashboard_screen.dart';

class QuizScreen extends StatefulWidget {
  final int userId;
  final Map<String, dynamic> topic;

  const QuizScreen({super.key, required this.userId, required this.topic});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _score = 0;
  int _index = 0;
  bool _finished = false;
  late final List<Map<String, dynamic>> _questions = QuizBank.questionsForTopic(widget.topic['id'].toString());

  Future<void> _onAnswer(int index) async {
    if (index == _questions[_index]['a']) _score++;
    if (_index == _questions.length - 1) {
      if (!widget.topic['id'].toString().contains('tangent') && !widget.topic['id'].toString().contains('interference')) {
        await ApiService.postProgress(userId: widget.userId, topic: widget.topic['id'], completed: true);
      }
      if (!mounted) return;
      setState(() => _finished = true);
      return;
    }
    setState(() => _index++);
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz Result')),
        body: MeshBackground(
          child: Center(
            child: GlassCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 42)),
                  Text('Score: $_score / ${_questions.length}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  NeonButton(
                    onTap: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => ProgressDashboardScreen(userId: widget.userId)),
                      (route) => route.isFirst,
                    ),
                    child: const Text('Go To Dashboard'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final q = _questions[_index];
    final options = (q['options'] as List<dynamic>).cast<String>();

    return Scaffold(
      appBar: AppBar(title: const Text('Mini Quiz')),
      body: MeshBackground(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearProgressIndicator(value: (_index + 1) / _questions.length, minHeight: 12),
              ),
              const SizedBox(height: 12),
              GlassCard(
                child: Text(q['q'], style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 12),
              ...options.map((o) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GlassCard(
                      onTap: () => _onAnswer(options.indexOf(o)),
                      child: Row(
                        children: [
                          const Icon(Icons.radio_button_unchecked, color: NeonPalette.cyan),
                          const SizedBox(width: 8),
                          Expanded(child: Text(o)),
                        ],
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

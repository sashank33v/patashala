import 'package:flutter/material.dart';
import 'api_service.dart';
import 'widgets.dart';

class TrigVisualScreen extends StatefulWidget {
  final String slug;
  const TrigVisualScreen({super.key, required this.slug});

  @override
  State<TrigVisualScreen> createState() => _TrigVisualScreenState();
}

class _TrigVisualScreenState extends State<TrigVisualScreen> {
  late Future<Map<String, dynamic>> _topicData;

  @override
  void initState() {
    super.initState();
    _topicData = ApiService.fetchTopic(widget.slug);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.slug),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _topicData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      _topicData = ApiService.fetchTopic(widget.slug);
                    }),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!;
          final vizType = data['viz_type'] as String;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['name'] ?? '',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (data['description'] != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    data['description'],
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
                const SizedBox(height: 24),
                _buildViz(vizType, data),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildViz(String vizType, Map<String, dynamic> data) {
    switch (vizType) {
      case 'sine_wave':
      case 'cosine_wave':
        return LineChartWidget(
          xValues: List<double>.from(data['x']),
          yValues: List<double>.from(data['y']),
          title: data['title'] ?? vizType,
        );
      default:
        return Center(
          child: Text(
            'Visualization "$vizType" not yet supported.',
            style: const TextStyle(color: Colors.grey),
          ),
        );
    }
  }
}

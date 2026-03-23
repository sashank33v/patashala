import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static http.Client client = http.Client();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (response.statusCode != 200) {
      throw Exception('Invalid username or password');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String username,
    required String password,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'username': username, 'password': password}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to register');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<void> forgotPassword({
    required String username,
    required String newPassword,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'new_password': newPassword}),
    );
    if (response.statusCode != 200) {
      throw Exception('Unable to reset password');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchTopics() async {
    final response = await client.get(Uri.parse('$baseUrl/topics'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load topics');
    }
    final List<dynamic> data = jsonDecode(response.body);
    return data.cast<Map<String, dynamic>>();
  }

  static Future<Map<String, dynamic>> fetchVisualization(
    String topicId, {
    Map<String, dynamic> params = const {},
  }) async {
    final uri = Uri.parse('$baseUrl/visualization/$topicId').replace(
      queryParameters: params.map((key, value) => MapEntry(key, value.toString())),
    );
    final response = await client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load visualization');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<void> postProgress({
    required int userId,
    required String topic,
    required bool completed,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl/progress'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'topic': topic,
        'completed': completed,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update progress');
    }
  }

  static Future<Map<String, dynamic>> fetchProgress(int userId) async {
    final response = await client.get(Uri.parse('$baseUrl/progress/$userId'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load progress');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> fetchRecommendation(int userId) async {
    final response = await client.get(Uri.parse('$baseUrl/recommendation/$userId'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load recommendation');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<List<Map<String, dynamic>>> fetchPresets(String topicId) async {
    final response = await client.get(Uri.parse('$baseUrl/presets/$topicId'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load presets');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final presets = (data['presets'] as List<dynamic>? ?? []);
    return presets.cast<Map<String, dynamic>>();
  }

  static Future<List<Map<String, dynamic>>> fetchLeaderboard() async {
    final response = await client.get(Uri.parse('$baseUrl/leaderboard'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load leaderboard');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final leaders = (data['leaders'] as List<dynamic>? ?? []);
    return leaders.cast<Map<String, dynamic>>();
  }

  static Future<String> studyChat({
    required String topicId,
    required String topicTitle,
    required List<String> notes,
    required List<Map<String, String>> messages,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl/ai/study-chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'topic_id': topicId,
        'topic_title': topicTitle,
        'notes': notes,
        'messages': messages,
      }),
    );

    if (response.statusCode != 200) {
      String message = 'Study chat is unavailable right now';
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        message = data['detail']?.toString() ?? message;
      } catch (_) {}
      throw Exception(message);
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['answer']?.toString() ?? 'No answer available';
  }
}

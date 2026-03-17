import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api';

  static Future<List<Map<String, dynamic>>> fetchTopics() async {
    final response = await http.get(Uri.parse('$baseUrl/topics'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception('Failed to load topics');
  }

  static Future<Map<String, dynamic>> fetchTopic(String slug) async {
    final response = await http.get(Uri.parse('$baseUrl/topics/$slug'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load topic: $slug');
  }
}

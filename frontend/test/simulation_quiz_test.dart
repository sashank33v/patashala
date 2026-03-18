import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:patashala/api_service.dart';
import 'package:patashala/screens/quiz_screen.dart';
import 'package:patashala/screens/simulation_screen.dart';

void main() {
  testWidgets('Simulation preset chip updates visualization query params', (WidgetTester tester) async {
    final requestedUrls = <String>[];

    ApiService.client = MockClient((request) async {
      requestedUrls.add(request.url.toString());

      if (request.url.path == '/presets/trig-right-triangle') {
        return http.Response(
          jsonEncode({
            'topic_id': 'trig-right-triangle',
            'presets': [
              {
                'label': 'Balanced',
                'params': {'angle': 45, 'hypotenuse': 10}
              }
            ]
          }),
          200,
        );
      }

      if (request.url.path == '/visualization/trig-right-triangle') {
        final angle = num.tryParse(request.url.queryParameters['angle'] ?? '35') ?? 35;
        return http.Response(
          jsonEncode({
            'topic': {
              'id': 'trig-right-triangle',
              'title': 'Right Triangle Basics',
              'subject': 'Trigonometry',
              'description': 'desc'
            },
            'visualization': {
              'graph': {},
              'simulation': {
                'angle': angle,
                'hypotenuse': 10,
                'opposite': 5,
                'adjacent': 8,
              },
              'animation_steps': ['a', 'b', 'c'],
              'controls': [
                {'id': 'angle', 'type': 'slider', 'min': 5, 'max': 85, 'value': angle},
                {'id': 'hypotenuse', 'type': 'slider', 'min': 5, 'max': 20, 'value': 10}
              ]
            }
          }),
          200,
        );
      }

      return http.Response('{}', 200);
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: SimulationScreen(
          userId: 1,
          topic: {
            'id': 'trig-right-triangle',
            'title': 'Right Triangle Basics',
            'subject': 'Trigonometry',
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Balanced'), findsOneWidget);

    await tester.tap(find.text('Balanced'));
    await tester.pumpAndSettle();

    expect(requestedUrls.any((url) => url.contains('/visualization/trig-right-triangle?') && url.contains('angle=45')), isTrue);
  });

  testWidgets('Quiz flow completes and saves progress', (WidgetTester tester) async {
    var progressPostCount = 0;

    ApiService.client = MockClient((request) async {
      if (request.url.path == '/progress' && request.method == 'POST') {
        progressPostCount += 1;
        return http.Response(
          jsonEncode({'user_id': 1, 'topic': 'mens-rectangle-area', 'completed': true}),
          200,
        );
      }

      if (request.url.path == '/progress/1') {
        return http.Response(
          jsonEncode({
            'user_id': 1,
            'completed_topics': ['mens-rectangle-area'],
            'summary': {
              'Trigonometry': {'completed': 0, 'total': 4, 'percent': 0.0},
              'Mensuration': {'completed': 1, 'total': 4, 'percent': 25.0},
            },
            'badges': []
          }),
          200,
        );
      }

      if (request.url.path == '/leaderboard') {
        return http.Response(
          jsonEncode({
            'leaders': [
              {'rank': 1, 'user_id': 1, 'name': 'Test Student', 'completed_count': 1}
            ]
          }),
          200,
        );
      }

      return http.Response('{}', 200);
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: QuizScreen(
          userId: 1,
          topic: {
            'id': 'mens-rectangle-area',
            'title': 'Area of Rectangle',
            'subject': 'Mensuration',
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Length x Width'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Square units'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Doubles'));
    await tester.pumpAndSettle();

    expect(find.text('Quiz Result'), findsOneWidget);
    expect(find.text('Score: 3 / 3'), findsOneWidget);
    expect(progressPostCount, 1);
  });
}

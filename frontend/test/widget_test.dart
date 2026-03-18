import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:patashala/api_service.dart';
import 'package:patashala/main.dart';
import 'package:patashala/widgets/neon_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Login then home renders', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    ApiService.client = MockClient((request) async {
      if (request.url.path == '/auth/login') {
        return http.Response(jsonEncode({'user_id': 1, 'name': 'Test', 'username': 'student'}), 200);
      }
      if (request.url.path == '/progress/1') {
        return http.Response(
          jsonEncode({
            'summary': {
              'Trigonometry': {'percent': 40.0},
              'Mensuration': {'percent': 20.0},
            }
          }),
          200,
        );
      }
      return http.Response('{}', 200);
    });

    await tester.pumpWidget(const PatashalaApp());
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Login'), findsOneWidget);
    final loginButton = find.widgetWithText(NeonButton, 'Login');
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    expect(find.text('Patashala'), findsOneWidget);
    expect(find.text('Featured Topics'), findsOneWidget);
  });
}

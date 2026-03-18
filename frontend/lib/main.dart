import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/local_prefs.dart';
import 'widgets/neon_ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalPrefs.initialize();
  runApp(const PatashalaApp());
}

class PatashalaApp extends StatelessWidget {
  const PatashalaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData.dark(useMaterial3: true);
    return MaterialApp(
      title: 'Patashala',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        scaffoldBackgroundColor: NeonPalette.bg,
        textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(
          bodyColor: NeonPalette.text,
          displayColor: NeonPalette.text,
        ),
        colorScheme: base.colorScheme.copyWith(
          primary: NeonPalette.purple,
          secondary: NeonPalette.cyan,
          surface: NeonPalette.panel,
        ),
      ),
      builder: (context, child) {
        return ValueListenableBuilder<AppSettings>(
          valueListenable: LocalPrefs.settingsNotifier,
          builder: (context, settings, _) {
            final media = MediaQuery.of(context);
            return MediaQuery(
              data: media.copyWith(textScaler: TextScaler.linear(settings.textScale)),
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
      home: const _BootstrapScreen(),
    );
  }
}

class _BootstrapScreen extends StatelessWidget {
  const _BootstrapScreen();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int?>(
      future: LocalPrefs.loadSessionUserId(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final userId = snapshot.data;
        if (userId != null) {
          return HomeScreen(userId: userId);
        }
        return const LoginScreen();
      },
    );
  }
}

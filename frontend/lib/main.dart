import 'package:flutter/material.dart';
import 'home_screen.dart';

void main() {
  runApp(const PatashalaApp());
}

class PatashalaApp extends StatelessWidget {
  const PatashalaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Patashala',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

import 'package:flutter/material.dart';

import '../api_service.dart';
import '../services/local_prefs.dart';
import '../widgets/neon_ui.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameCtrl = TextEditingController(text: 'student');
  final passwordCtrl = TextEditingController(text: 'student123');
  bool loading = false;
  bool obscure = true;
  bool rememberMe = true;
  String? error;

  @override
  void dispose() {
    usernameCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final username = usernameCtrl.text.trim();
    final password = passwordCtrl.text;
    if (username.isEmpty) {
      setState(() => error = 'Enter a username');
      return;
    }
    if (password.length < 6) {
      setState(() => error = 'Password must be at least 6 characters');
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });
    try {
      final result = await ApiService.login(
        username: username,
        password: password,
      );
      await LocalPrefs.saveSession(
        userId: result['user_id'] as int,
        username: username,
        rememberMe: rememberMe,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(userId: result['user_id'] as int)),
      );
    } catch (e) {
      setState(() => error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MeshBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, viewport) => SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: viewport.maxHeight - 40),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 980),
                    child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 850;
                    final panels = [
                      GlassCard(
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 420),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Patashala', style: TextStyle(fontSize: 44, fontWeight: FontWeight.w900)),
                              const SizedBox(height: 6),
                              const Text(
                                'Learn Trigonometry + Mensuration with interactive visuals.',
                                style: TextStyle(fontSize: 18, color: NeonPalette.subtext, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 26),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: const [
                                  _Badge(icon: Icons.functions, text: 'Live Graphs'),
                                  _Badge(icon: Icons.grid_on_rounded, text: 'Area & Perimeter'),
                                  _Badge(icon: Icons.quiz_rounded, text: 'Quick Quizzes'),
                                  _Badge(icon: Icons.emoji_events_rounded, text: 'XP + Badges'),
                                ],
                              ),
                              const SizedBox(height: 28),
                              const Text(
                                'Tip: Use `student / student123` for demo login.',
                                style: TextStyle(color: NeonPalette.cyan, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GlassCard(
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 420),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Welcome Back', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
                              const SizedBox(height: 6),
                              const Text('Login with username and password', style: TextStyle(color: NeonPalette.subtext)),
                              const SizedBox(height: 20),
                              TextField(
                                controller: usernameCtrl,
                                decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder()),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: passwordCtrl,
                                obscureText: obscure,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  border: const OutlineInputBorder(),
                                  suffixIcon: IconButton(
                                    onPressed: () => setState(() => obscure = !obscure),
                                    icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Checkbox(
                                    value: rememberMe,
                                    onChanged: (value) => setState(() => rememberMe = value ?? true),
                                  ),
                                  const Text('Remember me'),
                                ],
                              ),
                              if (error != null) ...[
                                const SizedBox(height: 8),
                                Text(error!, style: const TextStyle(color: Colors.redAccent)),
                              ],
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: NeonButton(
                                  onTap: loading ? () {} : _login,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (loading)
                                        const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                      else
                                        const Icon(Icons.login, size: 18),
                                      const SizedBox(width: 8),
                                      const Text('Login'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ];

                    if (compact) {
                      return Column(
                        children: [
                          panels[0],
                          const SizedBox(height: 14),
                          panels[1],
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: panels[0]),
                        const SizedBox(width: 18),
                        Expanded(child: panels[1]),
                      ],
                    );
                  },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Badge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: NeonPalette.cyan),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

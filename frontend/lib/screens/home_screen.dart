import 'package:flutter/material.dart';

import '../api_service.dart';
import '../services/local_prefs.dart';
import '../widgets/neon_ui.dart';
import '../widgets/progress_ring.dart';
import 'login_screen.dart';
import 'progress_dashboard_screen.dart';
import 'topic_selection_screen.dart';
import 'visualization_screen.dart';

class HomeScreen extends StatefulWidget {
  final int userId;

  const HomeScreen({super.key, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Map<String, dynamic>> _progressFuture;
  AppSettings _settings = AppSettings.defaults();
  bool _settingsLoaded = false;

  @override
  void initState() {
    super.initState();
    _progressFuture = ApiService.fetchProgress(widget.userId);
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await LocalPrefs.loadSettings();
    if (!mounted) return;
    setState(() {
      _settings = settings;
      _settingsLoaded = true;
    });
  }

  Future<void> _updateSettings(AppSettings next) async {
    setState(() => _settings = next);
    await LocalPrefs.saveSettings(next);
  }

  Future<void> _logout() async {
    await LocalPrefs.clearSession();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = AdaptiveColors.text(context);
    final subtextColor = AdaptiveColors.subtext(context);
    final drawerTextColor = AdaptiveColors.text(context);
    final drawerSubtextColor = AdaptiveColors.subtext(context);
    final drawerColor = AdaptiveColors.isDark(context)
        ? const Color(0xFF0A1024)
        : const Color(0xFFF7F0FF);
    return Scaffold(
      drawerScrimColor: Colors.transparent,
      endDrawer: Drawer(
        backgroundColor: drawerColor,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
          children: [
            Text('Home Settings',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: drawerTextColor)),
            const SizedBox(height: 16),
            if (!_settingsLoaded)
              const Center(
                  child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator()))
            else ...[
              Text('Appearance', style: TextStyle(color: drawerSubtextColor)),
              SwitchListTile(
                value: _settings.darkMode,
                onChanged: (v) =>
                    _updateSettings(_settings.copyWith(darkMode: v)),
                title: Text(_settings.darkMode ? 'Dark Mode' : 'Bright Mode',
                    style: TextStyle(color: drawerTextColor)),
              ),
              Text('Learning Boost', style: TextStyle(color: drawerSubtextColor)),
              SwitchListTile(
                value: _settings.showHints,
                onChanged: (v) =>
                    _updateSettings(_settings.copyWith(showHints: v)),
                title: Text('Show Formula Hints',
                    style: TextStyle(color: drawerTextColor)),
              ),
             SwitchListTile(
               value: _settings.autoPlay,
               onChanged: (v) =>
                   _updateSettings(_settings.copyWith(autoPlay: v)),
                title: Text('Auto-play Visuals',
                    style: TextStyle(color: drawerTextColor)),
              ),
              Text('Experience', style: TextStyle(color: drawerSubtextColor)),
              SwitchListTile(
                value: _settings.soundEffects,
                onChanged: (v) =>
                    _updateSettings(_settings.copyWith(soundEffects: v)),
                title: Text('Sound Effects',
                    style: TextStyle(color: drawerTextColor)),
              ),
              SwitchListTile(
                value: _settings.haptics,
                onChanged: (v) =>
                    _updateSettings(_settings.copyWith(haptics: v)),
                title: Text('Haptic Feedback',
                    style: TextStyle(color: drawerTextColor)),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Text Size',
                    style: TextStyle(color: drawerTextColor)),
                subtitle: Slider(
                  value: _settings.textScale,
                  min: 0.8,
                  max: 1.8,
                  divisions: 10,
                  label: _settings.textScale.toStringAsFixed(1),
                  activeColor: NeonPalette.purple,
                  onChanged: (v) =>
                      _updateSettings(_settings.copyWith(textScale: v)),
                ),
              ),
              const Divider(height: 28),
              ListTile(
                onTap: _logout,
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text('Logout',
                    style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ],
        ),
      ),
      body: MeshBackground(
        child: SafeArea(
          child: FutureBuilder<Map<String, dynamic>>(
            future: _progressFuture,
            builder: (context, snapshot) {
              final summary =
                  snapshot.data?['summary'] as Map<String, dynamic>?;
              final trig =
                  (summary?['Trigonometry'] as Map<String, dynamic>?) ??
                      {'percent': 0.0};
              final mens = (summary?['Mensuration'] as Map<String, dynamic>?) ??
                  {'percent': 0.0};
              final overall = ((((trig['percent'] as num?)?.toDouble() ?? 0) +
                          ((mens['percent'] as num?)?.toDouble() ?? 0)) /
                      2) /
                  100;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Text('Patashala',
                              style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                  color: textColor))),
                      Builder(
                        builder: (context) => IconButton(
                          tooltip: 'Settings',
                          onPressed: () => Scaffold.of(context).openEndDrawer(),
                          icon: const Icon(Icons.settings,
                              color: NeonPalette.cyan),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GlassCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Welcome Back',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: textColor)),
                              const SizedBox(height: 4),
                              Text('Streak: 5 days',
                                  style: TextStyle(color: subtextColor)),
                            ],
                          ),
                        ),
                        ProgressRing(progress: overall),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text('Featured Topics',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: textColor)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 160,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _featuredCard(
                          title: 'Sine Wave',
                          subtitle: 'Amplitude - Frequency',
                          colors: const [NeonPalette.purple, NeonPalette.cyan],
                          onTap: () => _openTopic(
                            {
                              'id': 'trig-sine-cosine',
                              'title': 'Sine Wave',
                              'description': 'Amplitude and frequency explorer',
                              'subject': 'Trigonometry'
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        _featuredCard(
                          title: 'Area & Perimeter',
                          subtitle: 'Rectangle + Square',
                          colors: const [NeonPalette.cyan, NeonPalette.pink],
                          onTap: () => _openTopic(
                            {
                              'id': 'mens-rectangle-area',
                              'title': 'Area of Rectangle',
                              'description': 'Length x width on grid',
                              'subject': 'Mensuration'
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text('Choose a Subject',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: textColor)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _subjectTile(
                          title: 'Maths',
                          subtitle: 'Trigonometry + Mensuration',
                          colors: const [NeonPalette.purple, NeonPalette.cyan],
                          icon: Icons.calculate_rounded,
                          subject: 'Maths'),
                      _subjectTile(
                          title: 'Chemistry',
                          subtitle: 'Reactions + Ionic visuals',
                          colors: const [Color(0xFF0EA5E9), Color(0xFF22C55E)],
                          icon: Icons.science_rounded,
                          subject: 'Chemistry'),
                      _subjectTile(
                          title: 'Physics',
                          subtitle: 'Mechanics + Field labs',
                          colors: const [Color(0xFFF97316), Color(0xFFEC4899)],
                          icon: Icons.bolt_rounded,
                          subject: 'Physics'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('All Topics',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: textColor)),
                  const SizedBox(height: 8),
                  GlassCard(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                TopicSelectionScreen(userId: widget.userId))),
                    child: const Row(
                      children: [
                        Icon(Icons.grid_view_rounded, color: NeonPalette.cyan),
                        SizedBox(width: 10),
                        Expanded(
                            child: Text(
                                'Browse Trigonometry + Mensuration topics')),
                        Icon(Icons.arrow_forward_ios, size: 14),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  GlassCard(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProgressDashboardScreen(
                                userId: widget.userId))),
                    child: const Row(
                      children: [
                        Icon(Icons.bar_chart_rounded, color: NeonPalette.pink),
                        SizedBox(width: 10),
                        Expanded(child: Text('Open Progress Dashboard')),
                        Icon(Icons.arrow_forward_ios, size: 14),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _featuredCard(
      {required String title,
      required String subtitle,
      required List<Color> colors,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(colors: colors),
          boxShadow: [
            BoxShadow(color: colors.first.withOpacity(0.35), blurRadius: 16)
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text(subtitle),
            const Spacer(),
            const Row(
              children: [
                Icon(Icons.play_circle_fill),
                SizedBox(width: 6),
                Text('Start', style: TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _subjectTile({
    required String title,
    required String subtitle,
    required List<Color> colors,
    required IconData icon,
    required String subject,
  }) {
    return GestureDetector(
      onTap: () => _openSubject(subject),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(colors: colors),
          boxShadow: [
            BoxShadow(color: colors.first.withOpacity(0.35), blurRadius: 16),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white.withOpacity(0.25),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 12),
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(subtitle,
                style:
                    const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  void _openTopic(Map<String, dynamic> topic) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) =>
              VisualizationScreen(userId: widget.userId, topic: topic)),
    );
  }

  void _openSubject(String subject) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => TopicSelectionScreen(
                userId: widget.userId,
                initialSubject: subject,
              )),
    );
  }
}

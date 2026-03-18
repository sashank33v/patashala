import 'package:flutter/material.dart';

import '../api_service.dart';
import '../services/local_prefs.dart';
import '../widgets/neon_ui.dart';
import '../widgets/progress_ring.dart';
import 'login_screen.dart';

class ProgressDashboardScreen extends StatefulWidget {
  final int userId;

  const ProgressDashboardScreen({super.key, required this.userId});

  @override
  State<ProgressDashboardScreen> createState() =>
      _ProgressDashboardScreenState();
}

class _ProgressDashboardScreenState extends State<ProgressDashboardScreen> {
  late Future<Map<String, dynamic>> _progress;
  late Future<List<Map<String, dynamic>>> _leaders;
  AppSettings _settings = AppSettings.defaults();
  bool _settingsLoaded = false;

  @override
  void initState() {
    super.initState();
    _progress = ApiService.fetchProgress(widget.userId);
    _leaders = ApiService.fetchLeaderboard();
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
    return Scaffold(
      endDrawer: Drawer(
        backgroundColor: const Color(0xFF0A1024),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
          children: [
            const Text('Settings',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            if (!_settingsLoaded)
              const Center(
                  child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator()))
            else ...[
              const Text('Appearance',
                  style: TextStyle(color: NeonPalette.subtext)),
              SwitchListTile(
                value: _settings.darkMode,
                onChanged: (v) =>
                    _updateSettings(_settings.copyWith(darkMode: v)),
                title: Text(_settings.darkMode ? 'Dark Mode' : 'Bright Mode'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Language'),
                trailing: DropdownButton<String>(
                  value: _settings.languageCode,
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'te', child: Text('Telugu')),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    _updateSettings(_settings.copyWith(languageCode: v));
                  },
                ),
              ),
              const Text('Learning',
                  style: TextStyle(color: NeonPalette.subtext)),
              SwitchListTile(
                value: _settings.showHints,
                onChanged: (v) =>
                    _updateSettings(_settings.copyWith(showHints: v)),
                title: const Text('Show Formula Hints'),
              ),
              SwitchListTile(
                value: _settings.autoPlay,
                onChanged: (v) =>
                    _updateSettings(_settings.copyWith(autoPlay: v)),
                title: const Text('Auto-play Animations'),
              ),
              const SizedBox(height: 8),
              const Text('Accessibility',
                  style: TextStyle(color: NeonPalette.subtext)),
              SwitchListTile(
                value: _settings.highContrast,
                onChanged: (v) =>
                    _updateSettings(_settings.copyWith(highContrast: v)),
                title: const Text('High Contrast UI'),
              ),
              SwitchListTile(
                value: _settings.reducedMotion,
                onChanged: (v) =>
                    _updateSettings(_settings.copyWith(reducedMotion: v)),
                title: const Text('Reduce Motion'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Text Size'),
                subtitle: Slider(
                  value: _settings.textScale,
                  min: 0.8,
                  max: 1.8,
                  divisions: 10,
                  label: _settings.textScale.toStringAsFixed(1),
                  onChanged: (v) =>
                      _updateSettings(_settings.copyWith(textScale: v)),
                ),
              ),
              const SizedBox(height: 8),
              const Text('App', style: TextStyle(color: NeonPalette.subtext)),
              SwitchListTile(
                value: _settings.notifications,
                onChanged: (v) =>
                    _updateSettings(_settings.copyWith(notifications: v)),
                title: const Text('Notifications'),
              ),
              SwitchListTile(
                value: _settings.soundEffects,
                onChanged: (v) =>
                    _updateSettings(_settings.copyWith(soundEffects: v)),
                title: const Text('Sound Effects'),
              ),
              SwitchListTile(
                value: _settings.haptics,
                onChanged: (v) =>
                    _updateSettings(_settings.copyWith(haptics: v)),
                title: const Text('Haptic Feedback'),
              ),
              SwitchListTile(
                value: _settings.dataSaver,
                onChanged: (v) =>
                    _updateSettings(_settings.copyWith(dataSaver: v)),
                title: const Text('Data Saver Mode'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Animation Speed'),
                subtitle: Slider(
                  value: _settings.animationSpeed,
                  min: 0.6,
                  max: 1.4,
                  divisions: 4,
                  label:
                      '${(_settings.animationSpeed * 100).toStringAsFixed(0)}%',
                  onChanged: (v) =>
                      _updateSettings(_settings.copyWith(animationSpeed: v)),
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
      appBar: AppBar(
        title: const Text('Progress Dashboard'),
        actions: [
          Builder(
            builder: (context) => IconButton(
              tooltip: 'Settings',
              icon: const Icon(Icons.settings),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      body: MeshBackground(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _progress,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }

            final summary = snapshot.data!['summary'] as Map<String, dynamic>;
            final trig = (summary['Trigonometry'] as Map<String, dynamic>?) ??
                {'percent': 0.0};
            final mens = (summary['Mensuration'] as Map<String, dynamic>?) ??
                {'percent': 0.0};
            final overall = ((((trig['percent'] as num).toDouble()) +
                        ((mens['percent'] as num).toDouble())) /
                    2) /
                100;

            return FutureBuilder<List<Map<String, dynamic>>>(
              future: _leaders,
              builder: (context, lSnap) {
                final leaders = lSnap.data ?? const <Map<String, dynamic>>[];
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Center(child: ProgressRing(progress: overall, size: 120)),
                    const SizedBox(height: 12),
                    GlassCard(
                      child: Row(
                        children: [
                          Expanded(
                              child: Text('Trigonometry: ${trig['percent']}%',
                                  style: const TextStyle(
                                      color: NeonPalette.cyan))),
                          Expanded(
                              child: Text('Mensuration: ${mens['percent']}%',
                                  style: const TextStyle(
                                      color: NeonPalette.pink))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Top Learners',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    ...leaders.take(5).map((l) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: GlassCard(
                            child: Row(
                              children: [
                                CircleAvatar(
                                    backgroundColor: Colors.white10,
                                    child: Text('#${l['rank']}')),
                                const SizedBox(width: 10),
                                Expanded(
                                    child: Text(
                                        l['name']?.toString() ?? 'Student')),
                                Text('${l['completed_count']} topics',
                                    style: const TextStyle(
                                        color: NeonPalette.cyan)),
                              ],
                            ),
                          ),
                        )),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

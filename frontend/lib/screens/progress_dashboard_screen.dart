import 'package:flutter/material.dart';

import '../api_service.dart';
import '../services/app_strings.dart';
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
    final textColor = AdaptiveColors.text(context);
    final subtextColor = AdaptiveColors.subtext(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.t('progress_dashboard')),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings),
            onPressed: () => _openSettingsSheet(context),
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
                    Text(AppStrings.t('top_learners'),
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: textColor)),
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

  Future<void> _openSettingsSheet(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    await showDialog<void>(
      context: context,
      barrierColor: Colors.transparent,
      builder: (dialogContext) => Align(
        alignment: Alignment.centerRight,
        child: Material(
          color: isDark ? const Color(0xFF0A1024) : const Color(0xFFFFEAF3),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            bottomLeft: Radius.circular(18),
          ),
          child: SizedBox(
            width: 360,
            height: double.infinity,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: _buildSettingsContent(dialogContext),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsContent(BuildContext context) {
    final textColor = AdaptiveColors.text(context);
    final subtextColor = AdaptiveColors.subtext(context);
    return ListView(
      shrinkWrap: true,
      children: [
        Text(AppStrings.t('settings'),
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.w800, color: textColor)),
        const SizedBox(height: 16),
        if (!_settingsLoaded)
          const Center(
              child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator()))
        else ...[
          Text(AppStrings.t('appearance'),
              style: TextStyle(color: subtextColor)),
          SwitchListTile(
            value: _settings.darkMode,
            onChanged: (v) => _updateSettings(_settings.copyWith(darkMode: v)),
            title: Text(_settings.darkMode
                ? AppStrings.t('dark_mode')
                : AppStrings.t('bright_mode')),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(AppStrings.t('language'),
                style: TextStyle(color: textColor)),
            trailing: DropdownButton<String>(
              value: _settings.languageCode,
              items: [
                DropdownMenuItem(
                    value: 'en', child: Text(AppStrings.t('english'))),
                DropdownMenuItem(
                    value: 'te', child: Text(AppStrings.t('telugu'))),
              ],
              onChanged: (v) {
                if (v == null) return;
                _updateSettings(_settings.copyWith(languageCode: v));
              },
            ),
          ),
          Text(AppStrings.t('learning'), style: TextStyle(color: subtextColor)),
          SwitchListTile(
            value: _settings.showHints,
            onChanged: (v) => _updateSettings(_settings.copyWith(showHints: v)),
            title: Text(AppStrings.t('show_hints')),
          ),
          SwitchListTile(
            value: _settings.autoPlay,
            onChanged: (v) => _updateSettings(_settings.copyWith(autoPlay: v)),
            title: Text(AppStrings.t('autoplay_animations')),
          ),
          const SizedBox(height: 8),
          Text(AppStrings.t('accessibility'),
              style: TextStyle(color: subtextColor)),
          SwitchListTile(
            value: _settings.highContrast,
            onChanged: (v) =>
                _updateSettings(_settings.copyWith(highContrast: v)),
            title: Text(AppStrings.t('high_contrast')),
          ),
          SwitchListTile(
            value: _settings.reducedMotion,
            onChanged: (v) =>
                _updateSettings(_settings.copyWith(reducedMotion: v)),
            title: Text(AppStrings.t('reduce_motion')),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(AppStrings.t('text_size')),
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
          Text(AppStrings.t('app_section'),
              style: TextStyle(color: subtextColor)),
          SwitchListTile(
            value: _settings.notifications,
            onChanged: (v) =>
                _updateSettings(_settings.copyWith(notifications: v)),
            title: Text(AppStrings.t('notifications')),
          ),
          SwitchListTile(
            value: _settings.soundEffects,
            onChanged: (v) =>
                _updateSettings(_settings.copyWith(soundEffects: v)),
            title: Text(AppStrings.t('sound_effects')),
          ),
          SwitchListTile(
            value: _settings.haptics,
            onChanged: (v) => _updateSettings(_settings.copyWith(haptics: v)),
            title: Text(AppStrings.t('haptic_feedback')),
          ),
          SwitchListTile(
            value: _settings.dataSaver,
            onChanged: (v) => _updateSettings(_settings.copyWith(dataSaver: v)),
            title: Text(AppStrings.t('data_saver')),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(AppStrings.t('animation_speed')),
            subtitle: Slider(
              value: _settings.animationSpeed,
              min: 0.6,
              max: 1.4,
              divisions: 4,
              label: '${(_settings.animationSpeed * 100).toStringAsFixed(0)}%',
              onChanged: (v) =>
                  _updateSettings(_settings.copyWith(animationSpeed: v)),
            ),
          ),
          const Divider(height: 28),
          ListTile(
            onTap: () async {
              Navigator.of(context).pop();
              await _logout();
            },
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: Text(AppStrings.t('logout'),
                style: const TextStyle(color: Colors.redAccent)),
          ),
        ],
      ],
    );
  }
}

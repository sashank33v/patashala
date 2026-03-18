import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final bool notifications;
  final bool soundEffects;
  final bool haptics;
  final bool autoPlay;
  final bool showHints;
  final bool dataSaver;
  final bool highContrast;
  final bool reducedMotion;
  final double textScale;
  final double animationSpeed;

  const AppSettings({
    required this.notifications,
    required this.soundEffects,
    required this.haptics,
    required this.autoPlay,
    required this.showHints,
    required this.dataSaver,
    required this.highContrast,
    required this.reducedMotion,
    required this.textScale,
    required this.animationSpeed,
  });

  factory AppSettings.defaults() {
    return const AppSettings(
      notifications: true,
      soundEffects: true,
      haptics: true,
      autoPlay: true,
      showHints: true,
      dataSaver: false,
      highContrast: false,
      reducedMotion: false,
      textScale: 1.0,
      animationSpeed: 1.0,
    );
  }

  AppSettings copyWith({
    bool? notifications,
    bool? soundEffects,
    bool? haptics,
    bool? autoPlay,
    bool? showHints,
    bool? dataSaver,
    bool? highContrast,
    bool? reducedMotion,
    double? textScale,
    double? animationSpeed,
  }) {
    return AppSettings(
      notifications: notifications ?? this.notifications,
      soundEffects: soundEffects ?? this.soundEffects,
      haptics: haptics ?? this.haptics,
      autoPlay: autoPlay ?? this.autoPlay,
      showHints: showHints ?? this.showHints,
      dataSaver: dataSaver ?? this.dataSaver,
      highContrast: highContrast ?? this.highContrast,
      reducedMotion: reducedMotion ?? this.reducedMotion,
      textScale: textScale ?? this.textScale,
      animationSpeed: animationSpeed ?? this.animationSpeed,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notifications': notifications,
      'soundEffects': soundEffects,
      'haptics': haptics,
      'autoPlay': autoPlay,
      'showHints': showHints,
      'dataSaver': dataSaver,
      'highContrast': highContrast,
      'reducedMotion': reducedMotion,
      'textScale': textScale,
      'animationSpeed': animationSpeed,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      notifications: map['notifications'] as bool? ?? true,
      soundEffects: map['soundEffects'] as bool? ?? true,
      haptics: map['haptics'] as bool? ?? true,
      autoPlay: map['autoPlay'] as bool? ?? true,
      showHints: map['showHints'] as bool? ?? true,
      dataSaver: map['dataSaver'] as bool? ?? false,
      highContrast: map['highContrast'] as bool? ?? false,
      reducedMotion: map['reducedMotion'] as bool? ?? false,
      textScale: (map['textScale'] as num?)?.toDouble() ?? 1.0,
      animationSpeed: (map['animationSpeed'] as num?)?.toDouble() ?? 1.0,
    );
  }
}

class LocalPrefs {
  static const _rememberMeKey = 'remember_me';
  static const _sessionUserIdKey = 'session_user_id';
  static const _sessionUsernameKey = 'session_username';
  static const _settingsKey = 'app_settings';
  static final ValueNotifier<AppSettings> settingsNotifier = ValueNotifier<AppSettings>(AppSettings.defaults());

  static Future<void> initialize() async {
    settingsNotifier.value = await loadSettings();
  }

  static Future<void> saveSession({
    required int userId,
    required String username,
    required bool rememberMe,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, rememberMe);
    if (rememberMe) {
      await prefs.setInt(_sessionUserIdKey, userId);
      await prefs.setString(_sessionUsernameKey, username);
      return;
    }
    await prefs.remove(_sessionUserIdKey);
    await prefs.remove(_sessionUsernameKey);
  }

  static Future<int?> loadSessionUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool(_rememberMeKey) ?? false;
    if (!remember) {
      return null;
    }
    return prefs.getInt(_sessionUserIdKey);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_rememberMeKey);
    await prefs.remove(_sessionUserIdKey);
    await prefs.remove(_sessionUsernameKey);
  }

  static Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_settingsKey);
    if (raw == null || raw.isEmpty) {
      return AppSettings.defaults();
    }
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return AppSettings.fromMap(map);
  }

  static Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(settings.toMap()));
    settingsNotifier.value = settings;
  }
}

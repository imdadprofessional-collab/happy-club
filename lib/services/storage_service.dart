import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Local-first persistence layer.
///
/// This is intentionally the *only* place that talks to on-device storage.
/// In production this would sit behind a `BackendService` interface backed
/// by Firebase (Firestore for synced documents, Firebase Auth for identity)
/// so the same app code works offline and syncs when connectivity returns —
/// today it simply persists everything to [SharedPreferences] so the whole
/// experience is fully demonstrable without any backend credentials.
class StorageService {
  StorageService(this._prefs);

  final SharedPreferences _prefs;

  static Future<StorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  String? getString(String key) => _prefs.getString(key);
  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  int? getInt(String key) => _prefs.getInt(key);
  Future<void> setInt(String key, int value) => _prefs.setInt(key, value);

  double? getDouble(String key) => _prefs.getDouble(key);
  Future<void> setDouble(String key, double value) =>
      _prefs.setDouble(key, value);

  bool? getBool(String key) => _prefs.getBool(key);
  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);

  List<String> getStringList(String key) => _prefs.getStringList(key) ?? [];
  Future<void> setStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);

  T? getJson<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      return fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> setJson(String key, Map<String, dynamic> json) =>
      _prefs.setString(key, jsonEncode(json));

  List<Map<String, dynamic>> getJsonList(String key) {
    final raw = _prefs.getStringList(key) ?? [];
    return raw.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  Future<void> setJsonList(String key, List<Map<String, dynamic>> value) =>
      _prefs.setStringList(key, value.map(jsonEncode).toList());

  Future<void> remove(String key) => _prefs.remove(key);

  Future<void> clearAll() => _prefs.clear();
}

/// Storage keys used across the app, centralized to avoid typos/collisions.
class StorageKeys {
  StorageKeys._();

  static const onboardingComplete = 'onboarding_complete';
  static const membershipStatus = 'membership_status';
  static const membershipRenewsAt = 'membership_renews_at';
  static const userProfile = 'user_profile';
  static const xp = 'xp';
  static const coins = 'coins';
  static const streak = 'streak';
  static const longestStreak = 'longest_streak';
  static const lastCompletionDate = 'last_completion_date';
  static const completedMissions = 'completed_missions';
  static const completedDates = 'completed_dates';
  static const todayMissionId = 'today_mission_id';
  static const todayMissionDate = 'today_mission_date';
  static const unlockedAchievements = 'unlocked_achievements';
  static const gratitudeEntries = 'gratitude_entries';
  static const reflectionEntries = 'reflection_entries';
  static const moodEntries = 'mood_entries';
  static const communityReactionCount = 'community_reaction_count';
  static const communityPostCount = 'community_post_count';
  static const themeMode = 'theme_mode';
}
